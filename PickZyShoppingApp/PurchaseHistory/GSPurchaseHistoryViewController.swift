//
//  GSPurchaseHistory.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/9/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPurchaseHistoryViewController: GSLoggedInBaseViewController {

    @IBOutlet var navigationBar_view: NavigationBarNormal!
    @IBOutlet var purchaseHistory_tableView: UITableView!
    
    let headerHeight:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60.0 : 50.0
    
    var purchaseHistory_array = [New_GSPurchasedListData]()
    
    var selectionsArray = [Bool]()
    var selectedSection = -1
    
    var skipItems = 0
    var limitToLoad = 10
    var isToLoadMore = true
    lazy var refreshController = UIRefreshControl()
    
    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFewIntializers()
        applyColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getPurchaseHistoryList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        purchaseHistory_tableView.backgroundColor = UIColor(hexString: defaultTheme.purchaseHistory_table_BG)
    }
    
    //MARK: User defined methods
    
    func addFewIntializers() {
        
        navigationBar_view.delegate = self
        
        purchaseHistory_tableView.delegate = self
        purchaseHistory_tableView.dataSource = self
        
        purchaseHistory_tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        
        let simpleHeaderNib = UINib.init(nibName: GSString.NibNames.GSPurchaseHistoryTableHeaderView, bundle: nil)
        purchaseHistory_tableView.register(simpleHeaderNib, forHeaderFooterViewReuseIdentifier: GSPurchaseHistoryTableHeaderView.headerIdentifier)
        
        purchaseHistory_tableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(purchaseHistoryRefreshControllerAction(_:)), for: .valueChanged)
        purchaseHistory_tableView.addSubview(refreshController)
    }
    
    // MARK: - UIRefreshController Action Target
    
    @objc private func purchaseHistoryRefreshControllerAction(_ sender:UIRefreshControl) {
        
        if purchaseHistory_array.count > 0 {
            purchaseHistory_array.removeAll()
            purchaseHistory_tableView.reloadData()
        }
        isToLoadMore = true
        getPurchaseHistoryList()
    }
}

// MARK: - API Methods

extension GSPurchaseHistoryViewController {
    
    func getPurchaseHistoryList() {
        
        skipItems = purchaseHistory_array.count
        
        let urlString = APIurl.baseURL + APIurl.subURL.purchaseHistoryList + "skip=\(skipItems)&limit=\(limitToLoad)"
        self.removeInfoLable()
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            DispatchQueue.main.async {
                weakSelf.refreshController.endRefreshing()
            }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(New_GSPurchasedListModel.self, from: responseData)
                    
                    if let unwrappedData = responseModel.data {
//                        let currentlyLoaded = unwrappedData.sorted(by: { (firstItem, secondItem) -> Bool in
//                            return firstItem.date?.compare(secondItem.date ?? "") == .orderedDescending
//                        })
//
//                        weakSelf.purchaseHistory_array.append(contentsOf: currentlyLoaded)
                        
                        weakSelf.purchaseHistory_array.append(contentsOf: unwrappedData)
                        
                        if weakSelf.selectionsArray.count > 0 {
                            weakSelf.selectionsArray.removeAll()
                        }
                        for _ in weakSelf.purchaseHistory_array {
                            weakSelf.selectionsArray.append(false)
                        }
                        
                        if weakSelf.selectedSection >= 0, weakSelf.selectionsArray.count > weakSelf.selectedSection {
                            weakSelf.selectionsArray[weakSelf.selectedSection] = true
                        }
                        weakSelf.purchaseHistory_tableView.reloadData()
                        
                        if weakSelf.purchaseHistory_array.count == 0 {
                            weakSelf.addInfoLableWith("You will see a history of your past orders here")
                        }
                        
                        if (responseModel.data?.count ?? 0) == 0 {
                            weakSelf.isToLoadMore = false
                        }
                        
                    } else {
                        weakSelf.isToLoadMore = false
                    }
                    
                } catch {
                    #if DEBUG
                    print(error)
                    #endif
                    
                    weakSelf.manageTheDataForFailureResponse()
                    weakSelf.addInfoLableWith(error.localizedDescription)
                }
            } else {
                #if DEBUG
                print(error?.localizedDescription ?? GSString.API.unknownError)
                #endif
                
                weakSelf.manageTheDataForFailureResponse()
                weakSelf.addInfoLableWith(error?.localizedDescription ?? GSString.API.unknownError)
            }
            
        }
    }
    
    private func manageTheDataForFailureResponse() {
        if selectionsArray.count > 0 {
            selectionsArray.removeAll()
        }
        if purchaseHistory_array.count > 0 {
            purchaseHistory_array.removeAll()
        }
        
        DispatchQueue.main.async {
            self.purchaseHistory_tableView.reloadData()
        }
    }
}

