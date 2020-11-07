//
//  GSCartViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ratheesh on 2/19/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit

class GSCartViewController: GSLoggedInBaseViewController,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate {
    
    @IBOutlet weak var cartTable: UITableView!
    @IBOutlet weak var payNowBtn : UIButton!
    @IBOutlet weak var subscribeBtn : GSBaseButton!
    @IBOutlet weak var navigationBar_view: NavigationWithSearchBar!
    @IBOutlet weak var bottomStackBg_view:UIView!
    @IBOutlet weak var customizeOrder_btn:UIButton!
    @IBOutlet weak var deliveryMode_btn:UIButton!
    @IBOutlet weak var payMentIcon_btn:UIButton!
    @IBOutlet weak var customizeOrder_lbl: GSBaseLabel!
    @IBOutlet weak var deliveryMode_lbl: GSBaseLabel!
    @IBOutlet weak var deliveryModeFloat_lbl: GSBaseLabel!
    @IBOutlet weak var paymentIcon_view: GSCornerEdgeView!
    @IBOutlet weak var paymentCalculation_activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var customOrderBtnBg_view: GSCornerEdgeView!
    @IBOutlet weak var viewBillingBtnBg_view: GSCornerEdgeView!
    @IBOutlet weak var deliveryModeBtnBg_view: GSCornerEdgeView!
    @IBOutlet weak var viewBilling_btn: UIButton!
    @IBOutlet weak var paymentMethod_lbl: GSBaseLabel!
    @IBOutlet weak var paymentMethod_imgView: UIImageView!
    
    @IBOutlet weak var subscribeView: UIView!
    
    
    var popUp_view:GSSubscriptionPopupView!
    var picker:GSCustomPickerView!
    var monthPicker : GSMonthYearPickerView!
    
    var billing_view:GSViewBillingView!
    var billing_data: GSViewBillingData?
    
    var isDraftView = false
    var isWishListView = false
    
    var mismatchedStock_data = [GSStockAvailabilityProduct]()
    var mismatchedStockId_array = [String]()
    
    var cartListNewProducts = [GSCartListNewData]()
    var saveForLaterNewProducts = [GSCartListNewData]()
    
    var cartListNewProducts_backup = [GSCartListNewData]()
    var saveForLaterNewProducts_backUp = [GSCartListNewData]()
    
    var subscriptionTypeArray    = [SubscriptionTypeData]()
    var subscriptionInfo         = [SubscriptionInfo]()
    var subscribeButName         = "Subscribe"

    let headerTitles_array = ["Cart", "Save for later"]
    
    var detailsWithOfferPopup:GSProductDetailsWithOfferPopUpView!
    
    var clearCartSupport:GSClearCartSupport?
    
    let apiQueue = OperationQueue()

    
    // Need to set cart total amount
    var purchaseAmountToPay : String = "0.0"
    
    var isAPI_running = false
    
    //PickerView

    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyColors()
        addFewIntializers()
        deliveryTypesAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar_view.navigationBarReload()
        paymentMethodChanges()
        deliveryMethodChanges()
        SharedPersistence.removeValue(key: UserDefaultKeys.Payment.promoCode)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Need to update in the payment method button
        if let decodedSavedPaymentMethod = SharedPersistence.getValue(key: GSPaymentConstants.SAVED_CARD_METHOD) as? Data {
            
            if let decodedSavedPaymentMethod = try? JSONDecoder().decode(GSSavePaymentMethod.self, from: decodedSavedPaymentMethod) {
                print("decodedSavedPaymentMethod = ",decodedSavedPaymentMethod.cardNumber as Any)
            }
        }
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        
        bottomStackBg_view.backgroundColor = UIColor(hexString: defaultTheme.cart_BottomStack_BG)
        payNowBtn.backgroundColor = UIColor(hexString: defaultTheme.cart_MakePayment_BG)
        payNowBtn.setTitleColor(UIColor(hexString: defaultTheme.cart_MakePaymentBtn_title), for: .normal)
        payNowBtn.layer.borderColor = UIColor(hexString: defaultTheme.cart_MakePaymentBtn_border).cgColor
        payNowBtn.layer.borderWidth = 0
        viewBilling_btn.setTitleColor(UIColor(hexString: defaultTheme.cart_viewBilling_btn_title), for: .normal)
        customizeOrder_lbl.backgroundColor = UIColor(hexString: defaultTheme.cart_customOrderBtn_BG)
        customizeOrder_lbl.textColor = UIColor(hexString: defaultTheme.cart_customOrderBtn_title)
        deliveryMode_lbl.backgroundColor = UIColor(hexString: defaultTheme.cart_deliveryModeBtn_BG)
        deliveryMode_lbl.textColor = UIColor(hexString: defaultTheme.cart_deliveryModeBtn_title)
        paymentIcon_view.backgroundColor = UIColor(hexString: defaultTheme.cart_paymentIconBtn_BG)
        
