//
//  GSForgotPasswordViewController.swift
//  Shopor
//
//  Created by Ratheesh on 25/02/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSForgotPasswordViewController: GSBaseViewController {
    
    @IBOutlet weak var otp_txtField: GSBaseTextField!
    @IBOutlet weak var newconfirmPassword_txtField: GSBaseTextField!
    @IBOutlet weak var confirmPassword_txtField: GSBaseTextField!
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var topInfo_lbl: GSBaseLabel!
    @IBOutlet weak var resendOtp_btn:GSBaseButton!
    
    var otpEntered = ""
    var mobileNumber:String = ""
    var dailCode:Int = 0
    
    // MARK: - ViewController Life Cycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadFewIntializers()
        applyColors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Configuring with data
    
    func configureResetPasswordWith(number:String, dial:Int) {
        
        self.mobileNumber = number
        self.dailCode = dial
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        
        topInfo_lbl.textColor = UIColor(hexString: defaultTheme.welcome_infoLabelText)
        newconfirmPassword_txtField.backgroundColor = UIColor(hexString: defaultTheme.welcome_textFieldBG)
        confirmPassword_txtField.backgroundColor = UIColor(hexString: defaultTheme.welcome_textFieldBG)
        newconfirmPassword_txtField.PlaceHolderTextColor = UIColor(hexString: defaultTheme.login_textField_placeholder)
        confirmPassword_txtField.PlaceHolderTextColor = UIColor(hexString: defaultTheme.login_textField_placeholder)
        newconfirmPassword_txtField.textColor = UIColor(hexString: defaultTheme.login_textField_text)
        confirmPassword_txtField.textColor = UIColor(hexString: defaultTheme.login_textField_text)
        
        resendOtp_btn.setTitleColor(UIColor(hexString: defaultTheme.underLineButtonTxt), for: .normal)
        otp_txtField.backgroundColor = UIColor(hexString: defaultTheme.welcome_textFieldBG)
        otp_txtField.PlaceHolderTextColor = UIColor(hexString: defaultTheme.login_textField_placeholder)
        otp_txtField.textColor = UIColor(hexString: defaultTheme.login_textField_text)
    }
    
    // MARK : - User defined methods
    func loadFewIntializers() {
        navigationBar_view.delegate = self
        otp_txtField.delegate = self
    }
    
    // MARK: - IBAction Methods
    
    @IBAction private func resendOtpAction(_ sender:UIButton) {
        regenerateOtpFromAPI()
    }
}

// MARK: - UITextField Delegate Methods

extension GSForgotPasswordViewController: UITextFieldDelegate {
    
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

extension GSForgotPasswordViewController {
    
    
    func regenerateOtpFromAPI() {
        
        navigationBar_view.rightBarBtn.isHidden = true
        navigationBar_view.rightBarImage.isHidden = true
        
        otp_txtField.text = ""
        
        let urlString = APIurl.baseURL + APIurl.subURL.forgotPasswordVerify
        
        let params = ["mobile": ["dialing_code": dailCode,
                                 "number": mobileNumber]] as [String:AnyObject]

        
        APIHandler.NetworkSetupRequestWithoutToken(method: .post, params: params, urlString: urlString, withLoader: false) { (response, error) in
            
            self.navigationBar_view.rightBarBtn.isHidden = false
            self.navigationBar_view.rightBarImage.isHidden = false
            
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
    
    
    fileprivate func resetPasswordAPI() {
        
        navigationBar_view.rightBarBtn.isHidden = true
        navigationBar_view.rightBarImage.isHidden = true
        
        
        let urlString = APIurl.baseURL + APIurl.subURL.resetPassword
        
        let password = confirmPassword_txtField.text ?? ""
        let hashedPassword = password.md5()
        
        let params = ["mobile": ["dialing_code": dailCode,
                                 "number": mobileNumber],
                      "otp": Int(otpEntered) ?? 0,
                      "password": hashedPassword] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequestWithoutToken(method: .post, params: params, urlString: urlString, withLoader: false) { (response, error) in
            
            self.navigationBar_view.rightBarBtn.isHidden = false
            self.navigationBar_view.rightBarImage.isHidden = false
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", alertButtonsArray: ["Ok"], viewController: self, completion: { _ in
                        
                        if responseModel.success == true {
                            // Need to Login Page
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    })
                    
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
    
    fileprivate func validateFileds() -> Bool {
        
        let newPassword = newconfirmPassword_txtField.text ?? ""
        let confirmPassword = confirmPassword_txtField.text ?? ""
        otpEntered = otp_txtField.text ?? ""
        
        if otpEntered.count == 0 {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.enterOtp, viewController: self)
            return false
            
        } else if newPassword.count == 0 {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.enterPassword, viewController: self)
            return false
        } else if newPassword.isValidPwd() == false {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.validPassword, viewController: self)
            return false
        } else if confirmPassword.count == 0 {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.enterConfirmPwd, viewController: self)
            return false
        } else if newPassword != confirmPassword {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.passwordConfirmPwdNoMatch, viewController: self)
            return false
        }
        return true
    }
}

// MARK: - Navigation Bar View Delegates

extension GSForgotPasswordViewController: NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        if validateFileds() == true {
            resetPasswordAPI()
        }
    }
}

