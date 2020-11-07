//
//  GSPromoCodeListViewController.swift
//  Shopor
//
//  Created by Ratheesh on 29/05/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class GSPromoCodeListViewController: GSPaymentViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var cards_tableView: UITableView!
    @IBOutlet weak var promo_txtField: GSBaseTextField!
    @IBOutlet weak var promoBG_view:GSCornerEdgeView!

    var promoList_array = [GSPromoCodeListData]()
    var searchedPromoList_array = [GSPromoCodeListData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
        applyColors()
        
        getPromoCodesList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(promoTextDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: promo_txtField)
    }

    // MARK: - Colors For UI
    private func applyColors() {
        
        view.backgroundColor = UIColor(hexString: defaultTheme.PromoCodeView_bg)
        promoBG_view.layer.borderColor = UIColor(hexString: defaultTheme.PromoCodeView_header_border).cgColor
    }
    
    // MARK: User defined Methods
    private func addFewIntializers() {
        
        navigationBar_view.delegate = self
        cards_tableView.dataSource = self
        cards_tableView.delegate = self
        cards_tableView.tableFooterView = UIView()
        
        navigationBar_view.rightBarBtn.isHidden = true
    }
    
    @objc func promoTextDidChange(_ notification: NSNotification) {
        
        let promoEntered = (promo_txtField.text ?? "").removeEnclosedWhieteSpace()
        
        if promoEntered.count == 0 {
            navigationBar_view.rightBarBtn.isHidden = true
            searchedPromoList_array = promoList_array.filter({ $0.hideFromPublic == false })
            
        } else {
            navigationBar_view.rightBarBtn.isHidden = false
            searchedPromoList_array = promoList_array.filter({ ($0.promoCode ?? "").lowercased().contains(promoEntered.lowercased()) && ($0.hideFromPublic == false) })
        }
    }
}



// MARK: - UITableView Methods
extension GSPromoCodeListViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedPromoList_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.promoCodeTableViewCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSPromoCodeTableViewCell else {
            return UITableViewCell()
        }
        
        let promoCodeAtIndex = searchedPromoList_array[indexPath.row]
        
        cell.promoTitle_lbl.text = "Promo Code"
        cell.storeName_lbl.text = promoCodeAtIndex.promoTitle ?? ""
        cell.promo_lbl.text = promoCodeAtIndex.promoCode ?? ""
        cell.promo_lbl.adjustsFontSizeToFitWidth = true
        
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
        
        var offerType = "NA"
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
        } else if promoCodeAtIndex.minimumPurchaseEnable == false, isPercentage == false {
            
            if applicableForNew != "" {
                cell.validType_lbl.text = "\(applicableForNew)\nMinimum Purchase limit: \(promoCodeAtIndex.minPurchaseObj?.value ?? 0) \(GSConstant.currency_symbol)"
            } else {
                cell.validType_lbl.text = "Minimum Purchase limit: \(promoCodeAtIndex.minPurchaseObj?.value ?? 0) \(GSConstant.currency_symbol)"
            }
        }
                
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        SDWebImageDownloader.shared().setValue(accessToken, forHTTPHeaderField: "Authorization")
        let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
        cell.store_imgView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewPromoCodeStoreImage + (promoCodeAtIndex.storeIcon ?? "") + imgHeight) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
        
        cell.store_imgView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewPromoCodeStoreImage + (promoCodeAtIndex.storeIcon ?? "") + imgHeight), placeholderImage: #imageLiteral(resourceName: "blurImage"), options: .progressiveDownload, progress: nil) { (image, error, _ , _ ) in
            
            if let unwrappedImage = image {
                cell.store_imgView.image = GSCommonHelper.cropToBounds(image: unwrappedImage, width: Double(cell.store_imgView.frame.size.width), height: Double(cell.store_imgView.frame.size.height))
            }
        }
        
        cell.topMost_view.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        
        if promoCodeAtIndex.userCountPerDay == true, promoCodeAtIndex.minimumPurchaseEnable == true {
            cell.topMost_view.backgroundColor = UIColor.clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let promoCodeAtIndex = searchedPromoList_array[indexPath.row]
        
        managePromoSelection(promoCodeAtIndex)
    }
    
    
    fileprivate func managePromoSelection(_ promoCodeAtIndex: GSPromoCodeListData) {
        
        view.endEditing(true)
        
        if promoCodeAtIndex.userCountPerDay == true, promoCodeAtIndex.minimumPurchaseEnable == true {
            let promoCodeId = promoCodeAtIndex.id ?? ""
            promo_txtField.text = promoCodeAtIndex.promoCode ?? ""
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.promoCode, value: promoCodeId)
            //            navigationBar_view.rightBarBtn.isHidden = false
            
            var isCashBackOffer = false
            if let offerTypeObject = promoCodeAtIndex.codeProObj?.offerType, offerTypeObject == 1 {
                // Offer Type = 2   ---> Discount
                //              1   ---> CashBack
                
                isCashBackOffer = true
            }
            let viewControllerArray = navigationController?.viewControllers ?? [UIViewController]()
            for vc in viewControllerArray.reversed() {
                
                if let paymentTypeVC = vc as? GSPaymentTypeViewController {
                    paymentTypeVC.isCashBackOffer = isCashBackOffer
                    break
                }
            }
            
            navigationController?.popViewController(animated: true)
        } else {
            //            CustomAlert.showAlert(title: GSString.AppName, message: "Promo code is not applicable", viewController: self)
        }
    }
}

