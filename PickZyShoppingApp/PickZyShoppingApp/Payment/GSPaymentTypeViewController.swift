//
//  GSPaymentTypeViewController.swift
//  SampleSwift
//
//  Created by Ratheesh TR on 20/02/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import Foundation
import UIKit
import PayU_coreSDK_Swift
import MKToolTip
import Razorpay

class GSPaymentTypeViewController: GSPaymentViewController {
    
    var isGoingToOrder : Bool = false
    var isPaymentConfigurationFromCart = false
    var purchaseAmountToPay : String = "0.0";
    var purchaseAmountToShow = "0.0"
    var selectedIndexPath : IndexPath?
    var previousSelectedIndexPath : IndexPath?
    
    var saveSelectedMethod = GSSavePaymentMethod()
    var availableNetBanking = [AnyObject]()
    
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var paymentListTable: UITableView!
    
    var paymentParamHelper  = GSPaymentParametersHelper()
    var paymentParams : PayUModelPaymentParams? = nil
    var paymentParamsWithBayFayCash: PayUModelPaymentParams?
    var paymentParamsWithOutBayFayCash: PayUModelPaymentParams?
    let paymentWebService   = PayUWebService()
    
    var toolTip:MKToolTip?
    
    var placeOrderHelper:GSPlaceOrderHelper?
    var upiAlerView: GSUpiAlertView!
    var numberOfRowsInCodColumn = 1
    
    let headerHeight :CGFloat = 40.0
    let cellHeight :CGFloat = 50.0
    
    var isInEditingMode = false
    var isBayFayCashSelected = false
    var bayFayCoins: Double = 0
    
    var razorpayObj : Razorpay? = nil
    var  paymentHashData : GSPaymentHashesData?
    

    struct GSPaymentTypeListModel {
        let type: GSPaymentTypeEnum
        let title:String
        let headerTitle:String
        var savedCardArray: [AnyObject]?
        var wallets: [AnyObject]?
        let icon: UIImage?
    }
    enum GSPaymentTypeEnum {
        case cash
        case creditDebit
        case addPayment
        case internetBanking
        case upi
        case wallet
        case bayfayCash
        case promocode
    }
    
    var paymentTypeList_array = [GSPaymentTypeListModel]()
    var isCashBackOffer = false
    
    //MARK: View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        addFewIntializers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            
            if let decodedSavedPaymentMethod = SharedPersistence.getValue(key: GSPaymentConstants.SAVED_CARD_METHOD) as? Data {
                
                if let decodedSavedPaymentMethod = try? JSONDecoder().decode(GSSavePaymentMethod.self, from: decodedSavedPaymentMethod) {
                    self.saveSelectedMethod = decodedSavedPaymentMethod
                }
            }
            self.paymentListTable.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationBarView.navigationBarReload()
        GSConstant.linearBar.startAnimation()
        
        bayFayCashAPI()
        
        paymentParamsWithBayFayCash = nil
        paymentParamsWithOutBayFayCash = nil
        paymentParams = nil
        
        paymentParamHelper.setPaymentParams(isGoingToOrder: isGoingToOrder, isBayFayCash: false, transactionAmount: String(purchaseAmountToPay)) { (parameters, error) in
            
            if error == nil {
                self.paymentParams = parameters!
                self.paymentParamsWithOutBayFayCash = parameters!
                self.fetchPaymentOptions()
            }
            if self.isBayFayCashSelected == false {
                self.updatePurchaseAmount()
            }
            
           /* else {
                if self.checkPaymentParam() {
                    return
                }
            } */
        }
        
