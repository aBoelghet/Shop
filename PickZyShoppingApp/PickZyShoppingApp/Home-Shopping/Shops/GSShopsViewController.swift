//
//  GSShopsViewController.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/21/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage
import MKToolTip
import GLScratchCard

class GSShopsViewController: GSLoggedInBaseViewController {
    
    static var gsShopViewController : GSShopsViewController? = nil
        
    @IBOutlet weak var deliveryLocation_txtField: GSBaseTextField!
    @IBOutlet weak var productSearchLocation_txtField: GSBaseTextField!
    @IBOutlet weak var firstTFview: GSCornerEdgeView!
    @IBOutlet weak var navigationBar_View: NavigationBarHome!
    @IBOutlet weak var below_View: GSCornerEdgeView!
    @IBOutlet weak var shopsCat_TableView: UITableView!
    @IBOutlet weak var locationBGHeight_constraint: NSLayoutConstraint!
    @IBOutlet weak var locationFieldsBG_View: UIView!
    @IBOutlet weak var radius_lbl:GSBaseLabel!
    @IBOutlet weak var radius_view:UIView!
    @IBOutlet weak var locatinPermission_view: UIView!
    
    var categoryPopupView : GSCategorySearchView!
    
    let locationManger = CLLocationManager()
    var tfIndex:Int = 0
    var picker:GSCustomPickerView!
    var feedbackPopup_view:GSLastOrderFeedbackPopupView!
    
    var scratchCardView : GSScratchCardsViewController!

    var maxHeaderHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0 : 0   // iphone 75   ipad 90
    
    let minHeaderHeight: CGFloat = 0
    var previousScrollOffset: CGFloat = 0
    var heightRequired = 0.0
    
    var toolTip:MKToolTip?
    
    //--
    var suggestionToshow = true
    var shopTypeArray    = [ShopTypeModel]() // Shops Type Array eg, Public, Private, Branded etc
    lazy var shopListDictionary = [Int:GSHomeRootClass]()
    var searchRadius     = GSConstant.defaultRadius
    
    var storeData = [GSHomeDocsClass]()
    
    //--
    
    let privateShop_id = 0
    let globalShop_id = 3
    var isAllCategoriesEmpty = false
    var clearCartSupport:GSClearCartSupport?
    var isFirstTimeLoad = true
    var isGlobalShopsLoaded = false
    var clickedCloseForNoShopInfo = false
    var isFromLoginResponse = false
    var isFromSignUpResponse = false
    
    var welcomePopup_view : GSWelcomeViewInHome!
    var referralPopUp_view: GSReferOfferPopupView!
    
    var deepLinkPopup_view: GSDeepLinkPopupView!
    
    var isFirstLoadCompleted = false
    
    var urlSchemeToShopId = ""
    var needToShowURLSchemePop = false
    
    var scratchCardLoading = false

    var offerNotifications_array = [GSNotificationOffersListData]()
    
    // MARK: - ViewContrller Delegate Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyColors()
        addFewIntializers()
        isFirstTimeLoad = true
        locatinPermission_view.isHidden = true
        
