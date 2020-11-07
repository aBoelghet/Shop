//
//  GSSubscribeDailyViewController.swift
//  Shopor
//
//  Created by Ratheesh on 26/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSSubscribeDailyViewController: UIViewController {

    @IBOutlet weak var navigationBar_view:NavigationBarNormal!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var selectDays_Collectionview: UICollectionView!
    
    @IBOutlet weak var selectTimeslot_Textfield: UITextField!
    
    @IBOutlet weak var selectDate_Textfield: UITextField!
    
    @IBOutlet weak var deliveryAddress_Tableview: UITableView!
        
    @IBOutlet weak var backgroundViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var dateBackgroundView: UIView!
    
    @IBOutlet weak var scrollBackground: UIScrollView!
    
    var simpleDatePickerView : GSCustomDatePicker?
    
    var picker:GSCustomPickerView!
    
    var editAddressPopUp:GSEditAddressPopUpView?
    
    var address_array = [OrderConfirmationAddressObject]()
    
    var subscriptionProductData : ProductDataClass?
    var subscriptionDetails = [ProductListData]()

    var changeableAddress = ""
    var unchangebleAddress = ""
    var zipCode = ""
    var landmark = ""
    var street = ""
    
    var subscribeType = ""
    var subscribeId = ""
    var cancelReason = ""
    var feedBackText = ""
    var subscribeName = ""

    var selectedDate:Date!

    var arrayDays = [String]()
    var arrayTimeSlots = [String]()
    
    var selectedArrayList = [Int]()
    var pauseString = ""
    var unSubscribeString = ""

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
        
        self.SendRequestSubscriptionProductDetailsApi(subscriptionId: subscribeId)
        
        arrayDays = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        arrayTimeSlots = ["One time delivery","Anytime Pause or Unsubscribe.","24 Hours Support"]
        
        self.setTextFiledSetups(textField: selectTimeslot_Textfield)
        self.setviewProperties(view: dateBackgroundView)
        selectDate_Textfield.delegate = self
       
        deliveryAddress_Tableview.isScrollEnabled = false
        
        selectDays_Collectionview.isScrollEnabled = false
        
        selectDays_Collectionview.register(UINib(nibName: "collectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier:"collectionHeaderView")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSubscribeButtonAction(notification:)), name: Notification.Name((UserDefaultKeys.subscriptionUpdate)), object: nil)
    }
    
    func setviewProperties(view:UIView)  {
        
        view.layer.cornerRadius = 3
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setTextFiledSetups(textField:UITextField)  {
        
        textField.delegate = self
        textField.layer.cornerRadius = 3
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
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
                    weakSelf.deliveryAddress_Tableview .reloadData()
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
        
        let from =  self.convertTimeRequiredFormat(from_time)
        let to =  self.convertTimeRequiredFormat(to_time)
        
        selectTimeslot_Textfield.text = "\(from) - \(to)"
        
        //StartDate
        let startDate = productData.subscriptionInfo?.startDate ?? ""
        let start_array = startDate.components(separatedBy: " ")

        let startDat = start_array.first
        selectedDate = self.formatter.date(from: startDat ?? "")
        selectedArrayList = (productData.subscriptionInfo!.orderDays)!
        
        selectDate_Textfield.text = startDat
        
        unchangebleAddress = productData.subscriptionInfo?.deliveryAddress?.address?.area ?? ""
        street = productData.subscriptionInfo?.deliveryAddress?.address?.street ?? ""
        landmark = productData.subscriptionInfo?.deliveryAddress?.address?.landmark ?? ""
        zipCode = "\(productData.subscriptionInfo?.deliveryAddress?.address?.zipcode ?? 0)"
        changeableAddress = productData.subscriptionInfo?.deliveryAddress?.address?.street ?? ""

        pauseString = productData.isOnPause == true ? "UnPause" : "Pause"
        unSubscribeString = productData.isUnsubscribed == true ? "Subscribe" : "UnSubscribe" 
        
        subscribeName = productData.title ?? ""

        deliveryAddress_Tableview.delegate = self
        deliveryAddress_Tableview.dataSource = self
        deliveryAddress_Tableview.reloadData()
        selectDays_Collectionview.delegate = self
        selectDays_Collectionview.dataSource = self
        selectDays_Collectionview.reloadData()
    }
    
    // Webservices
    func sendRequestForEditSubscripeApi(transactionId:String) {

        let params: [String:Any]
        let hostString = APIurl.baseURL + APIurl.subURL.subscriptionProductEdits

        let selectedDelivery_type = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryType) as? Int ?? 1
        let intZipCode = Int64(zipCode) ?? 0

        let minimumDeliveryDate = minimumDateForDeliveryDate()
        selectedDate = minimumDeliveryDate

        let defaultDate = "\(formatter.string(from: selectedDate))"
        let preferredDate = selectDate_Textfield!.text // "\(formatter.string(from: selectDate_Textfield!.text))"
        let preferedTime = selectTimeslot_Textfield.text ?? ""

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

        let startDate = (preferredDate ?? defaultDate) + " 00:00:00:000"
        
        let landMarkString = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_landMark) as? String ?? ""

        var address_object = [String:AnyObject]()
        if landMarkString == "" {
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
                    "order_days": selectedArrayList,
                    "startDate": startDate ,
                    "deliveryType": selectedDelivery_type,
                    "deliveryTime": [
                        "from": "\(preferredDate ?? defaultDate) \(from_time):00:00:000",
                        "to": "\((preferredDate ?? defaultDate)) \(to_time):00:00:000",
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
                self.selectDate_Textfield.text = self.convertDateTimeReqFormat(selectedDate)
            }
        })
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

    // Get today date as String
    func getTodayCurrentTimeString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let hour = components.hour
        let today_string = String(hour!)
        return today_string
    }

    fileprivate func convertDateTimeReqFormat(_ inputDate:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // "dd MMM yyyy"
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateStr = dateFormatter.string(from: inputDate)
        return dateStr
    }
    
    fileprivate func convertDateTimeRequiredFormat(_ inputDate:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateStr = dateFormatter.string(from: inputDate)
        return dateStr
    }
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone.local
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate func convertTimeRequiredFormat(_ inputDate:String) -> String {
        
        let dateAsString = inputDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let date = dateFormatter.date(from: dateAsString)
        
        dateFormatter.dateFormat = "h a"
        let timeStr = dateFormatter.string(from: date ?? Date())
   
        return timeStr
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
                self.selectTimeslot_Textfield.text = selected
            }
        }
    }
    
    @IBAction func unSubscribeButtonAction(_ sender: Any) {
        
        if let subscribe = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSSubscriptionCancelPopupViewController") as? GSSubscriptionCancelPopupViewController {
            subscribe.modalPresentationStyle = .overCurrentContext
            subscribe.subscriptionId = subscribeId
            subscribe.delegate = self
            subscribe.subscriptionName = unSubscribeString  == "Subscribe" ? true : false
            present(subscribe, animated: true, completion: nil)
        }
    }
    
    @objc func updateSubscribeButtonAction(notification: Notification) {
        
        if unSubscribeString  == "Subscribe" {
            unSubscribeString = "UnSubscribe"
        } else {
            unSubscribeString = "Subscribe"
        }
        deliveryAddress_Tableview .reloadData()
        
    }
    // MARK: - Validations for Textfields
    func validateTextFileds() -> Bool {
        
        if (selectedArrayList.count == 0){
            CustomAlert.showAlert(title: GSString.AppName, message: "Please select the day", viewController: self)
            return false
        }
        return true
    }
}

