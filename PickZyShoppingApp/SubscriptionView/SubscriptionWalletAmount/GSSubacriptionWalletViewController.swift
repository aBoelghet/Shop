//
//  GSSubacriptionWalletViewController.swift
//  Shopor
//
//  Created by Ratheesh on 25/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import Razorpay
import MBProgressHUD
import IQKeyboardManagerSwift

class GSSubacriptionWalletViewController: GSLoggedInBaseViewController {

    @IBOutlet weak var navigationbar_View: NavigationBarNormal!
    
    @IBOutlet weak var walletAmount_Label: UILabel!
    
    @IBOutlet weak var walletAmount_Textfield: UITextField!
    
    @IBOutlet weak var walletAmount_Collectionview: UICollectionView!
    
    @IBOutlet weak var collectionView_Height: NSLayoutConstraint!
    
    @IBOutlet weak var subscriptionList_Tableview: UITableView!
    
    @IBOutlet weak var sendAmountButton: UIButton!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var addMoneyButton: UIButton!
    
    @IBOutlet weak var addMoneyView: UIView!
    
    @IBOutlet weak var insufficientLabel: UILabel!
    
    @IBOutlet weak var topview_Height: NSLayoutConstraint!
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var separatorView: UIView!
    
    
    var arrayWalletAmount = [Int]()
    var arraySubscriptionList = [SubscriptionList]()
    
    var razorpayObj : RazorpayCheckout? = nil
    var subscriptionKeyID = ""

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationBarMethod()
        self.viewInitializedMethod()
    }
    
    func navigationBarMethod()  {
        
        navigationbar_View.delegate = self
        navigationbar_View.titleLable.text = "Subscription"
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
       
        self.SendRequestSubscriptionWalletAmountApi()
        self.SendRequestSubscriptionListApi()
    }
    
    func viewInitializedMethod()  {
        
        insufficientLabel.isHidden = true
        addMoneyView.isHidden = true
        collectionView_Height.constant = 0
        addMoneyButton.isHidden = false
        sendAmountButton.isHidden = true
        separatorView.isHidden = true
        
        self.setviewProperties(button: addMoneyButton)
        self.setviewProperties(view: topView)

        subscriptionList_Tableview.delegate = self
        subscriptionList_Tableview.dataSource = self
       
        walletAmount_Collectionview.delegate = self
        walletAmount_Collectionview.dataSource = self
        
        walletAmount_Textfield.keyboardType = .decimalPad
        walletAmount_Textfield.delegate = self
        walletAmount_Textfield.addTarget(self, action: #selector(TextFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setviewProperties(button:UIButton)  {
        
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 1
        button.layer.borderColor =  UIColor(hexString: "33b754").cgColor
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5)
    }
    
    func setviewProperties(view:UIView)  {
        
        view.layer.cornerRadius = 3
        view.layer.borderWidth = 1
        view.layer.borderColor =  UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND).cgColor
    }
    
    @IBAction func addMoneyButtonAction(_ sender: Any) {
        
        addMoneyButton.isHidden = true
        addMoneyView.isHidden = false
        sendAmountButton.isHidden = true
        let height = walletAmount_Collectionview.contentSize.height
        collectionView_Height.constant =  height
        separatorView.isHidden = false
    }
    
    @IBAction func sendAmountButtonAction(_ sender: Any) {
        
        self.view .endEditing(true)
        guard validateTextFileds() == true else {return}
        guard let amount = Int(walletAmount_Textfield.text ?? "") else { return  }
        let amountVal = amount * 100
        self.openRazorpayAaaWalletAmountCheckout(walletAmount: "\(amountVal)")
    }
    
    // Common method to fetch the wallet amount from server
    fileprivate func SendRequestSubscriptionWalletAmountApi() {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionWalletAmount
        
        APIHandler.NetworkSetupRequest(method: .post, params: [String : AnyObject]() ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionWalletAmountModel.self, from: responseData)
                    
                    let amount = Double(round(100*responseModel.balance! )/100)

                    weakSelf.walletAmount_Label.text =  "₹\(String(describing: amount))"
                    
                    weakSelf.subscriptionKeyID = responseModel.payKeyID ?? ""

                    let intVal = Int(responseModel.balance ?? 0)
                    
                    if intVal == 0 {
                        weakSelf.insufficientLabel.isHidden = false
                    } else {
                         weakSelf.insufficientLabel.isHidden = true
                    }
                    
                    if let typesArray = responseModel.rechargeAmounts {
                        print(typesArray)
                        if typesArray.count > 0 {
                            weakSelf.arrayWalletAmount = typesArray
                            weakSelf.walletAmount_Collectionview.reloadData()
                        }
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
    
    // Common method to fetch the subscription list from server
    fileprivate func SendRequestSubscriptionListApi() {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionList
        
        let  params = ["status" : "1",] as [String : Any]
   
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionListModel.self, from: responseData)
                    
                    if let typesArray = responseModel.data {
                        #if DEBUG
                            print(typesArray)
                        #endif
                        if typesArray.count > 0 {
                            weakSelf.arraySubscriptionList = typesArray
                            weakSelf.subscriptionList_Tableview.reloadData()
                        }
                    }
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
    
    // Common method to fetch the recharge wallet from server
    fileprivate func SendRequestSubscriptionRechargeApi(paymentId:String) {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionRecharge
        
        let  params = ["paymentId" : paymentId,] as [String : Any]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionRechargeModel.self, from: responseData)
                    
                    weakSelf.walletAmount_Collectionview.reloadData()
                    weakSelf.walletAmount_Textfield.text = ""
                    weakSelf.walletAmount_Label.text =  "₹\(String(describing: responseModel.balance!))"
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
    
    private func openRazorpayAaaWalletAmountCheckout(walletAmount:String) {
        
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
            "amount" : walletAmount,
            "name" : userName,
        ]
        
        if let rzp = self.razorpayObj {
            rzp.open(options)
        } else {
            print("Unable to initialize")
        }
    }
    
    // MARK: - Validations for Textfields
    func validateTextFileds() -> Bool {
        
        if (walletAmount_Textfield.text?.isEmpty)!{
            CustomAlert.showAlert(title: GSString.AppName, message: "Please enter \(walletAmount_Textfield?.placeholder ?? "Please enter missing field")", viewController: self)
            return false
        }
        return true
    }
}

