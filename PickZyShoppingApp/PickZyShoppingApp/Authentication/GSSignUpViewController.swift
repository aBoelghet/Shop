//
//  GSSignInViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 5/2/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class GSSignUpViewController: GSBaseViewController {
    
    @IBOutlet weak var firstName_txtField: GSBaseTextField!
    @IBOutlet weak var lastName_txtField: GSBaseTextField!
    @IBOutlet weak var mobileNumber_txtField: GSBaseTextField!
    @IBOutlet weak var mobileNumberPrefix_lbl:GSBaseLabel!
    @IBOutlet weak var mobileFiledBG_view:UIView!
    @IBOutlet weak var password_txtField: GSBaseTextField!
    @IBOutlet weak var email_txtField: GSBaseTextField!
    @IBOutlet weak var loginWithOTP_btn:GSUnderlinedButton!
    @IBOutlet weak var main_ScrollView: UIScrollView!
    @IBOutlet weak var navigationBar_View: NavigationBarNormal!
    @IBOutlet weak var otpLoginBtn_view: UIView!
    @IBOutlet weak var info_lbl:GSBaseLabel!
    @IBOutlet weak var bottomOr_lbl:GSBaseLabel!
    
    @IBOutlet var textFieldBG_views:[UIView]!

    var locationManger:CLLocationManager?

    //MARK: - UIViewController Methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadFewIntializers()
        applyColors()
        addLocationServices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        let lengthToBeScroll = otpLoginBtn_view.frame.origin.y + loginWithOTP_btn.frame.size.height + 0.0
        main_ScrollView.contentSize = CGSize.init(width: 0, height: lengthToBeScroll)
        firstName_txtField.becomeFirstResponder()
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {

        info_lbl.textColor = UIColor(hexString: defaultTheme.welcome_infoLabelText)
        bottomOr_lbl.textColor = UIColor(hexString: defaultTheme.welcome_infoLabelText)
        loginWithOTP_btn.setTitleColor(UIColor(hexString: defaultTheme.underLineButtonTxt), for: .normal)
        
        let txtField_array = [firstName_txtField,lastName_txtField,mobileNumber_txtField,password_txtField,email_txtField]
        for textField in txtField_array {
//            textField?.backgroundColor = UIColor(hexString: defaultTheme.welcome_textFieldBG)
            textField?.PlaceHolderTextColor = UIColor(hexString: defaultTheme.signUp_textField_placeholder)
            textField?.textColor = UIColor(hexString: defaultTheme.signUp_textField_text)
        }
        
        for tfBG_view in textFieldBG_views {
            tfBG_view.backgroundColor = UIColor(hexString: defaultTheme.welcome_textFieldBG)
        }
        
//        mobileFiledBG_view.backgroundColor = UIColor(hexString: defaultTheme.welcome_textFieldBG)
        mobileNumberPrefix_lbl.textColor = UIColor(hexString: defaultTheme.signUp_textField_placeholder)
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
            locationManger?.startUpdatingLocation()
            break
        }
    }
    
    //MARK: - UIAction

    @IBAction func loginUsingOTPAction(_ sender: UIButton) {
        
//        pushToOTPView()
    }
    
    // MARK: - User defined methods
    
    func loadFewIntializers() {
        
        info_lbl.text = "Enter the below details to create an account"
        
        navigationBar_View.delegate = self
        
        let txtFieldArray = [firstName_txtField,lastName_txtField,mobileNumber_txtField,email_txtField,password_txtField]
        for tf in txtFieldArray {
            tf?.delegate = self
            tf?.autocorrectionType = .no
        }
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.apiDynamicSecretKey, value: AppKeys.staticSecurityKey)
    }
}

extension GSSignUpViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField.tag == 2 {
//            if textField.text == "" {
//            textField.text = "+91 "
//            }
//        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField.tag == 2 {
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
        
        if textField.tag == 2 {
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

// MARK: - NavigationBar Methods

extension GSSignUpViewController: NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        view.endEditing(true)
        guard validateTextFileds() == true else {return}
        otpAPI()
    }
}

