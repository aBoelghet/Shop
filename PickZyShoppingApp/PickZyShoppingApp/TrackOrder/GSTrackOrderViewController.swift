//
//  GSTrackOrderListViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/31/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import MapKit

class GSTrackOrderListViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var trackOrderList_tableView:UITableView!
    
    let headerHeight:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60.0 : 50.0
    let footerHeight:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60.0 : 50.0
    
    var selectionsArray = [TrackOrderFooterDef]()
    var selectedRow : Int = -1
    lazy var orderListObj_array = [New_GSTrackOrderListData]()
    lazy var refreshController = UIRefreshControl()
    
    var cancellationRequestPopup_view:GSOrderCancellationPopUpView!
    
    struct TrackOrderFooterDef {
        var isExpanded:Bool
        var isFooterButtonNeeded:Bool
    }
    
    struct OrderCancelDef {
        var isUserCanCancelOrder:Bool
        var isFooterButtonNeeded:Bool
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
        applyColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        trackOrderListAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
    
        trackOrderList_tableView.backgroundColor = UIColor(hexString: defaultTheme.trackOrderListVC_BG)
    }
    
    // MARK: User defined Methods
    
    func addFewIntializers() {
        
        navigationBarView.delegate = self
        navigationBarView.titleLable.text = GSString.NavBarTitle.TrackOrder
        
        trackOrderList_tableView.delegate = self
        trackOrderList_tableView.dataSource = self
        
        trackOrderList_tableView.estimatedRowHeight = 44.0
        trackOrderList_tableView.rowHeight = UITableViewAutomaticDimension
        
        trackOrderList_tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
       
        
        let simpleHeaderNib = UINib.init(nibName: GSString.NibNames.GSTrackOrderListTableHeaderView, bundle: nil)
        trackOrderList_tableView.register(simpleHeaderNib, forHeaderFooterViewReuseIdentifier: GSTrackOrderListTableHeaderView.headerIdentifier)
        trackOrderList_tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let footerNib = UINib(nibName: GSString.NibNames.GSTrackOrderListFooterView, bundle: nil)
        trackOrderList_tableView.register(footerNib, forHeaderFooterViewReuseIdentifier: GSTrackOrderListFooterView.identifier)
        
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(refreshControllerAction(_:)), for: .valueChanged)
        trackOrderList_tableView.addSubview(refreshController)
     }
    
    // MARK: - UIRefreshController Action Target
    
    @objc private func refreshControllerAction(_ sender:UIRefreshControl) {
        trackOrderListAPI()
    }
}