// RazorpayPaymentCompletionProtocol - This will execute two methods 1.Error and 2. Success case. On payment failure you will get a code and description. In payment success you will get the payment id.
extension GSSubacriptionWalletViewController : RazorpayPaymentCompletionProtocol {
    
    func onPaymentError(_ code: Int32, description str: String) {
        print("error: ", code, str)
        // self.presentAlert(withTitle: "Alert", message: str)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        print("success: ", payment_id)
        self.SendRequestSubscriptionRechargeApi(paymentId: payment_id)
        // self.presentAlert(withTitle: "Success", message: "Payment Succeeded")
    }
}

// RazorpayPaymentCompletionProtocolWithData - This will returns you the data in both error and success case. On payment failure you will get a code and description. In payment success you will get the payment id.
extension GSSubacriptionWalletViewController: RazorpayPaymentCompletionProtocolWithData {
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        print("error: ", code)
        // self.presentAlert(withTitle: "Alert", message: str)
    }
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        print("success: ", payment_id)
        // self.presentAlert(withTitle: "Success", message: "Payment Succeeded")
    }
}

// MARK: - TextField Methods
extension GSSubacriptionWalletViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    @objc func TextFieldDidChange(_ textField: UITextField) {
        
        if walletAmount_Textfield.text!.isEmpty {
            sendAmountButton.isHidden = true
        } else {
            sendAmountButton.isHidden = false
        }
    }
}

extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.currencySymbol = "₹"
        formatter.numberStyle = .currencyAccounting
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
}

// MARK: - NavigationBar Methods
extension GSSubacriptionWalletViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        addSideMenu()
    }
    
    func rightBarBtnPressed(sender:UIButton) {
    }
}

