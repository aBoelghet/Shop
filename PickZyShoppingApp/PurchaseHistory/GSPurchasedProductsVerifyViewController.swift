//
//  GSPurchasedProductsVerifyViewController.swift
//  Shopor
//
//  Created by Ratheesh on 09/01/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import QBImagePickerController
import MKToolTip
import MBProgressHUD

class GSPurchasedProductsVerifyViewController: GSLoggedInBaseViewController {
    
    @IBOutlet var navigationBarView: NavigationBarNormal!
    @IBOutlet var purchasedVerify_tableView: UITableView!
    
    @IBOutlet weak var deliveryStatus_lbl: GSBaseLabel!
    @IBOutlet weak var verifiedStaus_lbl: GSBaseLabel!
    
    @IBOutlet weak var header_lbl:GSBaseLabel!
    @IBOutlet weak var orderCost_lbl: GSBaseLabel!
    @IBOutlet weak var headerLabel_BG:UIView!
    @IBOutlet weak var deliveryLabelBG_view: UIView!
    @IBOutlet weak var delivered_lbl: GSBaseLabel!
    @IBOutlet weak var submit_btn:GSBaseButton!
    @IBOutlet weak var submitBtnHeight_constraint:NSLayoutConstraint!
    @IBOutlet weak var invoice_btn: GSUnderlinedButton!
    
    lazy var apiVerifyRequestBody_array = [PurchasedItemsVerifyModel]()
    
    var indexForComplaintCell:Int = -1
    var selectedIndex:Int = -1
    var isIndexPathSelected = false
    
    var isComplaintSelected = false
    
    lazy var replacementConfig_array = [String]()
    
    var imagesDictionary = [String:Any]()
    var maxImagesCount = 3
    var imageSelectionIndex = -1
    var isCancelledProduct = false
    
    var isVerified = false
    
    var category_id = ""
    var store_id = ""
    var order_id = ""
    
//    var orderDetails: GSPurchasedListDataOrderDetail?
//    var productList_array = [GSPurchasedListProduct]()
//    var orderRootObject:GSPurchasedListDataID?
    var totalPrice:Double = 0
    
    var picker:GSCustomPickerView!
    var productStatus:GSPurchasedProductStatus!
    var toolTip:MKToolTip?
    
    // New Models
    
    var orderObject:GSTrackOrderProductListOrder?
    var productsData: GSTrackOrderProductListData?
    var products_array = [GSTrackOrderProductListProduct]()
    
    var apiOrderStatusEnum:OrderStatusFromAPI = .other
    var isReplacementDaysLeft:ReplacementDaysLeftObject?
    
    var isExpiryNeedToShow = false
    
    var productIdArrayToReOrder = [String]()
    
    // MARK: - Enum For Order Status
    
    enum OrderStatusFromAPI {
        case delivered
        case verified
        case other
        case cancelledOrRejected
    }
    
    // MARK: - Sturcturized Replacement Days Left Object
    
    struct ReplacementDaysLeftObject {
        let isExist:Bool
        let toShow:String
    }

    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFewIntializers()
        applyColors()
        replacementConfigurationAPI()
//        changesBasedOnOrderStatus()
        productListAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Initializing With Data
    
//    func intializeWith(orderDetailsObj:GSPurchasedListDataOrderDetail, headerObj:GSPurchasedListDataID?) {
//        self.orderDetails = orderDetailsObj
//        self.orderRootObject = headerObj
//
//        if let products_array = orderDetails?.products {
//            self.productList_array = products_array
//        }
//    }
    
    func initializeWith(categoryId:String?, storeId:String?, orderId:String?) {
        
        self.category_id = categoryId ?? ""
        self.store_id = storeId ?? ""
        self.order_id = orderId ?? ""
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        
        deliveryStatus_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_delStatus_green_text)
        verifiedStaus_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_delStatus_red_text)
        
        headerLabel_BG.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_header_bg)
        header_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_header_title)
        
        deliveryLabelBG_view.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_header_bg)
        delivered_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_header_title)
        
        submit_btn.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_submitBtn_BG)
        submit_btn.setTitleColor(UIColor(hexString: defaultTheme.verifyItems_submitBtn_title), for: .normal)
        orderCost_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_header_cost_text)
    }
    
    // MARK: User defined Methods
    
    func addFewIntializers() {
        
        navigationBarView.delegate = self
        
        purchasedVerify_tableView.delegate = self
        purchasedVerify_tableView.dataSource = self
        
        purchasedVerify_tableView.estimatedRowHeight = 44.0
        purchasedVerify_tableView.rowHeight = UITableViewAutomaticDimension
        purchasedVerify_tableView.tableFooterView = UIView()
        
        let cellNib = UINib(nibName: GSString.NibNames.GSTrackPurchaseVerifyTableCell, bundle: nil)
        purchasedVerify_tableView.register(cellNib, forCellReuseIdentifier: GSString.CellIdentifier.commonCellForVerifyTrackorderPurchaseHistory)
        
        deliveryStatus_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_delStatus_green_text)
        verifiedStaus_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_delStatus_green_text)
        
        header_lbl.text = "Delivered Items"
        
        navigationBarView.titleText = ""
        navigationBarView.rightBarBtn.isHidden = true
    }
    
    // MARK: - Model For Maintaining to send request and to manage tableView
    
    struct PurchasedItemsVerifyModel {
        let productName:String
        var product_id:String
        var verify_status:Int
        var apiVerify_status:Int
        var previousSelectedVerify_status:Int
        var enable_expiry_date:Bool
        var title:String
        var message:String
        var selectedQty:Int
        var totalQty:Int
        var price:Double
    }
    
    // MARK: View Controller Methods
    
    @IBAction func submitAction(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Reorder" {
            
            reorderCheck()
            return
        }
        
        // Verify the request body
        
        if apiOrderStatusEnum == .delivered {
            
            for index in 0..<apiVerifyRequestBody_array.count {
                
                let requestBody = apiVerifyRequestBody_array[index]
                
                if requestBody.verify_status == 0, requestBody.apiVerify_status == 0 {

                    CustomAlert.showAlert(title: GSString.AppName, message: "Please verify \(requestBody.productName)", viewController: self)
                    return
                    
                } else if requestBody.verify_status == TrackOrderConstants.VerifyStatus.replacement {
                    let replacementValidation = validateReplacementRequest(for: index)
                    
                    if replacementValidation.0 == false {
                        CustomAlert.showAlert(title: GSString.AppName, message: "\(requestBody.productName)\n\(replacementValidation.1)", viewController: self)
                        return
                    }
                }
            }
        } else {            // Already verified
            // Nothing to do as of now....
            
        }
        
        // After Verifying Will Call API
        
        verifyTotalOrderAPI()
    }
    @IBAction func invoice_action(_ sender: UIButton) {
        
        if let invoiceVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSOrderInvoiceViewController) as? GSOrderInvoiceViewController {
            
            invoiceVC.productsArray = products_array
            invoiceVC.productsData = productsData
            navigationController?.pushViewController(invoiceVC, animated: true)
        }
    }
    
    // MARK: - View Changes Based On The Order Status
    
    fileprivate func changesBasedOnOrderStatus() {
        
        guard let unwrappedOrderDetailsObject = orderObject else { return }
        guard let orderStatus = unwrappedOrderDetailsObject.status else { return }
        
        var delivery_status = "NA"
        var isDeliveryStatusGoingGood = false
        var customerVerifyStatus = ""
        
        var isHelpButtonNeeded = true
        
        var headerDateKeyText = "Delivered Date: "
        var headerItemsStatus = "Delivered Items"
        
        apiOrderStatusEnum = .other
        
        var updatedDate = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: orderObject?.ordered, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
        
        switch orderStatus {
        case TrackOrderConstants.NewOrderStatus.Ordered.status:
            delivery_status = TrackOrderConstants.NewOrderStatus.Ordered.name
            isDeliveryStatusGoingGood = true
            break
        case TrackOrderConstants.NewOrderStatus.Accepted.status:
            delivery_status = TrackOrderConstants.NewOrderStatus.Accepted.name
            isDeliveryStatusGoingGood = true
            break
        case TrackOrderConstants.NewOrderStatus.Rejected.status:
            apiOrderStatusEnum = .cancelledOrRejected
            delivery_status = TrackOrderConstants.NewOrderStatus.Rejected.name
            isDeliveryStatusGoingGood = false
            isHelpButtonNeeded = false
            headerDateKeyText = "Cancelled Date: "
            headerItemsStatus = "Cancelled Items"
            updatedDate = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: orderObject?.rejected, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
            break
        case TrackOrderConstants.NewOrderStatus.Cancelled.status:
            apiOrderStatusEnum = .cancelledOrRejected
            delivery_status = TrackOrderConstants.NewOrderStatus.Cancelled.name
            customerVerifyStatus = TrackOrderConstants.NewOrderStatus.Cancelled.name
            isDeliveryStatusGoingGood = false
            isHelpButtonNeeded = false
            headerDateKeyText = "Cancelled Date: "
            headerItemsStatus = "Cancelled Items"
            updatedDate = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: orderObject?.cancelled, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
            break
        case TrackOrderConstants.NewOrderStatus.Denied.status:
            apiOrderStatusEnum = .cancelledOrRejected
            delivery_status = TrackOrderConstants.NewOrderStatus.Denied.name
            customerVerifyStatus = TrackOrderConstants.NewOrderStatus.Denied.name
            isDeliveryStatusGoingGood = false
            isHelpButtonNeeded = false
            headerDateKeyText = "Denied Date: "
            headerItemsStatus = "Denied Items"
            updatedDate = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: orderObject?.cancelled, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
            break
        case TrackOrderConstants.NewOrderStatus.ReadyToShip.status:
            delivery_status = TrackOrderConstants.NewOrderStatus.ReadyToShip.name
            isDeliveryStatusGoingGood = true
            break
        case TrackOrderConstants.NewOrderStatus.Shipping.status:
            delivery_status = TrackOrderConstants.NewOrderStatus.Shipping.name
            isDeliveryStatusGoingGood = true
            isExpiryNeedToShow = true
            break
        case TrackOrderConstants.NewOrderStatus.Delivered.status:
            delivery_status = TrackOrderConstants.NewOrderStatus.Delivered.name
            isDeliveryStatusGoingGood = true
            isExpiryNeedToShow = true
            apiOrderStatusEnum = .delivered
            updatedDate = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: orderObject?.delivered, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
            customerVerifyStatus = "Not Verified"
            break
        case TrackOrderConstants.NewOrderStatus.Verified.status:
            delivery_status = TrackOrderConstants.NewOrderStatus.Delivered.name
            customerVerifyStatus = TrackOrderConstants.NewOrderStatus.Verified.name
            isDeliveryStatusGoingGood = true
            isExpiryNeedToShow = true
            apiOrderStatusEnum = .verified
            headerDateKeyText = "Verified Date: "
            updatedDate = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: orderObject?.verified, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
            break
        default:
            break
        }
        
        deliveryStatus_lbl.text = delivery_status
        verifiedStaus_lbl.text = customerVerifyStatus
        deliveryStatus_lbl.textColor = isDeliveryStatusGoingGood ? UIColor(hexString: defaultTheme.verifyItems_delStatus_green_text) : UIColor(hexString: defaultTheme.verifyItems_delStatus_red_text)
        
        delivered_lbl.text = headerDateKeyText + updatedDate
        header_lbl.text = headerItemsStatus
        
        if isHelpButtonNeeded {
            navigationBarView.rightBarBtn.isHidden = false
            navigationBarView.rightBtnTitle = "Help"
        } else {
            navigationBarView.rightBarBtn.isHidden = true
        }
        
        isSubmitButtonEnabled = false
        
        if apiOrderStatusEnum == .delivered {
            isSubmitButtonEnabled = true
            submit_btn.setTitle("Submit", for: .normal)
            
        } else {
            isSubmitButtonEnabled = true
            submit_btn.setTitle("Reorder", for: .normal)
        }
        
//        else if apiOrderStatusEnum == .verified {
//            isSubmitButtonEnabled = false
//            submitBtnHeight_constraint.constant = 0
//        }
    }
    
    struct GSPurchasedProductStatus {
        let status: PurchasedProductCustomerStatus
        let replacementExistStatus: ProductReplacement
    }

    enum PurchasedProductCustomerStatus {
        case delivered
        case verified
        case other
    }
    enum ProductReplacement {
        case replacementExist
        case noReplacement
    }
    
    fileprivate var isSubmitButtonEnabled:Bool = false {
        
        didSet {
            if submit_btn != nil {
                if isSubmitButtonEnabled == true {
                    submit_btn.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_submitBtn_BG)
                    submit_btn.isUserInteractionEnabled = true
                } else {
                    submit_btn.backgroundColor = UIColor.lightGray
                    submit_btn.isUserInteractionEnabled = false
                }
            }
        }
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