        for borderLineView in [paymentIcon_view,customOrderBtnBg_view,viewBillingBtnBg_view,deliveryModeBtnBg_view] {
            borderLineView?.layer.borderColor = UIColor(hexString: defaultTheme.Cart_btn_border).cgColor
        }
    }
    
    // MARK: User defined Methods
    private func addFewIntializers() {
        
        navigationBar_view.delegate = self
        navigationBar_view.navigSearchBar.delegate = self
        navigationBar_view.cartIconView.isHidden = true
        navigationBar_view.rightBarBtn.isHidden = true
        navigationBar_view.rightBarImage.isHidden = true
        
        paymentCalculation_activityIndicator.hidesWhenStopped = true
        
        self.requestSubscriptionTypeApi()
        
        changeThePaynowButtonInteraction(false, title: "")
        changeTheSubscribeButtonInteraction(false, title: subscribeButName)
        
        decideTheViewToBe()
        cartTable.tableFooterView = UIView()
        
        popUp_view = GSSubscriptionPopupView()
        popUp_view.delegate = self
        
        cartTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.selectedPaymentMode, value: 1)
    
        // Removing stored properties of delivery methods
        
        SharedPersistence.removeValue(key: UserDefaultKeys.Payment.selectedDeliveryType)
        SharedPersistence.removeValue(key: UserDefaultKeys.Payment.selectedDeliveryTypeDisplayName)
        
        let isEnableSubscription = SharedPersistence.getValue(key: UserDefaultKeys.Shops.isSubscriptionEnabled) as? Bool ?? false

        if isEnableSubscription == true {
            subscribeView.isHidden = false
        } else {
            subscribeView.isHidden = true
        }
        
    }
    
    fileprivate func loadAPIWithQueues(requiredDependecy:Bool, loadDeliverTypes:Bool) {
        
        apiQueue.cancelAllOperations()
        
        let cartApiOperation = BlockOperation {

            self.getCartDetailsAPI(isSaveForLater: false)
        }
        
        let saveForLaterOperation = BlockOperation {

            self.getCartDetailsAPI(isSaveForLater: true)
        }
        
        let deliveryApiOperation = BlockOperation {

            self.deliveryTypesAPI()
        }

        if requiredDependecy {
            saveForLaterOperation.addDependency(cartApiOperation)
            if loadDeliverTypes {
                cartApiOperation.addDependency(deliveryApiOperation)
                apiQueue.addOperation(deliveryApiOperation)
            }
        }
        
        apiQueue.addOperation(cartApiOperation)
        apiQueue.addOperation(saveForLaterOperation)
    }
    
    // Common method to fetch the subscription types from server
    fileprivate func requestSubscriptionTypeApi() {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionType
        
        APIHandler.NetworkSetupRequest(method: .post, params: [String : AnyObject]() ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionTypeModel.self, from: responseData)
                    
                    if let typesArray = responseModel.data {
                        print(typesArray)
                        
                        if typesArray.count > 0 {
                            weakSelf.subscriptionTypeArray = typesArray
                        }
                        
                    }
                    
                    if let infoArray = responseModel.info {
                        print(infoArray)
                        
                        if infoArray.count > 0 {
                            weakSelf.subscriptionInfo = infoArray
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
    
    fileprivate func changeTheSubscribeButtonInteraction(_ status:Bool, title:String) {
        
        subscribeBtn.isUserInteractionEnabled = status
        subscribeBtn.setTitle(title, for: .normal)
        if subscribeBtn.isUserInteractionEnabled {
            subscribeBtn.backgroundColor = UIColor(hexString: defaultTheme.cart_Subscribe_BG)
        } else {
            subscribeBtn.backgroundColor = UIColor.lightGray
        }
    }
    
    fileprivate func changeThePaynowButtonInteraction(_ status:Bool, title:String) {
        
        payNowBtn.isUserInteractionEnabled = status
        payNowBtn.setTitle(title, for: .normal)
        if payNowBtn.isUserInteractionEnabled {
            payNowBtn.backgroundColor = UIColor(hexString: defaultTheme.cart_MakePayment_BG)
        } else {
            payNowBtn.backgroundColor = UIColor.lightGray
        }
    }
    
    fileprivate func paymentMethodChanges() {
        
        // For Payment type selected
        var paymentMode_icon:UIImage? = #imageLiteral(resourceName: "Card")
        var paymentModeDisplayName = "Configure"
        
        if let decodedSavedPaymentMethod = SharedPersistence.getValue(key: GSPaymentConstants.SAVED_CARD_METHOD) as? Data {
            
            if let decodedSavedPaymentMethod = try? JSONDecoder().decode(GSSavePaymentMethod.self, from: decodedSavedPaymentMethod) {
                
                let paymentMethod = decodedSavedPaymentMethod.payMethod ?? 0
                
                switch paymentMethod {
                    
                case PaymentMethod.Cash.hashValue:
                    
                    let isNeedToShowCOD = SharedPersistence.getValue(key: UserDefaultKeys.Shops.isNeedToShowCOD) as? Bool ?? false
                    if isNeedToShowCOD {
                        paymentMode_icon = #imageLiteral(resourceName: "CashIcon")
                        paymentMethod_imgView.isHidden = false
                        paymentModeDisplayName = "  Cash"
                    } else {
                        paymentMode_icon = nil
                        paymentMethod_imgView.isHidden = true
                        paymentModeDisplayName = "COD Unavailable"
                    }

                    break
                case PaymentMethod.SavedCard.hashValue:
                    paymentMode_icon = GSPaymentParametersHelper.imageForTheCardtypeWithObject(cardBrand: decodedSavedPaymentMethod.cardBrand ?? "")
//                    let cardNum = (decodedSavedPaymentMethod.cardNumber?.substring(from:(decodedSavedPaymentMethod.cardNumber?.index((decodedSavedPaymentMethod.cardNumber?.endIndex)!, offsetBy: -3))!))
                   
                    if let cardNumber = decodedSavedPaymentMethod.cardNumber {
                        
                        let cardNum = cardNumber[cardNumber.index(cardNumber.endIndex, offsetBy: -3)...]
                        paymentModeDisplayName = "Credit/Debit *" + cardNum
                    }
                    break
                default:
                    paymentMode_icon = #imageLiteral(resourceName: "Card")
                    paymentModeDisplayName = "Configure"
                    break
                }
            }
        }
        
        paymentMethod_imgView.image = paymentMode_icon
        paymentMethod_lbl.text = paymentModeDisplayName
    }
    
    fileprivate func deliveryMethodChanges() {
        
        // For Deliver method Selected
        if let selectedDeliveryOption = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryTypeDisplayName) as? String {
            deliveryModeFloat_lbl.text = "Delivery Mode"
            deliveryMode_lbl.text = selectedDeliveryOption
        } else {
            deliveryModeFloat_lbl.text = ""
            deliveryMode_lbl.text = "Delivery Mode"          // By Default
        }
    }
    
    fileprivate func addPopupView() {
        if popUp_view != nil {
            if popUp_view.isDescendant(of: self.view) {
                return
            }
            popUp_view = nil
        }
        popUp_view = GSSubscriptionPopupView()
        popUp_view.delegate = self
        popUp_view.showTheViewFromBottom(on: view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: {})
    }
    
    fileprivate func addPicker(_ dataArr : [String], selectedValue: String?, completion:@escaping (_ sel:String, _ isCancel:Bool) -> Void) {
        
        if picker != nil {
            if picker.isDescendant(of: self.view) {
                return
            }
            picker = nil
        }
        picker = GSCustomPickerView()
        picker.pickerData = dataArr
        
        picker.showTheView(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom))
        
        // This is to check whether selected value exists and if exists, to show selected one as highlighted...
        if let unwrappedSelectedValue = selectedValue {
            if let selectedIndex = dataArr.index(of: unwrappedSelectedValue) {
                picker.pickerView.selectRow(selectedIndex, inComponent: 0, animated: true)
            }
        }
        
        picker.selectedPicker { (selValue, cancel) in
            completion(selValue ?? "",cancel)
        }
    }
    
    fileprivate func addMonthPicker() {
        
        if monthPicker != nil {
            if monthPicker.isDescendant(of: self.view) {
                return
            }
            monthPicker = nil
        }
        monthPicker = GSMonthYearPickerView()
        monthPicker.showTheViewFromBottom(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: { [weak self] in
            
            UIView.animate(withDuration: 0.1, animations: {
                self?.monthPicker.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            })
        })
        
        monthPicker.selectedPicker { (selValue, cancel) in
            if !cancel {
                self.popUp_view.date_lbl.text = "\(selValue!)"
            }
        }
    }
    
    private func decideTheViewToBe() {
        
        if isDraftView {
            navigationBar_view.leftBarImage.image = #imageLiteral(resourceName: "SideMenu_icon")
            navigationBar_view.titleText = "Draft"
            navigationBar_view.rightBarBtn.setTitle("", for: .normal)
            
        } else if isWishListView {
            navigationBar_view.leftBarImage.image = #imageLiteral(resourceName: "Back_arrow")
            navigationBar_view.titleText = "WishList"
            navigationBar_view.rightBarBtn.setTitle("", for: .normal)
            
        } else {
            navigationBar_view.leftBarImage.image = #imageLiteral(resourceName: "Back_arrow")
            navigationBar_view.titleText = "Cart - Verify Items"
            //          navigationBar_view.rightBarBtn.setTitle("Save", for: .normal)
        }
    }
    
    func onsearchandSelect(_ index: IndexPath) {
        
    }
    
    fileprivate func isAPIRunning() -> Bool {
        
        return isAPI_running
    }
    
    //MARK: - Button actions
    @IBAction func makePaymentButtonPressed(_ sender: UIButton) {
        if isAPI_running { return }
        
        stockAvailabilityAPI()
    }

    @IBAction func selectPaymentButtonPressed(_ sender: UIButton) {
        
        if isAPI_running { return }
        
        if let paymentTypeVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPaymentTypeViewController) as? GSPaymentTypeViewController {
            paymentTypeVC.purchaseAmountToPay = purchaseAmountToPay
            paymentTypeVC.isPaymentConfigurationFromCart = true
            if let navigator = navigationController {
                navigator.pushViewController(paymentTypeVC, animated: true)
            }
        }
    }
    
    @IBAction func selectDeliveryOption(_ sender:Any){
        if isAPI_running { return }

        if let deliveryOptionVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSDeliveryOptionViewController) as? GSDeliveryOptionViewController {
            deliveryOptionVC.delegate = self
            if let navigator = navigationController {
                navigator.pushViewController(deliveryOptionVC, animated: true)
            }
        }
    }
    
    @IBAction func customizeOrderButtonPressed(_ sender: UIButton) {
        if isAPI_running { return }

        if cartListNewProducts_backup.count == 0 {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.noProductsToCustomize, viewController: self)
            return
        }
        
        if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSOrderCustomizationViewController) as? GSOrderCustomizationViewController {
            tempVC.delegate = self
            if let navigator = navigationController {
                navigator.pushViewController(tempVC, animated: true)
            }
        }
    }
    
    @IBAction func viewBillingAction(_ sender: UIButton) {
        
        if cartListNewProducts_backup.count == 0 {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.noProductsInBilling, viewController: self)
            return
        } else if billing_data == nil {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.cartBillLoadingIssue, alertButtonsArray: ["Cancel","Refresh"], viewController: self) { btnIndex in
                if btnIndex == 1 {
                    self.viewBillingAPI()
                }
            }
            return
        }
        
        if billing_view != nil {
            if billing_view.isDescendant(of: self.view) {
                return
            }
            billing_view = nil
        }
        billing_view = GSViewBillingView()
        billing_view.intializeWithDataModel(billing_data: billing_data)
        billing_view.showTheViewOn(self.view)
    }
    
    @IBAction func subscriptionAction(_ sender: Any) {
        
       self.deliveryTimeSlotViewDisplay()
    }
    
    private func deliveryTimeSlotViewDisplay() {
        
        if let pushVC = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "BottomTableViewController") as? BottomTableViewController {
            pushVC.delegate = self
            pushVC.modalPresentationStyle = .overCurrentContext
            pushVC.arraySubscriptionList = subscriptionTypeArray
            pushVC.delegate = self
            present(pushVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - tableView View delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if saveForLaterNewProducts.count > 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return cartListNewProducts.count
        } else {
            return saveForLaterNewProducts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.CartVC_cartList_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSCartListTableCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        cell.remove_btn.tag = indexPath.row
        cell.more_btn.tag = indexPath.row
        cell.quantitySelection_btn.tag = indexPath.row
        cell.btnSel.tag = indexPath.row
        
        cell.quantityLblBG_view.layer.borderColor = UIColor(hexString: defaultTheme.cart_quantity_border).cgColor
        
        if indexPath.section == 0 {                 /// Cart Item Cell
            
            cell.quantitySelection_btn.isUserInteractionEnabled = true
            
            let itemAtIndex = cartListNewProducts[indexPath.row]
            cell.configureTheCellWithNewModel(model_item: itemAtIndex)
            
            let idOfTheProduct = itemAtIndex.id ?? ""
            
            if mismatchedStockId_array.contains(idOfTheProduct) {
                cell.quantityLblBG_view.layer.borderColor = UIColor.red.cgColor
            }
            
            cell.btnSel.setImage(#imageLiteral(resourceName: "Check_icon"), for: .normal)
        } else {                                    /// Save for later Cell
            cell.quantitySelection_btn.isUserInteractionEnabled = false
            
            let itemAtIndex = saveForLaterNewProducts[indexPath.row]
            cell.configureTheCellWithNewModel(model_item: itemAtIndex)
            cell.info_lbl.text = ""
            
            cell.btnSel.setImage(#imageLiteral(resourceName: "Uncheck_icon"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        
        let title_lable = UILabel()
        title_lable.text = headerTitles_array[section]
        title_lable.font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont.systemFont(ofSize: 18) : UIFont.systemFont(ofSize: 15)
        title_lable.textColor = UIColor(hexString: defaultTheme.cart_header_title)
        headerView.backgroundColor = UIColor(hexString: defaultTheme.cart_header_bg)
        headerView.addSubview(title_lable)

        title_lable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: title_lable, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

// MARK: - Order Customization Delegate
extension GSCartViewController: GSRefreshCartDelegate {
    
    func refreshTheCart() {        // Whene the Order Customized... Will reload the cart
        getCartDetailsAPI(isSaveForLater: false)
    }
}

// MARK: - Cell Delegate Methods
extension GSCartViewController:GSCartListTableCellDelegate {
    
    func cell_quantitySelection(_ sender: UIButton, checkBoxSender: UIButton) {
        if isAPI_running { return }
        let tag = sender.tag

        if checkBoxSender.imageView?.image == #imageLiteral(resourceName: "Check_icon") {                                    // Cart product
            
            let productAtIndex = cartListNewProducts[tag]
            
            productQuantityAPI(for: productAtIndex)
        }
    }
    
    func showQuantityResponseOnUI(viewCartProductData:GSCartListNewData, quantityProductData: GSCartListNewData) {
        
        guard let storesArray = quantityProductData.stores else { return }
        
        var stock = 0
        var selectedQuantity = 0
        
        for store_item in storesArray {
            let localStockVar = store_item.productDetails?.stock ?? 0
            stock += localStockVar
        }
        
        if let viewCartStoreArray = viewCartProductData.stores {
            for store in viewCartStoreArray {
                let localQuantityVar = store.productDetails?.qty ?? 0
                selectedQuantity += localQuantityVar
            }
        }
        
        if stock == 0 {     // Checking whether it is having any stock or not
            CustomAlert.showAlert(title: "Error", message: GSConstant.AlertMessages.cartProductUnavailability, viewController: self)
            return
        }
        
        var picker_array = [String]()
        for index in 1..<stock+1 {
            picker_array.append("\(index)")
        }
        
        addPicker(picker_array, selectedValue: "\(selectedQuantity)", completion: { selValue, isCancel in
            
            if !isCancel {
                self.checkAndUpdateQuantity(viewCartProductData: viewCartProductData, quantityProductData: quantityProductData, selValue: selValue)
            }
        })
    }
    
    private func checkAndUpdateQuantity(viewCartProductData:GSCartListNewData, quantityProductData: GSCartListNewData, selValue:String) {
        
        var sel_stock = Int(selValue) ?? 0
        
        guard let theStore_array = quantityProductData.stores else { return }
        
        var addingCartRequestArray = [[String:Any]]()
        
        for index in 0..<theStore_array.count {
            
            let storeAtIndex = theStore_array[index]
            
            let stock_available = storeAtIndex.productDetails?.stock ?? 0
//            let quantitySelectedInThisStore = storeAtIndex.productDetails?.qty ?? 0
            
            let quantitySelectedInThisStore = getSelectedQuantityForTheStoreWith(store_id: storeAtIndex.storeID ?? "", viewCartProductData: viewCartProductData)
            
            if sel_stock < 0 {
                break
            }
            if sel_stock == 0 {
                
                let reqDictionaryForAddingCart = ["store_id": storeAtIndex.storeID ?? "",
                                                  "qty"     : -quantitySelectedInThisStore] as [String : Any]
                addingCartRequestArray.append(reqDictionaryForAddingCart)
                
            } else if sel_stock <= stock_available {
                
                if sel_stock != quantitySelectedInThisStore {
                    
                    let remaining = quantitySelectedInThisStore - sel_stock
                    let reqDictionaryForAddingCart = ["store_id": storeAtIndex.storeID ?? "",
                                                      "qty"     : -remaining] as [String : Any]
                    addingCartRequestArray.append(reqDictionaryForAddingCart)
                }
                sel_stock = 0           // If selected stock is lesser than available stock.. will add or remove selected stock... and makes selected to zero...
                
            } else {
                
                if quantitySelectedInThisStore != stock_available {
                    let quantityNeedToBeAdded = stock_available - quantitySelectedInThisStore
                    let reqDictionaryForAddingCart = ["store_id": storeAtIndex.storeID ?? "",
                                                      "qty"     : quantityNeedToBeAdded] as [String : Any]
                    addingCartRequestArray.append(reqDictionaryForAddingCart)
                }
                sel_stock = sel_stock - stock_available
            }
        }
        
        // Filtering the request input
        
        var indexesToRemove = [Int]()
        for index in 0..<addingCartRequestArray.count {
            let requestItem = addingCartRequestArray[index]
            if let qty = requestItem["qty"] as? Int, qty == 0 {
                indexesToRemove.append(index)
            }
        }
        
        for index in indexesToRemove.sorted().reversed() {
            addingCartRequestArray.remove(at: index)
        }
        
        // Check whether need to call api
        if addingCartRequestArray.count == 0 {
            return
        }

        addToCartApi(storeItemArray: addingCartRequestArray, product_id: quantityProductData.id ?? "")
    }
    
    private func getSelectedQuantityForTheStoreWith(store_id:String, viewCartProductData:GSCartListNewData) -> Int {
        
        guard let viewCartProductStores = viewCartProductData.stores else { return 0 }
        
        for store_item in viewCartProductStores {
            if (store_item.storeID ?? "") == store_id {
                return store_item.productDetails?.qty ?? 0
            }
        }
        return 0
    }
    
    func cell_moreAction(_ sender: UIButton, checkBoxSender: UIButton) {
        if isAPI_running { return }

        let tag = sender.tag
        view.endEditing(true)
        let productAtIndex = (checkBoxSender.imageView?.image == #imageLiteral(resourceName: "Uncheck_icon") ) ? saveForLaterNewProducts[tag] : cartListNewProducts[tag]
        
        if detailsWithOfferPopup != nil {
            if detailsWithOfferPopup.isDescendant(of: self.view) {
                return
            }
            detailsWithOfferPopup = nil
        }
        
        detailsWithOfferPopup = GSProductDetailsWithOfferPopUpView()
        detailsWithOfferPopup.initializeProductModel(model: productAtIndex)
        detailsWithOfferPopup.showTheViewOn(self.view)
    }
    
    func cell_removeAction(_ sender: UIButton, checkBoxSender: UIButton) {
        if isAPI_running { return }

        CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.cartRemoveProduct, alertButtonsArray: ["No","Yes"], isLastButtonDestructive: true, viewController: self) { btnIndex in
            
            if btnIndex == 1 {
                self.removeProductFromList(sender, checkBoxSender: checkBoxSender)
            }
        }
    }
    
    private func removeProductFromList(_ sender: UIButton, checkBoxSender: UIButton) {
        let tag = sender.tag
        var productAtIndex:GSCartListNewData?
        var store_id_array = [String]()
        var isSaveLaterLoc = false
        
        if checkBoxSender.imageView?.image == #imageLiteral(resourceName: "Uncheck_icon") {         // Save For later product
            
            isSaveLaterLoc = true
            productAtIndex = saveForLaterNewProducts[tag]
            
        } else {                                   // Cart product
            
            isSaveLaterLoc = false
            productAtIndex = cartListNewProducts[tag]
        }
        
        guard let store_array = productAtIndex?.stores else { return }
        
        for store_item in store_array {
            let store_id = store_item.storeID ?? ""
            store_id_array.append(store_id)
        }
        
        var storeArrayForApiRequest = [[String:Any]]()
        
        if let store_array = productAtIndex?.stores {
            for index in 0..<store_array.count {
                let singleStore = store_array[index]
                
                let store_item = ["store_id": singleStore.storeID ?? "",
                                  "qty"     : singleStore.productDetails?.qty ?? 0] as [String : Any]
                storeArrayForApiRequest.append(store_item)
            }
        }
        
        removeItemAPI(product_id: productAtIndex?.id ?? "", stores_array: storeArrayForApiRequest, isSaveForLater: isSaveLaterLoc, isReloadNeeded: true)
    }
    
    func cell_checkBoxAction(_ sender: UIButton) {
        if isAPI_running { return }
        
        let tag = sender.tag
        var productAtIndex:GSCartListNewData?
        var isCheckLoc = false
        
        if sender.imageView?.image == #imageLiteral(resourceName: "Uncheck_icon") {         // Save For later product
            
            isCheckLoc = true
            
            if tag < saveForLaterNewProducts.count {
                productAtIndex = saveForLaterNewProducts[tag]
            }
            
        } else {                                   // Cart product
            
            isCheckLoc = false
            if tag < cartListNewProducts.count {
                productAtIndex = cartListNewProducts[tag]
            }
        }
        
        if productAtIndex == nil {
            return
        }
        
        guard let store_array = productAtIndex?.stores else { return }
        var storeArrayForApiRequest = [[String:Any]]()
        
        for index in 0..<store_array.count {
            let singleStore = store_array[index]
            let store_item = ["store_id": singleStore.storeID ?? "",
                              "qty"     : singleStore.productDetails?.qty ?? 0] as [String : Any]
            storeArrayForApiRequest.append(store_item)
        }
        checkOrUncheckTheItem(product_id: productAtIndex?.id ?? "", stores_array: storeArrayForApiRequest, isCheck: isCheckLoc)
    }
}

// MARK: NavigationBar Methods
extension GSCartViewController:NavigationWithSearchBarDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        
        apiQueue.cancelAllOperations()
        
        if isDraftView {
            addSideMenu()
            
        } else {            // For WishList and Cart
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func rightBarBtnPressed(sender: UIButton) {

        CustomAlert.showActionSheet(title: nil, message: nil, cancelTitle: "Cancel", optionArray: ["Clear Cart"], sourceView: navigationBar_view.rightBarBtn, in: self) { [weak self] selectedIndex in
            
            guard let weakSelf = self else { return }
            
            if selectedIndex == 0 {
                // Clear Cart
                CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.cartClearCart, alertButtonsArray: ["No","Yes"], isLastButtonDestructive: true, viewController: weakSelf) { btnIndex in
                    
                    if btnIndex == 1 {
                        weakSelf.clearCartSupport = GSClearCartSupport()
                        weakSelf.clearCartSupport?.delegate = weakSelf
                        weakSelf.clearCartSupport?.clearCartAPI()
                    }
                }
 
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: "Saved to draft", viewController: weakSelf)
            }
        }  // Action Sheet loop ends here...
    }
}