// MARK: - API Methods

extension GSPromoCodeListViewController {
    
    func getPromoCodesList() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.promoCodeList
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        let params = ["_id"     :   storeCategory_id] as [String : AnyObject]
        
        self.removeInfoLable()
        
        print(params)
        
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSPromoCodeListModel.self, from: responseData)
                    
                    if let promoCodeArray = responseModel.data {
                        weakSelf.promoList_array = promoCodeArray.sorted(by: { (firstItem, secondItem) -> Bool in
                            return ((firstItem.userCountPerDay ?? true) && (firstItem.minimumPurchaseEnable ?? true)) && ((firstItem.userCountPerDay ?? false) || (firstItem.minimumPurchaseEnable ?? false))
                        })
                        
                        weakSelf.searchedPromoList_array = weakSelf.promoList_array.filter({ $0.hideFromPublic == false })
                    }
                    weakSelf.cards_tableView.reloadData()
                    
                } catch {
                    print(error)
//                    weakSelf.addInfoLableWith(error.localizedDescription)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
//                weakSelf.addInfoLableWith(error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }
}

// MARK: - Navigation Bar View Delegate Methods

extension GSPromoCodeListViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        if let promoObject = getPromoObject().0 {
            
            managePromoSelection(promoObject)
            
        } else {
            
            CustomAlert.showAlert(title: getPromoObject().1 ?? "", message: "", viewController: self)
        }
    }
    
    func getPromoObject() -> (GSPromoCodeListData?, String?) {
        
        let promoEntered = promo_txtField.text ?? ""
        
        for promoObject in promoList_array {
            
            let promoId = promoObject.promoCode ?? ""
            
            if promoEntered == promoId, promoObject.userCountPerDay == true, promoObject.minimumPurchaseEnable == true {
                
                return (promoObject, nil)
                
            } else if promoEntered == promoId {
                
                return (nil, "Promo is not applicable for your order")
            }
        }
        
        return (nil, "Invalid promo code")
    }
}



// MARK: - GSPromoCodeListModel
struct GSPromoCodeListModel: Codable {
    let success: Bool?
    let data: [GSPromoCodeListData]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

// MARK: - Datum
struct GSPromoCodeListData: Codable {
    let id, merchantID: String?
    let appliedStoreObj: GSPromoCodeListAppliedStoreObj?
    let promoTitle, promoCode, expiryDate: String?
    let customerType: Int?
    let codeProObj: GSPromoCodeListCodeProObj?
    let minPurchaseObj: GSPromoCodeListMinPurchaseObj?
    let maxUserCountObj: GSPromoCodeListMaxUserCountObj?
    let promoActiveStatus: Int?
    let limitedUsersPerDay, applicableOnlyForNewCustomer, maxLimit: String?
    let userCountPerDay: Bool?
//    let images: [GSPromoCodeListImage]?
    let storeIcon: String?
    let maxUser: Int?
    let diff: Int?
    let minimumPurchaseEnable: Bool?
    let hideFromPublic: Bool?
    
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
    }
}

// MARK: - AppliedStoreObj
struct GSPromoCodeListAppliedStoreObj: Codable {
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
struct GSPromoCodeListCodeProObj: Codable {
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
struct GSPromoCodeListImage: Codable {
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
struct GSPromoCodeListMaxUserCountObj: Codable {
    let type, value: Int?
    let purchaseUserCount: [GSPromoCodeListMaxUserCountPurchaseUserCount]?
    
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
struct GSPromoCodeListMaxUserCountPurchaseUserCount: Codable {
    let count: Int?
    let at: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        count = values.decodeSafely(.count)
        at = values.decodeSafely(.at)
    }
}

// MARK: - MinPurchaseObj
struct GSPromoCodeListMinPurchaseObj: Codable {
    let type, value: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        type = values.decodeSafely(.type)
        value = values.decodeSafely(.value)
    }
}