// MARK: - UIImagePicker Controller Delegate

extension GSPurchasedProductsVerifyViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let productItem = products_array[selectedIndex]
        let idOfTheProduct = productItem.id ?? ""
        
        var resultImage:UIImage!
        
//        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            resultImage = selectedImage
//        }  else {
//            // Need to manage this case
//            return
//        }
        
        if let selectedImage = UIImage.from(info: info) {
            resultImage = GSCommonHelper.fixOrientation(img: selectedImage)
        } else {
            picker.dismiss(animated: true) {
                CustomAlert.showAlert(title: "Error", message: GSConstant.AlertMessages.unableToFetchPhoto, viewController: self)
            }
            return
        }
        
        if self.imageSelectionIndex < 0 {      // Accessory Selection
            
            if let imageArray = self.imagesDictionary["\(idOfTheProduct)"] as? [Any], imageArray.count < self.maxImagesCount {
                var tempImageArray = imageArray
                tempImageArray.append(resultImage)
                self.imagesDictionary["\(idOfTheProduct)"] = tempImageArray
                
            } else if self.imagesDictionary["\(idOfTheProduct)"] == nil {
                
                let tempImageArray = [resultImage]
                self.imagesDictionary["\(idOfTheProduct)"] = tempImageArray
            }
            
            
        } else {                                // Replacing Image
            
            if let imageArray = self.imagesDictionary["\(idOfTheProduct)"] as? [Any] {
                
                if self.imageSelectionIndex < imageArray.count {
                    var tempImageArray = imageArray
                    tempImageArray[self.imageSelectionIndex] = resultImage
                    self.imagesDictionary["\(idOfTheProduct)"] = tempImageArray
                } else if imageArray.count < self.maxImagesCount {
                    var tempImageArray = imageArray
                    tempImageArray.append(resultImage)
                    self.imagesDictionary["\(idOfTheProduct)"] = tempImageArray
                }
                
            } else if self.imagesDictionary["\(idOfTheProduct)"] == nil {
                
                let tempImageArray = [resultImage]
                self.imagesDictionary["\(idOfTheProduct)"] = tempImageArray
            }
        }
        
        purchasedVerify_tableView.reloadData()
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - QB ImagePickerController Delegate