extension GSCartViewController:GSClearCartDelegate {
    func cartClearedSuccessfully() {
        getCartDetailsAPI(isSaveForLater: false)
    }
}

// MARK: - UISearchBar Delegate Methods
extension GSCartViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.count != 0 {
            cartListNewProducts = cartListNewProducts_backup.filter({ ($0.productInfo?.productName ?? "").lowercased().contains(searchText.lowercased())})
            saveForLaterNewProducts = saveForLaterNewProducts_backUp.filter({ ($0.productInfo?.productName ?? "").lowercased().contains(searchText.lowercased())})
            
        } else {
            cartListNewProducts = cartListNewProducts_backup
            saveForLaterNewProducts = saveForLaterNewProducts_backUp
        }
        cartTable.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

// MARK: - Subscription Popup Delegate Methods
extension GSCartViewController : GSSubscriptionPopupDelegate {
    
    func durationAction(sender: UIButton) {
        
        
        let alertController = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let options_array = ["Yearly","6 Months Once", "3 Months Once", "Monthly", "Weekly", "Daily"]
        
        for option in options_array {
            
            let alertAction = UIAlertAction.init(title: option, style: .default) { _ in
                
                self.popUp_view.duration_lbl.text = option
                self.popUp_view.date_lbl.text = "Date"
            }
            alertController.addAction(alertAction)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if let currentPopoverpresentioncontroller = alertController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = navigationBar_view.rightBarBtn
                let btnFrame = navigationBar_view.rightBarBtn.frame
                currentPopoverpresentioncontroller.sourceRect = CGRect(x: 0, y: 0, width: btnFrame.size.width, height: btnFrame.size.height)
                currentPopoverpresentioncontroller.permittedArrowDirections = .up
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func dateAction(sender: UIButton) {
        
        switch popUp_view.duration_lbl.text{
            
        case "Daily":
            print("Daily")
        case "Weekly" :
            addPicker(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], selectedValue: nil, completion: { selValue, isCancel in
                
            })
        case "Monthly", "3 Months Once", "6 Months Once":
            addPicker(["1","2","3","4", "5", "6", "7", "8", "9", "10", "11","12","13","14", "15", "16", "17", "18", "19", "20", "21","22","23", "24", "25", "26", "27", "28"], selectedValue: nil, completion: { selValue, isCancel in
                
            })
        case "Yearly":
            addMonthPicker()
        case .none:
            print("")
        case .some(_):
            print("")
        }
    }
    
    func okAction(sender: UIButton) {
        popUp_view.removeFromSuperview()
        CustomAlert.showAlert(title: GSString.AppName, message: "Subscribed Successfully", viewController: self)
    }
}

// MARK: - API Methods
extension GSCartViewController {
    