        if isGoingToOrder {
            paymentParamHelper.setPaymentParams(isGoingToOrder: isGoingToOrder, isBayFayCash: true, transactionAmount: String(purchaseAmountToPay)) { (parameters, error) in

                if error == nil {
                    self.paymentParamsWithBayFayCash = parameters!
                }

                if self.isBayFayCashSelected  {
                    self.updatePurchaseAmount()
                }
            }
        }
    }
    
    private func updatePurchaseAmount() {
        
        if self.isBayFayCashSelected {
            
            if let appliedPromoCode = SharedPersistence.getValue(key: UserDefaultKeys.Payment.promoCode) as? String, appliedPromoCode != "", self.paymentParamsWithBayFayCash == nil {
                CustomAlert.showAlert(title: GSString.AppName, message: "Unable to apply promo code", viewController: self)
                SharedPersistence.removeValue(key: UserDefaultKeys.Payment.promoCode)
                viewWillAppear(false)
                return
            }
            
            self.purchaseAmountToShow = self.paymentParamsWithBayFayCash?.amount ?? "0"
            self.paymentParams = self.paymentParamsWithBayFayCash
            
        } else {
            
            if let appliedPromoCode = SharedPersistence.getValue(key: UserDefaultKeys.Payment.promoCode) as? String, appliedPromoCode != "", self.paymentParamsWithOutBayFayCash == nil {
                CustomAlert.showAlert(title: GSString.AppName, message: "Unable to apply promo code", viewController: self)
                SharedPersistence.removeValue(key: UserDefaultKeys.Payment.promoCode)
                viewWillAppear(false)
                return
            }
            
            self.purchaseAmountToShow = self.paymentParamsWithOutBayFayCash?.amount ?? "0"
            self.paymentParams = self.paymentParamsWithOutBayFayCash
        }
    }
    
    func fetchPaymentOptions() {
        // temporary bool for UI updation
        // var updateUITempBool = false
        paymentParams?.isOneTap = false
        
        
        if self.checkPaymentParam() { return }
        
        paymentWebService.callVAS(paymentParamsforVas: paymentParams!)
        
        // call PayU's fetchPaymentOptions method to get payment options available for your account
        self.paymentWebService.fetchPayUPaymentOptions(paymentParamsToFetchPaymentOptions: paymentParams!) { (array, errorHere) in
            
            DispatchQueue.main.async {
                // Update UI
                if (errorHere == "") {
                    
//                    if (updateUITempBool == false) {

//                    updateUITempBool = true
//                    self.savedCardArray = array.availableSavedCards
                    self.availableNetBanking = array.availableNetBanking
                    
                    for index in 0..<self.paymentTypeList_array.count {
                        if self.paymentTypeList_array[index].type == .creditDebit {
                            self.paymentTypeList_array[index].savedCardArray = array.availableSavedCards
                        } else if self.paymentTypeList_array[index].type == .wallet {
                            self.paymentTypeList_array[index].wallets = array.availableCashCard
                        }
                    }
                    
                    if let availablePaymentTypes = array.availablePaymentOptions as? [String], availablePaymentTypes.contains("UPI"), self.paymentTypeList_array.contains(where: { $0.type == .upi }) == false {
                        
                        self.paymentTypeList_array.append(GSPaymentTypeListModel(type: .upi, title: "UPI", headerTitle: "", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "upi_payment_icon")))
                    } else {
                        
                        let filteredItems = self.paymentTypeList_array.contains(where: { $0.type == .upi })
                            
                         if filteredItems == false {
                        
                        self.paymentTypeList_array.append(GSPaymentTypeListModel(type: .upi, title: "UPI", headerTitle: "", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "upi_payment_icon")))
                         }
                        
                    }
                    
                    self.paymentListTable.reloadData()
                    GSConstant.linearBar.stopAnimation()
                    
                    /* Utilise the below sample to implment the other payment options
                     paymentOptionsVC.paymentOptinonsArray = array.availablePaymentOptions
                     paymentOptionsVC.netBankingSwiftArray = array.availableNetBanking
                     paymentOptionsVC.cashCardArray = array.availableCashCard
                     paymentOptionsVC.emiArray = array.availableEMI
                     paymentOptionsVC.savedCardArray = array.availableSavedCards
                     */
                    //                    }
                } else {
                    CustomAlert.showAlert(title: "oops !", message: errorHere as String, viewController: self)
                    GSConstant.linearBar.stopAnimation()
                }
            }
        }
    }
    
    // Verify Razorpay payment if already amount detected
    // Ratheesh
    func verifyRazorPayPayment() {
        
        let amountArray = purchaseAmountToPay.components(separatedBy: ".")
        var amountvalue = ""
        
        if amountArray.count > 1 {
            let verify = amountArray[1].count
            var secondDidgit = amountArray[1]
            if (verify < 2) {
                secondDidgit = secondDidgit + "0"
            }
            amountvalue = "\(amountArray.first ?? "")\(secondDidgit)"
        } else {
            amountvalue = String(purchaseAmountToPay) + "00"
        }
        let amount = Int(amountvalue) ?? 0
        
        let urlString = APIurl.baseURL + APIurl.subURL.verifyRazorPay
        let  params = ["rzy_amount" : amount]
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject], urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSRazorPayVerifyModel.self, from: responseData)
                    
                    if let rzy_payment_id = responseModel.payment_id {
                        weakSelf.placeAuthorisedPaymentOrder(payment_id: rzy_payment_id)
                    } else {
                        weakSelf.pushToUpiDetailedView()
                    }
                } catch {
                    #if DEBUG
                    print(error)
                    #endif
                    weakSelf.pushToUpiDetailedView()
                }
            } else {
                #if DEBUG
                print(error?.localizedDescription ?? "")
                #endif
                weakSelf.pushToUpiDetailedView()
            }
        }
    }
    
    func placeAuthorisedPaymentOrder(payment_id: String) {
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.razorPaymentId, value: payment_id )
        
        let hashValue = SharedPersistence.getValue(key: UserDefaultKeys.Payment.paymentHash) as? String
        let txnValue = SharedPersistence.getValue(key: UserDefaultKeys.Payment.transactionId) as? String
        let amount = SharedPersistence.getValue(key: UserDefaultKeys.Payment.paymentAmount) as? String
        
        let paymentObject:[String:AnyObject] = ["txnid":txnValue as AnyObject,
                                                "hash" : hashValue as AnyObject,
                                                "rzy_pay_txnid":payment_id as AnyObject]
        placeOrderHelper = GSPlaceOrderHelper()
        placeOrderHelper?.delegate = self
        placeOrderHelper?.paidAmount = amount ?? ""
        placeOrderHelper?.placeOrderAPI(paymentObject: paymentObject)
    }
    
    func bayFayCashAPI () {
        
        let urlString = APIurl.baseURL + APIurl.subURL.bayFayCash
        
        APIHandler.NetworkSetupRequest(method: .post, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            // Making sure the next code will not execute if the view controller not exists in memory
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSBayfayCashModel.self, from: responseData)
                    
                    if let bayFayCash = responseModel.walletAmount {

                        weakSelf.bayFayCoins = bayFayCash
                        
                        if weakSelf.isGoingToOrder {
                            
                            if weakSelf.bayFayCoins != 0 {
                                
                                if weakSelf.paymentTypeList_array.contains(where: {$0.type == .bayfayCash}) == false {
                                    
                                    weakSelf.paymentTypeList_array[0] = GSPaymentTypeListModel(type: .promocode, title: "Promo Code", headerTitle: "", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "promoCode_icon"))
                                    weakSelf.paymentTypeList_array.insert(GSPaymentTypeListModel(type: .bayfayCash, title: "\(GSString.AppName) Cash", headerTitle: "\(GSString.AppName) Cash", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "bayFayCash_icon")), at: 0)
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            weakSelf.paymentListTable.reloadData()
                        }
                    }
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    // MARK: User defined Methods
    func addFewIntializers() {
        
        navigationBarView.delegate = self
        self.paymentListTable.delegate = self
        self.paymentListTable.dataSource = self
        
        paymentListTable.tableFooterView = UIView()
        paymentListTable.backgroundColor = UIColor(hexString: defaultTheme.paymentOpt_table_BG)
        
        if isGoingToOrder || isPaymentConfigurationFromCart {
            navigationBarView.rightBarImage.image = nil
            navigationBarView.rightBarBtn.isUserInteractionEnabled = false
            navigationBarView.leftBarImage.image = #imageLiteral(resourceName: "Back_arrow")
            
            let isNeedToShowCOD = SharedPersistence.getValue(key: UserDefaultKeys.Shops.isNeedToShowCOD) as? Bool ?? true
            
            if isNeedToShowCOD {
                numberOfRowsInCodColumn = 1
            } else {
                numberOfRowsInCodColumn = 0
            }
            
        } else {
            navigationBarView.leftBarImage.image = #imageLiteral(resourceName: "SideMenu_icon")
        }
        
        paymentListTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)

        
        if isGoingToOrder {
            
            paymentTypeList_array = [GSPaymentTypeListModel(type: .cash, title: "Cash", headerTitle: "Payment Method", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "CashIcon")),
                                     GSPaymentTypeListModel(type: .creditDebit, title: "Credit / Debit card", headerTitle: "", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "CreditDebitIcon")),
                                     GSPaymentTypeListModel(type: .addPayment, title: "Add Payment Method", headerTitle: "", savedCardArray: nil, wallets: nil, icon: nil),
                                     GSPaymentTypeListModel(type: .internetBanking, title: "Net Banking", headerTitle: "", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "NetbankingIcon"))]
            
            if bayFayCoins != 0 {
                paymentTypeList_array.insert(GSPaymentTypeListModel(type: .promocode, title: "Promo Code", headerTitle: "", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "promoCode_icon")), at: 0)
                paymentTypeList_array.insert(GSPaymentTypeListModel(type: .bayfayCash, title: "\(GSString.AppName) Cash", headerTitle: "\(GSString.AppName) Cash", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "bayFayCash_icon")), at: 0)
            } else {
                paymentTypeList_array.insert(GSPaymentTypeListModel(type: .promocode, title: "Promo Code", headerTitle: "Promo Code", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "promoCode_icon")), at: 0)
            }
            
        } else {
            
            paymentTypeList_array = [GSPaymentTypeListModel(type: .cash, title: "Cash", headerTitle: "Payment Method", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "CashIcon")),
                                     GSPaymentTypeListModel(type: .creditDebit, title: "Credit / Debit card", headerTitle: "", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "CreditDebitIcon")),
                                     GSPaymentTypeListModel(type: .addPayment, title: "Add Payment Method", headerTitle: "", savedCardArray: nil, wallets: nil, icon: nil),
                                     GSPaymentTypeListModel(type: .internetBanking, title: "Net Banking", headerTitle: "", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "NetbankingIcon")),
                                     GSPaymentTypeListModel(type: .bayfayCash, title: "\(GSString.AppName) Cash", headerTitle: "\(GSString.AppName) Cash", savedCardArray: nil, wallets: nil, icon: #imageLiteral(resourceName: "bayFayCash_icon"))]
        }
        
        purchaseAmountToShow = purchaseAmountToPay
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.isBayFayCashSelected, value: false)
        SharedPersistence.removeValue(key: UserDefaultKeys.Payment.promoCode)
    }
    
    // MARK: - Calling Place Order API
    
    fileprivate func placeOrderAPI_setup() {
        placeOrderHelper = GSPlaceOrderHelper()
        placeOrderHelper?.delegate = self
        placeOrderHelper?.placeOrderAPI(paymentObject: nil)
    }
    
    // MARK: - Device rotation Methods
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if let unwrappedTooltip = self.toolTip {
            unwrappedTooltip.dismissWithAnimation()
        }
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
        }) { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
        }
    } // View Will Transition
    
    fileprivate func addTooltip(_ button:UIButton, message:String, title:String, arrowPosition:MKToolTip.ArrowPosition) {
        
        let gradientColor = UIColor(red: 0.886, green: 0.922, blue: 0.941, alpha: 1.000)
        let gradientColor2 = UIColor(red: 0.812, green: 0.851, blue: 0.875, alpha: 1.000)
        let preference = ToolTipPreferences()
        preference.drawing.bubble.gradientColors = [gradientColor, gradientColor2]
        preference.drawing.arrow.tipCornerRadius = 0
        preference.drawing.message.color = .black
        
        if title != "" {
            toolTip = button.showToolTip(identifier: "", title: title, message: message, arrowPosition: arrowPosition, preferences: preference, delegate: nil)
        } else {
            toolTip = button.showToolTip(identifier: "", message: message, arrowPosition: arrowPosition, preferences: preference, delegate: nil)
        }
    }
}

