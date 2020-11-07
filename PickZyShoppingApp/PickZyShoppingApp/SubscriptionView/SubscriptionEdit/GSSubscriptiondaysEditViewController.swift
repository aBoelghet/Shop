//
//  GSSubscriptiondaysEditViewController.swift
//  Shopor
//
//  Created by Ratheesh on 04/03/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import Razorpay

class GSSubscriptiondaysEditViewController: UIViewController {

    
    @IBOutlet weak var navigationBar_view:NavigationBarNormal!
    
    @IBOutlet weak var selectDateLabel: UILabel!
    
    @IBOutlet weak var addressList_Tableview: UITableView!
    
    @IBOutlet weak var deliveryTimeSlot_TextField: UITextField!
    
    @IBOutlet weak var calenderView: CalendarView!
    
    var picker:GSCustomPickerView!
    
    var editAddressPopUp:GSEditAddressPopUpView?
    
    var subscriberData : SubscriptionTypeData?
    
    var address_array = [OrderConfirmationAddressObject]()
    
    var razorpayObj : Razorpay? = nil
    
    var subscriptionProductData : ProductDataClass?
    
    var changeableAddress = ""
    var unchangebleAddress = ""
    var zipCode = ""
    var landmark = ""
    var street = ""

    var subscribeType = ""
    var subscribeAmount = Double()
    var subscriptionKeyID = ""
    var selectedDate:Date!
    var subscribeId = ""
    var subscribeName = ""

    var pauseString = ""
    var unSubscribeString = ""
    
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

