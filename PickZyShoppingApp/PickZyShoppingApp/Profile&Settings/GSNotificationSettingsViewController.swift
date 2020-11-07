//
//  GSNotificationSettingsViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 05/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSNotificationSettingsViewController: GSLoggedInBaseViewController {

    var notifySettingsArr = [String]()
    var imageOptionArr = [UIImage]()
    
    var selectionArray = [Bool]()
    
    @IBOutlet weak var navigationBar_view:NavigationBarNormal!
    @IBOutlet weak var tbleNotifySettings: UITableView!
    
    var settingsData:GSViewProfileSetting?
    
    struct GSNotificationPreferencesModel {
        let prefernce:String
        var isSelected:Bool
        let icon:UIImage
    }
    
    var tableData = [GSNotificationPreferencesModel]()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationBar_view.delegate = self
        notifySettingsArr = ["Push Notifications","SMS Notifications","Email Notifications"]
        
        for _ in (0..<notifySettingsArr.count-1) {
            selectionArray.append(false)
        }
        
        let pushNotification = GSNotificationPreferencesModel(prefernce: "Push Notifications", isSelected: settingsData?.preferences?.pns ?? false, icon: #imageLiteral(resourceName: "push_notification_icon"))
        let smsNotification = GSNotificationPreferencesModel(prefernce: "SMS Notifications", isSelected: settingsData?.preferences?.sms ?? false, icon: #imageLiteral(resourceName: "sms_notification_icon"))
        let emailNotification = GSNotificationPreferencesModel(prefernce: "Email Notifications", isSelected: settingsData?.preferences?.email ?? false, icon: #imageLiteral(resourceName: "mail_notification_icon"))
        
        tableData = [pushNotification,smsNotification,emailNotification]
        
//        imageOptionArr = [#imageLiteral(resourceName: "Phone_icon"),#imageLiteral(resourceName: "User_icon")]
        tbleNotifySettings.tableFooterView = UIView()
        tbleNotifySettings.backgroundColor = UIColor(hexString: defaultTheme.notificationSettings_table_BG)
        
        navigationBar_view.rightBarBtn.isHidden = true
        navigationBar_view.rightBarImage.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableView Methods

extension GSNotificationSettingsViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.NotificationSettingsVC_switch_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSNotificationSettingsTableViewCell else{
            
            return UITableViewCell()
        }
        
        let itemAtIndex = tableData[indexPath.row]
        
        cell.optionLbl.text = itemAtIndex.prefernce
        cell.imageIcon.image = itemAtIndex.icon
        cell.selection_switch.isOn = itemAtIndex.isSelected
        cell.selection_switch.tag = indexPath.row
        cell.selection_switch.addTarget(self, action: #selector(cellSwitchAction(_:)), for: .valueChanged)
        
        cell.selection_switch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
//        notifyCell.bg_view.addShadowEffectWith(color: UIColor.gray, opacity: 0.5, shadowRadius: 1.0, shadowOffset: CGSize.init(width: 0.0, height: 1.0))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row < notifySettingsArr.count - 1  {
            selectionArray[indexPath.row] = !selectionArray[indexPath.row]
            tbleNotifySettings.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 44.0         // Default Height
    }
    
    @objc func cellSwitchAction(_ sender:UIButton) {
        
        navigationBar_view.rightBarBtn.isHidden = false
        navigationBar_view.rightBarImage.isHidden = false
        tableData[sender.tag].isSelected = !tableData[sender.tag].isSelected
    }
}

// MARK: - API Methods

extension GSNotificationSettingsViewController {
    
    fileprivate func updatePreferencesAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.profileEditPreferences
        
        guard tableData.count == 3 else { return }
        
        let parameters = ["preferences": ["pns": tableData[0].isSelected,
                                          "sms": tableData[1].isSelected,
                                          "email": tableData[2].isSelected]] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    let status = responseModel.success ?? false
                    
                    if status {
                        weakSelf.navigationBar_view.rightBarImage.isHidden = true
                        weakSelf.navigationBar_view.rightBarBtn.isHidden = true
                    }
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


extension GSNotificationSettingsViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true
        
        )
    }
    func rightBarBtnPressed(sender: UIButton) {
        updatePreferencesAPI()
    }
}