extension GSPurchasedProductsVerifyViewController:QBImagePickerControllerDelegate {
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didSelect asset: PHAsset!) {
    }
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        
        //        MBProgressHUD.showAdded(to: imagePickerController.view, animated: true)
        
        var pickerError:NSError?
        
        let productItem = products_array[selectedIndex]
        
        let idOfTheProduct = productItem.id ?? ""
        
        DispatchQueue.global().async {
            let imageReqOptions = PHImageRequestOptions()
            
            imageReqOptions.isSynchronous = true
            imageReqOptions.isNetworkAccessAllowed = true
            
            imageReqOptions.progressHandler = { progress, error, stop, info in
                //                print(progress)
            }
            guard let imageAssets = assets as? [PHAsset] else {return}
            let imageManager = PHImageManager.default()
            
            for singleAsset in imageAssets {
                
                imageManager.requestImage(for: singleAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: imageReqOptions) { (resImage, infoDict) in
                    guard let image = resImage else {
                        
                        guard let infoDictionary = infoDict else {return}
                        guard let userInfo = infoDictionary["PHImageErrorKey"] as? NSError else {return}
                        pickerError = userInfo
                        
                        return
                    }
                    
                    let resultImage = GSCommonHelper.fixOrientation(img: image)
                    
                    if self.imageSelectionIndex < 0 {      // Accessory Selection
                        
                        if let imageArray = self.imagesDictionary["\(idOfTheProduct)"] as? [Any], imageArray.count < self.maxImagesCount {
                            var tempImageArray = imageArray
                            tempImageArray.append(resultImage)
                            self.imagesDictionary["\(idOfTheProduct)"] = tempImageArray
                            
                        } else if self.imagesDictionary["\(idOfTheProduct)"] == nil {
                            
                            let tempImageArray = [resultImage]
                            self.imagesDictionary["\(idOfTheProduct)"] = tempImageArray
                        }
                        
                    } else {                                // Replacing Image
                        
                        if let imageArray = self.imagesDictionary["\(idOfTheProduct)"] as? [Any] {
                            
                            if self.imageSelectionIndex < imageArray.count {
                                var tempImageArray = imageArray
                                tempImageArray[self.imageSelectionIndex] = resultImage
                                self.imagesDictionary["\(idOfTheProduct)"] = tempImageArray
                            } else if imageArray.count < self.maxImagesCount {
                                var tempImageArray = imageArray
                                tempImageArray.append(resultImage)
                                self.imagesDictionary["\(idOfTheProduct)"] = tempImageArray
                            }
                            
                        } else if self.imagesDictionary["\(idOfTheProduct)"] == nil {
                            
                            let tempImageArray = [resultImage]
                            self.imagesDictionary["\(idOfTheProduct)"] = tempImageArray
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                
                imagePickerController.dismiss(animated: true, completion: nil)
                
                if pickerError != nil {
                    
                    if !Reachability.isConnectedToNetwork() {
                        CustomAlert.showAlert(title: "Error", message: GSString.API.NoInternetConnection, viewController: self)
                        return
                    }
                    CustomAlert.showAlert(title: "", message: (pickerError?.localizedDescription)!, viewController: self)
                } else {
                    self.purchasedVerify_tableView.reloadData()
                }
            }  // Main queue ends here...
            
        }  // Global queue ends here...
        
    }
    
}

// MARK: - UITableView Methods

extension GSPurchasedProductsVerifyViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isIndexPathSelected {
            return products_array.count + 1
        }
        return products_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isIndexPathSelected {
            if indexPath.row == indexForComplaintCell {
                
                guard let updatedComplaintCell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.verifyOrderComplaintUpdatedTablCell) as? GSComplaintUpdatedTableCell else {
                    return UITableViewCell()
                }
                updatedComplaintCell.delegate = self
                updatedComplaintCell.configureTheCell(itemsToShow: replacementConfig_array)
                
                let productItem = products_array[selectedIndex]
                var images_array = [UIImage]()
                let idOfProduct = productItem.id ?? ""
                
                if let imageArray = imagesDictionary["\(idOfProduct)"] as? [UIImage] {
                    images_array = imageArray
                }
                
                let reqBodyItem = apiVerifyRequestBody_array[selectedIndex]
                
                updatedComplaintCell.intializeWith(feedback: reqBodyItem.message, selectedOption: reqBodyItem.title, imageArray: images_array)
                updatedComplaintCell.complaints_tableView.reloadData()
                
                updatedComplaintCell.tag = indexPath.row
                return updatedComplaintCell
                
            } else if indexPath.row > indexForComplaintCell {
                let tempIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                return unDeliveredCellAt(tempIndexPath)
            }
        }
        
        return unDeliveredCellAt(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isIndexPathSelected {
            if indexPath.row == indexForComplaintCell {
                return CGFloat((replacementConfig_array.count*40) + 140)
            }
        }
        return UITableViewAutomaticDimension
    }
    
    //MARK: Methods to support tableview
    
    func unDeliveredCellAt(_ indexPath:IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.commonCellForVerifyTrackorderPurchaseHistory
        
        guard let cell = purchasedVerify_tableView.dequeueReusableCell(withIdentifier: identifier) as? GSTrackPurchaseVerifyTableCell else {
            return UITableViewCell()
        }
        
        let productItem = products_array[indexPath.row]
        cell.configureTheCellFor_purchaseHistoryVerify(productItem: productItem)
        
        configureActionsFor_DeliveredCell(cell, indexPath: indexPath)
        let requestModelAtIndex = apiVerifyRequestBody_array[indexPath.row]
        
        cell.writeReviewBg_view.isHidden = true
        cell.helpBtnBG_view.isHidden = true
        cell.help_btn.isHidden = true
        cell.bottomStackBG_view.isHidden = false
        
        cell.quantity_lbl.text = "\(requestModelAtIndex.totalQty)"
        
        cell.qtyDropDown_btn.isHidden = true
        cell.qtyDropDownBG_view.layer.borderColor = UIColor.clear.cgColor
        cell.qtyDropDown_imgView.isHidden = true
        cell.dropDownInfo_lbl.isHidden = true
        
        cell.expiryNotify_switch.isHidden = true
        cell.expiryNotifyInfo_btn.isHidden = true
        cell.expiryNotifyInfoIcon_imgView.isHidden = true
        
        cell.moreExpiryDates_btn.isHidden = true
        cell.expiryDate_lbl.text = "NA"
        
        
        if apiOrderStatusEnum == .delivered {
            
            let replaceMentObject = isReplaceMentExist(lastDateInString: productItem.replacement)
            updatExpiryDateOnUI(cell, productItem: productItem, indexPath: indexPath)
            
            // After verifying the replacement days left conditions, will enable or disable the submit button based on the days left
            if replaceMentObject.isExist != isSubmitButtonEnabled {
                isSubmitButtonEnabled = replaceMentObject.isExist
                
                if replaceMentObject.isExist == false {
                    
                    isSubmitButtonEnabled = true
                    submit_btn.setTitle("Reorder", for: .normal)
                }
            }
            
            if replaceMentObject.isExist {
                
                cell.expiryNotify_switch.isHidden = false
                cell.expiryNotifyInfo_btn.isHidden = false
                cell.expiryNotifyInfoIcon_imgView.isHidden = false
                
                for cell_btns in [cell.deliverd_btn, cell.undelivered_btn, cell.replacement_btn] {
                    cell_btns?.isUserInteractionEnabled = true
                    cell_btns?.setTitleColor(UIColor.black, for: .normal)
                    cell_btns?.tintColor = UIColor.black
                }
                
                updateRadioButtonSelectionFor(indexPath: indexPath, cell: cell)
                
                if requestModelAtIndex.verify_status == TrackOrderConstants.VerifyStatus.undelivered || requestModelAtIndex.verify_status == TrackOrderConstants.VerifyStatus.replacement {
                    cell.expiryNotify_switch.isOn = false
                    cell.expiryNotify_switch.isUserInteractionEnabled = false
                } else {
                    cell.expiryNotify_switch.isOn = requestModelAtIndex.enable_expiry_date
                    cell.expiryNotify_switch.isUserInteractionEnabled = true
                }
                
            } else {
                cell.bottomStackBG_view.isHidden = true
            }
            
        } else if apiOrderStatusEnum == .verified {
            
            let replaceMentObject = isReplaceMentExist(lastDateInString: productItem.replacement)
            
            cell.deliverd_btn.isHidden = true
            cell.undelivered_btn.isHidden = true
            cell.expiryNotify_switch.isHidden = true
            cell.expiryNotifyInfo_btn.isHidden = true
            cell.expiryNotifyInfoIcon_imgView.isHidden = true
            cell.bottomStackBG_view.isHidden = false
            cell.writeReviewBg_view.isHidden = true
            cell.helpBtnBG_view.isHidden = false
            
            if replaceMentObject.isExist {
                cell.writeReviewBg_view.isHidden = false
                updateRadioButtonSelectionFor(indexPath: indexPath, cell: cell)
                
            } else {
                cell.bottomStackBG_view.isHidden = true
            }
            updateReplacementUndeliveredDetailsOnUI(cell, requestModel: requestModelAtIndex, indexPath: indexPath)
            
        } else {
            
            for cell_btns in [cell.deliverd_btn, cell.undelivered_btn, cell.replacement_btn] {
                cell_btns?.isUserInteractionEnabled = false
                cell_btns?.setTitleColor(UIColor.lightGray, for: .normal)
                cell_btns?.tintColor = UIColor.lightGray
            }
            cell.expiryNotify_switch.isOn = false
            cell.expiryNotify_switch.isUserInteractionEnabled = false
            
            if apiOrderStatusEnum == .other {
                cell.expiryNotify_switch.isHidden = false
                cell.expiryNotifyInfo_btn.isHidden = false
                cell.expiryNotifyInfoIcon_imgView.isHidden = false
            }
            
            cell.qtyDropDown_btn.isHidden = true
            cell.qtyDropDownBG_view.layer.borderColor = UIColor.clear.cgColor
            cell.qtyDropDown_imgView.isHidden = true
            cell.dropDownInfo_lbl.isHidden = true
            
            cell.quantity_lbl.text = "\(requestModelAtIndex.totalQty)"
            let totalPrice = (Double(requestModelAtIndex.totalQty) * requestModelAtIndex.price)
            cell.daysLeftOrProductCost_lbl.text = GSCommonHelper.formattedPrice(price: totalPrice)
            cell.expiryDate_lbl.text = "NA"
        }
        
        cell.productViewOnName_btn.tag = indexPath.row
        cell.productViewOnImage_btn.tag = indexPath.row
        
        cell.productViewOnImage_btn.addTarget(self, action: #selector(cell_productInfoAction(_:)), for: .touchUpInside)
        cell.productViewOnName_btn.addTarget(self, action: #selector(cell_productInfoAction(_:)), for: .touchUpInside)
        
        cell.layoutIfNeeded()
        return cell
    }
    
    
    private func priceOfProductWithOffer(originalPrice: Double) -> Double {
        
        var percentage: Double = 0
        
        if let offerObject = orderObject?.offer, let offerType = offerObject.offerType, offerType == GSConstant.offer_discount_type {
            let actualOriginalPrice = (orderObject?.prices?.netPrice ?? 0) + (orderObject?.prices?.delivery ?? 0)
            
            let offerAmount = offerObject.offerAmount ?? 0
            percentage = ((offerAmount / actualOriginalPrice) * 100)
        }
        
        let offerOnThisProduct = (originalPrice * percentage)/100
        return originalPrice - offerOnThisProduct
    }
    
    private func updateReplacementUndeliveredDetailsOnUI(_ cell:GSTrackPurchaseVerifyTableCell, requestModel: PurchasedItemsVerifyModel, indexPath:IndexPath) {
        
        let requestModelAtIndex = apiVerifyRequestBody_array[indexPath.row]
        
        cell.expiryDateKey_lbl.isHidden = true
        cell.moreExpiryDates_btn.isHidden = true
        cell.expiryNotify_switch.isHidden = true
        cell.expiryNotifyInfo_btn.isHidden = true
        cell.expiryNotifyInfoIcon_imgView.isHidden = true
        cell.expiryDateKeyBg_view.isHidden = false
        
        cell.quantity_lbl.text = "\(requestModel.totalQty - requestModel.selectedQty)"
        
        if requestModelAtIndex.apiVerify_status == TrackOrderConstants.VerifyStatus.replacement {
//            cell.expiryDate_lbl.text = checkForEscalationStatus(escalatedQty: requestModel.selectedQty, verifyStatus: requestModel.apiVerify_status, indexPath: indexPath)
            cell.expiryDate_lbl.text = GSCommonHelper.checkForEscalationStatus(escalatedQty: requestModel.selectedQty, escalationStatus: products_array[indexPath.row].escalationStatus ?? 1, verifyStatus: requestModel.apiVerify_status)
            cell.expiryDateKeyBg_view.isHidden = true
            cell.writeReviewBg_view.isHidden = true
            cell.bottomStackBG_view.isHidden = true
            
        } else if requestModelAtIndex.apiVerify_status == TrackOrderConstants.VerifyStatus.undelivered {
            cell.expiryDate_lbl.text = GSCommonHelper.checkForEscalationStatus(escalatedQty: requestModel.selectedQty, escalationStatus: products_array[indexPath.row].escalationStatus ?? 1, verifyStatus: requestModel.apiVerify_status)
            cell.expiryDateKeyBg_view.isHidden = true
            cell.writeReviewBg_view.isHidden = true
            cell.bottomStackBG_view.isHidden = true
            
        } else {
            cell.expiryDateKey_lbl.isHidden = false
            cell.expiryDate_lbl.text = "NA"
            
            cell.quantity_lbl.text = "\(requestModel.selectedQty)"
            
            updatExpiryDateOnUI(cell, productItem: products_array[indexPath.row], indexPath: indexPath)
        }
        
        updatePricesFor(verifyStatus: requestModelAtIndex.apiVerify_status, requestItemModel: requestModelAtIndex, productItem: products_array[indexPath.row], cell: cell)
        
        //        calculateTotalAmountToShow()
    }
    
    private func updatExpiryDateOnUI(_ cell:GSTrackPurchaseVerifyTableCell, productItem: GSTrackOrderProductListProduct, indexPath:IndexPath) {
        
        var expiryDate_str = "NA"
        cell.moreExpiryDates_btn.isHidden = true
        let expiry_status = productItem.mfdExp?.type ?? 0
        
        switch expiry_status {
        case TrackOrderConstants.ExpiryDateStatus.Available:
            
            if let dates_array = productItem.mfdExp?.dates, dates_array.count > 0 {
                
                if let nonNullExpiryDate = getDateInTheSimpleFormat(dateStr: dates_array[0].expDate) {
                    expiryDate_str = nonNullExpiryDate
                }
                if dates_array.count > 1 {
                    cell.moreExpiryDates_btn.isHidden = false
                    cell.moreExpiryDates_btn.tag = indexPath.row
                    cell.moreExpiryDates_btn.addTarget(self, action: #selector(showMoreExpiryDates(_:)), for: .touchUpInside)
                }
            }
            break
        case TrackOrderConstants.ExpiryDateStatus.Unavailable:
            expiryDate_str = "Not Applicable"
            break
        case TrackOrderConstants.ExpiryDateStatus.Unknown:
            expiryDate_str = "Unknown"
            break
        default:
            expiryDate_str = "NA"
        }
        cell.expiryDate_lbl.text = expiryDate_str
    }
    
    private func isReplaceMentExist(lastDateInString:String?)->GSPurchasedProductsVerifyViewController.ReplacementDaysLeftObject {
        
        if let replaceMentExist = isReplacementDaysLeft {
            return replaceMentExist
        }
        guard let unwrappedDatStr = lastDateInString else { return ReplacementDaysLeftObject(isExist: false, toShow: "") }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = GSConstant.apiDateFormatter
        guard let lastDateForReplacement = dateFormatter.date(from: unwrappedDatStr) else { return ReplacementDaysLeftObject(isExist: false, toShow: "") }
        let currentDate = Date()
        
        let calenderComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate, to: lastDateForReplacement)
        
        let yearDiff = calenderComponents.year ?? 0
        let monthDiff = calenderComponents.month ?? 0
        let dayDiff = calenderComponents.day ?? 0
        let hourDiff = calenderComponents.hour ?? 0
        let minuteDiff = calenderComponents.minute ?? 0
        
        var isExist = false
        var toShow = ""
        if yearDiff > 0 {
            isExist = true
            toShow = "\(yearDiff) year(s) left"
        } else if monthDiff > 0 {
            isExist = true
            toShow = "\(monthDiff) month(s) left"
        } else if dayDiff > 0 {
            isExist = true
            toShow = "\(dayDiff) day(s) left"
        } else if hourDiff > 0 {
            isExist = true
            toShow = "\(hourDiff) hour(s) left"
        } else if minuteDiff > 0 {
            isExist = true
            toShow = "\(minuteDiff) min(s) left"
        }
        
        if !isExist, navigationBarView.rightBarBtn.isHidden == false {
            navigationBarView.rightBtnTitle = ""
            navigationBarView.rightBarBtn.isHidden = true
        }
        
        return ReplacementDaysLeftObject(isExist: isExist, toShow: toShow)
    }
    
    private func updateRadioButtonSelectionFor(indexPath: IndexPath, cell:GSTrackPurchaseVerifyTableCell) {
        
        let requestItemModel = apiVerifyRequestBody_array[indexPath.row]
        let productItem = products_array[indexPath.row]
        
        let selectedIndex = requestItemModel.verify_status
        
        cell.deliverd_btn.setImage(#imageLiteral(resourceName: "Radio_off"), for: .normal)
        cell.undelivered_btn.setImage(#imageLiteral(resourceName: "Radio_off"), for: .normal)
        cell.replacement_btn.setImage(#imageLiteral(resourceName: "Radio_off"), for: .normal)
        
        cell.qtyDropDown_btn.isHidden = true
        cell.qtyDropDownBG_view.layer.borderColor = UIColor.clear.cgColor
        cell.qtyDropDown_imgView.isHidden = true
        cell.dropDownInfo_lbl.isHidden = true
        
        cell.moreExpiryDates_btn.isHidden = true
        
        var isQtyDropDownRequired = false
        var dropDownInfo = ""
        
        switch selectedIndex {
        case TrackOrderConstants.VerifyStatus.delivered:     // Delivered
            cell.deliverd_btn.setImage(#imageLiteral(resourceName: "Radio_on"), for: .normal)
            
            break
        case TrackOrderConstants.VerifyStatus.undelivered:     // Undelivered
            cell.undelivered_btn.setImage(#imageLiteral(resourceName: "Radio_on"), for: .normal)
            isQtyDropDownRequired = true
            dropDownInfo = "Select the quantity that has not been delivered"
            break
        case TrackOrderConstants.VerifyStatus.replacement:     // Replacement
            cell.replacement_btn.setImage(#imageLiteral(resourceName: "Radio_on"), for: .normal)
            isQtyDropDownRequired = true
            dropDownInfo = "Select the quantity for which you want replacement"
            break
        default:
            break
        }
        
        updatePricesFor(verifyStatus: selectedIndex, requestItemModel: requestItemModel, productItem: productItem, cell: cell)
        
        if isQtyDropDownRequired {
            cell.qtyDropDown_btn.isHidden = false
            cell.qtyDropDownBG_view.layer.borderColor = UIColor.lightGray.cgColor
            cell.qtyDropDown_imgView.isHidden = false
            cell.dropDownInfo_lbl.isHidden = false
            cell.dropDownInfo_lbl.text = dropDownInfo
        }
        
        let expiryDates_status = productItem.mfdExp?.type ?? 0
        
        cell.expiryNotify_switch.isOn = false
        cell.expiryNotify_switch.isUserInteractionEnabled = false
        
        cell.expiryDate_lbl.text = "NA"
        
        switch expiryDates_status {
        case TrackOrderConstants.ExpiryDateStatus.Available:
            if isExpiryNeedToShow, let dates_array = productItem.mfdExp?.dates, dates_array.count > 0 {
                
                if (selectedIndex != TrackOrderConstants.VerifyStatus.undelivered && selectedIndex != TrackOrderConstants.VerifyStatus.replacement) {
                    cell.expiryNotify_switch.isOn = requestItemModel.enable_expiry_date
                    cell.expiryNotify_switch.isUserInteractionEnabled = true
                    updatExpiryDateOnUI(cell, productItem: productItem, indexPath: indexPath)
                }
            }
            break
        case TrackOrderConstants.ExpiryDateStatus.Unavailable:
            cell.expiryDate_lbl.text = "Not Applicable"
            break
        case TrackOrderConstants.ExpiryDateStatus.Unknown:
            cell.expiryDate_lbl.text = "Unknown"
            break
        default:
            cell.expiryDate_lbl.text = "NA"
            break
        }
    }
    
    
    private func updatePricesFor(verifyStatus:Int, requestItemModel:PurchasedItemsVerifyModel, productItem: GSTrackOrderProductListProduct, cell:GSTrackPurchaseVerifyTableCell) {
        
        var isDelivered = true
        let totalQtyOrdered = productItem.qty ?? 0
        var priceToShow = productItem.netPrice ?? 0
        var qtyToShow = productItem.qty ?? 0
        
        var theVerifyStatus = verifyStatus
        
        if requestItemModel.verify_status != 0 {        // In a case of selection replacement locally
            theVerifyStatus = requestItemModel.verify_status
        }
        
        switch theVerifyStatus {
        case TrackOrderConstants.VerifyStatus.delivered:     // Delivered
            isDelivered = true
            break
        case TrackOrderConstants.VerifyStatus.undelivered, TrackOrderConstants.VerifyStatus.replacement:     // Undelivered  // Replacement
            isDelivered = false
            qtyToShow = requestItemModel.selectedQty
            break
        default:
            break
        }
        
        if !isDelivered {           // Undelivered or Replacement
            priceToShow = -(Double(qtyToShow) * (productItem.netPrice ?? 0))
            cell.daysLeftOrProductCost_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_delStatus_red_text)
        } else {
            cell.daysLeftOrProductCost_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderListVC_cell_cost_lbl_text)
            priceToShow = (Double(totalQtyOrdered) * (productItem.netPrice ?? 0))
        }
        
        cell.quantity_lbl.text = "\(qtyToShow)"
        cell.daysLeftOrProductCost_lbl.text = GSCommonHelper.formattedPrice(price: priceToShow)
        
        let totalPrice = getTotalPriceForTheProducts()
        orderCost_lbl.text = GSCommonHelper.formattedPrice(price: totalPrice)
    }
    
    func getDateInTheSimpleFormat(dateStr:String?) -> String? {
        
        guard let unwrappedString = dateStr else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = dateFormatter.date(from: unwrappedString) else { return nil }
        
        let anotherDateFormatter = DateFormatter()
        anotherDateFormatter.dateFormat = "dd-MM-yyyy"
        
        return anotherDateFormatter.string(from: date)
    }
    
    fileprivate func getTotalPriceForTheProducts() -> Double {
        
        var total_price:Double = 0
        
        let actualOriginalPrice = (orderObject?.prices?.netPrice ?? 0)
        
        var percentage: Double = 0
        
        if let offerObject = orderObject?.offer, let offerType = offerObject.offerType, offerType == GSConstant.offer_discount_type {
            
            let offerAmount = offerObject.offerAmount ?? 0
            percentage = ((offerAmount / actualOriginalPrice) * 100)
        }
        
        for requestItemModel in apiVerifyRequestBody_array {
            
            let localVar_sel_qty = requestItemModel.selectedQty
            let localVar_total_qty = requestItemModel.totalQty
            var local_qty = localVar_total_qty
            
            var verifyStatus = requestItemModel.verify_status
            
            if apiOrderStatusEnum == .verified {
                verifyStatus = requestItemModel.apiVerify_status
                if requestItemModel.verify_status != 0 {
                    verifyStatus = requestItemModel.verify_status
                }
            }
            
            switch verifyStatus {
            case TrackOrderConstants.VerifyStatus.delivered:
                local_qty = localVar_total_qty
                break
            case TrackOrderConstants.VerifyStatus.undelivered:
                local_qty = localVar_total_qty - localVar_sel_qty
                break
            case TrackOrderConstants.VerifyStatus.replacement:
                local_qty = localVar_total_qty - localVar_sel_qty
                break
            default:
                break
            }
            
            let offerOnThisProduct = (requestItemModel.price * percentage)/100
            let productPriceWithOffer = requestItemModel.price - offerOnThisProduct
            
            total_price += (Double(local_qty) * productPriceWithOffer)
        }
        
        let totalPriceToReturn = total_price + Double(orderObject?.prices?.delivery ?? 0)

//        if let offerObject = orderObject?.offer, let offerType = offerObject.offerType, offerType == GSConstant.offer_discount_type {
//            // Offer type = 1 is for cash back,  2 is for discount
//            let offerAmount = offerObject.offerAmount ?? 0
//
//            totalPriceToReturn -= offerAmount
//
//            if totalPriceToReturn < 0 {
//                totalPriceToReturn = 0
//            }
//        }
        
        return totalPriceToReturn
    }
    
    @objc private func showMoreExpiryDates(_ sender:UIButton) {
        
        if sender.tag >= products_array.count { return }
        
        let productItem = products_array[sender.tag]
        
        if let dates_array = productItem.mfdExp?.dates {
            
            var dates_string = ""
            
            for date_item in dates_array {
                let expectedDate = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: date_item.expDate, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
                dates_string += "\(expectedDate)\n"
            }
            dates_string = dates_string.removeEnclosedWhieteSpace()
            CustomAlert.showAlert(title: "Expiry dates", message: dates_string, viewController: self)
        }
    }
    
    
    //MARK:- GSDeliveredTableCell Methods
    
    func configureActionsFor_DeliveredCell(_ cell:GSTrackPurchaseVerifyTableCell, indexPath:IndexPath) {
        
        cell.replacement_btn.addTarget(self, action: #selector(cell_Replace_Action(_:)), for: .touchUpInside)
        cell.replacement_btn.tag = indexPath.row
        cell.help_btn.addTarget(self, action: #selector(cell_Help_Action(_:)), for: .touchUpInside)
        cell.help_btn.tag = indexPath.row
        cell.deliverd_btn.addTarget(self, action: #selector(cell_Delivered_Action(_:)), for: .touchUpInside)
        cell.deliverd_btn.tag = indexPath.row
        cell.undelivered_btn.addTarget(self, action: #selector(cell_UnDelivered_Action(_:)), for: .touchUpInside)
        cell.undelivered_btn.tag = indexPath.row
        cell.expiryNotify_switch.tag = indexPath.row
        cell.expiryNotify_switch.addTarget(self, action: #selector(cell_expirySwitchAction(_:)), for: .valueChanged)
        cell.expiryNotifyInfo_btn.addTarget(self, action: #selector(cell_expiryInfoAction(_:)), for: .touchUpInside)
        
        cell.qtyDropDown_btn.tag = indexPath.row
        cell.qtyDropDown_btn.addTarget(self, action: #selector(cell_qtyDropDownAction(_:)), for: .touchUpInside)
        
        if let reviewBtn = cell.writeReview_btn {
            reviewBtn.addTarget(self, action: #selector(cell_writeReview_Action(_:)), for: .touchUpInside)
            reviewBtn.tag = indexPath.row
        }
    }
    
    @objc func cell_Delivered_Action(_ sender:UIButton) {
        isIndexPathSelected = false
        indexForComplaintCell = -1
        selectedIndex = sender.tag
        apiVerifyRequestBody_array[sender.tag].verify_status = TrackOrderConstants.VerifyStatus.delivered
        purchasedVerify_tableView.reloadData()
        
        newVerifyOrderStatusAPI(for: sender.tag)
    }
    
    @objc func cell_UnDelivered_Action(_ sender:UIButton) {
        isIndexPathSelected = false
        indexForComplaintCell = -1
        selectedIndex = sender.tag
        apiVerifyRequestBody_array[sender.tag].verify_status = TrackOrderConstants.VerifyStatus.undelivered
        apiVerifyRequestBody_array[sender.tag].selectedQty = (apiVerifyRequestBody_array[sender.tag].selectedQty == 0) ? apiVerifyRequestBody_array[sender.tag].totalQty : apiVerifyRequestBody_array[sender.tag].selectedQty
        purchasedVerify_tableView.reloadData()
        
        newVerifyOrderStatusAPI(for: sender.tag)
    }
    
    @objc func cell_Replace_Action(_ sender:UIButton) {
        
        if isIndexPathSelected, sender.tag + 1 == indexForComplaintCell {       // Already Opened... Need to close
            isIndexPathSelected = false
            indexForComplaintCell = -1
            purchasedVerify_tableView.reloadData()
            return
        }
        
        isIndexPathSelected = true
        indexForComplaintCell = sender.tag + 1
        selectedIndex = sender.tag
        apiVerifyRequestBody_array[sender.tag].verify_status = TrackOrderConstants.VerifyStatus.replacement
        if apiVerifyRequestBody_array[sender.tag].title == TrackOrderConstants.VerifyStatusTitles.undelivered || apiVerifyRequestBody_array[sender.tag].title == TrackOrderConstants.VerifyStatusTitles.delivered {
            apiVerifyRequestBody_array[sender.tag].title = ""
        }
        
        //        // Is To enable submit button in verifed status whenever the replacement button clicked
        //        if isSubmitButtonEnabled == false {
        //            isSubmitButtonEnabled = true
        //        }
        apiVerifyRequestBody_array[sender.tag].selectedQty = (apiVerifyRequestBody_array[sender.tag].selectedQty == 0) ? apiVerifyRequestBody_array[sender.tag].totalQty : apiVerifyRequestBody_array[sender.tag].selectedQty
        purchasedVerify_tableView.reloadData()
    }
    
    @objc func cell_Help_Action(_ sender:UIButton) {
        indexForComplaintCell = sender.tag + 1
        selectedIndex = sender.tag
        
        if let helpScreen = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSHelpViewController) as? GSHelpViewController {
            
            helpScreen.configureHelpWith(order_root_id: orderObject?.id ?? "", is_combined_help: false, isDeliveredOrVerified: true)
            navigationController?.pushViewController(helpScreen, animated: true)
        }
    }
    
    @objc func cell_writeReview_Action(_ sender:UIButton) {
        
        if sender.tag >= products_array.count { return }
        
        let productItem = products_array[sender.tag]
        
        if let feedBackVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSStoreFeedbackViewController) as? GSStoreFeedbackViewController {
            
            feedBackVC.configureForProductFeedBack(categoryId: category_id, orderId: order_id, productId: productItem.id ?? "", isFromTrackOrder: false)
            navigationController?.pushViewController(feedBackVC, animated: true)
        }
    }
    
    @objc func cell_expirySwitchAction(_ sender:UISwitch) {
        sender.isOn = !sender.isOn
        apiVerifyRequestBody_array[sender.tag].enable_expiry_date = sender.isOn
    }
    
    @objc func cell_expiryInfoAction(_ sender:UIButton) {
        addTooltip(sender, message: GSConstant.ToolTip.toolTip_expiryButton_info, title: "", arrowPosition: .right)
    }
    
    @objc func cell_productInfoAction(_ sender: UIButton) {
        
        let productItem = products_array[sender.tag]
        
        let storeObjectHelper = StoreSelectionHelper()
        
        storeObjectHelper.fetchShopDetailsAPI(categoryId: self.category_id, storeId: self.store_id) { (shopObject, error) in
            
            if let unwrappedShopObject = shopObject {
                
                if let productDetailVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSProductDetailsViewController) as? GSProductDetailsViewController {
                    productDetailVC.catId = self.category_id
                    productDetailVC.storesArray = [self.store_id]
                    //                    productDetailVC.selectedProductItem = productListArray[indexPath.row]
                    productDetailVC.productId = productItem.id ?? ""
                    productDetailVC.isFromOrdersToSeeInfo = true
                    productDetailVC.templateArray = unwrappedShopObject.templateKeys ?? [GSProductDetailsKeyTemplate]()
                    //                    productDetailVC.productListArray = productListArray
                    //                    productDetailVC.selectedProductIndex = indexPath.row
                    GSCustomPushPop.doCustomPush(from: self, to: productDetailVC)
                }
                
            } else {
                
                CustomAlert.showAlert(title: GSString.AppName, message: error ?? "", viewController: self)
            }
        }
    }
    
    @objc func cell_qtyDropDownAction(_ sender:UIButton) {
        let productItem = products_array[sender.tag]
        let qtyOrdered = productItem.qty ?? 0
        
        var selectedQtyStr:String? = nil
        let selectedQty = apiVerifyRequestBody_array[sender.tag].selectedQty
        selectedQtyStr = "\(selectedQty)"
        
        if qtyOrdered != 0 {
            
            var picker_array = [String]()
            
            for qty in 1...qtyOrdered {
                picker_array.append("\(qty)")
            }
            
            addPicker(picker_array, selectedValue: selectedQtyStr, completion: { selValue, isCancel in
                
                if !isCancel {
                    self.apiVerifyRequestBody_array[sender.tag].selectedQty = Int(selValue) ?? 1
                    
                    if self.apiVerifyRequestBody_array[sender.tag].verify_status == TrackOrderConstants.VerifyStatus.replacement {
                        let validation = self.validateReplacementRequest(for: sender.tag)
                        if validation.0 == false {
                            self.purchasedVerify_tableView.reloadData()
                            return
                        }
                    }
                    self.newVerifyOrderStatusAPI(for: sender.tag)
                    self.purchasedVerify_tableView.reloadData()
                }
            })
        }
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
        
        picker.showTheView(on: self.view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.frame.size.width, height: self.view.frame.size.height - self.view.safeAreaInsets.top))
        
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
    
}

// MARK: - Complaint Cell Delegate Methods

extension GSPurchasedProductsVerifyViewController:GSComplaintCellDelegate {
    
    func attachmentSelected(actionCell:GSComplaintsNestedComplaintActionTableCell) {
        
        imageSelectionIndex = -1
        methodForImageSelection(source_view: actionCell.attachment_btn)
    }
    
    private func methodForImageSelection(source_view:UIView) {
        
        let itemAtIndex = apiVerifyRequestBody_array[selectedIndex]
        let idOfTheProduct = itemAtIndex.product_id
        
        var remainingToChoose = 0
        
        if imageSelectionIndex < 0 {            // Accessory Selection
            
            var imagesCount = 0
            
            if let imageArray = imagesDictionary["\(idOfTheProduct)"] as? [Any] {
                imagesCount = imageArray.count
            }
            
            if imagesCount >= maxImagesCount {
                CustomAlert.showAlert(title: "Info", message: GSConstant.AlertMessages.verifyItems_maximumAttachmentSelected, viewController: self)
                return
            }
            
            remainingToChoose = maxImagesCount - imagesCount
            
            
        } else {                                // Image selection ... Replace or add
            remainingToChoose = 1
        }
        
        CustomAlert.showActionSheet(title: "Choose", message: nil, cancelTitle: "Cancel", optionArray: ["Camera", "Photos"], sourceView: source_view, in: self) { btn_index in
            
            if btn_index == 0 {
                // Camera
                self.openCamera()
                
            } else {
                self.openPhotosAlbum(maxSelection: remainingToChoose)
            }
        }
        
    }
    
    private func openPhotosAlbum(maxSelection:Int) {
        
        if GSCommonHelper.checkForUsagePermission(resourceType: .photoLibrary, viewController: self) == false { return }
        
        let imagePicker = QBImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsMultipleSelection = true
        imagePicker.maximumNumberOfSelection = UInt(maxSelection)
        imagePicker.showsNumberOfSelectedAssets = true
        imagePicker.mediaType = .image
        self.present(imagePicker, animated: true, completion: nil)
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
    
    func replacementTitleSelected(selection: String) {
        apiVerifyRequestBody_array[selectedIndex].title = selection
    }
    
    func replacementMessage(message: String, needToCloseComplaintCell: Bool) {
        
        apiVerifyRequestBody_array[selectedIndex].message = message
        if !needToCloseComplaintCell { return }      // No need to close complaint cell while editing... this is to update the data while editing
        
        let validation = validateReplacementRequest(for: selectedIndex)
        if validation.0 == false {
            CustomAlert.showAlert(title: GSString.AppName, message: validation.1, viewController: self)
            return
        }
        
        isIndexPathSelected = false
        indexForComplaintCell = -1
        purchasedVerify_tableView.reloadData()
        
        newVerifyOrderStatusAPI(for: selectedIndex)
    }
    
    fileprivate func validateReplacementRequest(for index:Int) -> (Bool, String) {
        
        let apiVerifyRequest = apiVerifyRequestBody_array[index]
        
        var verifyStatus =  apiVerifyRequest.verify_status
        
        if verifyStatus == 0 {          // Checking the current selection... if 0 means, nothing has selected so will unwrap the value from api verify status
            verifyStatus = apiVerifyRequest.apiVerify_status
        }
        
        if verifyStatus == TrackOrderConstants.VerifyStatus.replacement, apiVerifyRequest.title == "" {
            return (false,"Select the reason for replacement")
        }
        if apiVerifyRequest.message.count < GSConstant.verifyItemsFeedback_minCharacter {
            return (false,"Minimum 40 characters are required")
        }
        
        if let images_array = imagesDictionary["\(apiVerifyRequestBody_array[index].product_id)"] as? [Any], images_array.count > 0 {
            
        } else {
            return (false, "Atleast one image is required")
        }
        return (true,"")
    }
    
    func imageButtonSelected(_ sender: UIButton, selectedImageView: UIImageView) {
        imageSelectionIndex = sender.tag
        
        let itemAtIndex = apiVerifyRequestBody_array[selectedIndex]
        let idOfTheProduct = itemAtIndex.product_id
        
        CustomAlert.showActionSheet(title: nil, message: nil, cancelTitle: "Cancel", optionArray: ["Add/Replace", "Delete"], sourceView: sender, in: self) { btnIndex in
            
            if btnIndex == 0 {          // Replace
                
                self.methodForImageSelection(source_view: sender)
                
            } else {                    // Delete
                
                let keyString = "\(idOfTheProduct)"
                
                if var imageArray = self.imagesDictionary[keyString] as? [Any], self.imageSelectionIndex < imageArray.count {
                    imageArray.remove(at: self.imageSelectionIndex)
                    self.imagesDictionary[keyString] = imageArray
                    self.purchasedVerify_tableView.reloadData()
                }
                
            }
        }
    }
}

// MARK: - API Methods

extension GSPurchasedProductsVerifyViewController {
    
    func productListAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.viewPurchaseHistoryProducts
        
        let parameters = [ "category_id": self.category_id,
                           "shop_id": self.store_id,
                           "order_id": self.order_id ] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if weakSelf.products_array.count > 0 || weakSelf.apiVerifyRequestBody_array.count > 0 {
                
                if weakSelf.products_array.count > 0 {
                    weakSelf.products_array.removeAll()
                }
                
                if weakSelf.apiVerifyRequestBody_array.count > 0 {
                    weakSelf.apiVerifyRequestBody_array.removeAll()
                }
                
                DispatchQueue.main.async {
                    weakSelf.purchasedVerify_tableView.reloadData()
                }
            }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSPurchaseHistoryProductListModel.self, from: responseData)
                    
                    weakSelf.orderObject = responseModel.data?.order
                    weakSelf.productsData = responseModel.data
                    
                    let navigationTitle = responseModel.data?.shop?.name ?? ""
                    weakSelf.navigationBarView.titleLable.text = navigationTitle
                    
                    let netPrice = responseModel.data?.order?.prices?.netPrice ?? 0
                    let deliveryCharge = responseModel.data?.order?.prices?.delivery ?? 0
                    
                    weakSelf.orderCost_lbl.text = GSCommonHelper.formattedPrice(price: netPrice + deliveryCharge)
                    
                    if let offerObject = responseModel.data?.order?.offer, let offerType = offerObject.offerType, offerType == GSConstant.offer_discount_type {
                        // Offer type = 1 is for cash back,  2 is for discount
                        
                        weakSelf.orderCost_lbl.text = GSCommonHelper.formattedPrice(price: netPrice + deliveryCharge - (offerObject.offerAmount ?? 0))
                    }
                    
                    if let orderProductsArray = responseModel.data?.products {
                        weakSelf.products_array = orderProductsArray
                        
                        for productItem in orderProductsArray {
                            
                            var verifyStatus = productItem.verifyStatus ?? 0
                            
                            if (weakSelf.orderObject?.status ?? 0) == TrackOrderConstants.NewOrderStatus.Verified.status {
                                verifyStatus = 0
                            }
                            
                            let request = PurchasedItemsVerifyModel(productName: productItem.productName ?? "", product_id: productItem.id ?? "",verify_status: verifyStatus, apiVerify_status: productItem.verifyStatus ?? 0, previousSelectedVerify_status: 0, enable_expiry_date: productItem.notifications ?? false, title: "", message: "", selectedQty: productItem.escalatedQty ?? 0, totalQty: productItem.qty ?? 0, price: productItem.netPrice ?? 0)
                            weakSelf.apiVerifyRequestBody_array.append(request)
                        }
                        
                        DispatchQueue.main.async {
                            weakSelf.purchasedVerify_tableView.reloadData()
                        }
                    }
                    weakSelf.changesBasedOnOrderStatus()
                    
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
    
    fileprivate func newVerifyOrderStatusAPI(for index:Int) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.verifyPurchaseHistoryProducts
        
        if index >= apiVerifyRequestBody_array.count { return }
        
        var imagesKeyArray = [String]()
        var imagesValueArray = [Data]()
        
        let requestBodyAtIndex = apiVerifyRequestBody_array[index]
        let verifyStatus = requestBodyAtIndex.verify_status
        let productId = requestBodyAtIndex.product_id
        
        
        var parameters = ["category_id": self.category_id.data(using: .utf8) ?? Data(),
                          "shop_id": self.store_id.data(using: .utf8) ?? Data(),
                          "order_id":self.order_id.data(using: .utf8) ?? Data(),
                          "product_id":productId.data(using: .utf8) ?? Data(),
                          "verify_status":"\(verifyStatus)".data(using: .utf8) ?? Data()]
        
        switch verifyStatus {
        case TrackOrderConstants.VerifyStatus.delivered:
            parameters["notifications"] = requestBodyAtIndex.enable_expiry_date.description.data(using: .utf8) ?? Data()
            break
        case TrackOrderConstants.VerifyStatus.undelivered:
            let selectedQty = requestBodyAtIndex.selectedQty
            parameters["qty"] = "\(selectedQty)".data(using: .utf8) ?? Data()
            break
        case TrackOrderConstants.VerifyStatus.replacement:
            parameters["title"] = requestBodyAtIndex.title.data(using: .utf8) ?? Data()
            parameters["message"] = requestBodyAtIndex.message.data(using: .utf8) ?? Data()
            let selectedQty = requestBodyAtIndex.selectedQty
            parameters["qty"] = "\(selectedQty)".data(using: .utf8) ?? Data()
            
            // Will Add Image files here
            
            if let imagesArray = imagesDictionary["\(productId)"] as? [Any] {
                
                for index in 0..<imagesArray.count {
                    if let image = imagesArray[index] as? UIImage {
                        imagesKeyArray.append("image\(index+1)")
                        imagesValueArray.append(UIImageJPEGRepresentation(image, 0.5)!)
                    }
                }
            }
            
            break
        default:
            break
        }
        
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        let headers = ["Authorization": accessToken,
                       "Content-Type":"multipart/form-data"]
        
        APIHandler.multiPartNetworkRequestWith(method: .post, multiPartItems: imagesValueArray, keyNames: imagesKeyArray, fileName: "test.doc", params: parameters, urlString: urlString, headers: headers, needToResignKeyboard: true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            weakSelf.apiVerifyRequestBody_array[index].verify_status = weakSelf.apiVerifyRequestBody_array[index].previousSelectedVerify_status
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    #if DEBUG
                    print(responseModel.success ?? false)
                    #endif
                    
                    weakSelf.apiVerifyRequestBody_array[index].previousSelectedVerify_status = verifyStatus
                    weakSelf.apiVerifyRequestBody_array[index].verify_status = verifyStatus
                    
                    if weakSelf.apiOrderStatusEnum == .verified {
                        weakSelf.verifyTotalOrderAPI()
                    } else {
                        weakSelf.apiVerifyRequestBody_array[index].apiVerify_status = verifyStatus
                        weakSelf.purchasedVerify_tableView.reloadData()
                    }
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? GSString.API.unknownError, viewController: weakSelf)
            }
            
            DispatchQueue.main.async {
                self?.purchasedVerify_tableView.reloadData()
            }
            
        }  // API Method Brace ends here.......
    }
    
    fileprivate func verifyTotalOrderAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.verifyPurchaseHistoryStatus
        
        let parameters = [ "category_id": self.category_id,
                           "shop_id": self.store_id,
                           "order_id": self.order_id ] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if responseModel.success == true {
                        CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", alertButtonsArray: ["Ok"], viewController: weakSelf, completion: { _ in
                            
                            if weakSelf.apiOrderStatusEnum == .delivered {
                                
                                // Need to check is this order an escalated one or not...
                                
//                                let isEscalatedOrder = weakSelf.orderObject?.isEscalatedProduct
//
//                                if isEscalatedOrder == true {
//                                    weakSelf.popToPurchaseHistoryVC()
//                                    return
//                                }
                                
                                let isAllProductsDelivered = weakSelf.isAllProductsVerifiedAsDelivered()
                                
                                if weakSelf.orderObject?.prices?.paymentFee != nil {     // Paid Order
                                    if isAllProductsDelivered {
                                        weakSelf.pushToStoreFeedBackVC()
                                    } else {
                                        weakSelf.popToPurchaseHistoryVC()
                                    }
                                    
                                } else {                                                // Cash on delivery
                                    if let netPrice = weakSelf.orderObject?.prices?.netPrice {
                                        
                                        let deliveryCharge = weakSelf.orderObject?.prices?.delivery ?? 0
                                        var amountToPay = netPrice + deliveryCharge
                                        
                                        if let offerObject = weakSelf.orderObject?.offer, let offerType = offerObject.offerType, offerType == GSConstant.offer_discount_type {
                                            // Offer type = 1 is for cash back,  2 is for discount
                                            let offerAmount = offerObject.offerAmount ?? 0
                                            
                                            amountToPay -= offerAmount
                                            
                                            if amountToPay < 0 {
                                                amountToPay = 0
                                            }
                                        }
                                        weakSelf.pushToCODPaymentMessageView(amountToPay: "\(amountToPay)", isAllDelivered: isAllProductsDelivered)
                                    } else {
                                        if isAllProductsDelivered {
                                            weakSelf.pushToStoreFeedBackVC()
                                        } else {
                                            weakSelf.popToPurchaseHistoryVC()
                                        }
                                    }
                                }
                                
                            } else if weakSelf.apiOrderStatusEnum == .verified {
                                
                                weakSelf.productListAPI()
                                
                            } else {
                                weakSelf.navigationController?.popViewController(animated: true)
                            }
                        })
                    } else {
                        weakSelf.manageVerifiedSubmitFailureResponse(with: responseModel.message ?? "")
                    }
                    
                } catch {
                    print(error)
                    weakSelf.manageVerifiedSubmitFailureResponse(with: error.localizedDescription)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                weakSelf.manageVerifiedSubmitFailureResponse(with: error?.localizedDescription ?? GSString.API.unknownError)
            }
            
        }
    }
    
    
    fileprivate func reorderCheck() {
        
        let storeObjectHelper = StoreSelectionHelper()
        
        let clearCartSupport = GSClearCartSupport()
        clearCartSupport.clearCartAPI()
        clearCartSupport.clearSaveForLaterAPI()

        storeObjectHelper.fetchShopDetailsAPI(categoryId: self.category_id, storeId: self.store_id) { (shopObject, error) in
            
            if let unwrappedShopObject = shopObject {
                
                if self.productIdArrayToReOrder.count > 0 {
                    self.productIdArrayToReOrder.removeAll()
                }
                
                for product in self.products_array {
                    self.productIdArrayToReOrder.append(product.id ?? "")
                }
                
                self.addToCartAPI(shopObject: unwrappedShopObject)
                
            } else {
                
                CustomAlert.showAlert(title: GSString.AppName, message: error ?? "", viewController: self)
            }
        }
    }
    
    
    fileprivate func addToCartAPI(shopObject: GSHomeDocsClass) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.addProductToCart
        
        if productIdArrayToReOrder.count == 0 {
            // Move to cart
            
            if let userLocationCoordinates = orderObject?.location?.coordinates, userLocationCoordinates.count > 1 {
                
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLong, value: userLocationCoordinates[0])
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryLat, value: userLocationCoordinates[1])
                
                SharedPersistence.removeValue(key: UserDefaultKeys.locations.delivery_zipCode)
                SharedPersistence.removeValue(key: UserDefaultKeys.locations.savedAddressObject)
                
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_unchangeable_address, value: orderObject?.address?.area ?? "")
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_changeable, value: orderObject?.address?.street ?? "")
                
                var fullAddress = ""
                
                if let street = orderObject?.address?.street, street.removeEnclosedWhieteSpace() != "" {
                    fullAddress += street.removeEnclosedWhieteSpace()
                }
                
                if let area = orderObject?.address?.area, area.removeEnclosedWhieteSpace() != "" {
                    
                    if fullAddress == "" {
                        fullAddress += area
                    } else {
                        fullAddress += ", \(area)"
                    }
                }
                
                if let zipCode = orderObject?.address?.zipcode, zipCode != "" {
                
                    if fullAddress == "" {
                        fullAddress += zipCode
                    } else {
                        fullAddress += ", \(zipCode)"
                    }
                }
                
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.deliveryPlace, value: fullAddress)
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.locations.delivery_landMark, value: orderObject?.address?.zipcode ?? "")
                
            }
            
            
            let storeSelectionHelper = StoreSelectionHelper()
            storeSelectionHelper.assignCommonStoreSettings(shopAtIndex: shopObject, tempSessionIndex: 1)
            
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.selecedStoreArray, value: [self.store_id])
            
            if let cartVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSCartViewController) as? GSCartViewController {
                navigationController?.pushViewController(cartVC, animated: true)
            }

            return
        }
        
        let prodId = productIdArrayToReOrder.last ?? ""
        guard let qty = products_array.first(where: { $0.id == prodId })?.qty else { return }
        
        let params = ["_id" : self.category_id as Any ,
                      "product_id" : prodId as Any ,
                      "is_private" : true,
                      "stores"     : [["store_id" : self.store_id as Any ,
                                       "qty" : qty]] ] as [String : Any]
        
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] , urlString: urlString, withLoader:true) { [weak self] (responseData, error) in
            
            guard let weakSelf = self else { return }

            DispatchQueue.main.async {
                MBProgressHUD.hide(for: weakSelf.view, animated: true)
            }
            
            if error == nil {
                weakSelf.productIdArrayToReOrder.removeLast()
                weakSelf.addToCartAPI(shopObject: shopObject)
                
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    private func isAllProductsVerifiedAsDelivered() -> Bool {
        
        for verifyItem in apiVerifyRequestBody_array {
            if verifyItem.apiVerify_status != TrackOrderConstants.VerifyStatus.delivered {
                return false
            }
        }
        return true
    }
    
    private func manageVerifiedSubmitFailureResponse(with message:String) {
        
        if apiOrderStatusEnum == .verified {
            CustomAlert.showAlert(title: GSString.AppName, message: message, alertButtonsArray: ["Cancel", "Refresh"], viewController: self) { btnIndex in
                
                if btnIndex == 0 {
                    // Cancel
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.verifyTotalOrderAPI()
                }
            }
        }
    }
    
    fileprivate func replacementConfigurationAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.replacementConfiguration
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSVerifyItemsReplacementConfigurationModel.self, from: responseData)
                    
                    if let replacementTitles = responseModel.data?.titles {
                        weakSelf.replacementConfig_array = replacementTitles
                        weakSelf.purchasedVerify_tableView.reloadData()
                    }
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }
    
    private func pushToStoreFeedBackVC() {
        if let storeFeedbackVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSStoreFeedbackViewController) as? GSStoreFeedbackViewController {
            
            storeFeedbackVC.configureForStoreFeedBack(orderId: order_id, storeId: store_id, isFromTrackOrder: false, isDeliveredProducts: true)
            navigationController?.pushViewController(storeFeedbackVC, animated: true)
        }
    }
    
    // Pushing to VC to show COD details
    
    private func pushToCODPaymentMessageView(amountToPay:String, isAllDelivered:Bool) {
        
        if let codDetailVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSDetailMakePaymentViewController) as? GSDetailMakePaymentViewController {
            
            codDetailVC.configureWith(orderId: order_id, storeId: store_id, payingAmount: amountToPay, isAllDelivered:isAllDelivered, isFromTrack:false, store_name: navigationBarView.titleLable.text ?? "", apiDeliveryDate: orderObject?.delivered ?? "")
            
            navigationController?.pushViewController(codDetailVC, animated: true)
        }
    }
    
    // Popping to TrackOrderViewController
    
    private func popToPurchaseHistoryVC() {
        
        for vc in (self.navigationController?.viewControllers.reversed() ?? []) {
            if vc is GSPurchaseHistoryViewController {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: NavigationBar Methods

extension GSPurchasedProductsVerifyViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    func rightBarBtnPressed(sender:UIButton) {
        if let helpScreen = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSHelpViewController) as? GSHelpViewController {
            
            helpScreen.configureHelpWith(order_root_id: orderObject?.id ?? "", is_combined_help: false, isDeliveredOrVerified: true)
            navigationController?.pushViewController(helpScreen, animated: true)
        }
    }
}
