//
//  GSMessagesRootViewController.swift
//  Shopor
//
//  Created by Ratheesh on 04/01/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSMessagesRootViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var messageList_tableView:UITableView!

    let headerHeight:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60.0 : 50.0
    
    var selectionsArray = [Bool]()
    
    var lastSelectedSection:Int?
    
    var messagesList_array = [New_GSMessagesOrderListData]()
    var products_dictionary = [String:GSMessagesProductListData]()
    lazy var refreshController = UIRefreshControl()
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFewIntializers()
        applyColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getMessagesOrderList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        
        messageList_tableView.backgroundColor = UIColor(hexString: defaultTheme.MessageRootVC_BG)
    }
    
    // MARK: User defined Methods
    
    func addFewIntializers() {
        
        navigationBarView.delegate = self
        navigationBarView.titleLable.text = "Messages"
        
        messageList_tableView.delegate = self
        messageList_tableView.dataSource = self
        
        messageList_tableView.estimatedRowHeight = 44.0
        messageList_tableView.rowHeight = UITableViewAutomaticDimension
        
        let separatorInset = ((0.2 * view.frame.size.width) + 20)
        messageList_tableView.separatorInset = UIEdgeInsetsMake(0, separatorInset, 0, 0)
        
        let simpleHeaderNib = UINib.init(nibName: GSString.NibNames.GSTrackOrderListTableHeaderView, bundle: nil)
        messageList_tableView.register(simpleHeaderNib, forHeaderFooterViewReuseIdentifier: GSTrackOrderListTableHeaderView.headerIdentifier)
        messageList_tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(messagesRefreshControllerAction(_:)), for: .valueChanged)
        messageList_tableView.addSubview(refreshController)
        
    }
    
    // MARK: - UIRefreshController Action Target
    
    @objc private func messagesRefreshControllerAction(_ sender:UIRefreshControl) {
        getMessagesOrderList()
    }
}

// MARK: - API Methods

extension GSMessagesRootViewController {
    
    func getMessagesOrderList() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.messages_orderList
        
        self.removeInfoLable()
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            DispatchQueue.main.async {
                weakSelf.refreshController.endRefreshing()
            }
            
            if weakSelf.messagesList_array.count > 0 {
                weakSelf.messagesList_array.removeAll()
                DispatchQueue.main.async {
                    weakSelf.messageList_tableView.reloadData()
                }
            }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(New_GSMessagesOrderListModel.self, from: responseData)
                    
                    if weakSelf.selectionsArray.count > 0 {
                        weakSelf.selectionsArray.removeAll()
                    }
                    
                    if weakSelf.products_dictionary.count > 0 {
                        weakSelf.products_dictionary.removeAll()
                    }
                    
                    if let unwrappedData = responseModel.data {
                        weakSelf.messagesList_array = unwrappedData
                        // Sorting to show recent orders on top
                        weakSelf.messagesList_array.sort(by: { (firstElement, secondElement) -> Bool in
                            return firstElement.date?.compare(secondElement.date ?? "") == .orderedDescending
                        })
                    }
                    for _ in weakSelf.messagesList_array {
                        weakSelf.selectionsArray.append(false)
                    }
                    
                    if let unwrappedLastSelection = weakSelf.lastSelectedSection, unwrappedLastSelection >= 0, unwrappedLastSelection < weakSelf.selectionsArray.count {
                        weakSelf.selectionsArray[unwrappedLastSelection] = true
                        
                        let itemAtSection = weakSelf.messagesList_array[unwrappedLastSelection]
                        weakSelf.getOrderProductListAPI(categoryId: itemAtSection.categoryID, storeId: itemAtSection.storeID, orderId: itemAtSection.id)
                    }
                    
                    if weakSelf.messagesList_array.count == 0 {
                        weakSelf.addInfoLableWith("No records found")
                    }
                    
                    weakSelf.messageList_tableView.reloadData()
                    
                } catch {
                    print(error)
                    weakSelf.addInfoLableWith(error.localizedDescription)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                weakSelf.addInfoLableWith(error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }
    
    fileprivate func getOrderProductListAPI(categoryId:String?, storeId:String?, orderId:String?) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.messages_orderProductList
        
        let parameters = [ "category_id": categoryId,
                           "shop_id": storeId,
                           "order_id": orderId] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }

            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSMessagesProductListModel.self, from: responseData)
                    
                    if let productsData = responseModel.data, let unwrappedOrderId = orderId {
                        weakSelf.products_dictionary[unwrappedOrderId] = productsData
                        weakSelf.messageList_tableView.reloadData()
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
}

// MARK: - UITableView Methods

extension GSMessagesRootViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messagesList_array.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let selectionStatus = selectionsArray[section]
        let messageObject = messagesList_array[section]
        
        if selectionStatus, let orderId = messageObject.id , let productsArray = products_dictionary[orderId]?.products {
            return productsArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = GSString.CellIdentifier.rootMessageCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GSMessagesRootTableCell else {
            return UITableViewCell()
        }

        let messageObject = messagesList_array[indexPath.section]
        
        if let orderId = messageObject.id , let productsArray = products_dictionary[orderId]?.products, indexPath.row < productsArray.count {
            cell.configureTheCell(product: productsArray[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: GSTrackOrderListTableHeaderView.headerIdentifier) as? GSTrackOrderListTableHeaderView else {
            return UIView()
        }
        
        headerView.applyColorsForUI()
        
        let selectionStatus = selectionsArray[section]
        if selectionStatus {
            headerView.accessoryIndicator_imgView.image = #imageLiteral(resourceName: "Up_Arrow_blue")
        } else {
            headerView.accessoryIndicator_imgView.image = #imageLiteral(resourceName: "Down_Arrow_blue")
        }
        
        let item = messagesList_array[section]
        let order_id = item.orderID ?? ""
        let orderedDate = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: item.date, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
        
        headerView.titleLabel.text = "Order id: \(order_id) | \(orderedDate)"
        
        headerView.sel_btn.tag = section
        headerView.sel_btn.addTarget(self, action: #selector(handleExpandOrClose(_:)), for: .touchUpInside)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let messageObject = messagesList_array[indexPath.section]
        lastSelectedSection = indexPath.section
        
        if let orderId = messageObject.id , let productsArray = products_dictionary[orderId]?.products, indexPath.row < productsArray.count {
            let productItem = productsArray[indexPath.row]
            if let messagesVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSMessagesViewController) as? GSMessagesViewController {
                messagesVC.configureWith(categoryId: messageObject.categoryID ?? "", idOfTheOrder: messageObject.id ?? "", storeId: messageObject.storeID ?? "", productId: productItem.id ?? "")
                navigationController?.pushViewController(messagesVC, animated: true)
            }
        }
    }
    
    // MARK: TableView Added Methods
    @objc func handleExpandOrClose(_ button:UIButton) {
        let section = button.tag
        let selectionStatus = selectionsArray[section]
        
        let isExpanded = selectionStatus
        selectionsArray[section] = !isExpanded
        
        let messageObject = messagesList_array[section]
        
        if let orderId = messageObject.id , products_dictionary[orderId] == nil {
            getOrderProductListAPI(categoryId: messageObject.categoryID, storeId: messageObject.storeID, orderId: messageObject.id)
        }
        
        messageList_tableView.beginUpdates()
        messageList_tableView.reloadSections([section], with: .automatic)
        messageList_tableView.endUpdates()
    }
    
}


// MARK: - Navigation Bar Delegates
extension GSMessagesRootViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        addSideMenu()
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
}