extension GSPaymentTypeViewController:GSPlaceOrderHelperDelegate {
    
    func orderPlacedWith(status: Bool, data: GSPlaceOrderResponseData?, message: String) {
        
        if status {
            if let orderPlacedVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSOrderPlacedViewController) as? GSOrderPlacedViewController {
                orderPlacedVC.placeOrderResponse = data
                
                if isBayFayCashSelected {
                    orderPlacedVC.transaction_id = paymentParams?.txnId ?? ""
                } else {
                    orderPlacedVC.isCodOrder = true
                }
                orderPlacedVC.amountPaid = paymentParams?.amount ?? ""
                if let navigator = navigationController {
                    navigator.pushViewController(orderPlacedVC, animated: true)
                }
            }
        } else {
            
            self.isBayFayCashSelected = false
            self.paymentListTable.reloadData()
            CustomAlert.showAlert(title: GSString.AppName, message: message, viewController: self)
        }
    }
}

extension GSPaymentTypeViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return paymentTypeList_array.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionItem = paymentTypeList_array[section]
        
        switch sectionItem.type {
        case .cash:
            return numberOfRowsInCodColumn
        case .creditDebit:
            if let savedCards = sectionItem.savedCardArray, savedCards.count > 0 {
                return savedCards.count
            }
            return 1
        case .addPayment:
            return 1
        case .internetBanking, .upi:
            return 1
        case .wallet:
            
            if let wallet_array = sectionItem.wallets {
                return wallet_array.count
            }
            return 0
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionItem = paymentTypeList_array[indexPath.section]
        
        if sectionItem.type == .promocode {
            return promoCodeCell(at: indexPath)
            
        } else if sectionItem.type == .bayfayCash {
            return bayfayCoinsCell(at: indexPath)
            
        }
        return cellAt(indexPath)
    }
    
    private func promoCodeCell(at indexPath:IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.PaymentTypeVC_promocode_tableCell
        guard let cell = paymentListTable.dequeueReusableCell(withIdentifier: identifier) as? GSPaymentPromoCodeTableViewCell else {
            return UITableViewCell()
        }
        let sectionItem = paymentTypeList_array[indexPath.section]
        cell.cellIcon.image = sectionItem.icon
        cell.topLabel.text = sectionItem.title
        cell.topLabel.textColor =  UIColor(hexString: defaultTheme.paymentOpt_cellTitle_text)
        cell.promocodeStatus_lbl.text = "Apply code"
        
        let textAndTintColor = UIColor(hexString: defaultTheme.paymentOpt_cellApplyPromoLable)
        
        cell.promocodeStatus_lbl.textColor = textAndTintColor
        cell.promocodeStatus_imgView.image = #imageLiteral(resourceName: "VerifiedTickDefaultIcon").withRenderingMode(.alwaysTemplate)
        cell.promocodeStatus_imgView.tintColor = textAndTintColor
        cell.promocodeBG_view.layer.borderColor = textAndTintColor.cgColor
        
        cell.removePromoCodeBG_view.isHidden = true
        cell.removePromo_btn.addTarget(self, action: #selector(cell_removePromoCodeAction(_:)), for: .touchUpInside)
        
        if let promoCode = SharedPersistence.getValue(key: UserDefaultKeys.Payment.promoCode) as? String, promoCode != "" {
            
            cell.promocodeStatus_lbl.text = "Code Applied"
            let textAndTintColor_applied = UIColor(hexString: defaultTheme.paymentOpt_cellPromoAppliedLable)
            cell.promocodeStatus_lbl.textColor = textAndTintColor_applied
            cell.promocodeStatus_imgView.image = #imageLiteral(resourceName: "VerifiedTickIcon").withRenderingMode(.alwaysTemplate)
            cell.promocodeStatus_imgView.tintColor = textAndTintColor_applied
            cell.promocodeBG_view.layer.borderColor = textAndTintColor_applied.cgColor
            
            cell.removePromoCodeBG_view.isHidden = false
        }
        
        return cell
    }
    
    private func bayfayCoinsCell(at indexPath:IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.PaymetnTypeVC_bayFayCoins_cell
        guard let cell = paymentListTable.dequeueReusableCell(withIdentifier: identifier) as? GSPaymentBayFayCoinsTableViewCell else {
            return UITableViewCell()
        }
        let sectionItem = paymentTypeList_array[indexPath.section]
        cell.cellIcon.image = sectionItem.icon
        cell.topLabel.text = sectionItem.title
        cell.topLabel.textColor =  UIColor(hexString: defaultTheme.paymentOpt_cellTitle_text)
    
        cell.bayFayCoins_lbl.text = GSCommonHelper.formattedPrice(price: bayFayCoins)
        cell.info_btn.addTarget(self, action: #selector(cell_infoAction(_:)), for: .touchUpInside)
        
        if isGoingToOrder {
            
            cell.selectionImage.image = #imageLiteral(resourceName: "Uncheck_icon")
            
            if isBayFayCashSelected {
                cell.selectionImage.image = #imageLiteral(resourceName: "Check_icon")
            }
            
        } else if isInEditingMode {
            cell.selectionImage.image = nil
        }
        
        return cell
    }
    
    private func cellAt(_ indexPath:IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.PaymentTypeVC_paymentMode_tableCell
        guard let cell = paymentListTable.dequeueReusableCell(withIdentifier: identifier) as? GSPaymentTypeTableViewCell else {
            return UITableViewCell()
        }

        let sectionItem = paymentTypeList_array[indexPath.section]
        cell.cellIcon.image = sectionItem.icon
        cell.topLabel.text = sectionItem.title
        cell.cellIcon.isHidden = false
        cell.topLabel.textColor =  UIColor(hexString: defaultTheme.paymentOpt_cellTitle_text)
        
        if sectionItem.type != .addPayment {
            
            cell.selectionImage.image = nil
            if isInEditingMode == true || isGoingToOrder {
                cell.selectionImage.image = #imageLiteral(resourceName: "payment_accessory_icon")
            } else if sectionItem.type == .cash || sectionItem.type == .creditDebit {
                cell.selectionImage.image = #imageLiteral(resourceName: "VerifiedTickDefaultIcon")
            }
        } else {
            cell.selectionImage.image = nil
        }
        
        switch sectionItem.type {
        case .cash:
            if self.saveSelectedMethod.payMethod == PaymentMethod.Cash.hashValue && isInEditingMode != true && !isGoingToOrder {
                selectedIndexPath = indexPath
                cell.selectionImage.image = #imageLiteral(resourceName: "VerifiedTickIcon")
            }
            break
        case .creditDebit:
            if let savedCardArray = sectionItem.savedCardArray, savedCardArray.count > indexPath.row {
                
                let cardAtIndex = savedCardArray[indexPath.row] as! PUExtended
//                cell.topLabel.text = "Credit / Debit Card **" + cardAtIndex.cardNo.substring(from:cardAtIndex.cardNo.index(cardAtIndex.cardNo.endIndex, offsetBy: -4))
                cell.topLabel.text = "Credit / Debit Card **" + cardAtIndex.cardNo[cardAtIndex.cardNo.index(cardAtIndex.cardNo.endIndex, offsetBy: -4)...]
                cell.cellIcon.image = GSPaymentParametersHelper.imageForTheCardtypeWithObject(cardBrand: cardAtIndex.cardBrand)
                
                if self.saveSelectedMethod.cardNumber == cardAtIndex.cardNo && self.saveSelectedMethod.cardExpMonth == cardAtIndex.expiryMonth && self.saveSelectedMethod.cardExpYear == cardAtIndex.expiryYear && isInEditingMode != true && !isGoingToOrder  {
                    selectedIndexPath = indexPath
                    cell.selectionImage.image = #imageLiteral(resourceName: "VerifiedTickIcon")
                }
            } else {
                cell.selectionImage.image = #imageLiteral(resourceName: "payment_accessory_icon")
                if isInEditingMode {
                    cell.selectionImage.image = nil
                }
            }
            break
        case .addPayment:
            cell.cellIcon.isHidden = true
            cell.topLabel.textColor =  UIColor(hexString: defaultTheme.paymentOpt_addPaymentBtn_text)
            
            break
        case .internetBanking:
//            if self.saveSelectedMethod.payMethod == PaymentMethod.Netbanking.hashValue && isInEditingMode != true && !isGoingToOrder {
//                selectedIndexPath = indexPath
//                cell.selectionImage.image = #imageLiteral(resourceName: "VerifiedTickIcon")
//            }
            if isInEditingMode {
                cell.selectionImage.image = nil
            }
            break
        case .upi:
            if self.saveSelectedMethod.payMethod == PaymentMethod.Upi.hashValue && isInEditingMode != true && !isGoingToOrder {
                selectedIndexPath = indexPath
                cell.selectionImage.image = #imageLiteral(resourceName: "VerifiedTickIcon")
            }
            if isInEditingMode {
                cell.selectionImage.image = nil
            }
            break
        case .wallet:
            
            if let wallet_array = sectionItem.wallets, wallet_array.count > indexPath.row {

                let walletAtIndex = wallet_array[indexPath.row] as! PUExtended
                cell.topLabel.text = walletAtIndex.title
                cell.cellIcon.image = #imageLiteral(resourceName: "wallet_common_icon")
                
                if self.saveSelectedMethod.payMethod == PaymentMethod.wallet.hashValue && self.saveSelectedMethod.bankCode == walletAtIndex.bankCode && isInEditingMode != true && !isGoingToOrder {
                    selectedIndexPath = indexPath
                    cell.selectionImage.image = #imageLiteral(resourceName: "VerifiedTickIcon")
                }
                if isInEditingMode {
                    cell.selectionImage.image = nil
                }
            }
            break
            
        default:
            break
        }
        
        return cell
    }
    
//    @objc private func cell_selection_action(_ sender:UIButton) {
//        let indexPathSection = sender.tag
//        if indexPathSection == PaymentMethod.SavedCard.hashValue {
//            // Will do delete action for the saved card here
//        }
//    }
    
    @objc private func cell_infoAction(_ sender:UIButton) {
        
        addTooltip(sender, message: GSConstant.ToolTip.bayFayCash, title: "", arrowPosition: .bottom)
    }
    
    @objc private func cell_removePromoCodeAction(_ sender: UIButton) {
        SharedPersistence.removeValue(key: UserDefaultKeys.Payment.promoCode)
        self.paymentParams = nil
        self.paymentParamsWithBayFayCash = nil
        self.paymentParamsWithOutBayFayCash = nil
        self.viewWillAppear(false)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionItem = paymentTypeList_array[section]
        
        if sectionItem.headerTitle == "" {
            return nil
        }
        
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerHeight))
        let headerLabel = UILabel.init(frame: CGRect(x: 20, y: 0, width: headerView.frame.size.width - 20, height: headerHeight))
        headerLabel.textColor = UIColor(hexString: defaultTheme.paymentOpt_header_text)
        
        headerLabel.text = sectionItem.headerTitle
        headerLabel.font = headerLabel.font.withSize(14)
        headerLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        headerView.addSubview(headerLabel)
        headerView.backgroundColor = UIColor(hexString: defaultTheme.paymentOpt_tableHeader_BG)
        headerView.addShadowEffectWith(color: UIColor(hexString: defaultTheme.paymentOpt_BorderC), opacity: 1.0, shadowRadius: 0, shadowOffset: CGSize(width: 0.0, height: 1.0))
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        let headerLableConstraintIdentifier = "headerLable"
        
        let verticalHeaderLableCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[\(headerLableConstraintIdentifier)]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: [headerLableConstraintIdentifier:headerLabel])
        
        if sectionItem.type == .cash {
            
            let amountToPay_lbl = UILabel()
            amountToPay_lbl.font = UIFont.boldSystemFont(ofSize: 14)
            amountToPay_lbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
            amountToPay_lbl.text = ""
            
            if isGoingToOrder {
                amountToPay_lbl.text = GSConstant.currency_symbol + purchaseAmountToShow
            }
            headerView.addSubview(amountToPay_lbl)
            
            amountToPay_lbl.translatesAutoresizingMaskIntoConstraints = false
            let amountToPayLbl_identifier = "amountToPayLable"
            
            let horizontalCons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[\(headerLableConstraintIdentifier)]-10-[\(amountToPayLbl_identifier)]-20-|", options: .directionLeadingToTrailing, metrics: nil, views: [headerLableConstraintIdentifier:headerLabel, amountToPayLbl_identifier:amountToPay_lbl])
            let verticalAmountToPayLableCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[\(amountToPayLbl_identifier)]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: [amountToPayLbl_identifier:amountToPay_lbl])
            
            NSLayoutConstraint.activate(horizontalCons)
            NSLayoutConstraint.activate(verticalHeaderLableCons)
            NSLayoutConstraint.activate(verticalAmountToPayLableCons)
            
            return headerView
        }
        
        let horizontalCons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[\(headerLableConstraintIdentifier)]-20-|", options: .directionLeadingToTrailing, metrics: nil, views: [headerLableConstraintIdentifier:headerLabel])
        
        NSLayoutConstraint.activate(horizontalCons)
        NSLayoutConstraint.activate(verticalHeaderLableCons)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var sessionHeight: CGFloat = headerHeight
        let sectionItem = paymentTypeList_array[section]
        
        if sectionItem.headerTitle == "" {
            sessionHeight = 0
        }
        
        return sessionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionItem = paymentTypeList_array[indexPath.section]
        
        if isGoingToOrder {
            
//            if isBayFayCashSelected {
//                purchaseAmountToShow = paymentParamsWithBayFayCash?.amount ?? "0"
//                paymentParams = paymentParamsWithBayFayCash
//            } else {
//                purchaseAmountToShow = paymentParamsWithOutBayFayCash?.amount ?? "0"
//                paymentParams = paymentParamsWithOutBayFayCash
//            }
            
            updatePurchaseAmount()
            
            switch sectionItem.type {
            case .cash:
                
                if isBayFayCashSelected {
                    CustomAlert.showAlert(title: GSString.AppName, message: "You cannot select the COD if you want to proceed with the BayFay cash", viewController: self)
                    return
                }
                
                if let appliedPromoCode = SharedPersistence.getValue(key: UserDefaultKeys.Payment.promoCode) as? String, appliedPromoCode != "", isCashBackOffer == true {
                    
                    CustomAlert.showAlert(title: "", message: GSConstant.AlertMessages.codAlert_cashBack, alertButtonsArray: ["Cancel","Ok"], isLastButtonDestructive: true, viewController: self) { btnIndex in
                        
                        if btnIndex == 1 {
                            self.placeOrderAPI_setup()
                            return
                        }
                    }
                    
                } else {
                    //                    self.placeOrderAPI_setup()
                    
                    CustomAlert.showAlert(title: "", message: GSConstant.AlertMessages.codAlert, alertButtonsArray: ["Cancel","Confirm"], isLastButtonDestructive: false, viewController: self) { btnIndex in
                        
                        if btnIndex == 1 {
                            self.placeOrderAPI_setup()
                            return
                        }
                    }
                }
                
                //                CustomAlert.showAlert(title: "Cash Option", message: GSConstant.AlertMessages.codAlert, alertButtonsArray: ["Cancel","Ok"], isLastButtonDestructive: true, viewController: self) { btnIndex in
                
                //                    if btnIndex == 1 {
                //                        self.placeOrderAPI_setup()
                //                        return
                //                    }
                //                }
                
                break
            case .creditDebit:
                
                if checkPaymentParam() {
                    return
                }
                
                if let savedCards = sectionItem.savedCardArray, savedCards.count > indexPath.row {
                    
                    let savedCard = savedCards[indexPath.row] as! PUExtended
                    if let makePaymentVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil)
                        .instantiateViewController(withIdentifier: GSString.Push.GSMakePaymentViewController) as? GSMakePaymentViewController {
                        
                        paymentParams?.cardNumber  = savedCard.cardNo
                        paymentParams?.expiryYear  = savedCard.expiryYear
                        paymentParams?.expiryMonth = savedCard.expiryMonth
                        
                        paymentParams?.cardToken = savedCard.cardToken
                        paymentParams?.cardBin = savedCard.cardBin
                        paymentParams?.cardBrand = savedCard.cardBrand
                        
                        makePaymentVC.paymentParams = paymentParams!
                        
                        if let navigator = navigationController {
                            navigator.pushViewController(makePaymentVC, animated: true)
                        }
                    }
                    
                } else {
                    pushToAddCardViewController()
                }
                
                break
            case .addPayment:
                pushToAddCardViewController()
                break
            case .internetBanking:
                if checkPaymentParam() {
                    return
                }
                // Ratheesh
                // pushToNetbankingDetailedView() // PayU
                // pushToUpiDetailedView() // RazorPay
                verifyRazorPayPayment()
                break
            case .upi:
                if checkPaymentParam() {
                    return
                }
                // pushToUpiDetailedView() // RazorPay
                verifyRazorPayPayment()
                break
            case .wallet:
                
                if let wallet_array = sectionItem.wallets, wallet_array.count > indexPath.row {
                    
                    let walletAtIndex = wallet_array[indexPath.row] as! PUExtended
                    checkWalletStatusAndProceed(bankCode: walletAtIndex.bankCode)
                }
                break                
            case .bayfayCash:
                
                // Before changing the checkbox will check the bill amount
                
//                guard let totalCartValue = Double(purchaseAmountToPay) else { return }
                guard let totalCartValue = Double(paymentParamsWithOutBayFayCash?.amount ?? "0") else { return }
                if bayFayCoins >= totalCartValue {
                    // We can place the order with only bayfay coins
                    
                    if let appliedPromo = SharedPersistence.getValue(key: UserDefaultKeys.Payment.promoCode) as? String, appliedPromo != "" {
                        CustomAlert.showAlert(title: GSString.AppName, message: "Promo code is not applicable if you want to pay only with \(GSString.AppName) cash", viewController: self)
                        return
                    }
                    
                    placeOrderWithOnlyBayFayCoinsWithPermisson()
                    return
                }
                
                isBayFayCashSelected.toggle()
                
//                if isBayFayCashSelected {
//                    purchaseAmountToShow = paymentParamsWithBayFayCash?.amount ?? "0"
//                    paymentParams = paymentParamsWithBayFayCash
//                } else {
//                    purchaseAmountToShow = paymentParamsWithOutBayFayCash?.amount ?? "0"
//                    paymentParams = paymentParamsWithOutBayFayCash
//                }
                
                updatePurchaseAmount()
                
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.isBayFayCashSelected, value: isBayFayCashSelected)
                paymentListTable.reloadData()
                break
                
            case .promocode:
                
                pushToPromoCodeListView()
                break
            }
            
        } else if isPaymentConfigurationFromCart {
            
            if sectionItem.type == .addPayment {
                pushToAddCardViewController()
                return
            } else if sectionItem.type == .creditDebit && (sectionItem.savedCardArray == nil || (sectionItem.savedCardArray?.count ?? 0) == 0){
                pushToAddCardViewController()
                return
            }
            managePaymentTypeSelections(sectionItem: sectionItem, indexPath: indexPath)
            reloadTheTableView(indexPath)
            
        } else {
            
            if isInEditingMode {
                switch sectionItem.type {
                case .cash:
                    pushToPaymentCCDCView(paymentOption: PaymentMethod.Cash)
                    break
                case .creditDebit:
                    if let savedCards = sectionItem.savedCardArray, savedCards.count > indexPath.row {
                        pushToPaymentCCDCView(savedCard: savedCards[indexPath.row] as! PUExtended)
                    } else {
                        // Credit debit option falls here
                    }
                    break
                default:
                    break
                }
                
            } else {
                if sectionItem.type == .addPayment {
                    pushToAddCardViewController()
                    return
                } else if sectionItem.type == .creditDebit && (sectionItem.savedCardArray == nil || (sectionItem.savedCardArray?.count ?? 0) == 0) {
                    pushToAddCardViewController()
                    return
                }
                managePaymentTypeSelections(sectionItem: sectionItem, indexPath: indexPath)
                reloadTheTableView(indexPath)
            }
        }
    }
    
    private func reloadTheTableView(_ indexPath:IndexPath) {
        paymentListTable.deselectRow(at: indexPath, animated: true)
        previousSelectedIndexPath = selectedIndexPath ?? indexPath
        selectedIndexPath = indexPath
        paymentListTable.reloadRows(at: [selectedIndexPath!,previousSelectedIndexPath!], with: .fade)
    }
    
    private func managePaymentTypeSelections(sectionItem: GSPaymentTypeListModel, indexPath: IndexPath) {
        
        switch sectionItem.type {
        case .cash:
            
            var saveSelectedMethod = GSSavePaymentMethod()
            saveSelectedMethod.payMethod = PaymentMethod.Cash.hashValue
            self.saveSelectedMethod = saveSelectedMethod
            
            if let encodedSavedPayMethod = try? JSONEncoder().encode(saveSelectedMethod) {
                SharedPersistence.storeUserDefaults(key: GSPaymentConstants.SAVED_CARD_METHOD, value: encodedSavedPayMethod)
            }
            
            break
        case .creditDebit:
            if let savedCards = sectionItem.savedCardArray, savedCards.count > indexPath.row {
                
                let savedCard = savedCards[indexPath.row] as! PUExtended
                
                var saveSelectedMethod = GSSavePaymentMethod()
                saveSelectedMethod.payMethod    = PaymentMethod.SavedCard.hashValue
                saveSelectedMethod.cardNumber   = savedCard.cardNo
                saveSelectedMethod.cardType     = savedCard.cardBrand
                saveSelectedMethod.cardExpMonth = savedCard.expiryMonth
                saveSelectedMethod.cardExpYear  = savedCard.expiryYear
                saveSelectedMethod.cardToken    = savedCard.cardToken
                saveSelectedMethod.cardBin      = savedCard.cardBin
                saveSelectedMethod.cardName     = savedCard.cardName
                saveSelectedMethod.cardBrand    = savedCard.cardBrand
                
                self.saveSelectedMethod = saveSelectedMethod
                if let encodedSavedPayMethod = try? JSONEncoder().encode(saveSelectedMethod) {
                    SharedPersistence.storeUserDefaults(key: GSPaymentConstants.SAVED_CARD_METHOD, value: encodedSavedPayMethod)
                }
                
            } else {
                // Credit debit option falls here
                
            }
            break
//        case .internetBanking:
//            var saveSelectedMethod = GSSavePaymentMethod()
//            saveSelectedMethod.payMethod = PaymentMethod.Netbanking.hashValue
//            self.saveSelectedMethod = saveSelectedMethod
//
//            if let encodedSavedPayMethod = try? JSONEncoder().encode(saveSelectedMethod) {
//                SharedPersistence.storeUserDefaults(key: GSPaymentConstants.SAVED_CARD_METHOD, value: encodedSavedPayMethod)
//            }
//            break
            
        case .upi:
            var saveSelectedMethod = GSSavePaymentMethod()
            saveSelectedMethod.payMethod = PaymentMethod.Upi.hashValue
            self.saveSelectedMethod = saveSelectedMethod
            
            if let encodedSavedPayMethod = try? JSONEncoder().encode(saveSelectedMethod) {
                SharedPersistence.storeUserDefaults(key: GSPaymentConstants.SAVED_CARD_METHOD, value: encodedSavedPayMethod)
            }
            break
            
        case .wallet:
            if let wallet_array = sectionItem.wallets, wallet_array.count > indexPath.row {
                let wallet = wallet_array[indexPath.row] as! PUExtended
                
                var saveSelectedMethod = GSSavePaymentMethod()
                saveSelectedMethod.payMethod    = PaymentMethod.wallet.hashValue
                saveSelectedMethod.bankCode     = wallet.bankCode
                
                self.saveSelectedMethod = saveSelectedMethod
                if let encodedSavedPayMethod = try? JSONEncoder().encode(saveSelectedMethod) {
                    SharedPersistence.storeUserDefaults(key: GSPaymentConstants.SAVED_CARD_METHOD, value: encodedSavedPayMethod)
                }
            }
            
        default:
            break
        }
    }
    