        self.SendRequestSubscriptionProductDetailsApi(subscriptionId: subscribeId)

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
        
        
        deliveryTimeSlot_TextField.delegate = self
        deliveryTimeSlot_TextField.layer.cornerRadius = 3
        deliveryTimeSlot_TextField.layer.borderWidth = 1
        deliveryTimeSlot_TextField.layer.borderColor =  UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND).cgColor
        
        calenderView.layer.cornerRadius = 3
        calenderView.clipsToBounds = true
        calenderView.layer.borderColor =  UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND).cgColor
        calenderView.layer.borderWidth = 1
        
        calenderView.dataSource = self

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
        
        addressList_Tableview.isScrollEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSubscribeButtonAction(notification:)), name: Notification.Name((UserDefaultKeys.subscriptionUpdate)), object: nil)
    }
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.local
        formatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    private func deliveryTimeSlotViewDisplay() {
        
        self.addPicker()
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
    
    fileprivate func minimumDateForDeliveryDate() -> Date {
        
        let _date = Date()
        let hour = Calendar.current.component(.hour, from: _date)
        let date = Date.tomorrow
        switch hour {
        case 0..<16 : return date
        case 16..<24 : return Calendar.current.date(byAdding: .day, value: 1, to: date) ?? Date()
        default:
            return date
        }
    }
    
    fileprivate func convertTimeRequiredFormat(_ inputDate:String) -> String {
        
        let dateAsString = inputDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let date = dateFormatter.date(from: dateAsString)
        
        dateFormatter.dateFormat = "h a"
        let timeStr = dateFormatter.string(from: date!)
        
        return timeStr
    }

    // Get today date as String
    func getTodayCurrentTimeString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let hour = components.hour
        
        let today_string = String(hour!)
        
        return today_string
        
    }
    // Webservices
    func sendRequestForEditSubscripeApi(transactionId:String) {
        
        let params: [String:Any]
        let hostString = APIurl.baseURL + APIurl.subURL.subscriptionProductEdits
        
        let selectedDelivery_type = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryType) as? Int ?? 1
       
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
        
        let startDate = "\(preferredDate ?? "") \(to_time):00:00:000"
        
        let intZipCode = Int64(zipCode) ?? 0

        let landMarkString = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_landMark) as? String ?? ""

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
        
        
        params = ["subs_mongo_id":transactionId ,
                  "is_auto_payment": false,
                  "subscription_title": subscribeName,
                  "subscriptionInfo": [
                    "scheduled_days": arrayDateList,
                    "startDate": startDate ,
                    "deliveryType": selectedDelivery_type,
                    "deliveryTime": [
                        "from": "\(preferredDate ?? "") \(from_time):00:00:000",
                        "to": "\(preferredDate ?? "") \(to_time):00:00:000",
                        "offset": strMilliSec
                    ],
                    "deliveryAddress": [
                        "address": address_object
                    ]
            ]] as [String : Any]
        
        #if DEBUG
        print(params)
        #endif
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject],urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionProductEditModel.self, from: responseData)
                    weakSelf.showAlertMessage(message: responseModel.message ?? "")

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
    func showAlertMessage(message:String)
    {
        let alert = UIAlertController.init(title: GSString.AppName, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okaction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(okaction)
        self.present(alert,animated: true,completion: nil)
    }
   
    func pushtoSubscribeSuccessView(subscriptionData:SubscriptionOrderData)  {
        
        if let success = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSSubscriberSuccessViewController") as? GSSubscriberSuccessViewController {
            success.placeOrderResponse = subscriptionData
            navigationController?.pushViewController(success, animated: true)
        }
       
    }
    
    // Common method to fetch the ProductDetailsApi from server
    fileprivate func SendRequestSubscriptionProductDetailsApi(subscriptionId:String) {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionProductDetails
        
        let  params = ["subs_mongo_id" : subscriptionId,] as [String : Any]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionProductDetailsModel.self, from: responseData)
                    
                    if let typesArray = responseModel.data {
                        print(typesArray)
                        weakSelf.subscriptionProductData = typesArray
                        weakSelf.productDataDetails(productData: typesArray)
                    }
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
            
        }
    }
    // Common method to fetch the recharge wallet from server
    fileprivate func SendRequestSubscriptionProductPauseApi(subscriptionId:String, isPause:Bool) {

        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionProductPause
        
        let  params = ["subs_mongo_id" : subscriptionId,
                       "is_pause": isPause] as [String : Any]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionProductEditModel.self, from: responseData)
                    CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: weakSelf)
                    if isPause == true{
                        weakSelf.pauseString = "UnPause"
                    } else {
                        weakSelf.pauseString = "Pause"
                    }
                    weakSelf.addressList_Tableview.reloadData()

                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
            
        }
    }
    
    func productDataDetails(productData:ProductDataClass) {
        
        
        let fromdate = productData.subscriptionInfo?.deliveryTime?.from ?? ""
        let todate = productData.subscriptionInfo?.deliveryTime?.to ?? ""
        
        let from_array = fromdate.components(separatedBy: " ")
        let to_array = todate.components(separatedBy: " ")
        
        var from_time = ""
        var to_time = ""
        if from_array.count > 1 {
            from_time = from_array[1].removeEnclosedWhieteSpace().components(separatedBy: ":").first ?? ""
            
        }
        if to_array.count > 1 {
            to_time = to_array[1].removeEnclosedWhieteSpace().components(separatedBy: ":").first ?? ""
            
        }
        
        pauseString = productData.isOnPause == true ? "UnPause" : "Pause"
        unSubscribeString = productData.isUnsubscribed == true ? "Subscribe" : "UnSubscribe"

        addressList_Tableview.estimatedRowHeight = 80
        addressList_Tableview.delegate = self
        addressList_Tableview.dataSource = self
        addressList_Tableview.reloadData()
        
        let from =  self.convertTimeRequiredFormat(from_time)
        let to =  self.convertTimeRequiredFormat(to_time)
        
        deliveryTimeSlot_TextField.text = "\(from) - \(to)"

        unchangebleAddress = productData.subscriptionInfo?.deliveryAddress?.address?.area ?? ""
        street = productData.subscriptionInfo?.deliveryAddress?.address?.street ?? ""
        landmark = productData.subscriptionInfo?.deliveryAddress?.address?.landmark ?? ""
        zipCode = "\(productData.subscriptionInfo?.deliveryAddress?.address?.zipcode ?? 0)"
        changeableAddress = productData.subscriptionInfo?.deliveryAddress?.address?.street ?? ""

        subscribeName = productData.title ?? ""
        
        arrayDateList = (productData.subscriptionInfo!.scheduledDays)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for date in ((productData.subscriptionInfo!.scheduledDays)!){
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let datevalue = dateFormatter.date(from: date)
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.calenderView.selectDate(datevalue!)
        }
        calenderView.delegate = self
        
        var convertedArray: [Date] = []
        
        for dat in arrayDateList {
            let date = dateFormatter.date(from: dat)
            if let date = date {
                convertedArray.append(date)
            }
        }
        
        let convertedList = convertedArray.sorted(by: { $0.compare($1) == .orderedAscending })
        
        let firstMonth = dateFormatter.string(from: convertedList.first ?? Date())
       
        let times_array = firstMonth.components(separatedBy: "-")
        let month = times_array[1]
        let today = NSDate()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentMonth = dateFormatter.string(from:today as Date)
        let curentMoth_array = currentMonth.components(separatedBy: "-")
        let currentmonth = curentMoth_array[1]
        let dislayMonth: Int = (Int(month) ?? 0) - (Int(currentmonth) ?? 0)

        calenderView.goToMonthWithOffet(dislayMonth )

    }
   
    @IBAction func subscribeButtonAction(_ sender: Any) {
        
        if let subscribe = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSSubscriptionCancelPopupViewController") as? GSSubscriptionCancelPopupViewController {
            subscribe.modalPresentationStyle = .overCurrentContext
            subscribe.subscriptionId = subscribeId
            present(subscribe, animated: true, completion: nil)
        }
       
    }
    @objc func updateSubscribeButtonAction(notification: Notification) {
        
        if unSubscribeString  == "Subscribe" {
            unSubscribeString = "UnSubscribe"
        } else{
            unSubscribeString = "Subscribe"
        }
        addressList_Tableview .reloadData()
        
    }
    
}
// MARK: - Delivery Time Slot Methods
extension GSSubscriptiondaysEditViewController:SubscriptionPopViewDelegate {
    func subscriptionName(subscription: String) {
        
    }
    
}

