//
//  GSOrderConfirmationViewController.swift
//  Shopor
//
//  Created by Ratheesh on 16/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import PayU_coreSDK_Swift

class GSOrderConfirmationViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var deliveryTimeKey_lbl: GSBaseLabel!
    @IBOutlet weak var deliveryTime_lbl: GSBaseLabel!
    @IBOutlet weak var deliveryBy_lbl: GSBaseLabel!
    @IBOutlet weak var address_tableView: UITableView!
    @IBOutlet weak var deliveryMethodHeaderBG_view: UIView!
    @IBOutlet weak var confirmDeliveryAddressHeaderBG_view: UIView!
    @IBOutlet weak var line_view: UIView!
    @IBOutlet weak var confirmAddress_btn: GSBaseButton!
    @IBOutlet weak var otherLocationDeliveryKey_lbl: GSBaseLabel!
    @IBOutlet weak var otherLocationDeliveryValue_lbl: GSBaseLabel!
    @IBOutlet weak var otherLocationDeliveryBG_view: UIView!
    @IBOutlet weak var localDeliveryBG_view: UIView!
    
    @IBOutlet weak var confirmDeliveryLocationHeaderTitle_lbl:GSBaseLabel!
    @IBOutlet weak var merchantDeliveryPreference_lbl:GSBaseLabel!
    
    var address_array = [OrderConfirmationAddressObject]()
    var extra_specifiedAddressArray = [String]()
    
    var changeableAddress = ""
    var unchangebleAddress = ""
    var zipCode = ""
    var landmark = ""
    
    var paymentParamHelper  = GSPaymentParametersHelper()
    var paymentParams : PayUModelPaymentParams? = nil
    
    let createRequest = PayUCreateRequest()
    
    var paymentParameterHelper:GSPaymentParametersHelper?
    
    var placeOrderHelper:GSPlaceOrderHelper?
    //--
    var purchaseAmountToPay : String = "0"
    //--
    
    var editAddressPopUp:GSEditAddressPopUpView?
    var picker:GSCustomPickerView?
    var simpleDatePickerView : GSCustomDatePicker?
    var prefferedDeliveryTime:String = ""
    var prefferedDeliveryDate:String = ""
    var selectedDate:Date!
    
    let data_array = ["7 AM - 10 AM", "10 AM - 1 PM", "1 PM - 4 PM", "4 PM - 7 PM", "7 PM - 10 PM"]
    
    var isFooterCheckBoxChecked = false
    var numberOfSections = 1
    
    var attachedImage:UIImage?
    var deliveryNotes = ""
    var isDeliveryNotesEnabled = false
    var isUploadFeatureEnabled = false
    
    struct OrderConfirmationAddressObject {
        var changeableAddress:String
        var unChangebleAddress:String
        var zipCode:String
        var landMark:String
    }
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyColors()
        addFewIntializers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        paymentParamHelper.setPaymentParams(isGoingToOrder: true, isBayFayCash: false, transactionAmount: String(purchaseAmountToPay)) { (parameters, error) in
            
            if error == nil {
                self.paymentParams = parameters!
            } else {
                if self.checkPaymentParam(error: error?.localizedDescription ?? GSString.API.unknownError) {
                    return
                }
            }
        }
        //paymentParams = paymentParamHelper.setPaymentParams(selfObject: self, isGoingToOrder:true, transactionAmount: String(purchaseAmountToPay))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkPaymentParam(error:String) -> Bool {
        
        if paymentParams == nil {
            
            CustomAlert.showAlert(title: "Error", message: error, alertButtonsArray: ["Cancel","Retry"], isLastButtonDestructive: false, viewController: self) { btnIndex in
                
                if btnIndex == 1 {
                    self.viewWillAppear(false)
                }
            }
            return true
        }
        return false
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        
        for header in [deliveryMethodHeaderBG_view,confirmDeliveryAddressHeaderBG_view] {
            header?.backgroundColor = UIColor(hexString: defaultTheme.OrderAddressConfirmationVC_header_bg)
        }
        for lbl in [deliveryTimeKey_lbl,deliveryTime_lbl,deliveryBy_lbl, otherLocationDeliveryKey_lbl, otherLocationDeliveryValue_lbl] {
            lbl?.textColor = UIColor(hexString: defaultTheme.OrderAddressConfirmationVC_normal_text)
        }
        confirmAddress_btn.setTitleColor(UIColor(hexString: defaultTheme.OrderPlacedVC_trackOrder_Btn_title), for: .normal)
        confirmAddress_btn.backgroundColor = UIColor(hexString: defaultTheme.cart_MakePayment_BG)
        confirmAddress_btn.layer.borderColor = UIColor(hexString: defaultTheme.OrderAddressConfirmationVC_confirmAddressBtn_border).cgColor
    }
    
    // MARK: User defined Methods
    private func addFewIntializers() {
        
        navigationBar_view.delegate = self
        address_tableView.dataSource = self
        address_tableView.delegate = self
        
        let footerNib = UINib(nibName: GSString.NibNames.GSOrderConfirmationPreferenceTimeFooterView, bundle: nil)
        address_tableView.register(footerNib, forHeaderFooterViewReuseIdentifier: GSOrderConfirmationPreferenceTimeFooterView.identifier)
        
        address_tableView.estimatedSectionFooterHeight = 44.0
        address_tableView.sectionFooterHeight = UITableViewAutomaticDimension
        
        deliveryBy_lbl.text = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryTypeDisplayName) as? String ?? "Delivery by Shop"
        address_tableView.tableFooterView = UIView()
        
        let minimumDeliveryDate = minimumDateForDeliveryDate()
        selectedDate = minimumDeliveryDate
        prefferedDeliveryDate = convertDateTimeRequiredFormat(minimumDeliveryDate)
        prefferedDeliveryTime = timeSlots_array().first ?? ""
        
        // Changes for delivery selections
        
        let selectedDeliveryType = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryType) as? Int ?? 1
        
        numberOfSections = 1
        unchangebleAddress = (SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_unchangeable_address) as? String ?? "")
        zipCode = (SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_zipCode) as? String ?? "")
        changeableAddress = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_changeable) as? String ?? ""
        landmark = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_landMark) as? String ?? ""
        
        let deliveryAddressObject = OrderConfirmationAddressObject(changeableAddress: changeableAddress, unChangebleAddress: unchangebleAddress, zipCode: zipCode, landMark: landmark)
        address_array.append(deliveryAddressObject)
        
        deliveryTime_lbl.text = "Within 1 day"
        otherLocationDeliveryValue_lbl.text = "Within 6 days"
        
        if let localDeliveryDuration = SharedPersistence.getValue(key: UserDefaultKeys.Shops.localDeliveryDuration) as? Int, let localDeliveryDurationUnit = SharedPersistence.getValue(key: UserDefaultKeys.Shops.localDeliveryDurationUnit) as? String {
            deliveryTime_lbl.text = "Within " + "\(localDeliveryDuration) " + localDeliveryDurationUnit
        }
        
        if let otherDeliveryDuration = SharedPersistence.getValue(key: UserDefaultKeys.Shops.otherDeliveryDuration) as? Int, let otherDeliveryDurationUnit = SharedPersistence.getValue(key: UserDefaultKeys.Shops.otherDeliveryDurationUnit) as? String {
            otherLocationDeliveryValue_lbl.text = "Within " + "\(otherDeliveryDuration) " + otherDeliveryDurationUnit
        }
        
        merchantDeliveryPreference_lbl.isHidden = true
        
        if selectedDeliveryType == GSConstant.defaultDeliveryMethod_id {    // Delivery By Shop

            if let localDeliveryFromTime = SharedPersistence.getValue(key: UserDefaultKeys.Shops.localDeliveryFromTime) as? String, let localDeliveryToTime = SharedPersistence.getValue(key: UserDefaultKeys.Shops.localDeliveryToTime) as? String {
                
                var partOneattributes = [NSAttributedStringKey: AnyObject]()
                partOneattributes[.foregroundColor] = UIColor.black
                
                let partOne = NSMutableAttributedString(string: "Shop delivery time: ", attributes: partOneattributes)
                
                let simpleFromTime = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: localDeliveryFromTime, inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", reqFormat: GSConstant.appTimeFormatter)
                let simpleToTime = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: localDeliveryToTime, inputFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", reqFormat: GSConstant.appTimeFormatter)
                
                var partTwoAttributes = [NSAttributedStringKey: AnyObject]()
                partTwoAttributes[.foregroundColor] = UIColor.red
                
                let partTwo = NSMutableAttributedString(string: simpleFromTime + " - " + simpleToTime, attributes: partTwoAttributes)
                
                merchantDeliveryPreference_lbl.isHidden = false
                let combination = NSMutableAttributedString()
                combination.append(partOne)
                combination.append(partTwo)
                
                merchantDeliveryPreference_lbl.attributedText = combination
            }
            
            
        } else {                                                            // Take Away
            //            numberOfSections = 0
            deliveryTimeKey_lbl.text = "Approximate dispatch time:"
            //            confirmDeliveryAddressHeaderBG_view.isHidden = true
            confirmDeliveryLocationHeaderTitle_lbl.text = "Your address"
            otherLocationDeliveryBG_view.isHidden = true
        }
        
        if let isGlobalShopsLoaded = SharedPersistence.getValue(key: UserDefaultKeys.Shops.isGlobalShopsLoaded) as? Bool, isGlobalShopsLoaded == true {
            
            otherLocationDeliveryBG_view.isHidden = false
            localDeliveryBG_view.isHidden = true
        }
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.DeliveryPreferences.isPrefferDateTimeSelected, value: false)
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.DeliveryPreferences.prefferedDate, value: "")
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.DeliveryPreferences.prefferedTime, value: "")
        
        isDeliveryNotesEnabled = SharedPersistence.getValue(key: UserDefaultKeys.Shops.isNoteFeatureEnabled) as? Bool ?? false
        isUploadFeatureEnabled = SharedPersistence.getValue(key: UserDefaultKeys.Shops.isUploadFeatureEnabled) as? Bool ?? false
    }
    
    // MARK: - Action Methods
    @IBAction func confirmDeliveryAddress_action(_ sender: UIButton) {
        
//        let selectedDeliveryType = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryType) as? Int ?? 1
        
//        if selectedDeliveryType == GSConstant.defaultDeliveryMethod_id, validateAddress() == false { return }
        
        if validateAddress() == false { return }
        
        if isFooterCheckBoxChecked {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.DeliveryPreferences.isPrefferDateTimeSelected, value: isFooterCheckBoxChecked)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.DeliveryPreferences.prefferedDate, value: prefferedDeliveryDate)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.DeliveryPreferences.prefferedTime, value: prefferedDeliveryTime)
        } else {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.DeliveryPreferences.isPrefferDateTimeSelected, value: isFooterCheckBoxChecked)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.DeliveryPreferences.prefferedDate, value: "")
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.DeliveryPreferences.prefferedTime, value: "")
        }
        
        SharedPersistence.removeValue(key: UserDefaultKeys.DeliveryFeatureDetails.deliveryNotes)
        SharedPersistence.removeValue(key: UserDefaultKeys.DeliveryFeatureDetails.deliveryInstructionImage)
        
        if deliveryNotes != "" {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.DeliveryFeatureDetails.deliveryNotes, value: deliveryNotes)
        }
        if let unwrappedAttachedImage = attachedImage, let imageData = UIImageJPEGRepresentation(unwrappedAttachedImage, 0.5) {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.DeliveryFeatureDetails.deliveryInstructionImage, value: imageData)
        }
        
        verifyShopsAPI()
        
        /*  May useful later
         
         if selectedDeliveryType == GSConstant.defaultDeliveryMethod_id {    // Delivery By Shop
         
         verifyShopsAPI()
         
         } else {                                                            // Take Away
         confirmDeliveryAddressAfterVerifyingTheShops()
         }
         
         */
    }
    
    private func validateAddress()-> Bool {
        
        let street = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_changeable) as? String ?? ""
        let zipcode = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_zipCode) as? String ?? ""
        
        if street == "" {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.orderConfirmation_enterDetailedAddress, viewController: self)
            return false
        } else if zipcode == "" {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.enterZipcode, viewController: self)
            return false
        }
        
        return true
    }
    
    fileprivate func confirmDeliveryAddressAfterVerifyingTheShops() {
        
        if self.checkPaymentParam(error: GSConstant.AlertMessages.loadCardIssue) {
            return
        }
        // Check for payment and delivery methods status
        if let decodedSavedPaymentMethod = SharedPersistence.getValue(key: GSPaymentConstants.SAVED_CARD_METHOD) as? Data {
            
            if let decodedSavedPaymentMethod = try? JSONDecoder().decode(GSSavePaymentMethod.self, from: decodedSavedPaymentMethod) {
                
                if decodedSavedPaymentMethod.payMethod == PaymentMethod.Cash.hashValue {
                    
                    self.pushToPaymentTypeVC()
                    
                } else if decodedSavedPaymentMethod.payMethod == PaymentMethod.SavedCard.hashValue {
                    
                    if let tempVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil)
                        .instantiateViewController(withIdentifier: GSString.Push.GSMakePaymentViewController) as? GSMakePaymentViewController {
                        
                        self.paymentParams?.cardNumber  = decodedSavedPaymentMethod.cardNumber
                        self.paymentParams?.expiryYear  = decodedSavedPaymentMethod.cardExpYear
                        self.paymentParams?.expiryMonth = decodedSavedPaymentMethod.cardExpMonth
                        
                        self.paymentParams?.cardToken = decodedSavedPaymentMethod.cardToken
                        self.paymentParams?.cardBin = decodedSavedPaymentMethod.cardBin
                        self.paymentParams?.cardBrand = decodedSavedPaymentMethod.cardBrand
                        
                        tempVC.paymentParams = self.paymentParams!
                        //tempVC.isSavedCard = true
                        //tempVC.isGoingToOrder = true
                        
                        if let navigator = navigationController {
                            navigator.pushViewController(tempVC, animated: true)
                        }
                    }
                } else {
                    self.pushToPaymentTypeVC()
                }
            }
        } else {
            self.pushToPaymentTypeVC()
        }
    }
    
    private func pushToPaymentTypeVC() {
        
        if let paymentTypeVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier:
            
            GSString.Push.GSPaymentTypeViewController) as? GSPaymentTypeViewController {
            paymentTypeVC.isGoingToOrder = true
            paymentTypeVC.purchaseAmountToPay = purchaseAmountToPay
            
            if let navigator = navigationController {
                navigator.pushViewController(paymentTypeVC, animated: true)
            }
        }
    }
    
    private func pushToDeliveryOptionVC() {
        if let deliveryOptionsVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSDeliveryOptionViewController) as? GSDeliveryOptionViewController {
            if let navigator = navigationController {
                navigator.pushViewController(deliveryOptionsVC, animated: true)
            }
        }
    }
    // check later
    private func createWebPageRequest(params:PayUModelPaymentParams) {
        
        createRequest.createRequest(withPaymentParam: params, forPaymentType: PAYMENT_PG_CCDC) { (request, error) in
            
            if (error == "") {
                
                DispatchQueue.main.async {
                    if let paymentWebVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPaymentWebViewController) as? GSPaymentWebViewController {
                        paymentWebVC.paymentRequest = request as URLRequest
                        if let navigator = self.navigationController {
                            navigator.pushViewController(paymentWebVC, animated: true)
                        }
                    }
                }
                
            } else {
                CustomAlert.showAlert(title: "oops !", message:  error as String, viewController: self)
            }
            
        }
    }
}

