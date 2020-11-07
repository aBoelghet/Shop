//
//  GSNotificationsViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh Mac Mini on 04/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSNotificationsViewController: GSLoggedInBaseViewController {
    
    let updateCellRowHeight : CGFloat = 60.0
    let discountCellRowHeight : CGFloat = 100.0
    
    @IBOutlet weak var notifications_tableView: UITableView!
    @IBOutlet weak var navigationBar: NotificationNavigationBar!
    
    var currentSelectedSegmentIdx = 0
    var isFromMenu = false
    
    var updateNotifications_array = [GSNotificationListData]()
    var offerNotifications_array = [GSNotificationOffersListData]()
    
    var allNotifications_array = [Any]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        addFewInitializers()
//        addInfoLableWith("Upcoming feature")
        updateNotificationAPI()
        offerNotificationsAPI()
    }
    
    // MARK: - User Defined Methods
    
    private func addFewInitializers() {
        
        navigationBar.delegate = self
        notifications_tableView.tableFooterView = UIView()
        
        if notificationCount.value > 0 {
            navigationBar.notificationIconButton.badgeString = "\(notificationCount.value)"
        }
        
        if isFromMenu {
            navigationBar.leftBarImage.image = #imageLiteral(resourceName: "SideMenu_icon")
        } else {
            navigationBar.leftBarImage.image = #imageLiteral(resourceName: "Back_arrow")
        }
    }
    
}

// MARK: - API Methods

extension GSNotificationsViewController {
    
    fileprivate func updateNotificationAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.notification_updates
        
        APIHandler.NetworkSetupRequest(method: .post, params: nil,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSNotificationListModel.self, from: responseData)
                    
                    if let notifications = responseModel.data {
                    
                        weakSelf.updateNotifications_array = notifications
                    }
                    
                    weakSelf.notifications_tableView.reloadData()
                    
                    
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
    
    fileprivate func offerNotificationsAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.notification_offers
        
        guard let notificationStores = SharedPersistence.getValue(key: UserDefaultKeys.storesForNotification) as? [String] else { return }
        
        let parameters = ["stores" : notificationStores] as [String: AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSNotificationOffersListModel.self, from: responseData)
                    
                    if let notifications = responseModel.data {
                        
                        weakSelf.offerNotifications_array = notifications.sorted(by: { (first, second) -> Bool in
                            return first.expiryDate?.compare(second.expiryDate ?? "") == ComparisonResult.orderedAscending
                        })
                        if notifications.count > 0 {
                            weakSelf.navigationBar.notificationIconButton.badgeString = "\(notifications.count)"
                        }
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
    
    private func resetAllNotifications() {
        
        if allNotifications_array.count > 0 {
            allNotifications_array.removeAll()
        }
        
        if offerNotifications_array.count > 0 {
            allNotifications_array.append(contentsOf: offerNotifications_array)
        }
        
        if updateNotifications_array.count > 0 {
            allNotifications_array.append(updateNotifications_array)
        }
        
        if currentSelectedSegmentIdx == 0 {
            notifications_tableView.reloadData()
        }
    }
}


extension GSNotificationsViewController : NavigationWithSegmentDelegate {
    
