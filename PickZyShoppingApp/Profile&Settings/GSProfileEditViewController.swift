//
//  GSProfileEditViewController.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 6/7/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProfileEditViewController: GSLoggedInBaseViewController {

    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var profEdit_tableView:UITableView!
    
    var profileObject:GSViewProfileData?
    var profileEdit_array = [GSProfileEditApiRequestModel]()
    
    var oldPwd_alertTextField:UITextField?
    var newPwd_alertTextField:UITextField?
    
    struct GSProfileEditApiRequestModel {
        let keyName:String
        var valueName:Any
        let type:GSProfileEditApiRequestModelType
        let icon:UIImage
        let isEditAllowed:Bool
        var isEditSelected:Bool
    }
    enum GSProfileEditApiRequestModelType {
        case firstName
        case lastName
        case email
        case mobile
        case password
    }

    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
        profEdit_tableView.backgroundColor = UIColor(hexString: defaultTheme.profileEdit_table_BG)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: User defined Methods
    
    private func addFewIntializers() {
        
        navigationBarView.delegate = self
        
        profEdit_tableView.delegate = self
        profEdit_tableView.dataSource = self
        
        profEdit_tableView.tableFooterView = UIView()
        
        if let unwrappedProfileObject = profileObject {
            
            let mobileObj = GSProfileEditApiRequestModel(keyName: "Mobile Number", valueName: unwrappedProfileObject.mobile ?? "", type: .mobile, icon: #imageLiteral(resourceName: "mobile_icon"), isEditAllowed: false, isEditSelected: false)
            let firstNameObj = GSProfileEditApiRequestModel(keyName: "First Name", valueName: unwrappedProfileObject.firstName ?? "", type: .firstName, icon: #imageLiteral(resourceName: "user_icon"), isEditAllowed: true, isEditSelected: false)
            let lastNameObj = GSProfileEditApiRequestModel(keyName: "Last Name", valueName: unwrappedProfileObject.lastName ?? "", type: .lastName, icon: #imageLiteral(resourceName: "user_icon"), isEditAllowed: true, isEditSelected: false)
            let emailObj = GSProfileEditApiRequestModel(keyName: "Email ID", valueName: unwrappedProfileObject.email?.id ?? "", type: .email, icon: #imageLiteral(resourceName: "mail_icon"), isEditAllowed: false, isEditSelected: false)
            let pwdObj = GSProfileEditApiRequestModel(keyName: "Password", valueName: "", type: .password, icon: #imageLiteral(resourceName: "password_icon"), isEditAllowed: true, isEditSelected: false)
            
            profileEdit_array = [mobileObj,firstNameObj,lastNameObj,emailObj,pwdObj]
            
        }
    }
    
    fileprivate func addAlertWithTextFields() {
        
        let alertController = UIAlertController(title: "Change Password", message: "For security of your account enter your old password", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter old password"
            textField.delegate = self
            textField.isSecureTextEntry = true
            self.oldPwd_alertTextField = textField
            NotificationCenter.default.removeObserver(self)
        }

        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter new password"
            textField.delegate = self
            textField.isSecureTextEntry = true
            self.newPwd_alertTextField = textField
            NotificationCenter.default.removeObserver(self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let secondTextField = alertController.textFields![1] as UITextField
            
            self.updatePasswordAPI(currentPwd: firstTextField.text ?? "", newPwd: secondTextField.text ?? "")
        })

        saveAction.isEnabled = false
        
        // adding the notification observer here
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: newPwd_alertTextField,
                                               queue: OperationQueue.main) { (notification) -> Void in
                                                                    
                                                saveAction.isEnabled = self.textDidChangeNotificationForAlertTextFields()
        }
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: newPwd_alertTextField,
                                                            queue: OperationQueue.main) { (notification) -> Void in
                                                                    
                                                            saveAction.isEnabled = self.textDidChangeNotificationForAlertTextFields()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func textDidChangeNotificationForAlertTextFields() -> Bool {
        
        let oldPwd = oldPwd_alertTextField?.text ?? ""
        let newPwd = newPwd_alertTextField?.text ?? ""
        
        if oldPwd.count > 0 && newPwd.count > 0 {
            return true
        }
        return false
    }
}

// MARK: - API Methods

extension GSProfileEditViewController {
    
    fileprivate func updateProfileAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.updateProfile
        
        var firstName = ""
        var lastName = ""
//
        for item in profileEdit_array {
            if item.type == .firstName {
                firstName = item.valueName as? String ?? ""
            } else if item.type == .lastName {
                lastName = item.valueName as? String ?? ""
            }
        }
        
        if firstName.count == 0 {
            CustomAlert.showAlert(title: GSString.AppName, message: "Enter your first name", viewController: self)
            return
        } else if lastName.count == 0 {
            CustomAlert.showAlert(title: GSString.AppName, message: "Enter your last name", viewController: self)
            return
        }
        
        let parameters = ["first_name": firstName.removeEnclosedWhieteSpace(),
                          "last_name": lastName.removeEnclosedWhieteSpace()] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }

            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    let status = responseModel.success ?? false
                    CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: weakSelf)
                    
                    if status {     // Need to save the details in database
                        
                        guard let decodedLoginUserData = SharedPersistence.getValue(key: UserDefaultKeys.user.user_details) as? Data else { return }
                        guard let loginUser_jsonObject = try? JSONDecoder().decode(GSLoginData.self, from: decodedLoginUserData) else { return }
                        
                        let newLoginUser = GSLoginDataUserProfile(firstName: firstName, lastName: lastName, image: loginUser_jsonObject.userProfile?.image, mobile: loginUser_jsonObject.userProfile?.mobile, email: loginUser_jsonObject.userProfile?.email, id: loginUser_jsonObject.userProfile?.id, referralCode: loginUser_jsonObject.userProfile?.referralCode, referralLink: loginUser_jsonObject.userProfile?.referralLink)
                        
                        let newUserLoginData = GSLoginData(userProfile: newLoginUser, authToken: loginUser_jsonObject.authToken)
                        
                        guard let encodedLoginUserData = try? JSONEncoder().encode(newUserLoginData) else { return }
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.user.user_details, value: encodedLoginUserData)
                    }
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? GSString.API.unknownError, viewController: weakSelf)
            }
        }
    }
    
    fileprivate func updatePasswordAPI(currentPwd:String, newPwd:String) {      // Under developement
        
        let urlString = APIurl.baseURL + APIurl.subURL.updateProfilePwd
        
        let hashedCurrentPwd = currentPwd.md5()
        let hashedNewPwd = newPwd.md5()
        let parameters = ["old_password": hashedCurrentPwd,
                          "new_password": hashedNewPwd] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: weakSelf)
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? GSString.API.unknownError, viewController: weakSelf)
            }
        }
    }
}