//    func addPaymentMethod() -> Void {
//
//        if checkPaymentParam() {
//            return
//        }
//
//        if let pushVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSAddPaymentViewController) as? GSAddPaymentViewController {
//            pushVC.paymentParams = paymentParams!
//            pushVC.isGoingToOrder = isGoingToOrder
//            if let navigator = navigationController {
//                navigator.pushViewController(pushVC, animated: true)
//            }
//        }
//    }
    
    private func pushToAddCardViewController() {
        
        if checkPaymentParam() {
            return
        }
        
        if let tempVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSAddCardViewController) as? GSAddCardViewController {
            tempVC.paymentParams = paymentParams!
            tempVC.isGoingToOrder = isGoingToOrder
            tempVC.isSaveThisCardSelected = true
            navigationController?.pushViewController(tempVC, animated: true)
        }
        
    }
    
    private func pushToPromoCodeListView() {
        
        if let promoListVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPromoCodeListViewController) as? GSPromoCodeListViewController {
            
            navigationController?.pushViewController(promoListVC, animated: true)
        }
    }
    
    private func pushToNetbankingDetailedView() {
        if let netbankingVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSNetbankingListViewController) as? GSNetbankingListViewController {
            
            netbankingVC.availableNetbanking_array = availableNetBanking
            netbankingVC.paymentParams = paymentParams!
            navigationController?.pushViewController(netbankingVC, animated: true)
        }
    }
    
    private func pushToUpiDetailedView() {
        
        let paymentType = SharedPersistence.getValue(key: UserDefaultKeys.Payment.paymentGatewayType) as? Int ?? 0
        if paymentType == 2 {
            // Razorpay
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.paymentAmount, value:  self.paymentParams?.amount ?? "0.0")
            self.openRazorpayAaaWalletAmountCheckout(walletAmount: self.paymentParams?.amount ?? "0.0")
        } else {
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let topLength = appDelegate?.topSafeAreaInset ?? 0
            let bottomLength = appDelegate?.bottomSafeAreaInset ?? 0
    
            if upiAlerView != nil, upiAlerView.isDescendant(of: view) { return }
            upiAlerView = GSUpiAlertView()
    
            view.addSubview(upiAlerView)
    
            upiAlerView.paymentParams = self.paymentParams!
    
            upiAlerView.translatesAutoresizingMaskIntoConstraints = false
            upiAlerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            upiAlerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            upiAlerView.topAnchor.constraint(equalTo: view.topAnchor, constant: topLength).isActive = true
            upiAlerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomLength).isActive = true
        }
        
