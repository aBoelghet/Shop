//
//  GSOtpViewController.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/17/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit
import CoreLocation

class GSOtpViewController: GSBaseViewController {
    
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var otpField: GSBaseTextField!
    @IBOutlet weak var descLabel: GSBaseLabel!
    @IBOutlet weak var otpInfo_lbl: GSBaseLabel!
    @IBOutlet weak var resendOtp_btn:GSUnderlinedButton!
    @IBOutlet weak var loginWithPwd_btn: GSUnderlinedButton!
    @IBOutlet weak var resendOtpBG_view: UIView!
    @IBOutlet weak var loginWithPasswordBG_view:UIView!
    
    var mobileNumber:String = ""
    var emailId = ""
    var dailCode:Int = 0
    var parameters = [String:AnyObject]()
    var urlString = ""
    var isLoginWithOtp = false
    
    var isFromSignUp = false
    
    var locationManger:CLLocationManager?
    
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadFewIntializers()
        applyColors()
        addLocationServices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        otpField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addLocationServices() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManger = CLLocationManager()
            locationManger?.delegate = self
            locationManger?.startUpdatingLocation()
            break
        case .denied, .restricted:
            break
        case .notDetermined:
            locationManger = CLLocationManager()
            locationManger?.requestWhenInUseAuthorization()
            locationManger?.delegate = self
            break
        }
    }
    
    // MARK: - Configuring with the required data
    func configureWith(mobile: String, dialingCode:Int, email:String, param: [String:AnyObject], urlStr:String, isOtpLogin:Bool) {
        self.mobileNumber = mobile
        self.emailId = email
        self.dailCode = dialingCode
        self.parameters = param
        self.urlString = urlStr
        self.isLoginWithOtp = isOtpLogin
        
//        let epochTime = ((otpData.exp ?? 0) / 1000)
//        let otpExpiryDateTime = Date(timeIntervalSince1970: TimeInterval(epochTime))
//        let remainTimeInterval = otpExpiryDateTime.timeIntervalSince(Date())
//        self.otpTimeIntervalLeft = Int(remainTimeInterval)
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        otpInfo_lbl.textColor = UIColor(hexString: defaultTheme.welcome_infoLabelText)
        otpField.backgroundColor = UIColor(hexString: defaultTheme.welcome_textFieldBG)
        otpField.PlaceHolderTextColor = UIColor(hexString: defaultTheme.otp_textField_placeholder)
        otpField.textColor = UIColor(hexString: defaultTheme.otp_textField_text)
        resendOtp_btn.setTitleColor(UIColor(hexString: defaultTheme.underLineButtonTxt), for: .normal)
        loginWithPwd_btn.setTitleColor(UIColor(hexString: defaultTheme.underLineButtonTxt), for: .normal)
    }
    
    // MARK: - UIAction

    @IBAction func doLogin(_ sender: UIButton) {
        
        checkAndVerifyOtp()
    }
    
    @IBAction func resendOTP(_ sender: UIButton) {
        
        regenerateOtpFromAPI()
    }
    
    @IBAction func loginWithPassword(_ sender: UIButton) {
        
        if let stackVC_array = navigationController?.viewControllers {
            
            for vc in stackVC_array.reversed() {
                if vc.isKind(of: GSLoginViewController.self) {
                    navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        if let tempVC = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSLoginViewController) as? GSLoginViewController {
            if let navigator = navigationController {
                navigator.pushViewController(tempVC, animated: false)
            }
        }
    }
    
    // MARK: User defined methods
    
    func loadFewIntializers() {
        
        navigationBarView.delegate = self
        descLabel?.text = "Login using the OTP sent to \(mobileNumber)"
        addGestures()
        
        otpField.delegate = self
        otpField.isSecureTextEntry = true
//        resendOtpBG_view.isHidden = true
        
        loginWithPasswordBG_view.isHidden = true
        if isLoginWithOtp {
            loginWithPasswordBG_view.isHidden = false
        }
    }
    
    func addGestures() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureAction))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapGestureAction(_ sender:UITapGestureRecognizer) {
        
        var boolOfNothing = Bool()
        boolOfNothing = otpField.resignFirstResponder()
        print("\(boolOfNothing)")
    }

    fileprivate func checkAndVerifyOtp() {
        
        if otpField.text == "" {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.enterOtp, viewController: self)
            return
        }
        
        let otpNumberInput = Int(otpField.text ?? "") ?? 0
        parameters["otp"] = otpNumberInput as AnyObject
        
        signUpLoginCommonAPI()
    }
}

// MARK: - UITextField Delegate Methods

extension GSOtpViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "" {
            return true
        }
        
        let validCharacters = GSConstant.numericCharacters
        
        if (textField.text?.count ?? 0) < GSConstant.otpMaxAllowedLength, validCharacters.contains(string) == true {
            return true
        } else {
            return false
        }
    }
}

// MARK: - API Methods

extension GSOtpViewController {
    
    func signUpLoginCommonAPI() {
        
        navigationBarView.rightBarBtn.isHidden = true
        navigationBarView.rightBarImage.isHidden = true
        
//        resendOtpBG_view.isHidden = false
        
        APIHandler.NetworkSetupRequestWithoutToken(method:.post, params: parameters, urlString: urlString, withLoader:true) { (response, error) in
            
            self.navigationBarView.rightBarBtn.isHidden = false
            self.navigationBarView.rightBarImage.isHidden = false
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSLoginRootClass.self, from: responseData)
                    
                    menuBar = nil
                    SharedPersistence.storeUserDefaults(key:"current_Latitude", value: self.locationManger?.location?.coordinate.latitude ?? 0.0)
                    SharedPersistence.storeUserDefaults(key: "current_Langitude", value: self.locationManger?.location?.coordinate.longitude ?? 0.0)
                    
                    GSCommonHelper.storeUserDetailsAfterLoginAndPush(responseModel: responseModel, isFromSignup: self.isFromSignUp, from: self)
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: self)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: self)
            }
        }
    }

    func regenerateOtpFromAPI() {
        
        navigationBarView.rightBarBtn.isHidden = true
        navigationBarView.rightBarImage.isHidden = true
        
        otpField.text = ""
        
        var urlString = ""
        
        var params = ["mobile": ["dialing_code": dailCode,
                                 "number": mobileNumber]] as [String:AnyObject]
        
        if isLoginWithOtp {
            urlString = APIurl.baseURL + APIurl.subURL.loginVerify
        } else {
            urlString = APIurl.baseURL + APIurl.subURL.signupVerify
            params["email"] = emailId as AnyObject
        }

        APIHandler.NetworkSetupRequestWithoutToken(method: .post, params: params, urlString: urlString, withLoader: false) { (response, error) in
            
            self.navigationBarView.rightBarBtn.isHidden = false
            self.navigationBarView.rightBarImage.isHidden = false
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    _ = try jsonDecoder.decode(GSOtpModel.self, from: responseData)
                    print("Otp sent successfully")
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: self)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: self)
            }
        }
    }
}

// MARK: - CLLocation Delegate
extension GSOtpViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        default:
            break
        }
    }
}

// MARK: - NavigationBar Methods
extension GSOtpViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        checkAndVerifyOtp()
    }
}

