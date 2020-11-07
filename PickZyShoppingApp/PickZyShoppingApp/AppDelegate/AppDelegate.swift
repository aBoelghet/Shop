//
//  AppDelegate.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/9/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import SDWebImage
import UserNotifications
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.all
    
    var topSafeAreaInset:CGFloat = 0
    var bottomSafeAreaInset:CGFloat = 0
    private var pushHelper:GSPushNotificationNavigationHelper?

    fileprivate var locationManager:CLLocationManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        GMSServices.provideAPIKey(AppKeys.Google_Maps_Key)
        GMSPlacesClient.provideAPIKey(AppKeys.Google_Maps_Key)
        
        var intialVC:UIViewController?
        var isLoggedInUser = false
        if SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) == nil { // User not yet logged in...
            
            let storyboard = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil)
            intialVC = storyboard.instantiateViewController(withIdentifier: GSString.Push.GSWelcomeScreenViewController)
            
        } else {        // User has logged in already...
            let storyboard = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            intialVC = storyboard.instantiateViewController(withIdentifier: GSString.Push.GSShopsViewController)
            isLoggedInUser = true
            
            if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                SharedPersistence.removeValues(for: [UserDefaultKeys.locations.searchLongitude,
                                                     UserDefaultKeys.locations.searchLatitude,
                                                     UserDefaultKeys.locations.searchPlace,
                                                     UserDefaultKeys.locations.deliveryLat,
                                                     UserDefaultKeys.locations.deliveryLong,
                                                     UserDefaultKeys.locations.deliveryPlace,
                                                     UserDefaultKeys.locations.delivery_zipCode,
                                                     UserDefaultKeys.locations.delivery_changeable,
                                                     UserDefaultKeys.locations.delivery_landMark,
                                                     UserDefaultKeys.locations.delivery_unchangeable_address,
                                                     UserDefaultKeys.locations.savedAddressObject])
            }
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        // Initialize all the root view controllers with GSBaseNavigationViewController
        let navigationController = GSBaseNavigationController(rootViewController: intialVC!)

        navigationController.navigationBar.isHidden = true
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        if #available(iOS 11.0, *) {
            topSafeAreaInset = self.window?.safeAreaInsets.top ?? 0
            bottomSafeAreaInset = self.window?.safeAreaInsets.bottom ?? 0
        } else {
            topSafeAreaInset = self.window?.rootViewController?.topLayoutGuide.length ?? 0
            bottomSafeAreaInset = self.window?.rootViewController?.bottomLayoutGuide.length ?? 0
        }
        
        print(topSafeAreaInset)
        print(bottomSafeAreaInset)
        GSConstant.deviceTopStatusBarHeight = topSafeAreaInset
        
        if let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
            statusBar.backgroundColor = UIColor(hexString: defaultTheme.NAVIGATION_BG_COLOR)
        }
        
        window?.backgroundColor = UIColor.white
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Cancel"
        
        SDImageCache.shared().config.shouldDecompressImages = false
        SDWebImageDownloader.shared().shouldDecompressImages = false
        SDImageCache.shared().config.maxCacheSize = UInt(GSConstant.MAX_CACHE_MEMORY_SIZE) // 50 MB
        
        if let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String {
            SDWebImageDownloader.shared().setValue(accessToken, forHTTPHeaderField: "Authorization")
        }

        if isLoggedInUser == false {
            registerForPushNotifications()
        }

        Fabric.with([Crashlytics.self])
        UIView.appearance().isExclusiveTouch = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        application.applicationIconBadgeNumber = 0;

        #if DEBUG
        print("applicationWillResignActive called")
        #endif
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        #if DEBUG
        print("applicationDidEnterBackground called")
        #endif
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        #if DEBUG
        print("applicationWillEnterForeground called")
        #endif
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        #if DEBUG
        print("applicationDidBecomeActive called")
        #endif
        
        application.applicationIconBadgeNumber = 0;
        
        if let shopVC = GSTopViewController.topViewController() as? GSShopsViewController {
            
            if shopVC.isFirstLoadCompleted {
                shopVC.addLocationServices()
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        #if DEBUG
        print("applicationWillTerminate called")
        #endif
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            return .portrait
        }
        return orientationLock
    }
    
    // MARK: - Push Notifications Methods
    
    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.badge, .alert, .sound]) { // 2
                granted, error in
                print("Permission granted: \(granted)") // 3
                
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                        UNUserNotificationCenter.current().delegate = self
                    }
                } else {
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.deviceToken, value: "")
                }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        let old_deviceToken = SharedPersistence.getValue(key: UserDefaultKeys.deviceToken) as? String ?? ""
        if old_deviceToken != deviceTokenString && SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) != nil {
            // We need to update the device token to server
            // Whenever the device token changes and...
            // If the user logged in to application
            updateDeviceTokenToAPI(deviceTokenString)
        }
        print(deviceTokenString)
        
    }
        
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
    }
    
    // This will not work but for testing purpose left it here... will remove later
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let appStatus = application.applicationState

        pushHelper = GSPushNotificationNavigationHelper.init(with: userInfo, applicationStatus: appStatus, isLocalNotification: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.pushHelper?.decideTheNavigation()
        }
        
        completionHandler(.newData)
    }
    
    // MARK: - Push Notification Delegate methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let appStatus = UIApplication.shared.applicationState
        
        pushHelper = GSPushNotificationNavigationHelper.init(with: notification.request.content.userInfo, applicationStatus: appStatus, isLocalNotification: false)
        
        if pushHelper?.isNeedToShowBanners() == true {
            completionHandler([.alert,.badge,.sound])
            
        } else {
            completionHandler([])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let appStatus = UIApplication.shared.applicationState
        
        pushHelper = GSPushNotificationNavigationHelper.init(with: response.notification.request.content.userInfo, applicationStatus: appStatus, isLocalNotification: (response.actionIdentifier == GSConstant.localPushNotificationIdentifier))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.pushHelper?.decideTheNavigation()
        }
        
        completionHandler()
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        
        if SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) == nil { // User not yet logged in...
            return true
        }
        
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("com.bayfay") == .orderedSame,
            let view = url.host {
            
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            
            let topVC = GSTopViewController.topViewController()

            switch view {
                
            case "shop":
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

                    if let shopVC = topVC as? GSShopsViewController {
                        
                        shopVC.urlSchemeToShopId = parameters["sid"] ?? ""
                        shopVC.needToShowURLSchemePop = true
                    } else {
                        
                        topVC.navigationController?.popToRootViewController(animated: false)
                        if let shopVC = GSTopViewController.topViewController() as? GSShopsViewController {
                            shopVC.urlSchemeToShopId = parameters["sid"] ?? ""
                            shopVC.needToShowURLSchemePop = true
                        }
                    }
                }
                
                break
            default:
                break
            }
        }
        
        return true
    }
}