// MARK: - Delivery Time Slot Methods
extension GSSubscribeDailyViewController:SubscriptionCancelPopViewDelegate {
    func subscriptionCancelResponseSuccess() {
    }
}

// MARK: - TextField Methods
extension GSSubscribeDailyViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.view .endEditing(true)
        
        if textField == selectTimeslot_Textfield {
            self.deliveryTimeSlotViewDisplay(selectType: "2")
        } else {
            let today = NSDate()
            
            let todayString =  self.formatter.string(from: today as Date)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let dateA = dateFormatter.date(from: todayString)
            let dateB = dateFormatter.date(from: selectDate_Textfield.text!)
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if dateA!.compare(dateB!) == .orderedSame {
                CustomAlert.showAlert(title: GSString.AppName, message: "Scheduled already started", viewController: self)
                // print("Both dates are same")
            } else if dateA!.compare(dateB!) == .orderedAscending {
                self.addDatePicker()
                // print("First Date is smaller then second date")
            } else if dateA?.compare(dateB!) == .orderedDescending {
                CustomAlert.showAlert(title: GSString.AppName, message: "Scheduled already started", viewController: self)
                // print("First Date is greater then second date")
            }
        }
    }
}

// MARK: - NavigationBar Methods
extension GSSubscribeDailyViewController:NavigationBarNormalDelegate {
    
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
extension GSSubscribeDailyViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
            case 1: break
            default: break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    { }
    
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
            subscribe.subscriptionId = self.subscribeId
            subscribe.subscriptionName = unSubscribeString  == "Subscribe" ? false : true
            present(subscribe, animated: true, completion: nil)
        }
    }
    
     @objc func addressRadioButtonAction(sender:UIButton) {

        let buttonPosition = sender.convert(CGPoint.zero, to: self.deliveryAddress_Tableview)
        let indexPath = self.deliveryAddress_Tableview.indexPathForRow(at:buttonPosition)
        let cell = self.deliveryAddress_Tableview.cellForRow(at: indexPath!) as! DeliveryAddressTableViewCell
        cell.address_radioImage.image = UIImage(named: "radioButton_Active")
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
extension GSSubscribeDailyViewController: GSEditAddressPopViewDelegate {
    
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
            self.deliveryAddress_Tableview.reloadData()
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

extension GSSubscribeDailyViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailydaysCollectionViewCell", for: indexPath) as! DailydaysCollectionViewCell
        cell.days_Label.text = arrayDays[indexPath.item]
        
        if subscribeType == "Weekly" {
            if selectedArrayList.contains(indexPath.item) {
                cell.tick_Image.image = UIImage(named: "radioButtonSelect_Active")
            } else {
                cell.tick_Image.image = UIImage(named: "radioButton_InActive")
            }
        } else {
            if selectedArrayList.contains(indexPath.item) {
                cell.tick_Image.image = UIImage(named: "checkedBox_Active")
            } else {
                cell.tick_Image.image = UIImage(named: "checkBox_InActive")
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if subscribeType == "Weekly" {
            selectedArrayList .removeAll()
            selectedArrayList .append(indexPath.item)
            selectDays_Collectionview .reloadData()
        } else {
            if selectedArrayList.contains(indexPath.item) {
                if let index = selectedArrayList.index(of: (indexPath.item)) {
                    selectedArrayList.remove(at: index)
                }
                let cell: DailydaysCollectionViewCell = collectionView.cellForItem(at: indexPath) as! DailydaysCollectionViewCell
                cell.tick_Image.image = UIImage(named: "checkBox_InActive")
            } else {
                let indexValue = indexPath.item
                selectedArrayList .append(indexValue)
                let cell: DailydaysCollectionViewCell = collectionView.cellForItem(at: indexPath) as! DailydaysCollectionViewCell
                cell.tick_Image.image = UIImage(named: "checkedBox_Active")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
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
        return CGSize(width: collectionView.frame.width, height: 30)
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

extension Date {
    
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

// MARK: - SubscriptionProductDetailsModel
struct SubscriptionProductDetailsModel: Codable {
    let success: Bool?
    let data: ProductDataClass?
}

// MARK: - DataClass
struct ProductDataClass: Codable {
    let id, categoryID, subscTypeID, title: String?
    let subscriptionID: String?
    let subscriptionInfo: SubscriptionProductInfo?
    let isActive, isUnsubscribed, isOnPause: Bool?
    let modifiedAt, createdAt: String?
    let shop: [ProductShop]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case categoryID = "category_id"
        case subscTypeID = "subsc_type_id"
        case title
        case subscriptionID = "subscription_id"
        case subscriptionInfo = "subscription_info"
        case isActive = "is_active"
        case isUnsubscribed = "is_unsubscribed"
        case isOnPause = "is_on_pause"
        case modifiedAt = "modified_at"
        case createdAt = "created_at"
        case shop
    }
}

// MARK: - SubscriptionInfo
struct SubscriptionProductInfo: Codable {
    let startDate: String?
    let deliveryAddress: ProductDeliveryAddress?
    let deliveryTime: ProductDeliveryTime?
    let deliveryType: Int?
    let orderDays: [Int]?
    let scheduledDays: [String]?

    enum CodingKeys: String, CodingKey {
        case startDate, deliveryAddress, deliveryTime, deliveryType
        case orderDays = "order_days"
        case scheduledDays = "scheduled_days"
    }
}

// MARK: - DeliveryAddress
struct ProductDeliveryAddress: Codable {
    let address: ProductAddress?
    let location: ProductLocation?
}

// MARK: - Address
struct ProductAddress: Codable {
    let area, landmark, street: String?
    let zipcode: Int?
}

// MARK: - Location
struct ProductLocation: Codable {
    let coordinates: [Double]?
    let type: String?
}

// MARK: - DeliveryTime
struct ProductDeliveryTime: Codable {
    let to, offset, from: String?
}
// MARK: - Shop
struct ProductShop: Codable {
    let address: ProductShopAddress?
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case address
        case displayName = "display_name"
    }
}
// MARK: - ShopAddress
struct ProductShopAddress: Codable {
    let locationID, street: String?
    let zipcode: Int?
    
    enum CodingKeys: String, CodingKey {
        case locationID = "location_id"
        case street, zipcode
    }
}