    fileprivate func getCartDetailsAPI(isSaveForLater:Bool){
        
        if !isSaveForLater {
            DispatchQueue.main.async {
                self.navigationBar_view.rightBarBtn.isHidden = true
                self.navigationBar_view.rightBarImage.isHidden = true
            }
        }
        
        let urlString = isSaveForLater ? APIurl.baseURL + APIurl.subURL.saveForLaterList : APIurl.baseURL + APIurl.subURL.viewCart
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        let params = ["_id"     :   storeCategory_id] as [String : AnyObject]
        
        isAPI_running = true
        
        APIHandler.NetworkSetupRequest(method: .post, params: params,urlString: urlString, withLoader:!isSaveForLater) { [weak self] (response, error) in
            self?.isAPI_running = false
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCartListNewModel.self, from: responseData)
                    
                    if let data = responseModel.data {
                        DispatchQueue.main.async {
                            weakSelf.handleDataReceivedFromServer(data: data, isSaveForLater: isSaveForLater)
                        }
                    }
                    
                } catch {
                    print(error)
                    if !isSaveForLater {
                        DispatchQueue.main.async {
                            CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                            weakSelf.changeThePaynowButtonInteraction(false, title: GSConstant.cartBillLoadingIssue)
                            weakSelf.changeTheSubscribeButtonInteraction(false, title: weakSelf.subscribeButName)
                        }
                    }
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)

