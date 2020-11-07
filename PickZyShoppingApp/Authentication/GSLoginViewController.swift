//
//  GSLoginViewController.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/15/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit
import CryptoSwift
import CoreLocation

class GSLoginViewController: GSBaseViewController {
    
    @IBOutlet weak var mobile_txtField: GSBaseTextField!
    @IBOutlet weak var mobileNumberPrefix_lbl:GSBaseLabel!
    @IBOutlet weak var mobileFiledBG_view:UIView!
    @IBOutlet weak var password_txtField: GSBaseTextField!
    @IBOutlet weak var signUp_navigationBar: NavigationBarNormal!
    @IBOutlet weak var topInfo_lbl: GSBaseLabel!
    @IBOutlet weak var loginBtn_view: UIView!
    @IBOutlet weak var login_btn:GSUnderlinedButton!
    @IBOutlet weak var forgotPassword_btn:GSUnderlinedButton!
    @IBOutlet weak var main_scrollView: UIScrollView!
    
    var locationManger:CLLocationManager?
    
    // MARK: - View Controller Life cycle methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadFewIntializers()
        applyColors()
        
        addLocationServices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        setScrollViewContentSize()
        mobile_txtField.becomeFirstResponder()
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
    
    // MARK: - Colors For UI
    private func applyColors() {
        
        topInfo_lbl.textColor = UIColor(hexString: defaultTheme.welcome_infoLabelText)
        mobileFiledBG_view.backgroundColor = UIColor(hexString: defaultTheme.welcome_textFieldBG)
        password_txtField.backgroundColor = UIColor(hexString: defaultTheme.welcome_textFieldBG)
        mobile_txtField.PlaceHolderTextColor = UIColor(hexString: defaultTheme.login_textField_placeholder)
        mobileNumberPrefix_lbl.textColor = UIColor(hexString: defaultTheme.login_textField_placeholder)
        password_txtField.PlaceHolderTextColor = UIColor(hexString: defaultTheme.login_textField_placeholder)
        mobile_txtField.textColor = UIColor(hexString: defaultTheme.login_textField_text)
        password_txtField.textColor = UIColor(hexString: defaultTheme.login_textField_text)
        login_btn.setTitleColor(UIColor(hexString: defaultTheme.underLineButtonTxt), for: .normal)
        forgotPassword_btn.setTitleColor(UIColor(hexString: defaultTheme.underLineButtonTxt), for: .normal)
    }
    
    // MARK: - UIAction
    @IBAction func loginUsingOTP(_ sender: UIButton) {
        
        let mobileNumber = mobile_txtField.text?.components(separatedBy: " ").last
        if !(mobileNumber!.isValidPhone()) {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.validPhoneNumber, viewController: self)
            return
        }
        
        loginOtpVerify()
    }
    
    @IBAction private func forgotPasswordAction(_ sender: UIButton) {
        
        let mobileNumber = mobile_txtField.text?.components(separatedBy: " ").last
        if !(mobileNumber!.isValidPhone()) {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.validPhoneNumber, viewController: self)
            return
        }
        forgotPasswordVerify()
    }
    
    // MARK : - User defined methods
    func loadFewIntializers() {
        
        signUp_navigationBar.delegate = self
        mobile_txtField.delegate = self
        password_txtField.delegate = self
        addGestures()
        
//        if #available(iOS 11.0, *) {
//            mobile_txtField.textContentType = UITextContentType.telephoneNumber
//            password_txtField.textContentType = UITextContentType.password
//        } else {
//            // Fallback on earlier versions
//        }
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.apiDynamicSecretKey, value: AppKeys.staticSecurityKey)
    }
    
    func addGestures() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureAction))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func setScrollViewContentSize() {
        
        main_scrollView.contentSize = CGSize.init(width: 0, height: 0)
    }
    
    @objc func tapGestureAction(_ sender:UITapGestureRecognizer) {
        
    }
}

extension GSLoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField.tag == 0 {
//            if textField.text == "" {
//                textField.text = "+91 "
//            }
//        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField.tag == 0 {
//            let textFieldText = textField.text?.trimmingCharacters(in: CharacterSet(charactersIn: " "))
//            if textFieldText == "+91" {
//                textField.text = ""
//            }
//        }
        textField.text = textField.text?.trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "" {
            return true
        }
        
        if textField.tag == 0 {
            //            var updatedText = ""
            //            if let text = textField.text,
            //                let textRange = Range(range, in: text) {
            //                updatedText = text.replacingCharacters(in: textRange, with: string)
            //            }
            //
            //            if updatedText.contains("+91 ") {
            //                return true
            //            }
            //            return false
            
            let validCharacters = GSConstant.numericCharacters
            
            if (textField.text?.count ?? 0) < GSConstant.mobileNumberLength, validCharacters.contains(string) == true {
                return true
            } else {
                return false
            }
        }
        return true
    }
}

//MARK: - API Methods
extension GSLoginViewController {
    