        self.setupInitializeRefreshTokenMethod()
    }
    
    func setupInitializeRefreshTokenMethod()  {
        
        APIHandler.refreshTokenAPI(topViewController: self, callback: { _ in
            
                self.addLocationServices()
                
                self.isFirstLoadCompleted = true
                let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
                if !isGuestLogin {
                    
                    self.getCartDetailsAPI(isSaveForLater:false)
                    self.checkLastFeedbackToGive()
                    
                    if self.isFromLoginResponse {
                        
                        let clearCartSupport = GSClearCartSupport()
                        clearCartSupport.clearCartAPI()
                        clearCartSupport.clearSaveForLaterAPI()
                    }
                }
                self.checkForWelcomeNotes()
                
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    
                    appDelegate.registerForPushNotifications()
                    appDelegate.checkAndUpdateLocation()
                }
//              self.scratchCardCountApi()
//              self.scratchCardApi(radius:GSConstant.defaultRadius)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if #available(iOS 11.0, *) {
            appDelegate?.topSafeAreaInset = view.safeAreaInsets.top
            appDelegate?.bottomSafeAreaInset = view.safeAreaInsets.bottom
        } else {
            appDelegate?.topSafeAreaInset = topLayoutGuide.length
            appDelegate?.bottomSafeAreaInset = bottomLayoutGuide.length
        }
        
        GSConstant.deviceTopStatusBarHeight = appDelegate?.topSafeAreaInset ?? 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        addFeedbackPopupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar_View.navigationBarReload()
        
        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
        if isFirstTimeLoad == false {
            
            self.addLocationServices()
            if !isGuestLogin {
                self.getCartDetailsAPI(isSaveForLater:false)
            }
        }
        if isGuestLogin {
            self.navigationBar_View.rewardImageButton.badgeString = "1"
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        radius_view.layer.masksToBounds = true
        radius_view.layer.cornerRadius = 0.5 * radius_view.frame.size.height
        
        if maxHeaderHeight < locationBGHeight_constraint.constant {
            maxHeaderHeight = locationBGHeight_constraint.constant              // To Load the iPad constraint only in first load
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isFirstTimeLoad = false
    }
    
    private func scratchCardViewDisplay(scratchModel: ScratchcardModel) {
        
        let scratch = GSScratchCardsViewController()
        scratch.modalPresentationStyle = .overCurrentContext
        scratch.scratchModel = scratchModel
        scratch.delegate = self
        present(scratch, animated: true, completion: nil)
    }
    
    func callBackMethodSCCount() {
        self.scratchCardCountApi()
    }
    
    private func addProductGifViewIfThisIsFirstOpen(message: String) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let topLength = appDelegate?.topSafeAreaInset ?? 0
        let bottomLength = appDelegate?.bottomSafeAreaInset ?? 0
        
        guard let theWindow = appDelegate?.window else { return }
        
        if welcomePopup_view != nil, welcomePopup_view.isDescendant(of: theWindow) { return }
        welcomePopup_view = GSWelcomeViewInHome()
        welcomePopup_view.messageText = message
        
        theWindow.addSubview(welcomePopup_view)
        welcomePopup_view.updateData()
        
        welcomePopup_view.translatesAutoresizingMaskIntoConstraints = false
        welcomePopup_view.leftAnchor.constraint(equalTo: theWindow.leftAnchor).isActive = true
        welcomePopup_view.rightAnchor.constraint(equalTo: theWindow.rightAnchor).isActive = true
        welcomePopup_view.topAnchor.constraint(equalTo: theWindow.topAnchor, constant: topLength).isActive = true
        welcomePopup_view.bottomAnchor.constraint(equalTo: theWindow.bottomAnchor, constant: -bottomLength).isActive = true
        
//      welcomePopup_view.updateData()
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        
        locationFieldsBG_View.backgroundColor = UIColor(hexString: defaultTheme.shopVC_locationsView_BG)
        let txtField_array = [deliveryLocation_txtField,productSearchLocation_txtField]
        for tf in txtField_array {
            tf?.PlaceHolderTextColor = UIColor(hexString: defaultTheme.shopVC_textField_placeholder)
            tf?.textColor = UIColor(hexString: defaultTheme.shopVC_textField_text)
        }
        
        for bgView in [firstTFview,below_View] {
            bgView?.backgroundColor = UIColor(hexString: defaultTheme.shopVC_textField_BG)
            bgView?.layer.borderColor = UIColor(hexString: defaultTheme.shopVC_textField_Border).cgColor
        }
        
        radius_lbl.backgroundColor = UIColor(hexString: defaultTheme.shopVC_textField_BG)
        radius_lbl.textColor = UIColor(hexString: defaultTheme.shopVC_textField_text)
        radius_view.layer.borderWidth = 1.0
        radius_view.layer.borderColor = UIColor(hexString: defaultTheme.shopVC_textField_Border).cgColor
    }
    
    // MARK: - User Defined methods
    func addFewIntializers() {
        
        self.configTableview()
        maxHeaderHeight = locationBGHeight_constraint.constant
        if #available(iOS 11, *)    {
            shopsCat_TableView.contentInsetAdjustmentBehavior = .never
        }
        
        shopsCat_TableView.sectionHeaderHeight = UITableViewAutomaticDimension
        shopsCat_TableView.estimatedSectionHeaderHeight = 25
        categoryPopupView = GSCategorySearchView()
        
        navigationBar_View.titleText = GSString.AppName
        navigationBar_View.rewardButton.isHidden = false
        navigationBar_View.rewardImageButton.isHidden = false
        radius_lbl.text = GSConstant.defaultRadiusToShow + "km"
    }
    
    func loadAddress() {
        
        if SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLatitude) != nil {
            
            let sourceLat = SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLatitude)
            
            let sourceLong = SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLongitude)
            
            let sourceLoc = CLLocation(latitude: sourceLat as! CLLocationDegrees , longitude: sourceLong as! CLLocationDegrees)
            
            if let searchPlace  = SharedPersistence.getValue(key: UserDefaultKeys.locations.searchPlace) as? String {
                productSearchLocation_txtField.text = searchPlace
            } else {
                getTheAddressDetailsUsing(sourceLoc, field : productSearchLocation_txtField)
            }
        }
        
        if SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLat) != nil {
            
            let deliveryLat = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLat)
            
            let deliveryLong = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong)
            
            let deliveryLoc = CLLocation(latitude: deliveryLat! as! CLLocationDegrees, longitude: deliveryLong! as! CLLocationDegrees)
            
            if let deliveryPlace = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryPlace) as? String {
                deliveryLocation_txtField.text = deliveryPlace
            } else {
                getTheAddressDetailsUsing(deliveryLoc, field : deliveryLocation_txtField)
            }
        }
    }
    
    private func configTableview() -> Void {
        
        shopsCat_TableView.delegate = self
        shopsCat_TableView.dataSource = self
        let headerNib = UINib.init(nibName: GSString.NibNames.GSShopCatCollectionHeaderView, bundle: nil)
        shopsCat_TableView.register(headerNib, forHeaderFooterViewReuseIdentifier: GSString.CellIdentifier.ShopVC_table_headerView)
        let simpleHeaderNib = UINib.init(nibName: GSString.NibNames.GSShopCatCollectionSimpleHeaderView, bundle: nil)
        shopsCat_TableView.register(simpleHeaderNib, forHeaderFooterViewReuseIdentifier: GSString.CellIdentifier.ShopVC_table_simple_headerView)
        navigationBar_View.delegate = self
        shopsCat_TableView.tableFooterView = UIView()
    }
    
    fileprivate func addSearchPopupView() {
        if categoryPopupView != nil {
            if categoryPopupView.isDescendant(of: self.view) {
                return
            }
            categoryPopupView = nil
        }
        categoryPopupView = GSCategorySearchView()
        categoryPopupView.showTheViewFromBottom(on: view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: {})
    }
    
    func locationAddressSelected() {
        addLocationServices()
    }
    
    func addLocationServices() {
        
        if SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLongitude) != nil || SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong) != nil {

            loadAddress()
            if SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLongitude) != nil {
                requestShopCategories()
            }
        } else {
            updateUserLocation()
        }
    }
    
    private func updateUserLocation() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManger.delegate = self
            locationManger.startUpdatingLocation()
            break
        case .denied, .restricted:
            locatinPermission_view.isHidden = false
            break
        case .notDetermined:
            locationManger.requestWhenInUseAuthorization()
            locationManger.delegate = self
            locationManger.startUpdatingLocation()
            break
        }
    }
    
    func addPicker() {
        
        if picker != nil {
            if picker.isDescendant(of: self.view) {
                return
            }
            picker = nil
        }
        picker = GSCustomPickerView()
        picker.pickerData = GSConstant.radiusPickerData

        picker.showTheView(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom))
        
        picker.selectedPicker { (selected, cancel) in
            if !cancel {
                
                guard let selValue = selected else { return }
                
                self.radius_lbl.text = "\(selValue)km"
                self.suggestionToshow = true
                self.searchRadius = Int(selValue)! * GSConstant.meterToKm
                
                SharedPersistence.storeUserDefaults(key:"location_radius", value: self.searchRadius)
                
                if SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLongitude) == nil || SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong) == nil {
                    return
                }
                
                self.requestShopCategories()
            }
        }
    }
    
    fileprivate func addFeedbackPopupView(feedbackData: GSLastOrderFeedbackData) {
        if feedbackPopup_view != nil {
            if feedbackPopup_view.isDescendant(of: self.view) {
                return
            }
            feedbackPopup_view = nil
        }
        feedbackPopup_view = GSLastOrderFeedbackPopupView()
        feedbackPopup_view.configureWith(feedbackData: feedbackData)
        feedbackPopup_view.showTheViewFromBottom(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: {
//            self.feedbackPopup_view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        })
    }
    
    func getTheAddressDetailsUsing(_ latestLoc:CLLocation, field: UITextField){
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(latestLoc, completionHandler: {[weak self] placeMarks, error in
            
            if(error != nil) {
                if let weakSelf = self {
                    CustomAlert.showAlert(title: "Error", message: GSString.API.NetworkFailure, viewController: weakSelf)
                    print("\(error!.localizedDescription)")
                }
            } else {

                let placeMark = placeMarks?.last
                var addressString : String = ""
                
                var changeableAddress = ""
                var unChangeableAddress = ""
                

                if placeMark?.subThoroughfare != nil {
                    addressString = addressString + (placeMark?.subThoroughfare!)! + ", "   // Changeable
                    changeableAddress = (changeableAddress == "") ? ((placeMark?.subThoroughfare!) ?? "") : (changeableAddress + ", " + ((placeMark?.subThoroughfare!) ?? ""))
                }
                if placeMark?.thoroughfare != nil {
                    addressString = addressString + (placeMark?.thoroughfare!)! + ", "  // Changeable
                    changeableAddress = (changeableAddress == "") ? ((placeMark?.thoroughfare!) ?? "") : (changeableAddress + ", " + ((placeMark?.thoroughfare!) ?? ""))
                }
                
                if placeMark?.subLocality != nil {
                    addressString = addressString + (placeMark?.subLocality!)! + ", "   // Unchangeable
                    // unChangeableAddress = (unChangeableAddress == "") ? ((placeMark?.subLocality!) ?? "") : (unChangeableAddress + ", " + ((placeMark?.subLocality!) ?? ""))
                    changeableAddress = (changeableAddress == "") ? ((placeMark?.subLocality!) ?? "") : (changeableAddress + ", " + ((placeMark?.subLocality!) ?? ""))
                }
                
                if placeMark?.locality != nil {
                    addressString = addressString + (placeMark?.locality!)! + ", "      // Unchangeable
                    unChangeableAddress = (unChangeableAddress == "") ? ((placeMark?.locality!) ?? "") : (unChangeableAddress + ", " + ((placeMark?.locality!) ?? ""))
                }
                if placeMark?.administrativeArea != nil {
                    addressString = addressString + (placeMark?.administrativeArea!)! + ", "      // Unchangeable
                    unChangeableAddress = (unChangeableAddress == "") ? ((placeMark?.administrativeArea!) ?? "") : (unChangeableAddress + ", " + ((placeMark?.administrativeArea!) ?? ""))
                }
                if placeMark?.country != nil {
                    addressString = addressString + (placeMark?.country!)! + ", "       // Unchangeable
                    unChangeableAddress = (unChangeableAddress == "") ? ((placeMark?.country!) ?? "") : (unChangeableAddress + ", " + ((placeMark?.country!) ?? ""))
                }
                if placeMark?.postalCode != nil {
                    addressString = addressString + (placeMark?.postalCode!)! + " "
                }
                
                if field == self?.productSearchLocation_txtField {
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.searchPlace, value: addressString)
                    
                    if SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_zipCode) == nil {
                        
                        if changeableAddress.last == "," {
                            changeableAddress.remove(at: changeableAddress.index(before: changeableAddress.endIndex))
                        }
                        if unChangeableAddress.last == "," {
                            unChangeableAddress.remove(at: unChangeableAddress.index(before: unChangeableAddress.endIndex))
                        }
                        
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_unchangeable_address, value: unChangeableAddress)
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_changeable, value: changeableAddress)
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_zipCode, value: placeMark?.postalCode ?? "")
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_landMark, value: "")
                    }
                } else if field == self?.deliveryLocation_txtField {
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryPlace, value: addressString)
                    
                    if changeableAddress.last == "," {
                        changeableAddress.remove(at: changeableAddress.index(before: changeableAddress.endIndex))
                    }
                    if unChangeableAddress.last == "," {
                        unChangeableAddress.remove(at: unChangeableAddress.index(before: unChangeableAddress.endIndex))
                    }
                    
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_unchangeable_address, value: unChangeableAddress)
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_changeable, value: changeableAddress)
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_landMark, value: "")
                    
                    if let postalCode = placeMark?.postalCode {
                        SharedPersistence.storeUserDefaults(key: postalCode, value: placeMark?.postalCode ?? "")
                    } else {
                        SharedPersistence.removeValue(key: UserDefaultKeys.locations.delivery_zipCode)
                    }
                }
                
                field.text = addressString
            }
        })
    }
    
    //MARK: - View Controller Action Methods
    @IBAction func updateDeliveryDiameterPressed(_ sender:UIButton){
        
        if cartCount.value > 0 {
            
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.radiusChangeAlert, alertButtonsArray: ["Cancel","Continue"], isLastButtonDestructive: true, viewController: GSTopViewController.topViewController()) { (btnIndex) in
                
                if btnIndex == 1 {  // Continue
                    self.clearCartSupport = GSClearCartSupport()
                    self.clearCartSupport?.clearCartAPI()
                    self.clearCartSupport?.clearSaveForLaterAPI()
                    self.addPicker()
                }
            }
            return
        }
        addPicker()
    }
    
    @IBAction func locationPermissonSettingsAction(_ sender: UIButton) {
        
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            if #available(iOS 10.0, *){
                UIApplication.shared.open(url, completionHandler: nil)
                print("\n--- in ios 10 ")
            } else{
                UIApplication.shared.openURL(url)
                print("\n--- in ios other than 10 ")
            }
        }
    }
    
    @IBAction func textFieldAction(_ sender:UIButton) {
        let tag = sender.tag
        if checkForTheCartExists(selectedTextFieldTag: tag) == false {
            showTheAutoCompleteLocationVC(selectedTextFieldTag: tag)
        }
    }
    
    //MARK: - Device Methods
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if let unwrappedTooltip = self.toolTip {
            unwrappedTooltip.dismissWithAnimation()
        }
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            let orient = UIApplication.shared.statusBarOrientation
            switch orient {

                case .portrait:
                    print("Portrait")
                case .landscapeLeft,.landscapeRight :
                    print("Landscape")
                default:
                    print("Anything But Portrait")
            }
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            //refresh view once rotation is completed not in will transition as it returns incorrect frame size.Refresh here
            //self.shopsCat_TableView.reloadData()
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let theWindow = appDelegate.window {
                if self.welcomePopup_view != nil, self.welcomePopup_view.isDescendant(of: theWindow) {
                    self.welcomePopup_view.updateContentSize() 
                }
            }
            
            self.shopsCat_TableView.reloadData()
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // Webservices
    func scratchCardApi(radius:Int) {
        
        let currentLatitude = SharedPersistence.getValue(key:"current_Latitude")
        let currentLangitude = SharedPersistence.getValue(key: "current_Langitude")
        
        let searchLat = SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLatitude) == nil ? currentLatitude : SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLatitude)
        let searchLong = SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLongitude) == nil ? currentLangitude : SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLongitude)
        
        let deliveryLat = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLat) ?? searchLat
        let deliveryLong = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong) ?? searchLong
        
        let hostString: String!
        
        let params: [String:Any]
        hostString = APIurl.baseURL + APIurl.subURL.scratchCard
        params = ["searchLocation" : ["type" : "Point",
                                      "coordinates" : [searchLong, searchLat]],
                  "deliveryLocation":["type": "Point",
                                      "coordinates": [deliveryLong, deliveryLat]],
                  "maxDistance" : "\(radius)"] as [String : Any]
        #if DEBUG
            print(params)
        #endif
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject],urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(ScratchcardModel.self, from: responseData)
                    let rewardInfo = responseModel.data?.cardInfo?.first?.rewardInfo
                    let promoInfo = responseModel.data?.cardInfo?.first?.promoInfo
                    
                    if rewardInfo != nil || promoInfo != nil{
                        self!.scratchCardViewDisplay(scratchModel: responseModel)
                    }
                    
                } catch {
                    #if DEBUG
                        print(error)
                    #endif
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                #if DEBUG
                    print(error?.localizedDescription ?? GSString.API.unknownError)
                #endif
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func scratchCardCountApi() {
        
        var params: [String:AnyObject]
        let hostString = APIurl.baseURL + APIurl.subURL.scratchCardCount
        
        params = ["" :""] as [String : AnyObject]
        #if DEBUG
            print(params)
        #endif
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject],urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(ScratchcardCountModel.self, from: responseData)
                    let rewardCount = responseModel.count!
                    #if DEBUG
                        print(responseModel)
                    #endif
                    if rewardCount > 0 {
                        self?.navigationBar_View.rewardImageButton.isHidden = false
                        self?.navigationBar_View.rewardImageButton.badgeString = "\(String(describing: rewardCount))"
                    } else {
                        self?.navigationBar_View.rewardImageButton.badgeString = ""
                    }
                } catch {
                    #if DEBUG
                        print(error)
                    #endif
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                #if DEBUG
                    print(error?.localizedDescription ?? GSString.API.unknownError)
                #endif
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
}