// MARK: - TextField Methods
extension GSSubscriptiondaysEditViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.view .endEditing(true)
        self.deliveryTimeSlotViewDisplay()
    }
}
// MARK: - NavigationBar Methods
extension GSSubscriptiondaysEditViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        self.view.endEditing(true)
        guard validateTextFileds() == true else {return}
        self.sendRequestForEditSubscripeApi(transactionId: subscribeId)
    }
}
// MARK:- TableView Delegates
extension GSSubscriptiondaysEditViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return (subscriptionProductData?.shop!.count)!
        case 1:
            return 1
        default:
            return 0
        }
        
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
        headerView.addSubview(title_lable)
        
        title_lable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: title_lable, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        switch section {
        case 0:
            
            title_lable.text = "Shop Address:"
            
        case 1:
            
            title_lable.text = "Current delivery address:"
            
        default: break
            
        }
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            
            return 0.01
            
        case 1:
            
            return 100
            
        default: break
            
        }
        return 100
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 100))
        footerView.backgroundColor = UIColor .white
        
        let pauseButton = UIButton()
        pauseButton.frame = CGRect(x: 0, y: 5, width: footerView.frame.size.width , height: 40)
        pauseButton.titleLabel?.font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont(name: "HelveticaNeue-Medium", size: 16) : UIFont(name: "HelveticaNeue-Medium", size: 14)
        pauseButton.setTitleColor(UIColor(hexString: defaultTheme.underLineButtonTxt) , for: .normal)
        pauseButton .setTitle(pauseString, for: .normal)
        pauseButton.contentHorizontalAlignment = .center
        pauseButton.addTarget(self, action: #selector(actionPauseButton(sender:)), for: .touchUpInside)
        footerView.addSubview(pauseButton)
        
        let unSubscribeButton = UIButton()
        unSubscribeButton.frame = CGRect(x: 0, y:pauseButton.frame.maxY + 5, width: footerView.frame.size.width , height: 40)
        unSubscribeButton.titleLabel?.font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont(name: "HelveticaNeue-Medium", size: 16) : UIFont(name: "HelveticaNeue-Medium", size: 14)
        unSubscribeButton.setTitleColor(UIColor(hexString: defaultTheme.underLineButtonTxt) , for: .normal)
        unSubscribeButton .setTitle(unSubscribeString, for: .normal)
        unSubscribeButton.contentHorizontalAlignment = .center
        unSubscribeButton.addTarget(self, action: #selector(actionUnSubscribeButton(sender:)), for: .touchUpInside)
        footerView.addSubview(unSubscribeButton)
        
        pauseButton.isHidden = unSubscribeString == "Subscribe" ? true : false

        
        switch section {
        case 0:
            
            footerView.isHidden = true
            
        case 1:
            
            footerView.isHidden = false
            
        default: break
            
        }
        
        return footerView
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier:"ShopAddressTableViewCell" ) as? ShopAddressTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            let shopName = subscriptionProductData?.shop?[indexPath.row].displayName ?? ""
            
            cell.shopAddress_Label.attributedText = String().getAttributedString(firstString: "\(shopName)\n", firstFont: UIFont.boldSystemFont(ofSize: 14), firstColor: UIColor.darkGray, secondString: "\(subscriptionProductData?.shop?[indexPath.row].address?.street ?? "")", secondFont: UIFont.systemFont(ofSize: 12), secondColor: UIColor.darkGray)

            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier:"DeliveryAddressTableViewCell" ) as? DeliveryAddressTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