    func rightBarBtnPressed(sender: UIButton) {
        // Nothing to do with this delegate method
    }
    
    
    func leftBarBtnPressed(sender: UIButton) {
        
        if isFromMenu {
            addSideMenu()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func segmentPressed(index: Int) {
        currentSelectedSegmentIdx = index
        self.notifications_tableView.reloadData()

    }
}

extension GSNotificationsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch currentSelectedSegmentIdx {
        case 0:
            return updateNotifications_array.count
        case 1:
            return offerNotifications_array.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentSelectedSegmentIdx {
        case 0:
             return updateNotifications(at: indexPath, notification: updateNotifications_array[indexPath.row])
        case 1:
             return discountNotifications(at: indexPath, notification: offerNotifications_array[indexPath.row])
        default:
            return UITableViewCell()
        }
    }
    
    fileprivate func discountNotifications (at indexPath: IndexPath, notification: GSNotificationOffersListData) ->  GSPromoCodeTableViewCell {
        
        let identifier = GSString.CellIdentifier.promoCodeTableViewCell
        guard let cell = self.notifications_tableView.dequeueReusableCell(withIdentifier: identifier) as? GSPromoCodeTableViewCell else {
            return UITableViewCell() as! GSPromoCodeTableViewCell
        }
        
        let promoCodeAtIndex = notification
        
        cell.promoTitle_lbl.text = "Promo Code"
        cell.storeName_lbl.text = promoCodeAtIndex.promoTitle ?? ""
        cell.promo_lbl.text = promoCodeAtIndex.promoCode ?? ""
        
        cell.promoExpiry_lbl.text = "Expiry on: " + GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: promoCodeAtIndex.expiryDate, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
        
        cell.limitType_lbl.isHidden = false
        let maxLimit = promoCodeAtIndex.maxLimit ?? ""
        let priceLimit = promoCodeAtIndex.codeProObj?.priceLimit ?? 0
        
        if maxLimit != "", priceLimit != 0 {
            cell.limitType_lbl.text = maxLimit + " \(priceLimit) \(GSConstant.currency_symbol)"
        }
        
        if let limitedUsers = promoCodeAtIndex.limitedUsersPerDay, limitedUsers != "" {
            
            if maxLimit != "", priceLimit != 0 {
                cell.limitType_lbl.text = maxLimit + " \(priceLimit) \(GSConstant.currency_symbol)\n\(limitedUsers)"
            } else {
                cell.limitType_lbl.text = limitedUsers
            }
        }
        
        var offerType = ""//"NA"
        if let offerTypeObject = promoCodeAtIndex.codeProObj?.offerType {
            // Offer Type = 2   ---> Discount
            //              1   ---> CashBack
            
            if offerTypeObject == 2 {
                offerType = "Discount"
            } else {
                offerType = "Cashback"
            }
        }
        cell.promoType_lbl.text = offerType
        
        var offerOrValue = ""
        var isPercentage = false
        if let offerOrValueType = promoCodeAtIndex.codeProObj?.valueType {
            // Offer Or Value   =   1   ---> Price
            //                      2   ---> Percentage
            
            if offerOrValueType == 1 {
                offerOrValue = "Value: \(promoCodeAtIndex.codeProObj?.codeValue ?? 0) \(GSConstant.currency_symbol)"
            } else {
                offerOrValue = "Offer: \(promoCodeAtIndex.codeProObj?.codeValue ?? 0) %"
                isPercentage = true
            }
        }
        cell.promoTitle_lbl.text = offerOrValue
        
        cell.validType_lbl.text = ""
        
        let applicableForNew = promoCodeAtIndex.applicableOnlyForNewCustomer ?? ""
        cell.validType_lbl.text = applicableForNew
        
        if promoCodeAtIndex.minimumPurchaseEnable == false, isPercentage == true {
            
            if applicableForNew != "" {
                cell.validType_lbl.text = "\(applicableForNew)\nMinimum Purchase limit: \(promoCodeAtIndex.minPurchaseObj?.value ?? 0) \(GSConstant.currency_symbol)"
            } else {
                cell.validType_lbl.text = "Minimum Purchase limit: \(promoCodeAtIndex.minPurchaseObj?.value ?? 0) \(GSConstant.currency_symbol)"
            }
        }  else if promoCodeAtIndex.minimumPurchaseEnable == false, isPercentage == false {
            
            if applicableForNew != "" {
                cell.validType_lbl.text = "\(applicableForNew)\nMinimum Purchase limit: \(promoCodeAtIndex.minPurchaseObj?.value ?? 0) \(GSConstant.currency_symbol)"
            } else {
                cell.validType_lbl.text = "Minimum Purchase limit: \(promoCodeAtIndex.minPurchaseObj?.value ?? 0) \(GSConstant.currency_symbol)"
            }
        }
        
        let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
        cell.store_imgView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewPromoCodeStoreImage + (promoCodeAtIndex.shopIcon ?? "") + imgHeight) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
        
        cell.store_imgView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewPromoCodeStoreImage + (promoCodeAtIndex.shopIcon ?? "") + imgHeight), placeholderImage: #imageLiteral(resourceName: "blurImage"), options: .progressiveLoad, progress: nil) { (image, error, _ , _ ) in
            
            if let unwrappedImage = image {
                cell.store_imgView.image = GSCommonHelper.cropToBounds(image: unwrappedImage, width: Double(cell.store_imgView.frame.size.width), height: Double(cell.store_imgView.frame.size.height))
            }
        }
        
        cell.topMost_view.backgroundColor = UIColor.clear
        