//MARK: - Shops API's here
extension GSShopsViewController {
    
    // Common method to fetch the shops from server
    func requestShopsList(radius: Int, category_id: Int) {
        
        let searchLat = SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLatitude)
        let searchLong = SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLongitude)
        
        let deliveryLat = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLat) ?? searchLat
        let deliveryLong = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong) ?? searchLong
        
        let hostString: String!
        let params: [String:Any]
        
        locatinPermission_view.isHidden = true
        
        if category_id == privateShop_id {
            
            hostString = APIurl.baseURL + APIurl.subURL.homePrivateShops
            params = ["searchLocation" : ["type" : "Point",
                                          "coordinates" : [searchLong, searchLat]],
                      "deliveryLocation":["type": "Point",
                                          "coordinates": [deliveryLong, deliveryLat]],
                      "maxDistance" : "\(radius)"] as [String : Any]
            
        } else if category_id == globalShop_id {
            
            hostString = APIurl.baseURL + APIurl.subURL.homeGlobalShops
            params = ["searchLocation" : ["type" : "Point",
                                          "coordinates" : [searchLong, searchLat]],
                      "deliveryLocation":["type": "Point",
                                          "coordinates": [deliveryLong, deliveryLat]],
                      "maxDistance" : "\(radius)"] as [String : Any]
            
        } else {
            hostString = APIurl.baseURL + APIurl.subURL.homePublicShops
            params = ["type" : category_id ,
                      "searchLocation" : ["type" : "Point",
                                          "coordinates" : [searchLong, searchLat]],
                      "deliveryLocation":["type": "Point",
                                          "coordinates": [deliveryLong, deliveryLat]],
                      "maxDistance" : "\(radius)"] as [String : Any]
        }
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject],urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSHomeRootClass.self, from: responseData)
                    
                    weakSelf.shopListDictionary[category_id] = responseModel
                    weakSelf.isAllCategoriesEmpty = weakSelf.checkIfAllTheStoresAreFoundedToBeNil()
                    
                    