    func loginApi() {
        
        signUp_navigationBar.rightBarBtn.isHidden = true
        signUp_navigationBar.rightBarImage.isHidden = true
        loginBtn_view.isHidden = true
        
        let loginUrl = APIurl.baseURL + APIurl.subURL.loginWithPassword
        
        let passWord = password_txtField.text ?? ""
        let hashedPassword = passWord.md5()
        
//        let mobileNumberSeparated_array = (mobile_txtField.text ?? "").components(separatedBy: " ")
//
//        if mobileNumberSeparated_array.count < 2 {
//            return
//        }
        
        var dialingCode = mobileNumberPrefix_lbl.text ?? ""
        if dialingCode.contains("+") {
            dialingCode.removeFirst()
        }
        if dialingCode.contains("|") {
            dialingCode.removeLast()
        }
        let intDialCode = Int(dialingCode) ?? 0
        let mobileNumber = Int64(mobile_txtField.text ?? "") ?? 0
        
        var param = [ APIKeys.loginVC.mobile        : [APIKeys.loginVC.number       :   mobileNumber,
                                                       APIKeys.loginVC.dialing_code :   intDialCode],
                      APIKeys.loginVC.password      :   hashedPassword] as [String : AnyObject]
        
        if let deviceToken = SharedPersistence.getValue(key: UserDefaultKeys.deviceToken) as? String, deviceToken != "" {
            param[APIKeys.loginVC.device_details] = [APIKeys.loginVC.deviceType : GSConstant.deviceType, APIKeys.loginVC.deviceToken: deviceToken] as AnyObject
        }
        
        if let unwrappedLat = locationManger?.location?.coordinate.latitude, let unwrappedLong = locationManger?.location?.coordinate.longitude {
            param[APIKeys.loginVC.current_location] = [APIKeys.loginVC.locationType :   "Point",
                                                       APIKeys.loginVC.coordinates : [unwrappedLong, unwrappedLat]] as AnyObject
        }
        
        APIHandler.NetworkSetupRequestWithoutToken(method: .post,params: param, urlString: loginUrl, withLoader:true) { (response, error) in
            
            self.signUp_navigationBar.rightBarBtn.isHidden = false
            self.signUp_navigationBar.rightBarImage.isHidden = false
            self.loginBtn_view.isHidden = false
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSLoginRootClass.self, from: responseData)
                    
                    menuBar = nil
                    
                    SharedPersistence.storeUserDefaults(key:"current_Latitude", value: self.locationManger?.location?.coordinate.latitude ?? 0.0)
                    SharedPersistence.storeUserDefaults(key: "current_Langitude", value: self.locationManger?.location?.coordinate.longitude ?? 0.0)

                    GSCommonHelper.storeUserDetailsAfterLoginAndPush(responseModel: responseModel, isFromSignup: false, from: self)
                    
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
    
    func loginOtpVerify() {
        
        signUp_navigationBar.rightBarBtn.isHidden = true
        signUp_navigationBar.rightBarImage.isHidden = true
        loginBtn_view.isHidden = true
        
        let loginOtpUrl = APIurl.baseURL + APIurl.subURL.loginVerify

//        let mobileNumberSeparated_array = (mobile_txtField.text ?? "").components(separatedBy: " ")
//
//        if mobileNumberSeparated_array.count < 2 {
//            return
//        }
        
        var dialingCode = mobileNumberPrefix_lbl.text ?? ""
        if dialingCode.contains("+") {
            dialingCode.removeFirst()
        }
        if dialingCode.contains("|") {
            dialingCode.removeLast()
        }
        let intDialCode = Int(dialingCode) ?? 0
        let mobileNumber = Int64(mobile_txtField.text ?? "") ?? 0
        
        let param = [ APIKeys.loginVC.mobile        : [APIKeys.loginVC.number       :   mobileNumber,
                                                       APIKeys.loginVC.dialing_code :   intDialCode]] as [String : AnyObject]
        
        APIHandler.NetworkSetupRequestWithoutToken(method: .post,params: param, urlString: loginOtpUrl, withLoader:true) { (response, error) in
            
            self.signUp_navigationBar.rightBarBtn.isHidden = false
            self.signUp_navigationBar.rightBarImage.isHidden = false
            self.loginBtn_view.isHidden = false
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSOtpModel.self, from: responseData)
                    
                    let status = responseModel.success ?? false
                    
                    if status {
                        
//                        guard let otpObject = responseModel.data else { return }
                        
                        if let otpVC = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSOtpViewController) as? GSOtpViewController {
                            guard let param = self.createLoginParameter() else { return }
                            let urlString = APIurl.baseURL + APIurl.subURL.loginWithOtp
                            otpVC.configureWith(mobile: String(mobileNumber), dialingCode: intDialCode, email: "", param: param, urlStr: urlString, isOtpLogin: true)
                            self.navigationController?.pushViewController(otpVC, animated: true)
                        }
                        
                    } else {
                        CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: self)
                    }
                    
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
    