//            let street = subscriptionProductData?.subscriptionInfo?.deliveryAddress?.address?.street ?? ""
//            let zipcode = subscriptionProductData?.subscriptionInfo?.deliveryAddress?.address?.zipcode ?? 0
//            cell.address_Label.text = "\(street), \(zipcode)"
            cell.address_EditButton.tag = indexPath.row
            cell.address_EditButton .addTarget(self, action: #selector(addressEditButtonAction(sender:)), for: .touchUpInside)
         
            cell.configureTheCell(address: unchangebleAddress, specifiedString: changeableAddress, zipCode: zipCode, landMark: landmark, indexPath: indexPath)

            return cell
            
        default: break
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0: break
            
        case 1:
            
            let cell: DeliveryAddressTableViewCell = tableView.cellForRow(at: indexPath) as! DeliveryAddressTableViewCell
            cell.address_radioImage.image = UIImage(named: "radioButton_Active")
            
        default: break
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        
        
    }
    
    @objc func actionPauseButton(sender:UIButton) {
        
        let message = sender.titleLabel?.text == "Pause" ? GSConstant.AlertMessages.pauseSubscription : GSConstant.AlertMessages.unPauseSubscription

        CustomAlert.showAlert(title: "", message: message, alertButtonsArray: ["Cancel","Ok"], isLastButtonDestructive: true, viewController: self) { btnIndex in
            
            if btnIndex == 1 {
                if sender.titleLabel?.text == "Pause" {
                    self.SendRequestSubscriptionProductPauseApi(subscriptionId: self.subscribeId, isPause: true)
                    
                } else {
                    self.SendRequestSubscriptionProductPauseApi(subscriptionId: self.subscribeId, isPause: false)
                    
                }
                return
            }
        }
        
    }
    @objc func actionUnSubscribeButton(sender:UIButton) {
        
        if sender.titleLabel?.text == "Subscribe" {
            CustomAlert.showAlert(title: "", message: GSConstant.AlertMessages.subscriptionalert, alertButtonsArray: ["Cancel","Ok"], isLastButtonDestructive: true, viewController: self) { btnIndex in
                
                if btnIndex == 1 {
                    self.SendRequestSubscriptionProductUnSubscribedApi(subscriptionId: self.subscribeId, isSubscribe: false)
                    return
                }
            }
            
        } else {
            CustomAlert.showAlert(title: "", message: GSConstant.AlertMessages.unSubscription, alertButtonsArray: ["Cancel","Ok"], isLastButtonDestructive: true, viewController: self) { btnIndex in
                
                if btnIndex == 1 {
                    self.pushSubscribecancelViewMethod()
                    return
                }
            }
        }
    }
    func pushSubscribecancelViewMethod()  {
        if let subscribe = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSSubscriptionCancelPopupViewController") as? GSSubscriptionCancelPopupViewController {
            subscribe.modalPresentationStyle = .overCurrentContext
            subscribe.subscriptionId = subscribeId
            subscribe.subscriptionName = unSubscribeString  == "Subscribe" ? false : true
            present(subscribe, animated: true, completion: nil)
        }
    }
    // Common method to fetch the recharge wallet from server
    fileprivate func SendRequestSubscriptionProductUnSubscribedApi(subscriptionId:String, isSubscribe:Bool) {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionProductUnSubscribe
        
        let  params = ["subs_mongo_id" : subscriptionId,
                       "is_unsubscribed": isSubscribe,
                       "feedback_text": "Subscribe",
                       "note": "Subscribe"] as [String : Any]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionProductEditModel.self, from: responseData)
                    NotificationCenter.default.post(name: Notification.Name(UserDefaultKeys.subscriptionUpdate), object: nil)
                    
                    CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: weakSelf)
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
            
        }
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

extension GSSubscriptiondaysEditViewController: GSEditAddressPopViewDelegate {
    
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

        //To call or execute function after some time
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //Here call your function
            self.addressList_Tableview.reloadData()
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

extension GSSubscriptiondaysEditViewController: CalendarViewDataSource {
    
    func startDate() -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.month = 0
        let today = Date.tomorrow
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

extension GSSubscriptiondaysEditViewController: CalendarViewDelegate {
    
    func calendar(_ calendar: CalendarView, didSelectDate date : Date, withEvents events: [CalendarEvent]) {
        print(self.calenderView.selectedDates)
        arrayDateList .removeAll()
        for selectDate in self.calenderView.selectedDates{
            
            let dates = self.formatter.string(from: selectDate)
            
            arrayDateList .append(dates)
            
        }
    }
    func calendar(_ calendar : CalendarView, didDeselectDate date : Date) -> Void
    {
        let dates = self.formatter.string(from: date)
        
        let index = arrayDateList .index(of: dates)
        arrayDateList .remove(at: index!)
        
    }
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
       
        
    }
    
    func calendar(_ calendar: CalendarView, didLongPressDate date : Date, withEvents events: [CalendarEvent]?) {
        
        
    }
}


// MARK: - SubscriptionProductEditModel
struct SubscriptionProductEditModel: Codable {
    let success: Bool?
    let message: String?
}
