//
//  GSSubscriberViewController.swift
//  Shopor
//
//  Created by Ratheesh on 21/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import Razorpay

enum MyTheme {
    case light
    case dark
}
class GSSubscriberViewController: UIViewController {
    
    @IBOutlet weak var navigationBar_view:NavigationBarNormal!
    
    @IBOutlet weak var calenderView: CalendarView!
    
    @IBOutlet weak var selectDateLabel: UILabel!
    
    @IBOutlet weak var addressList_Tableview: UITableView!
    
    @IBOutlet weak var deliveryTimeSlot_TextField: UITextField!
    
    @IBOutlet weak var deliveryShop_Label: UILabel!
    
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var subscribeButton: GSBaseButton!
    
    var picker:GSCustomPickerView!
    
    var editAddressPopUp:GSEditAddressPopUpView?
    
    var subscriberData : SubscriptionTypeData?
    
    var address_array = [OrderConfirmationAddressObject]()
    
    var razorpayObj : Razorpay? = nil

    var changeableAddress = ""
    var unchangebleAddress = ""
    var zipCode = ""
    var landmark = ""
    
    var subscribeType = ""
    var subscribeAmount = Int()
    var subscriptionKeyID = ""
    var selectedDate:Date!

    var arrayDeliveryList = [String]()
    var arrayDateList = [String]()

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
        