    private func createLoginParameter() -> [String:AnyObject]? {
        
//        let mobileNumberSeparated_array = (mobile_txtField.text ?? "").components(separatedBy: " ")
//
//        if mobileNumberSeparated_array.count < 2 {
//            return nil
//        }
        
        var dialingCode = mobileNumberPrefix_lbl.text ?? ""
        if dialingCode.contains("+") {
            dialingCode.removeFirst()
        }
        if dialingCode.contains("|") {
            dialingCode.removeLast()
        }
        let intDialCode = Int(dialingCode) ?? 0
        let mobileNumber = Int64(mobile_txtField.text ?? "") ?? 0
        
        var param = [ APIKeys.loginVC.mobile        : [APIKeys.loginVC.number       :   mobileNumber,
                                                       APIKeys.loginVC.dialing_code :   intDialCode]] as [String : AnyObject]
        
        if let deviceToken = SharedPersistence.getValue(key: UserDefaultKeys.deviceToken) as? String, deviceToken != "" {
            param[APIKeys.loginVC.device_details] = [APIKeys.loginVC.deviceType : GSConstant.deviceType,
                                                     APIKeys.loginVC.deviceToken: deviceToken] as AnyObject
        }
        
        if let unwrappedLat = locationManger?.location?.coordinate.latitude, let unwrappedLong = locationManger?.location?.coordinate.longitude {
            param[APIKeys.loginVC.current_location] = [APIKeys.loginVC.locationType :   "Point",
                                                       APIKeys.loginVC.coordinates : [unwrappedLong, unwrappedLat]] as AnyObject
        }
        return param
    }
    
    // MARK: - Validations for Textfields
    func validateTextFileds() -> Bool {
        
        let txtFieldArray = [mobile_txtField,password_txtField]
        
        if (mobile_txtField.text?.isEmpty)! && (password_txtField.text?.isEmpty)! {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.fillAllDetails, viewController: self)
            return false
        }
        for txtField in txtFieldArray {
            if (txtField?.text?.isEmpty)! {
                
                CustomAlert.showAlert(title: GSString.AppName, message: "Please enter \(txtField?.placeholder ?? "Please enter missing field")", viewController: self)
                return false
            }
            
            let mobileNumber = mobile_txtField.text
            
            if txtField == mobile_txtField && !(mobileNumber!.isValidPhone()) {
                CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.validPhoneNumber, viewController: self)
                return false
            } else if txtField == password_txtField && !(password_txtField.text?.isValidPwd())!{
                CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.validPassword, viewController: self)
                return false
            }
        }
        return true
    }
    
    func forgotPasswordVerify() {
        
        signUp_navigationBar.rightBarBtn.isHidden = true
        signUp_navigationBar.rightBarImage.isHidden = true
        loginBtn_view.isHidden = true
        
        let loginOtpUrl = APIurl.baseURL + APIurl.subURL.forgotPasswordVerify
        
        
        var dialingCode = mobileNumberPrefix_lbl.text ?? ""
        if dialingCode.contains("+") {
            dialingCode.removeFirst()
        }
        if dialingCode.contains("|") {
            dialingCode.removeLast()
        }
        let intDialCode = Int(dialingCode) ?? 0
        let mobileNumber = Int64(mobile_txtField.text ?? "") ?? 0
        
        let param = [ APIKeys.loginVC.mobile        : [APIKeys.loginVC.number       :   mobileNumber,
                                                       APIKeys.loginVC.dialing_code :   intDialCode]] as [String : AnyObject]
        
        APIHandler.NetworkSetupRequestWithoutToken(method: .post,params: param, urlString: loginOtpUrl, withLoader:true) { (response, error) in
            
            self.signUp_navigationBar.rightBarBtn.isHidden = false
            self.signUp_navigationBar.rightBarImage.isHidden = false
            self.loginBtn_view.isHidden = false
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSOtpModel.self, from: responseData)
                    
                    let status = responseModel.success ?? false
                    
                    if status {
                        
//                        if let otpVC = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSOtpViewController) as? GSOtpViewController {
//
//                            otpVC.configureWith(mobile: String(mobileNumber), dialingCode: intDialCode, email: "", param: [String:AnyObject](), urlStr: "", isOtpLogin: false, isForgotPwd: true)
//                            self.navigationController?.pushViewController(otpVC, animated: true)
//                        }
//                        
                        
                        if let resetPasswordVC = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSForgotPasswordViewController) as? GSForgotPasswordViewController {
                            
                            resetPasswordVC.configureResetPasswordWith(number: self.mobile_txtField.text ?? "", dial: intDialCode)
                            self.navigationController?.pushViewController(resetPasswordVC, animated: true)
                        }
                        
                        
                    } else {
                        CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: self)
                    }
                    
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

extension GSLoginViewController: CLLocationManagerDelegate {
    
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

// MARK: - NavigationBar Delegate Methods
extension GSLoginViewController: NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        view.endEditing(true)
        guard validateTextFileds() == true else {return}
        loginApi()
    }
}