//        if let netbankingVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSUPIPaymentViewController) as? GSUPIPaymentViewController {
//
//            netbankingVC.paymentParams = paymentParams!
//            navigationController?.pushViewController(netbankingVC, animated: true)
//        }
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
        // Ratheesh
        let amountArray = walletAmount.components(separatedBy: ".")
        var amountvalue = ""
        
        if amountArray.count > 1 {
            let verify = amountArray[1].count
            var secondDidgit = amountArray[1]
            if (verify < 2) {
                secondDidgit = secondDidgit + "0"
            }
            amountvalue = "\(amountArray.first ?? "")\(secondDidgit)"
        } else {
             amountvalue = walletAmount + "00"
        }

        let amount = Int(amountvalue) ?? 0
        
        let razorPaymentkey = SharedPersistence.getValue(key: UserDefaultKeys.Payment.razorPaykey) as? String ?? ""
        
        razorpayObj = Razorpay.initWithKey(razorPaymentkey, andDelegate: self)
        
        let options: [AnyHashable:Any] = [
            "prefill": [
                "contact": userPhone,
                "email": userEmail,
                //"method" : "upi",
            ],
            "amount" : amount,
            "name" : userName,
            
            ]
        if let rzp = self.razorpayObj {
            GSConstant.linearBar.startAnimation()
            rzp.open(options)
        } else {
            print("Unable to initialize")
        }
    }
    
    private func pushToPaymentCCDCView(paymentOption : PaymentMethod) {
        
        if let paymentCCDCDetailVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPaymentCCDCDetailViewController) as? GSPaymentCCDCDetailViewController {
            
            if paymentOption.hashValue == PaymentMethod.Cash.hashValue {
                paymentCCDCDetailVC.paymentOption = PaymentMethod.Cash
            }
            navigationController?.pushViewController(paymentCCDCDetailVC, animated: true)
        }
    }
    
    private func pushToPaymentCCDCView(savedCard: PUExtended) {
        
        if let paymentCCDCDetailVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPaymentCCDCDetailViewController) as? GSPaymentCCDCDetailViewController {
            
            paymentCCDCDetailVC.paymentOption = PaymentMethod.SavedCard
            paymentCCDCDetailVC.savedCard = savedCard
            paymentCCDCDetailVC.paymentParams = paymentParams!
            navigationController?.pushViewController(paymentCCDCDetailVC, animated: true)
        }
    }
    
    private func checkWalletStatusAndProceed(bankCode: String) {
        
        GSConstant.linearBar.startAnimation()

        paymentWebService.getVASStatus(bankCodeOrCardBin: bankCode) { (status, error) in
            
            DispatchQueue.main.async {
                GSConstant.linearBar.stopAnimation()
            }
            if (status as! String != "") {
                CustomAlert.showAlert(title: GSString.AppName, message: status as? String ?? "", viewController: self)
            } else {

                CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.redirectToBank, alertButtonsArray: ["Cancel","Proceed"], viewController: self, completion: { btnIndex in
                    if btnIndex == 1 {
                        self.createWebRequestForWalletPayment(bankCode: bankCode)
                    }
                })
            }
        }
    }
    
    private func createWebRequestForWalletPayment(bankCode: String) {
        
        let createRequest = PayUCreateRequest()
        paymentParams?.bankCode = bankCode
        GSConstant.linearBar.startAnimation()
        createRequest.createRequest(withPaymentParam: paymentParams!, forPaymentType: PAYMENT_PG_CASHCARD) { (request, error) in
            
            DispatchQueue.main.async {
                GSConstant.linearBar.stopAnimation()
            }
            
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
                CustomAlert.showAlert(title: GSString.AppName, message: error as String, viewController: self)
            }
        }
    }
    
    // function to call one tap token
    func callOneTapToken () -> () {
        
        let object = PUSAGenerateHashes()
        object.fetchOneTapTokenFromServer(withParams: paymentParams!) { (oneTapDictionary, error) in
            if(error == "") {
                //self.existingOneCardDict = oneTapDictionary
            }
        }
    }
    
    func placeOrderWithOnlyBayFayCoinsWithPermisson() {
        
        isBayFayCashSelected = true
        paymentListTable.reloadData()
        
        CustomAlert.showAlert(title: GSString.AppName, message: "Do you want to continue with \(GSString.AppName) cash to place order?", alertButtonsArray: ["Cancel", "Place Order"], viewController: self) { btnIndex in
            
            if btnIndex == 1 {
                
                self.placeOrderHelper = GSPlaceOrderHelper()
                self.placeOrderHelper?.delegate = self
                self.placeOrderHelper?.isOnlyBayFayCashOrder = true
                self.placeOrderHelper?.txn_id = self.paymentParams?.txnId ?? ""
                self.placeOrderHelper?.placeOrderAPI(paymentObject: nil)
            } else {
                self.isBayFayCashSelected = false
                self.paymentListTable.reloadData()
            }
        }
    }
}

