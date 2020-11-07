//
//  GSWelcomeScreenViewController.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/16/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit

class GSWelcomeScreenViewController: GSBaseViewController {
    
    @IBOutlet weak var signUpBtn:UIButton!
    @IBOutlet weak var loginBtn:UIButton!
    @IBOutlet weak var skip_btn:UIButton!
    
    var isShowingForGuestUser = false
    
    //MARK: - UIViewController Methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        applyColors()
        addFewInitializers()
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
    
    // MARK: - Initial Setup
    
    private func addFewInitializers() {
        
        if isShowingForGuestUser {
            skip_btn.setTitle("", for: .normal)
            skip_btn.setImage(#imageLiteral(resourceName: "CloseIcon"), for: .normal)
        } else {
            skip_btn.setImage(nil, for: .normal)
            skip_btn.setTitle("Skip", for: .normal)
        }
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {

        signUpBtn.backgroundColor = UIColor(hexString: defaultTheme.welcome_signUpButton_BG)
        loginBtn.backgroundColor = UIColor(hexString: defaultTheme.welcome_loginButton_BG)
        
        signUpBtn.setTitleColor(UIColor(hexString:defaultTheme.welcome_signUpBtn_title), for: .normal)
        loginBtn.setTitleColor(UIColor(hexString:defaultTheme.welcome_loginBtn_title), for: .normal)
        
        skip_btn.setTitleColor(UIColor(hexString: defaultTheme.welcome_skipButton_title), for: .normal)
    }
    
    // MARK: - UIAction
    
    @IBAction func loginOrSignupAction(_ sender: UIButton) {
        // tag = 0 for signup
        //       1 for login
        
        switch sender.tag {
        case 0:
            pushToSignUpPage()
            break
        case 1:
            pushToLoginpPage()
            break
        default:
            break
        }
    }
    @IBAction func skipLogin(_ sender: UIButton) {
        
        if isShowingForGuestUser {
            GSCustomPushPop.doCustomPop(from: self)
        } else {
            guestLoginAPI()
        }
    }
    
    // MARK: - User defined Method
    
    private func pushToSignUpPage () -> Void {
        
        if let tempVC = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSSignInViewController) as? GSSignUpViewController {
            if let navigator = navigationController {
                navigator.pushViewController(tempVC, animated: true)
            }
        }
    }
    
    private func pushToLoginpPage () -> Void {
        
        if let tempVC = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSLoginViewController) as? GSLoginViewController {
            if let navigator = navigationController {
                navigator.pushViewController(tempVC, animated: true)
            }
        }
    }
}

// MARK: - API Methods

extension GSWelcomeScreenViewController {
    
    fileprivate func guestLoginAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.guestLogin
        
        APIHandler.NetworkSetupRequestWithoutToken(method: .get, params: nil, urlString: urlString, withLoader: false) { (response, error) in
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSLoginRootClass.self, from: responseData)
                    
                    let accessToken = responseModel.data?.authToken?.access?.token ?? ""
                    let accessTokenPrefix = responseModel.data?.authToken?.access?.schema ?? ""
                    
                    SharedPersistence.storeAccessToken(accessToken: accessToken, prefix: accessTokenPrefix)
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.user.profile_image, value: responseModel.data?.userProfile?.image ?? "")
                    
                    if let encodedLoginUserData = try? JSONEncoder().encode(responseModel.data) {
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.user.user_details, value: encodedLoginUserData)
                    }
                    
                    // Storing a boolean to identify the guest user simply with out going for check complex data all times
                    SharedPersistence.storeUserDefaults(key: UserDefaultKeys.isGuestUserLogin, value: true)
                    menuBar = nil
                    
                    if let shopsVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSShopsViewController) as? GSShopsViewController {
                        
                        if let navigationController = self.navigationController {
                            navigationController.setViewControllers([shopsVC], animated: true)
                        }
                    }
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: self)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? GSString.API.unknownError, viewController: self)
            }
        }
    }
    
}