extension GSTrackOrderListViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderListObj_array.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let selectionStatus = selectionsArray[section]
        if !selectionStatus.isExpanded {
            return 0
        }
        let objectAtSection = orderListObj_array[section]

        if let orderDetails_arrar = objectAtSection.orders {
            return orderDetails_arrar.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = GSString.CellIdentifier.TrackOrderVC_rowList_tableCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GSTrackOrderRowListTableCell else {
            return UITableViewCell()
        }
        
        let objectAtSection = orderListObj_array[indexPath.section]

        if let orderDetails_array = objectAtSection.orders {
            cell.configureTheCell(orderDetails: orderDetails_array[indexPath.row])
        }

        cell.trackOrder_btn.tag = indexPath.row
        cell.trackOrder_btn.addTarget(self, action: #selector(trackOrderAction(_:)), for: .touchUpInside)
        
        cell.contact_btn.setTitle("Contact Shop", for: .normal)
        cell.contact_btn.tag = indexPath.row
        
        cell.openInMaps_btn.tag = indexPath.row
        cell.openInMaps_btn.addTarget(self, action: #selector(openInMapsAction(_:)), for: .touchUpInside)
        
        cell.contact_btn.addTarget(self, action: #selector(shopContactNumber(_:)), for: .touchUpInside)
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
        let objectAtSection = orderListObj_array[section]

        let dateSimplfied = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: objectAtSection.date, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
        let timeSimplefied = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: objectAtSection.date, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appTimeFormatter)
        
        headerView.titleLabel.text = "Date: \(dateSimplfied) - \(timeSimplefied)" // + " | " + "Order Id - \(objectAtSection.id?.cOrderID ?? "NA")"
        headerView.sel_btn.tag = section
        headerView.sel_btn.addTarget(self, action: #selector(handleExpandOrClose(_:)), for: .touchUpInside)
        
        let selectionStatus = selectionsArray[section]
        if selectionStatus.isExpanded {
            headerView.accessoryIndicator_imgView.image = #imageLiteral(resourceName: "Up_Arrow_blue")
        } else {
            headerView.accessoryIndicator_imgView.image = #imageLiteral(resourceName: "Down_Arrow_blue")
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        let selectionStatus = selectionsArray[section]
        if selectionStatus.isExpanded && selectionStatus.isFooterButtonNeeded {
            return footerHeight
        }
//        return CGFloat.leastNonzeroMagnitude
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let selectionStatus = selectionsArray[section]
        if !selectionStatus.isExpanded && !selectionStatus.isFooterButtonNeeded {
            
            let clearView = UIView(frame: CGRect(x: 0, y: 0, width: trackOrderList_tableView.frame.size.width, height: 1.0))
            clearView.backgroundColor = UIColor(hexString: defaultTheme.trackOrderListVC_Header_ContentBG)
            return clearView
        }
        
        guard let footer_view = tableView.dequeueReusableHeaderFooterView(withIdentifier: GSTrackOrderListFooterView.identifier) as? GSTrackOrderListFooterView else {
            return UIView()
        }
        
        footer_view.applyColors()
        
        footer_view.cancel_btn.addTarget(self, action: #selector(cancelOrderAction(_:)), for: .touchUpInside)
        footer_view.cancel_btn.tag = section
        
        footer_view.help_btn.addTarget(self, action: #selector(helpButtonAction(_:)), for: .touchUpInside)
        footer_view.help_btn.tag = section
        
        let objectAtSection = orderListObj_array[section]
        let cancelObject = isUserCanCancelTheOrder(objectAtSection: objectAtSection)
        selectionsArray[section].isFooterButtonNeeded = cancelObject.isFooterButtonNeeded
        
        footer_view.cancel_btn.isHidden = true
        footer_view.help_btn.isHidden = true
        
        if cancelObject.isUserCanCancelOrder {
            footer_view.cancel_btn.isHidden = false
            footer_view.help_btn.isHidden = false
        } else {
            footer_view.help_btn.isHidden = false
        }
        return footer_view
    }
    
    fileprivate func isUserCanCancelTheOrder(objectAtSection: New_GSTrackOrderListData) -> OrderCancelDef {
        
        if let orderObject_array = objectAtSection.orders {
            
            for orderDetails in orderObject_array {
                if let orderStatus = orderDetails.status {
                    
                    switch orderStatus {
                    case TrackOrderConstants.NewOrderStatus.Ordered.status,
                         TrackOrderConstants.NewOrderStatus.Accepted.status,
                         TrackOrderConstants.NewOrderStatus.ReadyToShip.status:
                        break
                    case TrackOrderConstants.NewOrderStatus.Rejected.status,
                         TrackOrderConstants.NewOrderStatus.Cancelled.status:
                        return OrderCancelDef(isUserCanCancelOrder: false, isFooterButtonNeeded: false)
//                    case TrackOrderConstants.NewOrderStatus.Packaging:
//                        break
                    case TrackOrderConstants.NewOrderStatus.Shipping.status,
                         TrackOrderConstants.NewOrderStatus.Delivered.status,
                         TrackOrderConstants.NewOrderStatus.Verified.status:
                        return OrderCancelDef(isUserCanCancelOrder: false, isFooterButtonNeeded: true)
                    default:
                        return OrderCancelDef(isUserCanCancelOrder: false, isFooterButtonNeeded: true)
                    }
                }
            }
        }
        
        return OrderCancelDef(isUserCanCancelOrder: true, isFooterButtonNeeded: true)
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let objectAtSection = orderListObj_array[indexPath.section]
        
        
        guard let orderDetails_array = objectAtSection.orders else { return }
        let orderDetailsObj = orderDetails_array[indexPath.row]
        
        if let verifyItemsVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSVerifyItemsViewController) as? GSVerifyItemsViewController {
            
            verifyItemsVC.initializeWith(categoryId: orderDetailsObj.categoryID, storeId: orderDetailsObj.storeID, orderId: orderDetailsObj.id)
            navigationController?.pushViewController(verifyItemsVC, animated: true)
        }
    }
    
    // MARK: TableView Added Methods
    @objc func handleExpandOrClose(_ button:UIButton) {
        let section = button.tag
        let selectionStatus = selectionsArray[section]
        
        let isExpanded = selectionStatus.isExpanded
        selectionsArray[section].isExpanded = !isExpanded
        selectionsArray[section].isFooterButtonNeeded = isUserCanCancelTheOrder(objectAtSection: orderListObj_array[section]).isFooterButtonNeeded
        trackOrderList_tableView.beginUpdates()
        trackOrderList_tableView.reloadSections([section], with: .automatic)
        trackOrderList_tableView.endUpdates()
        selectedRow = section
        if isExpanded {
            selectedRow = -1
        }
    }
    
    @objc func trackOrderAction(_ button:UIButton) {
        
        if let trackInMapVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSTrackOrderMapViewController) as? GSTrackOrderMapViewController {
            
            let buttonPosition = button.convert(CGPoint.zero, to: trackOrderList_tableView)
            guard let indexPath = trackOrderList_tableView.indexPathForRow(at: buttonPosition) else { return }
            let objectAtSection = orderListObj_array[indexPath.section]
            guard let orderDetails_array = objectAtSection.orders else { return }
            let orderDetailsObj = orderDetails_array[indexPath.row]
            
            trackInMapVC.configureWith(categoryId: orderDetailsObj.categoryID, storeId: orderDetailsObj.storeID, orderId: orderDetailsObj.id)
            navigationController?.pushViewController(trackInMapVC, animated: true)
        }
    }

    @objc func shopContactNumber(_ button:UIButton) {
        
        let buttonPosition = button.convert(CGPoint.zero, to: trackOrderList_tableView)
        guard let indexPath = trackOrderList_tableView.indexPathForRow(at: buttonPosition) else { return }
        let objectAtSection = orderListObj_array[indexPath.section]
        guard let orderDetails_array = objectAtSection.orders else { return }
        guard let storeObject = orderDetails_array[indexPath.row].shop else { return }
        guard let mobileObjectItem = storeObject.mobile else { return }
        
        var mobileNumber_array = [String]()
        
        for mobileObject in [mobileObjectItem.primary, mobileObjectItem.secondary] {
            if let mobile = mobileObject?.number, mobile != 0 {
                mobileNumber_array.append("\(mobile)")
            }
        }
        
        if mobileNumber_array.count == 0 { return }

        CustomAlert.showActionSheet(title: GSConstant.AlertMessages.merchantMobileActionSheet_title, message: GSConstant.AlertMessages.callMerchant, cancelTitle: "Cancel", optionArray: mobileNumber_array, sourceView: button, in: self) { btnIndex in
            let selectedNumber = mobileNumber_array[btnIndex]
            guard let number = URL(string: "tel://" + selectedNumber) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(number)
            } else {
                UIApplication.shared.openURL(number)
            }
        }
    }
    
    @objc func openInMapsAction(_ sender: UIButton) {
        
        let buttonPosition = sender.convert(CGPoint.zero, to: trackOrderList_tableView)
        guard let indexPath = trackOrderList_tableView.indexPathForRow(at: buttonPosition) else { return }
        let objectAtSection = orderListObj_array[indexPath.section]
        guard let orderDetails_array = objectAtSection.orders else { return }
        
        let orderDetailsAtIndex = orderDetails_array[indexPath.row]
        guard let shopCoordinates = orderDetailsAtIndex.shop?.location?.coordinates, shopCoordinates.count > 1 else { return }
        
        let long = shopCoordinates[0]
        let latt = shopCoordinates[1]

        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {

            UIApplication.shared.open(URL(string:
                "comgooglemaps://?saddr=&daddr=\(latt),\(long)&directionsmode=driving")!, options: [:], completionHandler: nil)

        } else {
            print("Can't use comgooglemaps://")

            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latt, long)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Store Address"
            mapItem.openInMaps(launchOptions: options)
        }

    }
    
    @objc func cancelOrderAction(_ button:UIButton) {
        
        let objectAtSection = self.orderListObj_array[button.tag]
        
        
        var isUserCanCancel = true
        
        guard let orders = objectAtSection.orders else { return }
        
        for orderItem in orders {
            
            let orderStatus = orderItem.status ?? 0
            let cancelSelectedStage = orderItem.cancelSelectedStage ?? 0
            
            if orderStatus >= cancelSelectedStage {
                isUserCanCancel = false
                break
            }
        }
        
        if isUserCanCancel == false {
            
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.cancelRestriction, viewController: self)
            return
        }
        
        if cancellationRequestPopup_view != nil {
            if cancellationRequestPopup_view.isDescendant(of: self.view) {
                return
            }
            cancellationRequestPopup_view = nil
        }
        
        cancellationRequestPopup_view = GSOrderCancellationPopUpView()
        cancellationRequestPopup_view.delegate = self
        
        var isEscalatedOrder = false
        var orderIdArray = [String]()
        
        if let orders = objectAtSection.orders, orders.count > 0 {
            let oneAndOnlyOrder = orders[0]
            isEscalatedOrder = oneAndOnlyOrder.isEscalatedProduct ?? false
            
            for order in orders {
                let orderId = order.id ?? ""
                orderIdArray.append(orderId)
            }
        }
        
        var isPaidOrder = false
        
        if let paymentType = orders.first?.paymentType, paymentType == 1 {
            isPaidOrder = true
        }
        
        if let isBayfayCashOrder = orders.first?.isBayfayCash, isBayfayCashOrder == 1 {
            isPaidOrder = false
        }
        
        cancellationRequestPopup_view.isPaidOrder = isPaidOrder
        cancellationRequestPopup_view.configureCancellPopupWith(orderIdArray: orderIdArray, isEscalated: isEscalatedOrder)
        
        view.addSubview(cancellationRequestPopup_view)
        cancellationRequestPopup_view.addConstraintsAndShow(on: view)
    }
    
    @objc func helpButtonAction(_ button:UIButton) {
        
        let objectAtSection = self.orderListObj_array[button.tag]
        guard let orders = objectAtSection.orders, orders.count > 0 else { return }
        let firstOrder = orders[0]
        
        if let helpScreen = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSHelpViewController) as? GSHelpViewController {
            
            helpScreen.configureHelpWith(order_root_id: firstOrder.id ?? "", is_combined_help: true, isDeliveredOrVerified: false)
            navigationController?.pushViewController(helpScreen, animated: true)
        }
    }
}