// MARK: - UITableView Methods

extension GSProfileEditViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return profileEdit_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = GSString.CellIdentifier.ProfileEditVC_prof_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GSProfileTableCell else {
            return UITableViewCell()
        }
        
        let valueAtIndex = profileEdit_array[indexPath.row]
        cell.placeHolder_lbl.text = valueAtIndex.keyName
        cell.profIcon_imageView.image = valueAtIndex.icon
        
        cell.cell_txtField.isSecureTextEntry = false
        cell.cell_txtField.keyboardType = .default
        cell.cell_txtField.delegate = self
        cell.cell_txtField.tag = indexPath.row
        
        cell.dialCode_lbl.isHidden = true

        switch valueAtIndex.type {
        case .firstName, .lastName, .email:
            cell.cell_txtField.text = valueAtIndex.valueName as? String ?? ""
            break
        case .mobile:
            if let mobileObj = valueAtIndex.valueName as? GSViewProfileMobile {
                cell.cell_txtField.text = "\(mobileObj.number ?? 0)"
                cell.dialCode_lbl.isHidden = false
                cell.dialCode_lbl.text = "+\(mobileObj.dialingCode ?? 0)"
            }
            cell.cell_txtField.keyboardType = .numberPad
            break
        case .password:
            cell.cell_txtField.isSecureTextEntry = true
            if let pwd = valueAtIndex.valueName as? String, pwd != "" {
                cell.cell_txtField.text = pwd
            } else {
                cell.cell_txtField.text = "123456"
            }
            break
        }
        
        cell.edit_btn.isHidden = !valueAtIndex.isEditAllowed
        cell.cell_txtField.isUserInteractionEnabled = false
        
        if (valueAtIndex.isEditAllowed && valueAtIndex.isEditSelected) {
            cell.cell_txtField.isUserInteractionEnabled = true
        }
        
        cell.edit_btn.tag = indexPath.row
        cell.edit_btn.addTarget(self, action: #selector(cell_editAction(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 65.0
        }
        return 55.0
    }
    
    //MARK:- Cell Action methods
    
    @objc func cell_editAction(_ sender:UIButton) {
        let theIndexPath = IndexPath(row: sender.tag, section: 0)
        if !profileEdit_array[theIndexPath.row].isEditAllowed { return }
        guard let cell = profEdit_tableView.cellForRow(at: theIndexPath) as? GSProfileTableCell else {return}
        profileEdit_array[theIndexPath.row].isEditSelected = true
        cell.cell_txtField.isUserInteractionEnabled = true
        
        if profileEdit_array[theIndexPath.row].type == .password {
            addAlertWithTextFields()
            return
        }
        
        cell.cell_txtField.becomeFirstResponder()
    }
}

// MARK: - UITextField Delegate Methods

extension GSProfileEditViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let tag = textField.tag
        
        if profileEdit_array[tag].type == .password {
            addAlertWithTextFields()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let tag = textField.tag
        
        if profileEdit_array[tag].type == .mobile {
            
            return
            
//            var dailing_code = 0
//
//            if let mobile = profileEdit_array[tag].valueName as? GSViewProfileMobile {
//                dailing_code = mobile.dialingCode ?? 0
//            }
//
//            let mobileObject = GSViewProfileMobile(dialingCode: dailing_code, number: Int64(textField.text ?? ""))
//            profileEdit_array[tag] = GSProfileEditApiRequestModel(keyName: "Mobile Number", valueName: mobileObject, type: .mobile, icon: #imageLiteral(resourceName: "mobile_icon"), isEditAllowed: false, isEditSelected: false)
            
        }
        
        if profileEdit_array[tag].type == .password {
            return
            
        } else {
            profileEdit_array[tag].valueName = textField.text ?? ""
        }
        profEdit_tableView.reloadData()
    }
}

// MARK: - NavigationBar Delegate Methods

extension GSProfileEditViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        view.endEditing(true)
        updateProfileAPI()
    }
}
