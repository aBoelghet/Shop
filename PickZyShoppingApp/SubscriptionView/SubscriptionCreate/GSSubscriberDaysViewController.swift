//
//  GSSubscriberDaysViewController.swift
//  Shopor
//
//  Created by Ratheesh on 24/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import Razorpay

class GSSubscriberDaysViewController: UIViewController {
    
    @IBOutlet weak var navigationBar_view:NavigationBarNormal!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var timelist_Tableview: UITableView!
    
    @IBOutlet weak var selectDays_Collectionview: UICollectionView!
    
    @IBOutlet weak var selectDelivery_Textfield: UITextField!
    
    @IBOutlet weak var selectTimeslot_Textfield: UITextField!
    
    @IBOutlet weak var selectDate_Textfield: UITextField!
    
    @IBOutlet weak var deliveryAddress_Tableview: UITableView!
    
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var datebackgroundView: UIView!
    
    @IBOutlet weak var deliveryShop_Label: UILabel!
    
    @IBOutlet weak var subscribeButton: GSBaseButton!
    
    
    var simpleDatePickerView : GSCustomDatePicker?
    
    var picker:GSCustomPickerView!

    var editAddressPopUp:GSEditAddressPopUpView?
    
    var subscriberData : SubscriptionTypeData?
    var arraySubsscriptionList = [SubscriptionInfo]()

    var address_array = [OrderConfirmationAddressObject]()

    var changeableAddress = ""
    var unchangebleAddress = ""
    var zipCode = ""
    var landmark = ""
    
    var selectedDate:Date!

    var razorpayObj : RazorpayCheckout? = nil

    var selectedArryaList = [String]()
    var subscribeType = ""
    var categoryId = ""
    
    var subscribeAmount = Int()
    var subscriptionKeyID = ""

    var arrayDays = [String]()
        
    struct OrderConfirmationAddressObject {
        var changeableAddress:String
        var unChangebleAddress:String
        var zipCode:String
        var landMark:String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBarMethod()
        self.viewInitializedMethod()
    }
    
    func navigationBarMethod()  {
        navigationBar_view.delegate = self
        navigationBar_view.titleLable.text = "Subscribe -\(subscribeType)"
    }
    
