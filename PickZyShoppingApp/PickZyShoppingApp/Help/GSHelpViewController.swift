//
//  GSHelpViewController.swift
//  Shopor
//
//  Created by Ratheesh on 05/03/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSHelpViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var help_tableView:UITableView!
    
    var orderRootId = ""
    var isCombinedHelp = false
    var isDeliveredOrVerified = false
    
    var helpData: GSHelpListData?
    var tableData_array = [GSHelpUIModel]()
    
    // MARK: - Help UI Model
    
    struct GSHelpUIModel {
        let id:String
        let displayName:String
        let type:HelpUIType
        let buzzUp:Bool?
        let dailingCode:Int?
        let number:Int64?
    }
    
    enum HelpUIType {
        case normal
        case store
        case help
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyColors()
        addFewIntializers()
        helpListAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Configuring With Data
    
    func configureHelpWith(order_root_id:String, is_combined_help:Bool, isDeliveredOrVerified:Bool) {
        
        self.orderRootId = order_root_id
        self.isCombinedHelp = is_combined_help
        self.isDeliveredOrVerified = isDeliveredOrVerified
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        
        help_tableView.backgroundColor = UIColor(hexString: defaultTheme.paymentOpt_table_BG)
    }
    
    // MARK: User defined Methods
    
    private func addFewIntializers() {
        navigationBar_view.delegate = self
        navigationBar_view.titleText = "Help"
        
        help_tableView.dataSource = self
        help_tableView.delegate = self
        
        help_tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableView Methods

extension GSHelpViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData_array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemAtIndex = tableData_array[indexPath.row]
        
        switch itemAtIndex.type {
        case .normal:
            return helpNormalCell(at: indexPath)
        case .help, .store:
            return helpContactCell(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let itemAtIndex = tableData_array[indexPath.row]
        
        if itemAtIndex.type == .help || itemAtIndex.type == .store {
            return
        }
        
        if let helpDetailsVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSHelpDetailViewController) as? GSHelpDetailViewController {

            helpDetailsVC.configureHelpDetailsWith(order_root_id: orderRootId, title_id: itemAtIndex.id, is_buzz_enabled: itemAtIndex.buzzUp ?? false, title_str: itemAtIndex.displayName)
            navigationController?.pushViewController(helpDetailsVC, animated: true)
        }
    }
    
    // MARK: - Creating Cells
    
    private func helpNormalCell(at indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = help_tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.helpScreenTableViewCell) as? GSHelpNormalTableViewCell else {
            return UITableViewCell()
        }
        
        let itemAtIndex = tableData_array[indexPath.row]
        
        cell.type_lbl.text = itemAtIndex.displayName
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    private func helpContactCell(at indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = help_tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.helpContactCell) as? GSHelpContactTableCell else {
            return UITableViewCell()
        }
        
        let itemAtIndex = tableData_array[indexPath.row]
        cell.title_lbl.text = itemAtIndex.displayName
        
        cell.contact_btn.tag = indexPath.row
        cell.contact_btn.addTarget(self, action: #selector(cellContact_action(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - Cell Actions
    
    @objc private func cellContact_action(_ sender:UIButton) {
        
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

// MARK: - API Methods

extension GSHelpViewController {
    
    fileprivate func helpListAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.orderHelp_titles + orderRootId
        
        if tableData_array.count > 0 {
            tableData_array.removeAll()
        }
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSHelpListModel.self, from: responseData)
                    
                    if let titlesArray = responseModel.data?.titles {
                        
                        for index in 0..<titlesArray.count {
                            
                            let title_item = titlesArray[index]
                            
                            if weakSelf.isCombinedHelp == true, title_item.buzzUp != nil {
                                continue
                            }
                            
                            if weakSelf.isDeliveredOrVerified == true, index == 0 || index == 1 {
                                continue
                            }
                            
                            weakSelf.tableData_array.append(GSHelpUIModel(id: title_item.id ?? "", displayName: title_item.displayName ?? "", type: .normal, buzzUp: title_item.buzzUp, dailingCode: nil, number: nil))
                        }
                    }
                    
                    if weakSelf.isCombinedHelp == false, let shopNumber = responseModel.data?.shop?.number, let dailingCode = responseModel.data?.shop?.dialingCode {
                        weakSelf.tableData_array.append(GSHelpUIModel(id: "", displayName: "Contact Shop:", type: .store, buzzUp: nil, dailingCode: dailingCode, number: shopNumber))
                    }
                    
                    if let helpNumber = responseModel.data?.help?.number, let dailingCode = responseModel.data?.help?.dialingCode {
                        weakSelf.tableData_array.append(GSHelpUIModel(id: "", displayName: "Contact \(GSString.AppName):", type: .help, buzzUp: nil, dailingCode: dailingCode, number: helpNumber))
                    }
                    
                    weakSelf.help_tableView.reloadData()
                    
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

extension GSHelpViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender:UIButton) {
    }
}
