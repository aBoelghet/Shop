//
//  GSAboutViewController.swift
//  Shopor
//
//  Created by Ratheesh on 04/03/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSSupportViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var support_tableView:UITableView!
    
    var emailID = ""
    var feedBack = ""
    var tableData_array = [GSSupportUIModel]()
    
    struct GSSupportUIModel {
        let id:String
        let displayName:String
        let type:GSSupportUIType
        let dailingCode:Int?
        let number:String?
        let availableTime: String?
    }
    
    enum GSSupportUIType {
        case normal
        case contact
        case feedback
    }

    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyColors()
        addFewIntializers()
        supportListAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        support_tableView.backgroundColor = UIColor(hexString: defaultTheme.paymentOpt_table_BG)
    }
    
    // MARK: User defined Methods
    
    private func addFewIntializers() {
        navigationBar_view.delegate = self
        navigationBar_view.titleText = "Support"
        
        support_tableView.dataSource = self
        support_tableView.delegate = self
        
        support_tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableView Methods

extension GSSupportViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemAtIndex = tableData_array[indexPath.row]
        
        switch itemAtIndex.type {
        case .normal:
            return normalSupportCell(at: indexPath)
        case .feedback:
            return sendMessageSupportCell(at: indexPath)
        case .contact:
            return contactSupportCell(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let itemAtIndex = tableData_array[indexPath.row]
        
        if itemAtIndex.type == .contact || itemAtIndex.type == .feedback{
            return
        }
        
        view.endEditing(true)
        if let supportDetailsVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSSupportDetailsViewController) as? GSSupportDetailsViewController {
            supportDetailsVC.titleId = itemAtIndex.id
            supportDetailsVC.titleText = itemAtIndex.displayName
            navigationController?.pushViewController(supportDetailsVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let itemAtIndex = tableData_array[indexPath.row]
        
        if itemAtIndex.type == .normal {
            return 50
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: - UITableView Cell Creation
    
    private func normalSupportCell(at indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = support_tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.supportNormalTableViewCell) as? GSSupportNormalTableCell else {
            return UITableViewCell()
        }
        
        let itemAtIndex = tableData_array[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        
        cell.title_lbl.text = itemAtIndex.displayName
        
        return cell
    }
    
    private func contactSupportCell(at indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = support_tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.supportContactTableViewCell) as? GSSupportContactTableCell else {
            return UITableViewCell()
        }
        let itemAtIndex = tableData_array[indexPath.row]

        cell.title_lbl.text = "Customer Support:"
        cell.contact_btn.tag = indexPath.row
        cell.availableTime_lbl.text = itemAtIndex.availableTime ?? ""
        cell.contact_btn.addTarget(self, action: #selector(contactCell_contactAction(_:)), for: .touchUpInside)
        
        return cell
    }
    
    private func sendMessageSupportCell(at indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = support_tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.supportSendMessageTableViewCell) as? GSSupportSendMessageTableCell else {
            return UITableViewCell()
        }
        
        cell.title_lbl.text = "Send your message to us"
        cell.message_txtView.text = feedBack
        cell.message_txtView.delegate = self
        cell.email_txtField.delegate = self
        cell.email_txtField.placeholder = "Email id"
        cell.email_txtField.text = emailID
        cell.submit_btn.tag = indexPath.row
        cell.submit_btn.addTarget(self, action: #selector(sendMessageCell_submitAction(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - Cell Action Methods
    
    @objc private func sendMessageCell_submitAction(_ sender:UIButton) {
        
        view.endEditing(true)
        
        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
        
        if isGuestLogin {
            
            if let welcomeViewController = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSWelcomeScreenViewController) as? GSWelcomeScreenViewController {
                welcomeViewController.isShowingForGuestUser = true
                
                GSCustomPushPop.doCustomPush(from: self, to: welcomeViewController)
            }
            return
        }
        
        
        if emailID.count == 0 {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.enterEmail, viewController: self)
            return
        } else if emailID.isValidEmail() == false {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.validEmail, viewController: self)
            return
        } else if feedBack.count == 0 {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.enterMessageInSupport, viewController: self)
            return
        }
        
        sendMessagesAPI()
    }
    
    @objc private func contactCell_contactAction(_ sender:UIButton) {
        
        let itemAtIndex = tableData_array[sender.tag]
        
        guard let selectedNumber = itemAtIndex.number else {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.supportContactUnavailable, viewController: self)
            return
        }
        guard let number = URL(string: "tel://" + "\(selectedNumber)") else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(number)
        } else {
            UIApplication.shared.openURL(number)
        }
    }
}

// MARK: - UITextField Delegate

extension GSSupportViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        emailID = textField.text ?? ""
    }
}

// MARK: - UITextView Delegate

extension GSSupportViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        feedBack = textView.text ?? ""
    }
}

// MARK: - API Methods

extension GSSupportViewController {
    
    fileprivate func supportListAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.support_titles
        
        if tableData_array.count > 0 {
            tableData_array.removeAll()
        }
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSSupportListModel.self, from: responseData)
                    
                    if let titleArray = responseModel.data?.titles {
                        
                        for title_item in titleArray {
                            weakSelf.tableData_array.append(GSSupportUIModel(id: title_item.id ?? "", displayName: title_item.displayName ?? "", type: .normal, dailingCode: nil, number: nil, availableTime: nil))
                        }
                    }
                    
                    if let helpNumber = responseModel.data?.help?.number, let dialCode = responseModel.data?.help?.dialingCode {
                        weakSelf.tableData_array.append(GSSupportUIModel(id: "", displayName: "Customer Support:", type: .contact, dailingCode: dialCode, number: helpNumber, availableTime: responseModel.data?.supportAvailableTime))
                    }
                    weakSelf.tableData_array.append(GSSupportUIModel(id: "", displayName: "Send your message to us", type: .feedback, dailingCode: nil, number: nil, availableTime: nil))
                    
//                    weakSelf.emailID = responseModel.data?.emailID ?? ""
                    
                    weakSelf.support_tableView.reloadData()
                    
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
    
    fileprivate func sendMessagesAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.support_ask
        
        let parameters = ["email_id": emailID,
                          "message": feedBack] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", alertButtonsArray: ["Ok"], viewController: weakSelf, completion: { _ in
                        
                        if responseModel.success == true {
                            weakSelf.emailID = ""
                            weakSelf.feedBack = ""
                            weakSelf.support_tableView.reloadData()
                        }
                    })
                    
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


// MARK:- NavigationBar Methods

extension GSSupportViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        addSideMenu()
    }
    
    func rightBarBtnPressed(sender:UIButton) {
    }
}