        unchangebleAddress = (SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_unchangeable_address) as? String ?? "")
        zipCode = (SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_zipCode) as? String ?? "")
        changeableAddress = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_changeable) as? String ?? ""
        landmark = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_landMark) as? String ?? ""
        
        let deliveryAddressObject = OrderConfirmationAddressObject(changeableAddress: changeableAddress, unChangebleAddress: unchangebleAddress, zipCode: zipCode, landMark: landmark)
        address_array.append(deliveryAddressObject)
        
        deliveryShop_Label.text = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryTypeDisplayName) as? String ?? "Delivery by Shop"
        
        deliveryTimeSlot_TextField.delegate = self
        deliveryTimeSlot_TextField.layer.cornerRadius = 3
        deliveryTimeSlot_TextField.layer.borderWidth = 1
        deliveryTimeSlot_TextField.layer.borderColor =  UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND).cgColor
        
        calenderView.layer.cornerRadius = 3
        calenderView.clipsToBounds = true
        calenderView.layer.borderColor =  UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND).cgColor
        calenderView.layer.borderWidth = 1
        
        calenderView.dataSource = self
        calenderView.delegate = self

        let style = CalendarView.Style()
        
        style.cellShape                = .round
        style.cellColorDefault         = UIColor.clear
        style.cellSelectedBorderColor  = UIColor(red: 55 / 255, green: 167 / 255, blue: 248 / 255, alpha: 1.0)
        style.headerTextColor          = UIColor.gray
        
        style.cellTextColorDefault     = UIColor.gray
        style.cellTextColorToday       = UIColor.gray
        style.cellTextColorWeekend     = UIColor.gray
        style.cellColorToday           = UIColor.clear
        style.cellColorOutOfRange      = UIColor(red: 249/255, green: 226/255, blue: 212/255, alpha: 1.0)
        
        style.headerBackgroundColor    = UIColor(red: 237/255.0, green: 237/255.0, blue: 237/255.0, alpha: 1.0)
        style.weekdaysBackgroundColor  = UIColor(red: 237/255.0, green: 237/255.0, blue: 237/255.0, alpha: 1.0)
        style.firstWeekday             = .sunday
        
        style.locale                   = Locale(identifier: "en_US")
        
        style.cellFont = UIFont(name: "Helvetica", size: 15.0) ?? UIFont.systemFont(ofSize: 15.0)
        style.headerFont = UIFont(name: "Helvetica", size: 20.0) ?? UIFont.systemFont(ofSize: 20.0)
        style.weekdaysFont = UIFont(name: "Helvetica", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
        
        calenderView.style = style
        
        calenderView.direction = .horizontal
        calenderView.marksWeekends = true
        
        if subscribeType == "Scheduled days" {
            calenderView.multipleSelectionEnable = true
        } else {
            calenderView.multipleSelectionEnable = false
        }
        
        addressList_Tableview.delegate = self
        addressList_Tableview.dataSource = self
        addressList_Tableview.isScrollEnabled = false
    }
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone.local
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func deliveryTimeSlotViewDisplay() {
       self.addPicker()
    }
    
    @IBAction func subscribeButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        guard validateTextFileds() == true else {return}
        self.pushSubscripeViewPopup()
    }
    
    func addPicker() {
        
        if picker != nil {
            if picker.isDescendant(of: self.view) {
                return
            }
            picker = nil
        }
        picker = GSCustomPickerView()
        picker.pickerData = ["5 AM - 07 AM", "07 AM - 9 AM", "9 AM - 11 AM", "11 AM - 01 PM", "01 PM - 03 PM"]
        
        picker.showTheView(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom))
        
        picker.selectedPicker { (selected, cancel) in
            if !cancel {
                self.deliveryTimeSlot_TextField.text = selected
            }
        }
    }
    
    // Webservices
    func sendRequestForAmountSubscripeApi() {
        
        let params: [String:Any]
        let hostString = APIurl.baseURL + APIurl.subURL.subscriptionAmount
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        
        if subscribeType == "Scheduled days" {
            params = ["category_id" : storeCategory_id,
                      "scheduled_days": arrayDateList,
                      "subsc_type_id" : subscriberData?.id ?? "",
                      "num_of_delivery" : arrayDateList.count] as [String : Any]
        } else {
            params = ["category_id" : storeCategory_id,
                      "subsc_type_id" : subscriberData?.id ?? "",
                      "num_of_delivery" : arrayDateList.count] as [String : Any]
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
                    #if DEBUG
                        print(responseModel.amount as Any)
                    #endif
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
    
    // MARK: - Validations for Textfields
    func validateTextFileds() -> Bool {
        
        if (arrayDateList.count == 0){
            CustomAlert.showAlert(title: GSString.AppName, message: "Please select the date", viewController: self)
            return false
        }
        
        if (deliveryTimeSlot_TextField.text?.isEmpty)!{
            CustomAlert.showAlert(title: GSString.AppName, message: "Please \(deliveryTimeSlot_TextField?.placeholder ?? "Please enter missing field")", viewController: self)
            return false
        }
        return true
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
        
        razorpayObj = Razorpay.initWithKey(subscriptionKeyID, andDelegate: self)
        
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

        let preferredDate = arrayDateList.first
        let preferedTime = deliveryTimeSlot_TextField.text ?? ""

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

        let seconds = TimeZone.current.secondsFromGMT()
        let milliSeconds = seconds * 1000
        let strMilliSec = "\(milliSeconds)"

        let landMarkString = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_landMark) as? String ?? ""

         let subscriptionName = SharedPersistence.getValue(key: UserDefaultKeys.subscriptionName) ?? ""
        
        var address_object = [String:AnyObject]()
        if landMarkString == "" {
            address_object = [
                "street": street,
                "area": unchangebleAddress,
                "zipcode": intZipCode
                ] as [String:AnyObject]
        } else {
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
                    "scheduled_days": arrayDateList,
                    "startDate": "\(preferredDate ?? "") \(to_time):00:00:000",
                    "deliveryType": selectedDelivery_type,
                    "deliveryTime": [
                        "from": "\(preferredDate ?? "") \(from_time):00:00:000",
                        "to": "\(preferredDate ?? "") \(to_time):00:00:000",
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
                  "num_of_delivery":arrayDateList.count] as [String : Any]

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
}

// MARK: - Delivery Time Slot Methods
extension GSSubscriberViewController:SubscriptionPopViewDelegate {

    func subscriptionName(subscription: String) {
        self.openRazorpayCheckout(subscriptionName: subscription)
    }
}

// RazorpayPaymentCompletionProtocol - This will execute two methods 1.Error and 2. Success case. On payment failure you will get a code and description. In payment success you will get the payment id.
extension GSSubscriberViewController : RazorpayPaymentCompletionProtocol {
    
    func onPaymentError(_ code: Int32, description str: String) {
        print("error: ", code, str)
        //        self.presentAlert(withTitle: "Alert", message: str)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        print("success: ", payment_id)
        self.sendRequestForSubscripeApi(transactionId: payment_id)
        
        //        self.presentAlert(withTitle: "Success", message: "Payment Succeeded")
    }
}

// RazorpayPaymentCompletionProtocolWithData - This will returns you the data in both error and success case. On payment failure you will get a code and description. In payment success you will get the payment id.
extension GSSubscriberViewController: RazorpayPaymentCompletionProtocolWithData {
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        print("error: ", code)
        //        self.presentAlert(withTitle: "Alert", message: str)
    }
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        print("success: ", payment_id)
        //        self.presentAlert(withTitle: "Success", message: "Payment Succeeded")
    }
}