    func viewInitializedMethod()  {
        
        arrayDays = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        
        selectedArryaList = (subscribeType == "Weekly") ? ["0"] : ["0","1","2","3","4","5","6"]
        
        self.setTextFiledSetups(textField: selectDelivery_Textfield)
        self.setTextFiledSetups(textField: selectTimeslot_Textfield)
        selectDate_Textfield.delegate = self
        self.setviewProperties(view: datebackgroundView)
        
        unchangebleAddress = (SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_unchangeable_address) as? String ?? "")
        zipCode = (SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_zipCode) as? String ?? "")
        changeableAddress = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_changeable) as? String ?? ""
        landmark = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_landMark) as? String ?? ""
        
        let deliveryAddressObject = OrderConfirmationAddressObject(changeableAddress: changeableAddress, unChangebleAddress: unchangebleAddress, zipCode: zipCode, landMark: landmark)
        address_array.append(deliveryAddressObject)
        
        deliveryShop_Label.text = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryTypeDisplayName) as? String ?? "Delivery by Shop"
        
        timelist_Tableview.delegate = self
        timelist_Tableview.dataSource = self
        timelist_Tableview.isScrollEnabled = false
        timelist_Tableview.tag = 1
        
        deliveryAddress_Tableview.delegate = self
        deliveryAddress_Tableview.dataSource = self
        deliveryAddress_Tableview.isScrollEnabled = false
        deliveryAddress_Tableview.tag = 2
        
        selectDays_Collectionview.delegate = self
        selectDays_Collectionview.dataSource = self
        selectDays_Collectionview.isScrollEnabled = false
        
        selectDays_Collectionview.register(UINib(nibName: "collectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier:"collectionHeaderView")
    }
    
    func setviewProperties(view:UIView)  {
        
        view.layer.cornerRadius = 3
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND).cgColor
    }
    
    func setTextFiledSetups(textField:UITextField)  {
        
        textField.delegate = self
        textField.layer.cornerRadius = 3
        textField.layer.borderWidth = 1
        textField.layer.borderColor =  UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND).cgColor
    }
    
    private func deliveryTimeSlotViewDisplay(selectType:String) {
        
        self.addPicker(selectType: selectType)
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
        simpleDatePickerView?.datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 60, to: minimumDate)
        simpleDatePickerView?.showTheViewFromBottom(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: { [weak self] in
            
            UIView.animate(withDuration: 0.1, animations: {
                self?.simpleDatePickerView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            })
        })
        simpleDatePickerView?.selectedPicker(completion: { (selectedDate, isCancel) in
            if !isCancel {
                self.selectDate_Textfield.text = self.convertDateTimeRequiredFormat(selectedDate)
            }
        })
    }
    
    fileprivate func minimumDateForDeliveryDate() -> Date {
        
        let _date = Date()
        let hour = Calendar.current.component(.hour, from: _date)
        let date = Date.tomorrow
        switch hour {
        case 0..<16 : return date
        case 16..<24 : return Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
        default:
            return date
        }
    }
    
    fileprivate func convertDateTimeRequiredFormat(_ inputDate:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateStr = dateFormatter.string(from: inputDate)
        return dateStr
    }
    
    func addPicker(selectType:String) {
        
        if picker != nil {
            if picker.isDescendant(of: self.view) {
                return
            }
            picker = nil
        }
        picker = GSCustomPickerView()
        picker.pickerData = selectType == "1" ? ["3", "6", "15", "30(Recommended)", "60", "90"] : ["5 AM - 07 AM", "07 AM - 9 AM", "9 AM - 11 AM", "11 AM - 01 PM", "01 PM - 03 PM", "03 PM - 05 PM", "05 PM - 07 PM", "07 PM - 09 PM", "09 PM - 11 PM"]
        
        picker.showTheView(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom))
        
        picker.selectedPicker { (selected, cancel) in
            if !cancel {
                
                if selectType == "1" {
                    if selected == "30(Recommended)" {
                        self.selectDelivery_Textfield.text = "30"
                    } else {
                        self.selectDelivery_Textfield.text = selected
                    }
                    self.sendRequestForAmountSubscripeApi()
                } else {
                    self.selectTimeslot_Textfield.text = selected
                }
            }
        }
    }
    
    // MARK: - Validations for Textfields
    func validateTextFileds() -> Bool {
        
        let txtFieldArray = [selectDelivery_Textfield,selectTimeslot_Textfield,selectDate_Textfield]
       
        if (selectedArryaList.count == 0) && (subscribeType != "Alternate days"){
            CustomAlert.showAlert(title: GSString.AppName, message: "Please select the days", viewController: self)
            return false
        }
        for txtField in txtFieldArray {
            if (txtField?.text?.isEmpty)! {
                
                CustomAlert.showAlert(title: GSString.AppName, message: "Please \(txtField?.placeholder ?? "Please enter missing field")", viewController: self)
                return false
            }
        }
        return true
    }
    
    @IBAction func datePickerButtonAction(_ sender: Any) {
        
        self.addDatePicker()
    }
    
    @IBAction func subscriptionButtonAction(_ sender: Any) {
        
        self.view.endEditing(true)
        guard validateTextFileds() == true else {return}
        self.pushSubscripeViewPopup()
    }
    
    // Webservices
    func sendRequestForSubscripeApi(transactionId:String) {
        
        let params: [String:Any]
        let hostString = APIurl.baseURL + APIurl.subURL.subscriptionSubscribe
        
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
        
        let minimumDeliveryDate = minimumDateForDeliveryDate()
        selectedDate = minimumDeliveryDate
        
        let preferredDate = self.selectDate_Textfield.text ?? ""
        let preferedTime = self.selectTimeslot_Textfield.text ?? "" 
        
        let times_array = preferedTime.components(separatedBy: "-")
        var from_time = ""
        var to_time = ""
        if times_array.count > 1 {
            from_time = times_array[0].removeEnclosedWhieteSpace().components(separatedBy: " ").first ?? ""
            let from_timeAMPM = times_array[0].removeEnclosedWhieteSpace().components(separatedBy: " ").last ?? ""
            if from_timeAMPM.lowercased().contains("pm") {
                let intFromTime = Int(from_time) ?? 0
                from_time = "\(intFromTime + 12)"
            }
            
            to_time = times_array[1].removeEnclosedWhieteSpace().components(separatedBy: " ").first ?? ""
            let to_timeAMPM = times_array[1].removeEnclosedWhieteSpace().components(separatedBy: " ").last ?? ""
            if to_timeAMPM.lowercased().contains("pm") {
                let intToTime = Int(to_time) ?? 0
                to_time = "\(intToTime + 12)"
            }
        }
        let landMarkString = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_landMark) as? String ?? ""

        let seconds = TimeZone.current.secondsFromGMT()
        let milliSeconds = seconds * 1000
        let strMilliSec = "\(milliSeconds)"
        let subscriptionName = SharedPersistence.getValue(key: UserDefaultKeys.subscriptionName) ?? ""

        var address_object = [String:AnyObject]()
        if landMarkString == ""{
            address_object = [
                "street": street,
                "area": unchangebleAddress,
                "zipcode": intZipCode
                ] as [String:AnyObject]
        }else{
            address_object = [
                "street": street,
                "area": unchangebleAddress,
                "landmark": landMarkString,
                "zipcode": intZipCode
                ] as [String:AnyObject]
        }
        
        params = ["categoryId": storeCategory_id,
                  "subsc_type_id":subscriberData?.id ?? "",
                  "is_bayfaycash": false,
                  "is_auto_payment": false,
                  "paymentId": transactionId,
                  "subscription_title": subscriptionName,
                  "subscriptionInfo": [
                    "order_days": selectedArryaList,
                    "startDate": "\(preferredDate) \(to_time):00:00:000",
                    "deliveryType": selectedDelivery_type,
                    "deliveryTime": [
                        "from": "\(preferredDate) \(from_time):00:00:000",
                        "to": "\(preferredDate) \(to_time):00:00:000",
                        "offset": strMilliSec
                    ],
                    "deliveryAddress": [
                        "location": [
                            "type": "Point",
                            "coordinates": [deliveryLongitude, deliveryLattitude]
                        ],
                        "address": address_object
                    ]
            ],
                  "num_of_delivery": self.selectDelivery_Textfield.text!] as [String : Any]
        
        
        
        #if DEBUG
        print(params)
        #endif
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject],urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionSuccessModel.self, from: responseData)
                    weakSelf.pushtoSubscribeSuccessView(subscriptionData: responseModel.data!)
                    
                } catch {
                    #if DEBUG
                    print(error)
                    #endif
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                #if DEBUG
                print(error?.localizedDescription ?? GSString.API.unknownError)
                #endif
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func pushtoSubscribeSuccessView(subscriptionData:SubscriptionOrderData)  {
        if let success = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSSubscriberSuccessViewController") as? GSSubscriberSuccessViewController {
            success.placeOrderResponse = subscriptionData
            navigationController?.pushViewController(success, animated: true)
        }
    }
    
    // Webservices
    func sendRequestForAmountSubscripeApi() {
        
        let params: [String:Any]
        let hostString = APIurl.baseURL + APIurl.subURL.subscriptionAmount
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        
        if subscribeType == "Alternate days"{
            params = ["category_id" : storeCategory_id,
                      "subsc_type_id" : subscriberData?.id ?? "",
                      "num_of_delivery" : self.selectDelivery_Textfield.text!] as [String : Any]
        } else {
            params = ["category_id" : storeCategory_id,
                      "selected_days": selectedArryaList,
                      "subsc_type_id" : subscriberData?.id ?? "",
                      "num_of_delivery" : self.selectDelivery_Textfield.text!] as [String : Any]
        }
       
        #if DEBUG
        print(params)
        #endif
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject],urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionAmountModel.self, from: responseData)
                    print(responseModel.amount as Any)
                    weakSelf.subscribeAmount = responseModel.amount ?? 0
                    weakSelf.subscriptionKeyID = responseModel.payKeyID ?? ""
                    let remove = "\(responseModel.amount ?? 0)"
                    let subvalue = remove.dropLast(2)
                    let amount = "(₹\(subvalue))"
                    weakSelf.subscribeButton .setTitle("Subscribe\(amount)", for: .normal)
                    
                } catch {
                    #if DEBUG
                    print(error)
                    #endif
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                #if DEBUG
                print(error?.localizedDescription ?? GSString.API.unknownError)
                #endif
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func pushSubscripeViewPopup()  {
        
        if let pushVC = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "SubscriptionPopupViewController") as? SubscriptionPopupViewController {
            pushVC.modalPresentationStyle = .overCurrentContext
            pushVC.delegate = self
            present(pushVC, animated: true, completion: nil)
        }
    }
    
    private func openRazorpayCheckout(subscriptionName:String) {
       
        var userEmail = ""
        var userPhone = ""
        var userName = ""

        if let decodedLoginUserData = SharedPersistence.getValue(key: UserDefaultKeys.user.user_details) as? Data {
            
            if let loginUser_jsonObject = try? JSONDecoder().decode(GSLoginData.self, from: decodedLoginUserData) {
                
                userEmail = loginUser_jsonObject.userProfile?.email?.id ?? ""
                let dialCode = loginUser_jsonObject.userProfile?.mobile?.dialingCode ?? 0
                let number = loginUser_jsonObject.userProfile?.mobile?.number ?? 0
                userPhone = "+\(dialCode)\(number)"
                
                let firstName = loginUser_jsonObject.userProfile?.firstName ?? ""
                let lastName = loginUser_jsonObject.userProfile?.lastName ?? ""
                userName = (firstName + " " + lastName).removeEnclosedWhieteSpace()
            }
        }
        
        razorpayObj = RazorpayCheckout.initWithKey(subscriptionKeyID, andDelegate: self)
       
        let options: [AnyHashable:Any] = [
            "prefill": [
                "contact": userPhone,
                "email": userEmail
               
            ],
            "amount" : subscribeAmount,
            "name" : userName,

        ]
        if let rzp = self.razorpayObj {
            rzp.open(options)
        } else {
            print("Unable to initialize")
        }
    }
}