        if promoCodeAtIndex.userCountPerDay == true, promoCodeAtIndex.minimumPurchaseEnable == true {
            cell.topMost_view.backgroundColor = UIColor.clear
        }
        
        return cell
    }
    
    fileprivate func updateNotifications (at indexPath: IndexPath, notification: GSNotificationListData) ->  GSNotificationsUpdatesTableViewCell {
        
        let cellIdentifier = GSString.CellIdentifier.NotificationVC_update_tableCell
        
        guard let cell = self.notifications_tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GSNotificationsUpdatesTableViewCell else {
            return GSNotificationsUpdatesTableViewCell()
        }
        
        cell.updateText_lbl.text = "\(notification.message ?? "")"
        cell.icon_imageView.image = UIImage(named: "notifi_logoIcon")
        let simpleFromTime = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: "\(notification.createdOn ?? "")", inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", reqFormat: GSConstant.appDateTimeFormatter)
        cell.Ad_ExpiryLabel.text = simpleFromTime
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch currentSelectedSegmentIdx {
        case 0:
            return UITableViewAutomaticDimension
        case 1:
            return UITableViewAutomaticDimension
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var shopId = ""
        switch currentSelectedSegmentIdx {
        case 0:
            shopId = updateNotifications_array[indexPath.row].id ?? ""
        case 1:
            shopId = offerNotifications_array[indexPath.row].storeID ?? ""
        default:
            shopId = ""
        }
        
        let topVC = GSTopViewController.topViewController()
        topVC.navigationController?.popToRootViewController(animated: false)
        if let shopVC = GSTopViewController.topViewController() as? GSShopsViewController {
            shopVC.urlSchemeToShopId = shopId
            shopVC.needToShowURLSchemePop = true
            self.redirectToProductlistPage(stroreId: shopId)
        }
    }
    func redirectToProductlistPage(stroreId:String) {
        
    }
}

// MARK: - GSNotificationListModel
struct GSNotificationListModel: Codable {
    let success: Bool?
    let data: [GSNotificationListData]?
}

// MARK: - Datum
struct GSNotificationListData: Codable {
    let id, userID: String?
    let msgType: Int?
    let messageTitle, message: String?
    let msgBody: GSNotificationListDataMsg?
    let isRead: Bool?
    let createdOn: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "user_id"
        case msgType = "msg_type"
        case messageTitle = "message_title"
        case message
        case msgBody = "msg_body"
        case isRead = "is_read"
        case createdOn = "created_on"
    }
}

// MARK: - MsgBody
struct GSNotificationListDataMsg: Codable {
    let type: Int?
    let body: GSNotificationListDataMsgBody?
}

// MARK: - Body
struct GSNotificationListDataMsgBody: Codable {
    let categoryID, shopID, orderID: String?
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case shopID = "shop_id"
        case orderID = "order_id"
    }
}

// MARK: - GSNotificationOffersListModel
struct GSNotificationOffersListModel: Codable {
    let success: Bool?
    let count: Int?
    let data: [GSNotificationOffersListData]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
        count = values.decodeSafely(.count)
        
    }
}