// MARK: - API Methods
extension GSOrderConfirmationViewController {
    
    fileprivate func verifyShopsAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.verifyShopsBeforeOrder
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        let selectedDelivery_type = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryType) as? Int ?? 1
        let deliveryLongitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong) as? Double ?? 0
        let deliveryLattitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLat) as? Double ?? 0
        let intZipCode = Int64(zipCode) ?? 0
        
        var street = ""
        
        if let landMark = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_landMark) as? String, landMark != "" {
            street += landMark
        }
        if changeableAddress != "" {
            if street == "" {
                street = changeableAddress
            } else {
                let tempVar = street + ", " + changeableAddress
                street = tempVar
            }
        }
        if street == "" {
            street = "NA"
        }
        
        let params = [ "_id"                :   storeCategory_id,
                       "deliveryType"       :   selectedDelivery_type,
                       "deliveryLocation"   :   [ "type"        : "Point",
                                                  "coordinates" : [deliveryLongitude, deliveryLattitude]],
                       "deliveryAddress"    :   [ "street"      : street,
                                                  "area"        : unchangebleAddress,
                                                  "zipcode"     : intZipCode]] as [String : AnyObject]
        
        confirmAddress_btn.isUserInteractionEnabled = false
        
        APIHandler.NetworkSetupRequest(method: .post, params: params,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            weakSelf.confirmAddress_btn.isUserInteractionEnabled = true
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    let unwrappedSuccessStatus = responseModel.success ?? false
                    
                    if unwrappedSuccessStatus {
                        // Success
                        weakSelf.confirmDeliveryAddressAfterVerifyingTheShops()
                        
                    } else {
                        // Failure
                        CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: weakSelf)
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

// MARK: - Place Order Helper Delegate  Methods

extension GSOrderConfirmationViewController:GSPlaceOrderHelperDelegate {
    
    func orderPlacedWith(status: Bool, data: GSPlaceOrderResponseData?, message: String) {
        
        if status {
            if let orderPlacedVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSOrderPlacedViewController) as? GSOrderPlacedViewController {
                orderPlacedVC.placeOrderResponse = data
                orderPlacedVC.amountPaid = purchaseAmountToPay
                orderPlacedVC.isCodOrder = true
                if let navigator = navigationController {
                    navigator.pushViewController(orderPlacedVC, animated: true)
                }
            }
        } else {
            CustomAlert.showAlert(title: GSString.AppName, message: message, viewController: self)
        }
    }
}