// RazorpayPaymentCompletionProtocol - This will execute two methods 1.Error and 2. Success case. On payment failure you will get a code and description. In payment success you will get the payment id.
extension GSSubscriberDaysViewController : RazorpayPaymentCompletionProtocol {
    
    func onPaymentError(_ code: Int32, description str: String) {
        print("error: ", code, str)
//      self.presentAlert(withTitle: "Alert", message: str)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        print("success: ", payment_id)
        self.sendRequestForSubscripeApi(transactionId: payment_id)
    }
}

// RazorpayPaymentCompletionProtocolWithData - This will returns you the data in both error and success case. On payment failure you will get a code and description. In payment success you will get the payment id.
extension GSSubscriberDaysViewController: RazorpayPaymentCompletionProtocolWithData {
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        print("error: ", code)
//      self.presentAlert(withTitle: "Alert", message: str)
    }
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        print("success: ", payment_id)
//      self.presentAlert(withTitle: "Success", message: "Payment Succeeded")
    }
}

// MARK: - Delivery Time Slot Methods
extension GSSubscriberDaysViewController:SubscriptionPopViewDelegate {
    func subscriptionName(subscription: String) {
        self.openRazorpayCheckout(subscriptionName: subscription)
    }
}

// MARK: - TextField Methods
extension GSSubscriberDaysViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.view .endEditing(true)
        
        if textField == selectDelivery_Textfield {
            self.deliveryTimeSlotViewDisplay(selectType: "1")
        } else if textField == selectTimeslot_Textfield {
            self.deliveryTimeSlotViewDisplay(selectType: "2")
        } else {
            self.addDatePicker()
        }
    }
}