// MARK: - CLLocation Delegate

extension GSSignUpViewController: CLLocationManagerDelegate {
    
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

//MARK: - API Methods

extension GSSignUpViewController {
    
    func otpAPI() {
        
        navigationBar_View.rightBarBtn.isHidden = true
        navigationBar_View.rightBarImage.isHidden = true
        
        let signUpUrl = APIurl.baseURL + APIurl.subURL.signupVerify
        
//        let _mobileNumber = mobileNumber_txtField.text
//
//        let mobileNumberSeparated_array = (_mobileNumber ?? "").components(separatedBy: " ")
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
        let mobileNumber = Int64(mobileNumber_txtField.text ?? "") ?? 0
        
        let params = ["mobile": ["dialing_code": intDialCode,
                                 "number": mobileNumber],
                      "email" : email_txtField.text ?? ""] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequestWithoutToken(method: .post, params: params, urlString: signUpUrl, withLoader: false) { (response, error) in
            
            self.navigationBar_View.rightBarBtn.isHidden = false
            self.navigationBar_View.rightBarImage.isHidden = false
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if responseModel.success == false {
                        CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: self)
                        return
                    }

                    if let otpVC = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSOtpViewController) as? GSOtpViewController {
                        guard let params = self.createParametersForSignup(dialCode: intDialCode, mobileNum: Int64(mobileNumber)) else { return }
                        let signUpUrl = APIurl.baseURL + APIurl.subURL.signUp
                        otpVC.configureWith(mobile: String(mobileNumber), dialingCode: intDialCode, email: self.email_txtField.text ?? "", param: params, urlStr: signUpUrl, isOtpLogin: false)
                        otpVC.isFromSignUp = true
                        self.navigationController?.pushViewController(otpVC, animated: true)
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
    
    private func createParametersForSignup(dialCode:Int, mobileNum:Int64) -> [String:AnyObject]? {
        
        let passWord = password_txtField.text!
        let hashedPassword = passWord.md5()
        
        var param = [ APIKeys.signUpVC.first_name : (firstName_txtField.text ?? "").removeEnclosedWhieteSpace(),
                      APIKeys.signUpVC.last_name  : (lastName_txtField.text ?? "").removeEnclosedWhieteSpace(),
                      APIKeys.signUpVC.mobile     : [APIKeys.signUpVC.dialing_code: dialCode,
                                                     APIKeys.signUpVC.number     : mobileNum] as [String : AnyObject] ,
                      APIKeys.signUpVC.emailObject   : [APIKeys.signUpVC.email_id : email_txtField.text ?? ""],
                      APIKeys.signUpVC.password   : hashedPassword] as [String : AnyObject]
        
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
        
        let txtFieldArray = [firstName_txtField,lastName_txtField,mobileNumber_txtField,password_txtField,email_txtField]
        
        if (firstName_txtField.text?.isEmpty)! && (lastName_txtField.text?.isEmpty)! && (mobileNumber_txtField.text?.isEmpty)! && (password_txtField.text?.isEmpty)! && (email_txtField.text?.isEmpty)! {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.fillAllDetails, viewController: self)
            return false
        }
        for txtField in txtFieldArray {
            if (txtField?.text?.isEmpty)! {
                
                CustomAlert.showAlert(title: GSString.AppName, message: "Please enter \(txtField?.placeholder ?? "Please enter missing field")", viewController: self)
                return false
            }
            
            let mobileNumber = mobileNumber_txtField.text
            
            if txtField == mobileNumber_txtField && !(mobileNumber!.isValidPhone()) {
                CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.validPhoneNumber, viewController: self)
                return false
            } else if txtField == password_txtField && !(password_txtField.text?.isValidPwd())!{
                CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.validPassword, viewController: self)
                return false
            } else if txtField == email_txtField && !(email_txtField.text?.isValidEmail())! {
                CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.validEmail, viewController: self)
                return false
            }
        }
        
        return true
    }
    
}