// MARK:- TableView Delegates
extension GSSubacriptionWalletViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arraySubscriptionList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30.0
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView = UIView()
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        headerView.backgroundColor = UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND)
        
        let title_lable = UILabel()
        title_lable.text = "Subscription List"
        title_lable.font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont(name: "HelveticaNeue-Medium", size: 16) : UIFont(name: "HelveticaNeue-Medium", size: 14)
        title_lable.textColor = UIColor(hexString: defaultTheme.cart_header_title)
        headerView.addSubview(title_lable)
        
        title_lable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: title_lable, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier:"SubscriptionListTableViewCell" ) as? SubscriptionListTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.subscriptionTypeLabel.text = arraySubscriptionList[indexPath.row].subscriptionType ?? ""
    
        let isActive = arraySubscriptionList[indexPath.row].isActive
        let isPause = arraySubscriptionList[indexPath.row].isOnPause
        let isUnsubscribe = arraySubscriptionList[indexPath.row].isUnsubscribed
    
        if isActive == true && isUnsubscribe == false && isPause == false {
            cell.statusLabel.text = "Active"
            cell.statusLabel.textColor = UIColor(hexString:defaultTheme.underLineButtonTxt)
            
        } else if isActive == true && isPause == true && isUnsubscribe == false {
            cell.statusLabel.text = "Paused"
            cell.statusLabel.textColor = UIColor(hexString:"e40000")
           
        } else if isActive == true && isPause == false && isUnsubscribe == true {
            cell.statusLabel.text = "UnSubscribed"
            cell.statusLabel.textColor = UIColor(hexString:"ff9800")
            
        } else if isUnsubscribe == true && isPause == true  && isActive == true {
            cell.statusLabel.text = "UnSubscribed \n Paused"
            cell.statusLabel.textColor = UIColor.black
        }
        cell.title_Label.text = arraySubscriptionList[indexPath.row].title ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let product = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSProductListViewController") as? GSProductListViewController {
            product.subscriptionId = arraySubscriptionList[indexPath.row].id ?? ""
            product.subscriptionType = arraySubscriptionList[indexPath.row].subscriptionType ?? ""
            navigationController?.pushViewController(product, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    { }
}

extension GSSubacriptionWalletViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayWalletAmount.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletAmountCollectionViewCell", for: indexPath) as! WalletAmountCollectionViewCell
        cell.walletAmount_Label.text =  "₹\(arrayWalletAmount[indexPath.row])"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let amountVal = arrayWalletAmount[indexPath.row] * 100
        self.openRazorpayAaaWalletAmountCheckout(walletAmount:"\(amountVal)")
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
        return CGSize(width: cellWidth, height: 30)
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
        collectionView_Height.constant =  height
        
    }
}

// MARK: - SubscriptionWalletAmountModel
struct SubscriptionWalletAmountModel: Codable {
    let success: Bool?
    let balance: Double?
    let rechargeAmounts: [Int]?
    let payKeyID: String?

    enum CodingKeys: String, CodingKey {
        case success, balance
        case rechargeAmounts = "recharge_amounts"
        case payKeyID = "pay_key_id"

    }
}

// MARK: - SubscriptionListModel
struct SubscriptionListModel: Codable {
    let success: Bool?
    let count: Int?
    let data: [SubscriptionList]?
}

// MARK: - Datum
struct SubscriptionList: Codable {
    let id, categoryID, subscTypeID, title: String?
    let subscriptionID: String?
    let isActive, isUnsubscribed, isOnPause: Bool?
    let createdAt, modifiedAt, subscriptionType: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case categoryID = "category_id"
        case subscTypeID = "subsc_type_id"
        case title
        case subscriptionID = "subscription_id"
        case isActive = "is_active"
        case isUnsubscribed = "is_unsubscribed"
        case isOnPause = "is_on_pause"
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
        case subscriptionType = "subsc_type_name"

    }
}
// MARK: - SubscriptionRechargeModel
struct SubscriptionRechargeModel: Codable {
    let success: Bool?
    let balance: Double?
    let message: String?
}