                if !isSaveForLater {
                    DispatchQueue.main.async {
                        CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
                        weakSelf.changeThePaynowButtonInteraction(false, title: GSConstant.cartBillLoadingIssue)
                        weakSelf.changeTheSubscribeButtonInteraction(false, title: weakSelf.subscribeButName)
                    }
                }
            }
            
        }
    }
    
    fileprivate func handleDataReceivedFromServer(data: [GSCartListNewData],isSaveForLater:Bool) {
        
        if isSaveForLater {
            
            saveForLaterNewProducts_backUp = data
            saveForLaterNewProducts = data
            
        } else {
            
            if data.count != 0 {
                viewBillingAPI()            // Will require billing api whenever cart reloads only
                navigationBar_view.rightBarBtn.isHidden = false
                navigationBar_view.rightBarImage.isHidden = false
            } else {
                changeThePaynowButtonInteraction(false, title: GSConstant.cartBillMessage)
                changeTheSubscribeButtonInteraction(false, title: subscribeButName)
            }
            
            cartListNewProducts_backup = data
            cartListNewProducts = data
            
            if cartItemsDictionary.count > 0 {
                cartItemsDictionary.removeAll()
            }
            
            for cartItem in cartListNewProducts {
                if let product_id = cartItem.id {
                    cartItemsDictionary[product_id] = cartItem
                }
            }
            
            calculateCartCount()
        }
        self.cartTable.reloadData()
    }
    
    private func calculateCartCount() {
        
        var cartCount_local = 0
        
        for cartProduct in cartListNewProducts {
            if let store_array = cartProduct.stores {
                for store_item in store_array {
                    let quantitySelectedInTheStore = store_item.productDetails?.qty ?? 0
                    cartCount_local += quantitySelectedInTheStore
                }
            }
        }
        cartCount.value = cartCount_local
    }
    // Need to create a common file/class for this method
    fileprivate func caluculatePriceWithOffer(_ original_price:Double, offer: Double) -> Double {
        if offer == 0 {
            return original_price
        }
        let costOfOffer = (original_price) * (offer/100)
        return (original_price) - costOfOffer
    }
    
    fileprivate func checkOrUncheckTheItem(product_id: String ,stores_array: [[String:Any]], isCheck:Bool) {
        
        let urlString = isCheck ? APIurl.baseURL + APIurl.subURL.checkSaveForLater : APIurl.baseURL + APIurl.subURL.uncheckCart
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        
        let params = [ "_id": storeCategory_id,
                       "product_id": product_id,
                       "is_private": SharedPersistence.getValue(key: UserDefaultKeys.Products.isPrivateShop) as? Bool ?? false,
                       "stores": stores_array ] as [String:AnyObject]
        self.isAPI_running = true
        
        APIHandler.NetworkSetupRequest(method: .post, params: params,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            self?.isAPI_running = false

            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if let success = responseModel.success {
                        if success {
                            weakSelf.getCartDetailsAPI(isSaveForLater: false)
                            weakSelf.getCartDetailsAPI(isSaveForLater: true)
//                            weakSelf.loadAPIWithQueues(requiredDependecy: false, loadDeliverTypes: false)
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
    
    fileprivate func deliveryTypesAPI () {
        
        let urlString = APIurl.baseURL + APIurl.subURL.deliveryTypes
        
        let storesArray = SharedPersistence.getValue(key: UserDefaultKeys.Products.selecedStoreArray) as? [String] ?? [String]()
        
        let params = ["stores" : storesArray] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:true) { [weak self]  (response, error) in
            
            // Making sure the next code will not execute if the view controller not exists in memory
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSDeliveryTypeModel.self, from: responseData)
                    
                    if let deliveryTypes = responseModel.data?.type {
                        
                        for type in deliveryTypes {
                            if let selectedDelType = responseModel.data?.deliveryType, selectedDelType == type.id {
                                
                                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.selectedDeliveryType, value: selectedDelType)
                                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.selectedDeliveryTypeDisplayName, value: type.name ?? "")
                                DispatchQueue.main.async {
                                    weakSelf.deliveryMethodChanges()
                                }
                                
//                                weakSelf.getCartDetailsAPI(isSaveForLater: false)
//                                weakSelf.getCartDetailsAPI(isSaveForLater: true)
                                
                                break
                            }
                        }
                        
                        if SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryType) == nil, let firstType = deliveryTypes.first {
                            weakSelf.updateDeliveryMethodAPI(selectedType: firstType)
                        }
                    }
                    
                    weakSelf.getCartDetailsAPI(isSaveForLater: false)
                    weakSelf.getCartDetailsAPI(isSaveForLater: true)
                    
                } catch {
                    #if DEBUG
                    print(error)
                    #endif
                    
                    weakSelf.getCartDetailsAPI(isSaveForLater: false)
                    weakSelf.getCartDetailsAPI(isSaveForLater: true)
                }
            } else {
                #if DEBUG
                print(error?.localizedDescription ?? "")
                #endif
                
                weakSelf.getCartDetailsAPI(isSaveForLater: false)
                weakSelf.getCartDetailsAPI(isSaveForLater: true)
            }
        }
    }
    
    func updateDeliveryMethodAPI (selectedType:GSDeliveryType) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.deliveryTypeEdit
        
        let parameters = ["delivery_type": selectedType.id ?? 1] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            // Making sure the next code will not execute if the view controller not exists in memory
            guard let weakSelf = self else { return }
            
            weakSelf.getCartDetailsAPI(isSaveForLater: false)
            weakSelf.getCartDetailsAPI(isSaveForLater: true)
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if responseModel.success == true {
                        let selectedIndex = selectedType.id ?? 1
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.selectedDeliveryType, value: selectedIndex)
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.selectedDeliveryTypeDisplayName, value: selectedType.name ?? "")
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.isDeliveryConfigured, value: true)
                        
                        DispatchQueue.main.async {
                            weakSelf.deliveryMethodChanges()
                        }
                    }
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? "")
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    fileprivate func removeItemAPI(product_id: String, stores_array: [[String:Any]], isSaveForLater:Bool, isReloadNeeded: Bool) {
        
        let urlString = isSaveForLater ? APIurl.baseURL + APIurl.subURL.removeSaveForLater : APIurl.baseURL + APIurl.subURL.removeCart
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        
        let params = [ "_id": storeCategory_id,
                       "product_id": product_id,
                       "is_private": SharedPersistence.getValue(key: UserDefaultKeys.Products.isPrivateShop) as? Bool ?? false,
                       "stores": stores_array ] as [String:AnyObject]
        self.isAPI_running = true
        APIHandler.NetworkSetupRequest(method: .delete, params: params,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            self?.isAPI_running = false
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if let success = responseModel.success {
                        if success && isReloadNeeded {
                            // Based on the deletion.. will refresh either cart or save for later
                            weakSelf.getCartDetailsAPI(isSaveForLater: isSaveForLater)
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
    
    fileprivate func stockAvailabilityAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.verifyStockInCart
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        
        let params = ["_id" : storeCategory_id as AnyObject] as [String : AnyObject]
        
        payNowBtn.isUserInteractionEnabled = false
        self.isAPI_running = true
        
        APIHandler.NetworkSetupRequest(method: .post, params: params,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            self?.isAPI_running = false
            self?.payNowBtn.isUserInteractionEnabled = true
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSStockAvailabilityModel.self, from: responseData)
                    print(responseModel)
                    
                    if weakSelf.mismatchedStock_data.count > 0 {
                        weakSelf.mismatchedStock_data.removeAll()
                    }
                    
                    if weakSelf.mismatchedStockId_array.count > 0 {
                        weakSelf.mismatchedStockId_array.removeAll()
                    }
                    
                    if let products_data = responseModel.data {
                        
                        if products_data.count > 0 {            // Stock mis-match happened... Need to show the mismatched stock
                            
                            for data_item in products_data {
                                guard let product_list = data_item.products else { continue }
                                weakSelf.mismatchedStock_data.append(contentsOf: product_list)
                                
                                for product in product_list {
                                    weakSelf.mismatchedStockId_array.append(product.id ?? "")
                                }
                            }
                            
                            CustomAlert.showAlert(title: "Error", message: "No sufficient stock for few of your cart and highlighted in your list. Please check and go further by either decreasing the stock or removing it from cart.", alertButtonsArray: ["Ok"], viewController: weakSelf, completion: { _ in
                                weakSelf.cartTable.reloadData()
                            })
                            
                        } else {
                            weakSelf.pushToAppropriateViewAsStockVerified()
                        }
                        
                    } else {
                        weakSelf.pushToAppropriateViewAsStockVerified()
                    }
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
            
        }
    }
    
    private func pushToAppropriateViewAsStockVerified() {
        
        // Will just check for the delivery method selected....
        // If By shop selected will verify the address for delivery purpose... otherwise places the order directly...
        
        if let addressConfirmationVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSOrderConfirmationViewController) as? GSOrderConfirmationViewController {
            addressConfirmationVC.purchaseAmountToPay = String(billing_data?.prices.netPrice ?? 0) //purchaseAmountToPay
            if let navigator = navigationController {
                navigator.pushViewController(addressConfirmationVC, animated: true)
            }
        }
    }
    
    func addToCartApi(storeItemArray:[[String:Any]], product_id:String) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.addProductToCart
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        
        let params = ["_id" : storeCategory_id as AnyObject ,
                      "product_id" : product_id as AnyObject ,
                      "is_private" : SharedPersistence.getValue(key: UserDefaultKeys.Products.isPrivateShop) as? Bool ?? false,
                      "stores"     : storeItemArray] as [String : AnyObject]
        self.isAPI_running = true
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:true) { [weak self]  (response, error) in
            
            self?.isAPI_running = false
            // Making sure the next code will not execute if the view controller not exists in memory
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSAddToCartModel.self, from: responseData)
                    
                    if responseModel.success ?? false {
                        self?.getCartDetailsAPI(isSaveForLater: false)
                        #if DEBUG
                        print("Added")
                        #endif
                    } else {
                        #if DEBUG
                        print("Error in adding to cart")
                        #endif
                    }
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? "")
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func viewBillingAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.viewBilling
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        
        let params = ["_id" : storeCategory_id as AnyObject] as [String : AnyObject]
        
        payNowBtn.setTitle("", for: .normal)
        paymentCalculation_activityIndicator.startAnimating()
        self.isAPI_running = true
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:true) { [weak self]  (response, error) in
            
            self?.isAPI_running = false
            if self == nil {        // Making sure the next code will not execute if the view controller not exists in memory
                return
            }
            
            DispatchQueue.main.async {
                self?.paymentCalculation_activityIndicator.stopAnimating()
            }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSViewBillingModel.self, from: responseData)
                    
                    let total_to_pay = responseModel.data.prices.netPrice
                    
                    if total_to_pay != 0 {
                        self?.changeThePaynowButtonInteraction(true, title: "Proceed to Buy ₹\(total_to_pay)")
                        self?.changeTheSubscribeButtonInteraction(true, title: self!.subscribeButName)
                    } else {
                        self?.changeThePaynowButtonInteraction(false, title: GSConstant.cartBillLoadingIssue)
                        self?.changeTheSubscribeButtonInteraction(false, title: self!.subscribeButName)
                    }
                    
                    self?.billing_data = responseModel.data
                    // Will check for COD case is available or not
                    self?.updateCodAvailabilityToUserDefaults()
                } catch {
                    print(error)
                    self?.changeThePaynowButtonInteraction(false, title: GSConstant.cartBillLoadingIssue)
                    self?.changeTheSubscribeButtonInteraction(false, title: self!.subscribeButName)
                }
            } else {
                print(error?.localizedDescription ?? "")
                self?.changeThePaynowButtonInteraction(false, title: GSConstant.cartBillLoadingIssue)
                self?.changeTheSubscribeButtonInteraction(false, title: self!.subscribeButName)
                // GSAlertController.initialization().showAlertWithOkButton(title: "", aStrMessage: error?.localizedDescription ?? "", completion: { _ in })
            }
        }
    }
    
    private func updateCodAvailabilityToUserDefaults() {
        
        if let isCodAvailable = SharedPersistence.getValue(key: UserDefaultKeys.Shops.isCodEnabled) as? Bool {
            
            if isCodAvailable == false {
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isNeedToShowCOD, value: false)
                
            } else {
                
                if let total_amount = billing_data?.prices.netPrice, let codLimit = SharedPersistence.getValue(key: UserDefaultKeys.Shops.codLimit) as? Double {
                    
                    if total_amount <= codLimit {
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isNeedToShowCOD, value: true)
                    } else {
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isNeedToShowCOD, value: false)
                    }
                }
            }
        }
        
        paymentMethodChanges()
    }
    
    func productQuantityAPI(for productAtIndex:GSCartListNewData) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.productQuantityInCart
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        let categoryStores_array = SharedPersistence.getValue(key: UserDefaultKeys.Products.selecedStoreArray) as? [String] ?? [""]
        
        let params = ["_id" : storeCategory_id,
                      "product_id": productAtIndex.id ?? "",
//                      "is_private": false,
                      "stores": categoryStores_array] as [String : AnyObject]
        self.isAPI_running = true
        
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:true) { [weak self]  (response, error) in
            
            self?.isAPI_running = false
            // Making sure the next code will not execute if the view controller not exists in memory
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCartListQuantityModel.self, from: responseData)
                    
                    if var singleProductQuantityData = responseModel.data {
                        
                        singleProductQuantityData.stores?.sort(by: {round((self?.caluculatePriceWithOffer($0.productDetails?.sellingPrice ?? 0,offer: $0.productDetails?.offer ?? 0))!) < round((self?.caluculatePriceWithOffer($1.productDetails?.sellingPrice ?? 0,offer: $1.productDetails?.offer ?? 0))!)})
                        
                        self?.showQuantityResponseOnUI(viewCartProductData: productAtIndex,  quantityProductData: singleProductQuantityData)
                    }
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? "")
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
}