//MARK: Naviagtion Bar delegate
extension GSPaymentTypeViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        
        if isGoingToOrder || isPaymentConfigurationFromCart {
            navigationController?.popViewController(animated: true)
            
        } else {
            addSideMenu()
        }
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        if !isInEditingMode {
            
            navigationBarView.rightBarImage.image = #imageLiteral(resourceName: "vertical_menu_icon")
            navigationBarView.rightBarBtn.setTitle("", for: .normal)
            
            CustomAlert.showActionSheet(title: nil, message: nil, cancelTitle: "Cancel", optionArray: ["Edit"], sourceView: navigationBarView.rightBarBtn, in: self) { _ in
                // Editing Option Will Start
                
                self.navigationBarView.rightBarImage.image = nil
                self.navigationBarView.rightBarBtn.setTitle("Done", for: .normal)
                self.isInEditingMode = true
                
                DispatchQueue.main.async {
                    self.paymentListTable.reloadData()
                }
            }
        } else {
            navigationBarView.rightBarImage.image = #imageLiteral(resourceName: "vertical_menu_icon")
            navigationBarView.rightBarBtn.setTitle("", for: .normal)
            self.isInEditingMode = false
            paymentListTable.reloadData()
        }
    }
    
    func checkPaymentParam() -> Bool {
        
        if paymentParams == nil {
            
            CustomAlert.showAlert(title: "Server Time out", message: GSConstant.AlertMessages.paymentServerTimeout, alertButtonsArray: ["Cancel","Retry"], isLastButtonDestructive: false, viewController: self) { btnIndex in
                
                if btnIndex == 1 {
                    self.viewWillAppear(false)
                }
            }
            return true
        }
        return false
    }
}