// MARK: - Cancellation Pop up view delegate

extension GSTrackOrderListViewController:GSOrderConcellationPopUpViewDelegate {
    
    func cancelOrderResponse(isCancelled: Bool,message: String) {
        
        CustomAlert.showAlert(title: GSString.AppName, message: message, alertButtonsArray: ["Ok"], viewController: self) { [weak self] _ in
            
            if isCancelled {
                self?.selectedRow = -1
                self?.trackOrderListAPI()
            }
        }
    }
}

// MARK: - API Methods

extension GSTrackOrderListViewController {
    
    func trackOrderListAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.trackOrderList
        
        self.removeInfoLable()
        
        APIHandler.NetworkSetupRequest(method: .get, params: [String:AnyObject](),urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            DispatchQueue.main.async {
                weakSelf.refreshController.endRefreshing()
            }
            
            if weakSelf.orderListObj_array.count > 0 {
                weakSelf.orderListObj_array.removeAll()
                DispatchQueue.main.async {
                    weakSelf.trackOrderList_tableView.reloadData()
                }
            }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(New_GSTrackOrderListModel.self, from: responseData)
                    
                    if let orderList = responseModel.data {
                        weakSelf.orderListObj_array = orderList
                        
                        // Sorting to show recent orders on top
                        weakSelf.orderListObj_array.sort(by: { (firstElement, secondElement) -> Bool in
                            return firstElement.date?.compare(secondElement.date ?? "") == .orderedDescending
                        })
                        
                        if weakSelf.selectionsArray.count > 0 {
                            weakSelf.selectionsArray.removeAll()
                        }
                        
                        for _ in orderList {
                            weakSelf.selectionsArray.append(TrackOrderFooterDef(isExpanded: false, isFooterButtonNeeded: true))
                        }
                        
                        if weakSelf.selectedRow >= 0 && weakSelf.selectionsArray.count > weakSelf.selectedRow  {
                            weakSelf.selectionsArray[weakSelf.selectedRow].isExpanded = true
                            weakSelf.selectionsArray[weakSelf.selectedRow].isFooterButtonNeeded = weakSelf.isUserCanCancelTheOrder(objectAtSection: weakSelf.orderListObj_array[weakSelf.selectedRow]).isFooterButtonNeeded
                        }
                        
                        if weakSelf.orderListObj_array.count == 0 {
                            weakSelf.addInfoLableWith("You will see a current orders here")
                        }
                        
                        weakSelf.trackOrderList_tableView.reloadData()
                    }
                    
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
}

// MARK: - Navigation Bar Delegates
extension GSTrackOrderListViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        addSideMenu()
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
}