// MARK: - Core Location Services And Device Token Update

extension AppDelegate:CLLocationManagerDelegate {
    
    func checkAndUpdateLocation() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager?.stopUpdatingLocation()
        locationManager = nil
        if let unwrappedLat = manager.location?.coordinate.latitude, let unwrappedLong = manager.location?.coordinate.longitude {
            let parameters = ["current_location": ["type": "Point",
            "coordinates": [unwrappedLong,unwrappedLat]]] as [String:AnyObject]
            updateLocationToAPI(params: parameters)
        }
    }
    
    // MARK: - Location Update API Service
    
    private func updateLocationToAPI(params:[String:AnyObject]) {
        
        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
        if isGuestLogin {
            return
        }
        
        let urlStr = APIurl.baseURL + APIurl.subURL.updateUserLocation
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlStr, withLoader: false) { (response, error) in
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    #if DEBUG
                    print(responseModel.message ?? "")
                    #endif

                } catch {
                    #if DEBUG
                    print(error)
                    #endif
                }
            } else {
                #if DEBUG
                print(error?.localizedDescription ?? "Unable to update location")
                #endif
            }
        }  // API Handler
    }
    
    // MARK: - Location Update API Service
    
    fileprivate func updateDeviceTokenToAPI(_ newToken:String) {
        
//        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
//        if isGuestLogin {
//            return
//        }
        
        let urlStr = APIurl.baseURL + APIurl.subURL.updateDeviceToken

        let parameters = ["device_details" : ["type": GSConstant.deviceType,
                                              "token": newToken]] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlStr, withLoader: false) { (response, error) in
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if responseModel.success == true {
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.deviceToken, value: newToken)
                    }
                    
                    #if DEBUG
                    print(responseModel.message ?? "")
                    #endif
                    
                } catch {
                    #if DEBUG
                    print(error)
                    #endif
                }
            } else {
                #if DEBUG
                print(error?.localizedDescription ?? "Unable to update Token")
                #endif
            }
        }  // API Handler
    }
}