// MARK: - NavigationBar Methods
extension GSSubscriberDaysViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
    }
}

// MARK:- TableView Delegates
extension GSSubscriberDaysViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView.tag {
        case 1:
            return arraySubsscriptionList.count
        case 2:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch tableView.tag {
        case 1:
            return 0.0
        case 2:
            return 30.0
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        switch tableView.tag {
        case 1:
            headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0)
            return headerView
        case 2:
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
            
            let title_lable = UILabel()
            title_lable.font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont(name: "HelveticaNeue-Medium", size: 16) : UIFont(name: "HelveticaNeue-Medium", size: 14)
            title_lable.textColor = UIColor(hexString: defaultTheme.cart_header_title)
            headerView.backgroundColor = UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND)
            title_lable.text = "Confirm delivery address:"
            headerView.addSubview(title_lable)
            
            title_lable.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: title_lable, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: title_lable, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
            NSLayoutConstraint(item: title_lable, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: title_lable, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            return headerView
        default: break
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView.tag {
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier:"DailyTimeSlotTableViewCell" ) as? DailyTimeSlotTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.titleLabel.text = arraySubsscriptionList[indexPath.row].info ?? ""
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier:"DeliveryAddressTableViewCell" ) as? DeliveryAddressTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.address_EditButton.tag = indexPath.row
            cell.address_EditButton .addTarget(self, action: #selector(addressEditButtonAction(sender:)), for: .touchUpInside)
            
            cell.configureTheCell(address: address_array[indexPath.row].unChangebleAddress, specifiedString: address_array[indexPath.row].changeableAddress, zipCode: address_array[indexPath.row].zipCode, landMark: address_array[indexPath.row].landMark, indexPath: indexPath)
            return cell
        default: break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView.tag {
        case 0: break
        case 1:
            let cell: DeliveryAddressTableViewCell = tableView.cellForRow(at: indexPath) as! DeliveryAddressTableViewCell
            cell.address_radioImage.image = UIImage(named: "radioButton_Active")
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        switch tableView.tag {
        case 1:
            let height = tableView.contentSize.height
            tableviewHeight.constant =  height
        default: break
        }
        backgroundViewHeight.constant = tableView.contentSize.height + backgroundView.frame.height
    }
    
    @objc func addressEditButtonAction(sender:UIButton) {
        
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
        
        editAddressPopUp?.home_btn.isHidden = true
        editAddressPopUp?.work_btn.isHidden = true
        editAddressPopUp?.others_btn.isHidden = true
        
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
}
// MARK: - Edit Address Pop Up Delegate

extension GSSubscriberDaysViewController: GSEditAddressPopViewDelegate {
    
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
            
            //To call or execute function after some time
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //Here call your function
                self.deliveryAddress_Tableview.reloadData()
            }
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

extension GSSubscriberDaysViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailydaysCollectionViewCell", for: indexPath) as! DailydaysCollectionViewCell
        if subscribeType == "Weekly" {
            if selectedArryaList.contains("\(indexPath.item)") {
                cell.tick_Image.image = UIImage(named: "radioButtonSelect_Active")
            } else {
                cell.tick_Image.image = UIImage(named: "radioButton_InActive")
            }
        } else {
            cell.tick_Image.image = UIImage(named: "checkedBox_Active")
        }
        cell.days_Label.text = arrayDays[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if subscribeType == "Weekly"{
            selectedArryaList .removeAll()
            selectedArryaList .append("\(indexPath.item )")
            selectDays_Collectionview .reloadData()

        }else{
            if selectedArryaList.contains("\(indexPath.item)") {
                
                if let index = selectedArryaList.index(of: "\(indexPath.item)") {
                    selectedArryaList.remove(at: index)
                }
                let cell: DailydaysCollectionViewCell = collectionView.cellForItem(at: indexPath) as! DailydaysCollectionViewCell
                cell.tick_Image.image = UIImage(named: "checkBox_InActive")
            }else{
                let indexValue = indexPath.item
                selectedArryaList .append("\(indexValue)")
                let cell: DailydaysCollectionViewCell = collectionView.cellForItem(at: indexPath) as! DailydaysCollectionViewCell
                cell.tick_Image.image = UIImage(named: "checkedBox_Active")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let cellsAcross: CGFloat = 4
        var widthRemainingForCellContent = collectionView.bounds.width
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            let borderSize: CGFloat = flowLayout.sectionInset.left + flowLayout.sectionInset.right
            widthRemainingForCellContent -= borderSize + ((cellsAcross - 1) * flowLayout.minimumInteritemSpacing)
        }
        let cellWidth = widthRemainingForCellContent / cellsAcross
        return CGSize(width: cellWidth + 5, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier:"collectionHeaderView", for: indexPath) as! collectionHeaderView
            
            headerView.title_label.text = "Select the Days:"
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        let height = collectionView.contentSize.height
        collectionViewHeight.constant =  height
        
        if subscribeType == "Alternate days"{
            collectionViewHeight.constant = 0
        }
    }
}
// MARK: - SubscriptionAmountModel
struct SubscriptionAmountModel: Codable {
    let success: Bool?
    let amount: Int?
    let payKeyID: String?
    
    enum CodingKeys: String, CodingKey {
        case success, amount
        case payKeyID = "pay_key_id"
    }
}
// MARK: - SubscriptionSuccessModel
struct SubscriptionSuccessModel: Codable {
    let success: Bool?
    let message: String?
    let data: SubscriptionOrderData?
}

// MARK: - DataClass
struct SubscriptionOrderData: Codable {
    let message, subscriptionID: String?
    let amountPaid: Double?
    let shopAddress: [ShopAddress]?
    
    enum CodingKeys: String, CodingKey {
        case message
        case subscriptionID = "subscription_id"
        case amountPaid = "amount_paid"
        case shopAddress = "shop_address"
    }
}

// MARK: - ShopAddress
struct ShopAddress: Codable {
    let locationID, street: String?
    let zipcode: Int?
    let shopName: String?
    
    enum CodingKeys: String, CodingKey {
        case locationID = "location_id"
        case street, zipcode
        case shopName = "shop_name"
    }
}