// make the view controller conform to `UINavigationControllerDelegate`
extension GSPaymentTypeViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushPopAnimator(operation: operation)
    }
}
extension GSPaymentTypeViewController : RazorpayPaymentCompletionProtocol {
    
    func onPaymentError(_ code: Int32, description str: String) {
        print("error: ", code, str)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.razorPaymentId, value: payment_id )
        
        let hashValue = SharedPersistence.getValue(key: UserDefaultKeys.Payment.paymentHash) as? String
        let txnValue = SharedPersistence.getValue(key: UserDefaultKeys.Payment.transactionId) as? String
        let amount = SharedPersistence.getValue(key: UserDefaultKeys.Payment.paymentAmount) as? String

        let paymentObject:[String:AnyObject] = ["txnid":txnValue as AnyObject,
                                                "hash" : hashValue as AnyObject,
                                                "rzy_pay_txnid":payment_id as AnyObject]
        placeOrderHelper = GSPlaceOrderHelper()
        placeOrderHelper?.delegate = self
        placeOrderHelper?.paidAmount = amount ?? ""
        // Ratheesh
        placeOrderHelper?.placeOrderAPI(paymentObject: paymentObject)
    }
}

// The animation controller
class PushPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let operation: UINavigationControllerOperation
    
    init(operation: UINavigationControllerOperation) {
        self.operation = operation
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let from = transitionContext.viewController(forKey: .from)!
        let to   = transitionContext.viewController(forKey: .to)!
        
        let rightTransform = CGAffineTransform(translationX: transitionContext.containerView.bounds.size.width, y: 0)
        if operation == .push {
            to.view.transform = rightTransform
            transitionContext.containerView.addSubview(to.view)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                to.view.transform = .identity
            }, completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        } else if operation == .pop {
            to.view.transform = .identity
            transitionContext.containerView.insertSubview(to.view, belowSubview: from.view)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                from.view.transform = rightTransform
            }, completion: { finished in
                from.view.transform = .identity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

// MARK: - GSRazorPayVerifyModel
struct GSRazorPayVerifyModel: Codable {
    let success: Bool?
    let is_authorized: Bool?
    let payment_id: String?
    
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case is_authorized = "is_authorized"
        case payment_id = "payment_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = values.decodeSafely(.success)
        is_authorized = values.decodeSafely(.is_authorized)
        payment_id = values.decodeSafely(.payment_id)
    }
}

// MARK: - GSBayfayCashModel
struct GSBayfayCashModel: Codable {
    let success: Bool?
    let walletAmount: Double?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case walletAmount = "wallet_amount"
        case message
    }
}