// MARK: - TextField Methods
extension GSSubscriberViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.view .endEditing(true)
        self.deliveryTimeSlotViewDisplay()
    }
}
// MARK: - NavigationBar Methods
extension GSSubscriberViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
    }
}
// MARK:- TableView Delegates
extension GSSubscriberViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
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
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier:"DeliveryAddressTableViewCell" ) as? DeliveryAddressTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.address_EditButton.tag = indexPath.row
        cell.address_EditButton .addTarget(self, action: #selector(addressEditButtonAction(sender:)), for: .touchUpInside)
        
        cell.configureTheCell(address: address_array[indexPath.row].unChangebleAddress, specifiedString: address_array[indexPath.row].changeableAddress, zipCode: address_array[indexPath.row].zipCode, landMark: address_array[indexPath.row].landMark, indexPath: indexPath)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let height = tableView.contentSize.height
        tableviewHeight.constant =  height

        backgroundViewHeight.constant = tableView.contentSize.height + backgroundView.frame.height
    }
    
    @objc func addressRadioButtonAction(sender:UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.addressList_Tableview)
        let indexPath = self.addressList_Tableview.indexPathForRow(at:buttonPosition)
        let cell = self.addressList_Tableview.cellForRow(at: indexPath!) as! DeliveryAddressTableViewCell
        cell.address_radioImage.image = UIImage(named: "radioButton_Active")
        
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
extension GSSubscriberViewController: GSEditAddressPopViewDelegate {
    
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
                self.addressList_Tableview.reloadData()
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

extension GSSubscriberViewController: CalendarViewDataSource {
    
    func startDate() -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.month = 0
        let today = minimumDateForDeliveryDate()
        let threeMonthsAgo = self.calenderView.calendar.date(byAdding: dateComponents, to: today)!
        return threeMonthsAgo
    }
    
    func endDate() -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.month = 12
        let today = Date()
        let twoYearsFromNow = self.calenderView.calendar.date(byAdding: dateComponents, to: today)!
        return twoYearsFromNow
    }
}

extension GSSubscriberViewController: CalendarViewDelegate {
    
    func calendar(_ calendar: CalendarView, didSelectDate date : Date, withEvents events: [CalendarEvent]) {
        print(self.calenderView.selectedDates)

        arrayDateList .removeAll()
        for selectDate in self.calenderView.selectedDates{
            
            let dates = self.formatter.string(from: selectDate)
            arrayDateList .append(dates)
        }
        
        if arrayDateList.count > 0 {
            self.sendRequestForAmountSubscripeApi()
        }
    }
    
    func calendar(_ calendar : CalendarView, didDeselectDate date : Date) -> Void
    {        
        let dates = self.formatter.string(from: date)
        
        let index = arrayDateList .index(of: dates)
        arrayDateList .remove(at: index!)
        
        if arrayDateList.count > 0 {
            self.sendRequestForAmountSubscripeApi()
        }
    }
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
    }
    
    func calendar(_ calendar: CalendarView, didLongPressDate date : Date, withEvents events: [CalendarEvent]?) {
    }
}