// MARK: - UITableView Methods

extension GSPurchaseHistoryViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return purchaseHistory_array.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let selectionStatus = selectionsArray[section]
        
        if selectionStatus {
            if let orderDetails_array = purchaseHistory_array[section].orders {
                return orderDetails_array.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cellIdentifier = GSString.CellIdentifier.PurchasedProductsVC_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GSPurchasedProductTableCell else {
            return UITableViewCell()
        }
        
        let theItemAtSection = purchaseHistory_array[indexPath.section]
        if let orderDetails_array = theItemAtSection.orders {
            let orderDetailItem = orderDetails_array[indexPath.row]
            cell.configureTheCell(orderDetailItem)
        }
        
        cell.writeReview_btn.addTarget(self, action: #selector(writeReviewAction(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: GSPurchaseHistoryTableHeaderView.headerIdentifier) as? GSPurchaseHistoryTableHeaderView else {
            return UIView()
        }
        
        let theItemAtSection = purchaseHistory_array[section]
        
        let dateToShow = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: theItemAtSection.date, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
        let timeToShow = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: theItemAtSection.date, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appTimeFormatter)
        
        headerView.title_lbl.text = "Date: \(dateToShow) - \(timeToShow)"
        headerView.sel_btn.tag = section
        headerView.sel_btn.addTarget(self, action: #selector(handleExpandOrClose(_:)), for: .touchUpInside)
        
//        headerView.extra_lbl.text = ""
//        if section == 0 {
//            headerView.extra_lbl.text = "Price"
//        }
//
        let selectionStatus = selectionsArray[section]
        if selectionStatus {
            headerView.accessoryIcon_imgView.image = #imageLiteral(resourceName: "Up_Arrow_blue")
        } else {
            headerView.accessoryIcon_imgView.image = #imageLiteral(resourceName: "Down_Arrow_blue")
        }
        
        if section == purchaseHistory_array.count - 1, isToLoadMore == true {
            getPurchaseHistoryList()
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        let selectionStatus = selectionsArray[section]
        if !selectionStatus {
            return 1.0
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let selectionStatus = selectionsArray[section]
        if selectionStatus { return UIView() }
        let footerLineView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1.0))
        footerLineView.backgroundColor = UIColor(hexString: defaultTheme.trackOrderListVC_Header_ContentBG)
        return footerLineView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let itemAtSection = purchaseHistory_array[indexPath.section]
        guard let orderDetails_array = itemAtSection.orders else { return }
        if orderDetails_array.count <= indexPath.row { return }
        let itemAtIndex = orderDetails_array[indexPath.row]
        selectedSection = indexPath.section
        
        if let productsPurchasedVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSPurchasedProductsVerifyViewController) as? GSPurchasedProductsVerifyViewController {

            productsPurchasedVC.initializeWith(categoryId: itemAtIndex.categoryID, storeId: itemAtIndex.storeID, orderId: itemAtIndex.id)
            
            if let navigator = navigationController {
                navigator.pushViewController(productsPurchasedVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: TableView Added Methods
    
    @objc func handleExpandOrClose(_ button:UIButton) {
        let section = button.tag
        let selectionStatus = selectionsArray[section]
        selectedSection = section
        let isExpanded = selectionStatus
        selectionsArray[section] = !isExpanded
        
        purchaseHistory_tableView.beginUpdates()
        purchaseHistory_tableView.reloadSections([section], with: .automatic)
        purchaseHistory_tableView.endUpdates()
    }
    
    @objc func writeReviewAction(_ sender:UIButton) {
        
        let buttonPosition = sender.convert(CGPoint.zero, to: purchaseHistory_tableView)
        guard let indexPath = self.purchaseHistory_tableView.indexPathForRow(at: buttonPosition) else { return }
        
        let itemAtSection = purchaseHistory_array[indexPath.section]
        guard let orderDetails_array = itemAtSection.orders else { return }
        if orderDetails_array.count <= indexPath.row { return }
        let itemAtIndex = orderDetails_array[indexPath.row]
        
        if let storeFeedbackVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSStoreFeedbackViewController) as? GSStoreFeedbackViewController {
            
            storeFeedbackVC.configureForStoreFeedBack(orderId: itemAtIndex.id ?? "", storeId: itemAtIndex.storeID ?? "", isFromTrackOrder: false, isDeliveredProducts: false)
            navigationController?.pushViewController(storeFeedbackVC, animated: true)
        }
    }
}

// MARK: - NavigationBar Delegate Methods

extension GSPurchaseHistoryViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        addSideMenu()
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
}