// MARK: - Datum
struct GSNotificationOffersListData: Codable {
    let id, merchantID: String?
    let appliedStoreObj: GSNotificationAppliedStoreObj?
    let promoTitle, promoCode, expiryDate: String?
    let customerType: Int?
    let codeProObj: CodeProObj?
    let minPurchaseObj: GSNotificationMinPurchaseObj?
    let maxUserCountObj: GSNotificationMaxUserCountObj?
    let promoActiveStatus: Int?
    let limitedUsersPerDay, applicableOnlyForNewCustomer, maxLimit: String?
    let userCountPerDay: Bool?
    //    let images: [GSNotificationListImage]?
    let storeIcon: String?
    let maxUser: Int?
    let diff: Int?
    let minimumPurchaseEnable: Bool?
    let hideFromPublic: Bool?
    let categoryID, shopName, shopIcon, storeID: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case merchantID = "merchant_id"
        case appliedStoreObj = "applied_store_obj"
        case promoTitle = "promo_title"
        case promoCode = "promo_code"
        case expiryDate = "expiry_date"
        case customerType = "customer_type"
        case codeProObj = "code_pro_obj"
        case minPurchaseObj = "min_purchase_obj"
        case maxUserCountObj = "max_user_count_obj"
        case promoActiveStatus = "promo_active_status"
        case limitedUsersPerDay = "limited_users_per_day"
        case applicableOnlyForNewCustomer = "applicable_only_for_new_customer"
        case maxLimit = "max_limit"
        case userCountPerDay = "user_count_per_day"
        //        case images
        case storeIcon = "store_icon"
        case maxUser = "max_user"
        case diff
        case minimumPurchaseEnable = "min_purchase_enable"
        case hideFromPublic = "hide_from_public"
        case shopName = "shop_name"
        case shopIcon = "shop_icon"
        case storeID = "store_id"
        case categoryID = "category_id"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = values.decodeSafely(.id)
        merchantID = values.decodeSafely(.merchantID)
        appliedStoreObj = values.decodeSafely(.appliedStoreObj)
        promoTitle = values.decodeSafely(.promoTitle)
        promoCode = values.decodeSafely(.promoCode)
        expiryDate = values.decodeSafely(.expiryDate)
        customerType = values.decodeSafely(.customerType)
        codeProObj = values.decodeSafely(.codeProObj)
        minPurchaseObj = values.decodeSafely(.minPurchaseObj)
        maxUserCountObj = values.decodeSafely(.maxUserCountObj)
        promoActiveStatus = values.decodeSafely(.promoActiveStatus)
        limitedUsersPerDay = values.decodeSafely(.limitedUsersPerDay)
        applicableOnlyForNewCustomer = values.decodeSafely(.applicableOnlyForNewCustomer)
        maxLimit = values.decodeSafely(.maxLimit)
        userCountPerDay = values.decodeSafely(.userCountPerDay)
        //        images = values.decodeSafely(.images)
        storeIcon = values.decodeSafely(.storeIcon)
        maxUser = values.decodeSafely(.maxUser)
        diff = values.decodeSafely(.diff)
        minimumPurchaseEnable = values.decodeSafely(.minimumPurchaseEnable)
        hideFromPublic = values.decodeSafely(.hideFromPublic)
        shopName = values.decodeSafely(.shopName)
        shopIcon = values.decodeSafely(.shopIcon)
        storeID = values.decodeSafely(.storeID)
        categoryID = values.decodeSafely(.categoryID)
        
    }
}

// MARK: - AppliedStoreObj
struct GSNotificationAppliedStoreObj: Codable {
    let storeType: Int?
    let storeID: String?
    
    enum CodingKeys: String, CodingKey {
        case storeType = "store_type"
        case storeID = "store_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        storeType = values.decodeSafely(.storeType)
        storeID = values.decodeSafely(.storeID)
    }
}

// MARK: - CodeProObj
struct CodeProObj: Codable {
    let valueType, codeValue, offerType, priceLimit: Int?
    
    enum CodingKeys: String, CodingKey {
        case valueType = "value_type"
        case codeValue = "code_value"
        case offerType = "offer_type"
        case priceLimit = "price_limit"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        valueType = values.decodeSafely(.valueType)
        codeValue = values.decodeSafely(.codeValue)
        offerType = values.decodeSafely(.offerType)
        priceLimit = values.decodeSafely(.priceLimit)
    }
}

// MARK: - Image
struct GSNotificationListImage: Codable {
    let keyid, name: String?
    let width, height: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        keyid = values.decodeSafely(.keyid)
        name = values.decodeSafely(.name)
        width = values.decodeSafely(.width)
        height = values.decodeSafely(.height)
    }
}

// MARK: - MaxUserCountObj
struct GSNotificationMaxUserCountObj: Codable {
    let type, value: Int?
    let purchaseUserCount: [GSNotificationMaxUserCountPurchaseUserCount]?
    
    enum CodingKeys: String, CodingKey {
        case type, value
        case purchaseUserCount = "purchase_user_count"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        type = values.decodeSafely(.type)
        value = values.decodeSafely(.value)
        purchaseUserCount = values.decodeSafely(.purchaseUserCount)
    }
}

// MARK: - PurchaseUserCount
struct GSNotificationMaxUserCountPurchaseUserCount: Codable {
    let count: Int?
    let at: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        count = values.decodeSafely(.count)
        at = values.decodeSafely(.at)
    }
}

// MARK: - MinPurchaseObj
struct GSNotificationMinPurchaseObj: Codable {
    let type, value: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        type = values.decodeSafely(.type)
        value = values.decodeSafely(.value)
    }
}