//                    if weakSelf.isGlobalShopsLoaded == false, category_id != weakSelf.globalShop_id, let categoryArray = responseModel.data?.category {
//                        for categoryItem in categoryArray {
//                            if categoryItem.deliveryOtherEnabled == true {
//                                weakSelf.isGlobalShopsLoaded = true
//                                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isGlobalShopsLoaded, value: true)
//                            }
//                        }
//                    }
                    
                    // Will check and update store array list in user defaults for cart, if category selected is Public
                    let selectedShopCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
                    let selectedShopType = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedShopType) as? Int ?? 0
                    
                    if category_id != self?.privateShop_id, category_id == selectedShopType, let categoryArray = responseModel.data?.category {
                        
                        for categoryItem in categoryArray {
                            let shopCategoryId = categoryItem._id ?? ""
                            if selectedShopCategory_id == shopCategoryId {
                                
                                let stores = categoryItem.stores ?? [String]()
                                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.selecedStoreArray, value: stores)
                            }
                        }
                    }
                    
                    // Need to check for global shops
                    
                    if category_id == weakSelf.globalShop_id {
                        
                        if responseModel.data?.count != 0 {
                            
                            if let globalCategoryIndex = weakSelf.shopTypeArray.firstIndex(where: { $0.shopTypeId == weakSelf.globalShop_id }) {
                                // Already exists... no need to do anything as of now
                                print(globalCategoryIndex)
                                
                            } else {
                                // Not having the global category in table array... need to add it
                                weakSelf.shopTypeArray.append(ShopTypeModel(shopTypeId: weakSelf.globalShop_id, shopTypeDisplayName: "Other Location Shops"))
                                
                            }
                            
                        } else {
                            
                            if let globalCategoryIndex = weakSelf.shopTypeArray.firstIndex(where: { $0.shopTypeId == weakSelf.globalShop_id }) {
                                // Global already exists.... Need to remove it
                                weakSelf.shopTypeArray.remove(at: globalCategoryIndex)
                            }
                            
                            if weakSelf.shopListDictionary[weakSelf.globalShop_id] != nil {
                                weakSelf.shopListDictionary.removeValue(forKey: weakSelf.globalShop_id)
                            }
                        }
                    }
                    
                    var tempStoreArray = [String]()
                    
                    if let categoryArray = responseModel.data?.category {
                        
                        for category in categoryArray {
                            
                            if let storesArray = category.stores {
                                tempStoreArray.append(contentsOf: storesArray)
                            }
                        }
                    }
                    
                    if let storedStoreArray = SharedPersistence.getValue(key: UserDefaultKeys.storesForNotification) as? [String] {
                        
                        var anotherTempStoreArray = [String]()
                        anotherTempStoreArray.append(contentsOf: storedStoreArray)
                        
                        for tempStore in tempStoreArray {
                            
                            if storedStoreArray.contains(tempStore) == false {
                                anotherTempStoreArray.append(tempStore)
                            }
                        }
                        
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.storesForNotification, value: anotherTempStoreArray)
                        
                    } else {
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.storesForNotification, value: tempStoreArray)
                    }
                    let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
                    if !isGuestLogin {
                        weakSelf.scratchCardCountApi()
                    }
                        
                    weakSelf.checkIfItIsFromUrlScheme()
                    weakSelf.sortTheStoreBasedOnTheShopsAvailability()
                    
                    weakSelf.shopsCat_TableView.reloadData()
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func checkIfItIsFromUrlScheme() {
        
        if needToShowURLSchemePop == false { return }
        
        if let privateShopsObject = shopListDictionary[privateShop_id] {
            
            needToShowURLSchemePop = false
            
            if let privateStores = privateShopsObject.data?.category, privateStores.count != 0, let urlSchemeShopObject = privateStores.first(where: { $0.stores?.contains(urlSchemeToShopId) ?? false }) {
                
                // Show PopUp
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let topLength = appDelegate?.topSafeAreaInset ?? 0
                let bottomLength = appDelegate?.bottomSafeAreaInset ?? 0
                
                if deepLinkPopup_view != nil, deepLinkPopup_view.isDescendant(of: view) { return }
                deepLinkPopup_view = GSDeepLinkPopupView()

                view.addSubview(deepLinkPopup_view)
                
                deepLinkPopup_view.urlSchemeShopObject = urlSchemeShopObject
                deepLinkPopup_view.privateShop_id = self.privateShop_id
                deepLinkPopup_view.shopIconUrl = urlSchemeShopObject.image ?? ""
                
                deepLinkPopup_view.updateData()
                
                deepLinkPopup_view.translatesAutoresizingMaskIntoConstraints = false
                deepLinkPopup_view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                deepLinkPopup_view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                deepLinkPopup_view.topAnchor.constraint(equalTo: view.topAnchor, constant: topLength).isActive = true
                deepLinkPopup_view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomLength).isActive = true
            } else {
                // No shop found
//                CustomAlert.showAlert(title: "Store is unavailable", message: "", viewController: self)
            }
        }
    }
    
    // Merchants Ads Click
    func redirectToProductlistPage() {
        
        if needToShowURLSchemePop == false { return }
        
        if let privateShopsObject = shopListDictionary[privateShop_id] {
            
            needToShowURLSchemePop = false
            
            if let privateStores = privateShopsObject.data?.category, privateStores.count != 0, let urlSchemeShopObject = privateStores.first(where: { $0.stores?.contains(urlSchemeToShopId) ?? false }) {
                
                let storeSelectionHelper = StoreSelectionHelper()
                storeSelectionHelper.pushToProductListPage(shopAtIndex: urlSchemeShopObject, tempSessionIndex: self.privateShop_id)
            }
        }
    }
    
    private func sortTheStoreBasedOnTheShopsAvailability() {
        
        let tempArray = shopTypeArray
        
        if shopListDictionary.count == shopTypeArray.count {
        
            shopTypeArray = tempArray.sorted { (firstType, secondType) -> Bool in
                
                var firstShopDataCount = shopListDictionary[firstType.shopTypeId]?.data?.count ?? 0
                if firstShopDataCount > 0 { firstShopDataCount = 1 }
                
                var secondShopDataCount = shopListDictionary[secondType.shopTypeId]?.data?.count ?? 0
                if secondShopDataCount > 0 { secondShopDataCount = 1 }
                
                
                return firstShopDataCount > secondShopDataCount
            }
            
            // Will sort after loading all the categories.... This is the correct place to call offers API for all stores....
            
            offerNotificationsAPI()
        }
    }
    
    private func checkIfAllTheStoresAreFoundedToBeNil()-> Bool {
        
        let homeDataModel_array = Array(shopListDictionary.values)
        
        var zeroValuesCount = 0
        
        for homeData in homeDataModel_array {
            let storesCount = homeData.data?.count ?? 0
            
            if storesCount == 0 {
                zeroValuesCount += 1
            }
        }
        
        if zeroValuesCount == homeDataModel_array.count {
            return true
        }
        return false
    }
    
    
    // Common method to fetch the Categories from server
    func requestShopCategories() {
                
        let hostString  = APIurl.baseURL + APIurl.subURL.storeCategories
        
        SharedPersistence.removeValue(key: UserDefaultKeys.storesForNotification)
        
//        isGlobalShopsLoaded = false
//        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isGlobalShopsLoaded, value: false)
        
        APIHandler.NetworkSetupRequest(method: .get, params: [String : AnyObject]() ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSHomeShopCategoriesModel.self, from: responseData)
                    
                    if let typesArray = responseModel.data?.type {
                        print(typesArray)
                        
                        if weakSelf.shopTypeArray.count > 0 {
                            weakSelf.shopTypeArray.removeAll()
                        }
                        if weakSelf.shopListDictionary.count > 0 {
                            weakSelf.shopListDictionary.removeAll()
                        }
                        
                        for typeItem in typesArray {
                            let shopCatModel = ShopTypeModel(shopTypeId: typeItem.id ?? 0, shopTypeDisplayName: typeItem.name ?? "")
                            weakSelf.shopTypeArray.append(shopCatModel)
                        }
                    }
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
            
            if weakSelf.shopTypeArray.count == 0 {
                weakSelf.shopTypeArray.append(contentsOf: ShopTypeModel.shopTypeArray)
            } else {
                weakSelf.shopTypeArray.insert(ShopTypeModel(shopTypeId: weakSelf.privateShop_id, shopTypeDisplayName: "Private Shops"), at: 1)
            }
            
            SharedPersistence.storeUserDefaults(key:"location_radius", value: weakSelf.searchRadius)

            for shopType in weakSelf.shopTypeArray {
                weakSelf.requestShopsList(radius: weakSelf.searchRadius, category_id: shopType.shopTypeId)
            }
            
            // Calling manually for global shops
            weakSelf.requestShopsList(radius: weakSelf.searchRadius, category_id: weakSelf.globalShop_id)
        }
    }
    
    //Mark: - Fetch Cart Data from server - API
    fileprivate func getCartDetailsAPI(isSaveForLater:Bool){
        
        let urlString = isSaveForLater ? APIurl.baseURL + APIurl.subURL.saveForLaterList : APIurl.baseURL + APIurl.subURL.viewCart
        
        guard let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String else {
            // No selected store category found...
            #if DEBUG
            print("No selected category found")
            #endif
            return
        }
        
//        guard let categoryStores_array = SharedPersistence.getValue(key: UserDefaultKeys.Products.selecedStoreArray) as? [String] else {
//            // No store array found...
//            #if DEBUG
//            print("No store array found")
//            #endif
//            return
//        }
        
        let params = ["_id"     :   storeCategory_id /*,
                      "stores"  :   categoryStores_array */] as [String : AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params,urlString: urlString, withLoader:!isSaveForLater) { (response, error) in
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCartListNewModel.self, from: responseData)
                    
                    if let data = responseModel.data {
                        
                        self.handleDataReceivedFromServer(productData: data, isSaveForLater: isSaveForLater)
                    }
                } catch {
                    print(error)
                    if !isSaveForLater {
                        CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: self)
                    }
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                
                if !isSaveForLater {
                    CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: self)
                }
            }
        }
    }

    // Add into the cart
    fileprivate func handleDataReceivedFromServer(productData: [GSCartListNewData],isSaveForLater:Bool) {
        
        if isSaveForLater != true {
            
            if cartItemsDictionary.count > 0 {
                cartItemsDictionary.removeAll()
            }
            
            var cartCount_local = 0
            for product_item in productData {
                
                guard let stores_array = product_item.stores else { continue }
                
                for store in stores_array {
                    cartCount_local = cartCount_local + (store.productDetails?.qty ?? 0)
                }
                
                guard let product_id = product_item.id else { continue }
                cartItemsDictionary[product_id] = product_item
            }
            cartCount.value = cartCount_local
        }
    }
    
    
    func checkLastFeedbackToGive() {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.recentOrders
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSLastOrderFeedbackModel.self, from: responseData)
                    
                    guard let feedbackArray = responseModel.data else { return }
                    if feedbackArray.count > 0 {
                        let firstItem = feedbackArray[0]
                        weakSelf.addFeedbackPopupView(feedbackData: firstItem)
                    }
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }

        }
    }
    
    func checkForWelcomeNotes() {
        
        let isShopWelcomeShown = SharedPersistence.getValue(key: UserDefaultKeys.isShopWelcomeShown) as? Bool ?? false
        
        if isShopWelcomeShown == true {
            referralAmountAPI()
            return
        }
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.isShopWelcomeShown, value: true)
        
        let hostString  = APIurl.baseURL + APIurl.subURL.welcomeMessage
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSWelcomeMessageModel.self, from: responseData)
                    
                    if let welcomeData = responseModel.data, welcomeData.available == true, let content = welcomeData.content, content != "" {

                        weakSelf.addProductGifViewIfThisIsFirstOpen(message: content)
                    }
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }
    
    func referralAmountAPI() {
        
        if isFromSignUpResponse == false { return }
        
        let urlString = APIurl.baseURL + APIurl.subURL.bayFayCash
        
        APIHandler.NetworkSetupRequest(method: .post, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            // Making sure the next code will not execute if the view controller not exists in memory
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSBayfayCashModel.self, from: responseData)
                    
                    if let bayFayCash = responseModel.walletAmount {
                        weakSelf.addReferralPopupView(bayFayCash)
                    }
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func addReferralPopupView(_ bayfayCash: Double) {
        
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let topLength = appDelegate?.topSafeAreaInset ?? 0
        let bottomLength = appDelegate?.bottomSafeAreaInset ?? 0
        
        guard let theWindow = appDelegate?.window else { return }
        
        if referralPopUp_view != nil, referralPopUp_view.isDescendant(of: theWindow) { return }
        referralPopUp_view = GSReferOfferPopupView()
        referralPopUp_view.bayFayCash = bayfayCash
        theWindow.addSubview(referralPopUp_view)
        
        referralPopUp_view.updateData()
        
        referralPopUp_view.translatesAutoresizingMaskIntoConstraints = false
        referralPopUp_view.leftAnchor.constraint(equalTo: theWindow.leftAnchor).isActive = true
        referralPopUp_view.rightAnchor.constraint(equalTo: theWindow.rightAnchor).isActive = true
        referralPopUp_view.topAnchor.constraint(equalTo: theWindow.topAnchor, constant: topLength).isActive = true
        referralPopUp_view.bottomAnchor.constraint(equalTo: theWindow.bottomAnchor, constant: -bottomLength).isActive = true
    }
    
    
    fileprivate func offerNotificationsAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.notification_offers
        
        guard let notificationStores = SharedPersistence.getValue(key: UserDefaultKeys.storesForNotification) as? [String] else { return }
        
        let parameters = ["stores" : notificationStores] as [String: AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSNotificationOffersListModel.self, from: responseData)
                    
                    if let notifications = responseModel.data {
                        
                        if notifications.count > 0 {
                            weakSelf.navigationBar_View.notificationCountButton.badgeString =  "\(notifications.count)"
                        } else {
                             weakSelf.navigationBar_View.notificationCountButton.badgeString =  ""
                        }
                        
                        weakSelf.offerNotifications_array = notifications
                        
                        weakSelf.shopsCat_TableView.reloadData()
                    }                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }  // Offers Notifications API
}

// MARK: - GSWelcomeMessageModel
struct GSWelcomeMessageModel: Codable {
    let success: Bool?
    let data: GSWelcomeMessageDataClass?
}

// MARK: - DataClass
struct GSWelcomeMessageDataClass: Codable {
    let available: Bool?
    let content: String?
}

extension GSShopsViewController: GLScratchCardDelegate {
    
    func didDoneButtonPressed(sender: UIButton) {
    }
    
    func didCloseButtonPressed(sender: UIButton) {
    }
}

extension GSShopsViewController: ScratchCardViewDelegate {
    
    func selectedBannerStoreId(storeID: String) {
        
        let topVC = GSTopViewController.topViewController()
        topVC.navigationController?.popToRootViewController(animated: false)
        if let shopVC = GSTopViewController.topViewController() as? GSShopsViewController {
            shopVC.urlSchemeToShopId = storeID
            shopVC.needToShowURLSchemePop = true
            self.redirectToProductlistPage()
        }
    }
}