// MARK: - UITableView Methods

extension GSOrderConfirmationViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isDeliveryNotesEnabled || isUploadFeatureEnabled {
            return 3
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            return addressCell(at: indexPath)
        case 1:
            return deliveryPreferencesCell(at: indexPath)
        case 2:
            return deliveryNotesCell(at: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func addressCell(at indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = address_tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.addressInOrderConfirmationTableCell) as? GSAddressInOrderConfirmationTableCell else {
            return UITableViewCell()
        }
        cell.configureTheCell(address: address_array[indexPath.row].unChangebleAddress, specifiedString: address_array[indexPath.row].changeableAddress, zipCode: address_array[indexPath.row].zipCode, landMark: address_array[indexPath.row].landMark, indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    private func deliveryPreferencesCell(at indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = address_tableView.dequeueReusableCell(withIdentifier: GSDeliveryPreferenceTableCell.identifier) as? GSDeliveryPreferenceTableCell else {
            return UITableViewCell()
        }
        
        cell.date_lbl.text = prefferedDeliveryDate
        cell.timeSlot_lbl.text = prefferedDeliveryTime
        cell.dateSelection_btn.addTarget(self, action: #selector(footerDatePickerSelection(_:)), for: .touchUpInside)
        cell.timeSlotSelection_btn.addTarget(self, action: #selector(footerTimeSlotPickerSelection(_:)), for: .touchUpInside)
        
        cell.checkBox_btn.addTarget(self, action: #selector(footerCheckBoxAction(_:)), for: .touchUpInside)
        
        let selectedDeliveryType = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryType) as? Int ?? 1
        
        if selectedDeliveryType == GSConstant.defaultDeliveryMethod_id {    // Delivery By Shop
            
            cell.info_lbl.text = "Choose preferred delivery date & time"
            
        } else {
            cell.info_lbl.text = "Choose preferred pickup date & time"
        }
        
        if isFooterCheckBoxChecked {
            cell.checkBox_btn.setImage(#imageLiteral(resourceName: "Check_icon"), for: .normal)
        } else {
            cell.checkBox_btn.setImage(#imageLiteral(resourceName: "Uncheck_icon"), for: .normal)
        }
        cell.preferenceTimeSelectionBG_view.isHidden = !isFooterCheckBoxChecked
        
        return cell
    }
    
    private func deliveryNotesCell(at indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = address_tableView.dequeueReusableCell(withIdentifier: GSDeliveryNotesTableViewCell.identifier) as? GSDeliveryNotesTableViewCell else {
            return UITableViewCell()
        }
        
        cell.attachment_btn.addTarget(self, action: #selector(cell_attachmentAction(_:)), for: .touchUpInside)
        cell.attachment_btn.setImage(#imageLiteral(resourceName: "attachment_icon"), for: .normal)
        cell.selected_imgView.image = nil
        
        if attachedImage != nil {
            cell.attachment_btn.setImage(nil, for: .normal)
            cell.selected_imgView.image = attachedImage
        }
        
        cell.uploadBg_view.isHidden = !isUploadFeatureEnabled
        cell.txtViewBG_view.isHidden = !isDeliveryNotesEnabled
        
        cell.notes_txtView.delegate = self
        
        return cell
    }
    
    // MARK: - Header Footer Methods
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    @objc private func footerCheckBoxAction(_ sender:UIButton) {
        isFooterCheckBoxChecked = !isFooterCheckBoxChecked
        
        address_tableView.reloadData()
    }
    
    @objc private func footerDatePickerSelection(_ sender:UIButton) {
        addDatePicker()
    }
    @objc private func footerTimeSlotPickerSelection(_ sender:UIButton) {
        addTimeSlotPicker()
    }
    
    fileprivate func addDatePicker() {
        
        if simpleDatePickerView != nil {
            if (simpleDatePickerView?.isDescendant(of: self.view) ?? false) {
                return
            }
            simpleDatePickerView = nil
        }
        simpleDatePickerView = GSCustomDatePicker()
        simpleDatePickerView?.datePicker.datePickerMode = .date
        let minimumDate = minimumDateForDeliveryDate()
        simpleDatePickerView?.datePicker.minimumDate = minimumDate
        simpleDatePickerView?.datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 6, to: minimumDate)
        simpleDatePickerView?.showTheViewFromBottom(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: { [weak self] in
            
            UIView.animate(withDuration: 0.1, animations: {
                self?.simpleDatePickerView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            })
        })
        simpleDatePickerView?.selectedPicker(completion: { (selectedDate, isCancel) in
            if !isCancel {
                self.selectedDate = selectedDate
                self.prefferedDeliveryDate = self.convertDateTimeRequiredFormat(selectedDate)
                self.prefferedDeliveryTime = self.timeSlots_array().first ?? ""
                self.address_tableView.reloadData()
            }
        })
    }
    
    fileprivate func minimumDateForDeliveryDate() -> Date {
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<18 : return Date()
        case 18..<24 : return Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        default:
            return Date()
        }
    }
    
    fileprivate func timeSlots_array() -> [String] {
        var dataArray = data_array
        
        //        let todayDate = Calendar.current.startOfDay(for: Date())
        
        let todayDate = Date()
        
        //        let daysDifference = interval(ofComponent: .day, fromDate: todayDate, toDate: selectedDate)
        
        let isBothDatesSame = Calendar.current.isDate(selectedDate, inSameDayAs: todayDate)
        
        if isBothDatesSame {
            let hour = Calendar.current.component(.hour, from: Date())
            
            //            for slot_hour in [7,10,13,16,19] {
            //                if (hour + 1) >= slot_hour {
            //                    if dataArray.count > 0 {
            //                        dataArray.removeFirst()
            //                    }
            //                }
            //            }
                        
            let tempArray = [7,10,13,16,19]
            
            for index in stride(from: tempArray.count - 1, through: 0, by: -1) {
                
                let slot_hour = tempArray[index]
                
                if (hour + 1) >= slot_hour {
                    if dataArray.count > 0 {
                        dataArray.remove(at: index)
                    }
                }
            }
        }
        return dataArray
    }
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date, toDate:Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: toDate) else { return 0 }
        
        return end - start
    }
    
    private func addTimeSlotPicker() {
        
        if picker != nil {
            if (picker?.isDescendant(of: self.view) ?? false) {
                return
            }
            picker = nil
        }
        picker = GSCustomPickerView()
        var dataArray = timeSlots_array()
        picker?.pickerData = dataArray
        
        //        picker?.showTheViewFromBottom(on: self.view, for: CGRect(x: 0, y: self.topLayoutGuide.length, width: self.view.frame.size.width, height: self.view.frame.size.height - self.topLayoutGuide.length), completionHandler: { [weak self] in
        //
        //            UIView.animate(withDuration: 0.1, animations: {
        //                self?.picker?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //            })
        //        })
        
        picker?.showTheView(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom))
        
        for index in 0..<dataArray.count {
            let item = dataArray[index]
            if item == prefferedDeliveryTime {
                picker?.pickerView.selectRow(index, inComponent: 0, animated: true)
            }
        }
        
        picker?.selectedPicker { (selValue, cancel) in
            if !cancel {
                self.prefferedDeliveryTime = selValue ?? ""
                self.address_tableView.reloadData()
            }
        }
    }
    
    fileprivate func convertDateTimeRequiredFormat(_ inputDate:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: inputDate)
        return dateStr
    }
    
    @objc fileprivate func cell_attachmentAction(_ sender:UIButton) {
        
        if attachedImage != nil {
            
            CustomAlert.showActionSheet(title: "Choose", message: nil, cancelTitle: "Cancel", optionArray: ["Replace", "Remove"], sourceView: sender, in: self) { btnIndex in
                
                if btnIndex == 0 {
                    self.addOrReplacePhoto(sender)
                } else {
                    
                    self.attachedImage = nil
                    self.address_tableView.reloadData()
                }
            }
            
        } else {
            
            addOrReplacePhoto(sender)
        }
    }

    private func addOrReplacePhoto(_ sender:UIButton) {
        
        CustomAlert.showActionSheet(title: "Choose", message: nil, cancelTitle: "Cancel", optionArray: ["Camera", "Photos"], sourceView: sender, in: self) { btnIndex in
            
            if btnIndex == 0 {
                self.openCamera()
            } else {
                self.openPhotosAlbum()
            }
        }
    }
    
    private func openPhotosAlbum() {
        
        if GSCommonHelper.checkForUsagePermission(resourceType: .photoLibrary, viewController: self) == false { return }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    private func openCamera() {
        
        if GSCommonHelper.checkForUsagePermission(resourceType: .camera, viewController: self) == false { return }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.allowsEditing = false
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
}

// MARK: - UITextView Delegate Methods

extension GSOrderConfirmationViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        deliveryNotes = textView.text
    }
}

// MARK: - UIImagePicker Controller Delegate

extension GSOrderConfirmationViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = UIImage.from(info: info) {
            
            var oriented = selectedImage
            oriented = GSCommonHelper.fixOrientation(img: selectedImage)
            
            attachedImage = oriented
            self.address_tableView.reloadData()
            
        } else {
            picker.dismiss(animated: true) {
                CustomAlert.showAlert(title: "Error", message: "Unable to fetch the photo", viewController: self)
            }
            return
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - AddressInOrderConfirmation TableView Cell Delegate
extension GSOrderConfirmationViewController:GSAddressInOrderConfirmationCellDelegate {
    
    func radioButtonPressed(_ sender: UIButton) {
        
    }
    
    func editActionPressed(_ sender: UIButton) {
        
        
        if editAddressPopUp != nil {
            if editAddressPopUp!.isDescendant(of: self.view) {
                return
            }
            editAddressPopUp = nil
        }
        editAddressPopUp = GSEditAddressPopUpView()
        editAddressPopUp?.delegate = self
        let zipCode:String? = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_zipCode) as? String
        let deliveryLongitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong) as? Double ?? 0
        let deliveryLattitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLat) as? Double ?? 0
        
        if let decodedSavedAddress = SharedPersistence.getValue(key: UserDefaultKeys.locations.savedAddressObject) as? Data {
            
            if let decodedSavedAddressObject = try? JSONDecoder().decode(GSViewProfileAddressObject.self, from: decodedSavedAddress) {
                
                editAddressPopUp?.configureWith(addressObj: decodedSavedAddressObject)
                editAddressPopUp!.showTheViewFromBottom(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: {
                })
                return
            }
        }
        
        editAddressPopUp?.configureWith(street: changeableAddress, area: unchangebleAddress, landMark:landmark, zipCode: zipCode, coordinate: [deliveryLongitude,deliveryLattitude], isAddressConfirmation: true)
        editAddressPopUp!.showTheViewFromBottom(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: {
            self.editAddressPopUp?.setTextViewHeightBasedOnContent()
        })
        
    }
    