// MARK: - UIImagePicker Controller Delegate

extension GSCartViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = UIImage.from(info: info) {
            
            var oriented = selectedImage
            oriented = GSCommonHelper.fixOrientation(img: selectedImage)
            
//            attachedImage = oriented
//            self.address_tableView.reloadData()
            
        } else {
            picker.dismiss(animated: true) {
//                CustomAlert.showAlert(title: "Error", message: "Unable to fetch the photo", viewController: self)
            }
            return
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
// MARK: - Delivery Time Slot Methods
extension GSCartViewController:BottomTableViewDelegate {
    func selectSubscribeType(subscription: SubscriptionTypeData) {
        
        SharedPersistence.removeValue(key: UserDefaultKeys.subscriptionName)
        
        if subscription.displayName == "Daily" || subscription.displayName == "Alternate days" || subscription.displayName == "Weekly" {
            
            if let subscribe = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSSubscriberDaysViewController") as? GSSubscriberDaysViewController {
                subscribe.subscribeType = subscription.displayName ?? ""
                subscribe.subscriberData = subscription
                subscribe.arraySubsscriptionList = subscriptionInfo
                if let navigator = navigationController {
                    navigator.pushViewController(subscribe, animated: true)
                }
            }

            
        }else{
            
            if let subscribe = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSSubscriberViewController") as? GSSubscriberViewController {
                subscribe.subscribeType = subscription.displayName ?? ""
                subscribe.subscriberData = subscription
                if let navigator = navigationController {
                    navigator.pushViewController(subscribe, animated: true)
                }
            }
 
        }
        
    }
    
}

// MARK: - SubscriptionAmountModel
struct SubscriptionTypeModel: Codable {
    let success: Bool?
    let data: [SubscriptionTypeData]?
    let info: [SubscriptionInfo]?
}

// MARK: - Datum
struct SubscriptionTypeData: Codable {
    let id, model, displayName: String?
    let index: Int?
    let isActive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case model
        case displayName = "display_name"
        case index, isActive
    }
}

// MARK: - Info
struct SubscriptionInfo: Codable {
    let info: String?
}