    private func addTextfieldAlertController(index:Int) {
        
        let alertController = UIAlertController(title: "Address", message: "Edit your address", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            let text = textField.text ?? ""
            
            if text != "" {
                //                self.extra_specifiedAddressArray[index] = text
                self.address_array[index].changeableAddress = text
                self.changeableAddress = text
                self.address_tableView.reloadData()
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "Edit your address"
            textField.text = self.address_array[index].changeableAddress
        })
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Edit Address Pop Up Delegate

extension GSOrderConfirmationViewController: GSEditAddressPopViewDelegate {
    
    func saveAddressWith(editAddressObj: GSEditAddressModel) {
        
        changeableAddress = editAddressObj.street
        unchangebleAddress = editAddressObj.area
        self.zipCode = editAddressObj.zipcode
        self.landmark = editAddressObj.landMark
        
        if let unwrappedZipCode = Double(zipCode) {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_zipCode, value: unwrappedZipCode)
        }
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_unchangeable_address, value: unchangebleAddress)
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_changeable, value: changeableAddress)
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_zipCode, value: editAddressObj.zipcode)
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_landMark, value: editAddressObj.landMark)
        
        if address_array.count > 0 {
            address_array[0].changeableAddress = changeableAddress
            address_array[0].unChangebleAddress = unchangebleAddress
            address_array[0].zipCode = zipCode
            address_array[0].landMark = editAddressObj.landMark
            address_tableView.reloadData()
        }
        
        if editAddressObj.addressId != nil {
            createAddressObject(street: editAddressObj.street, area: editAddressObj.area, landMark: editAddressObj.landMark, zipCode: editAddressObj.zipcode, addressId: editAddressObj.addressId, type: editAddressObj.type)
        }
    }
    
    private func createAddressObject(street: String, area: String, landMark: String, zipCode: String, addressId: String?, type: String) {
        
        let deliveryLongitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong) as? Double ?? 0
        let deliveryLattitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLat) as? Double ?? 0
        
        let locationObject = GSViewProfileLocation(type: "Point", coordinates: [deliveryLongitude, deliveryLattitude])
        let address = GSViewProfileAddress(street: street, area: area, landmark: landMark, zipcode: Int(zipCode))
        
        let addressObject = GSViewProfileAddressObject(location: locationObject, address: address, isDefault: false, type: type, id: addressId)
        
        if let encodedSavedAddress = try? JSONEncoder().encode(addressObject) {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.savedAddressObject, value: encodedSavedAddress)
        }
    }
}

// MARK: - Navigation Bar View Delegate Methods

extension GSOrderConfirmationViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
    }
}
