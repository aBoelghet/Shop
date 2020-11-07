//
//  GSVerifyItemsViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/4/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import QBImagePickerController
import MKToolTip

class GSVerifyItemsViewController: GSLoggedInBaseViewController {

    @IBOutlet var navigationBarView: NavigationBarNormal!
    @IBOutlet var productTable: UITableView!
    
    @IBOutlet weak var deliveryStatus_lbl: GSBaseLabel!
    @IBOutlet weak var verifiedStaus_lbl: GSBaseLabel!
    
    @IBOutlet weak var header_lbl:GSBaseLabel!
    @IBOutlet weak var orderCost_lbl: GSBaseLabel!
    @IBOutlet weak var headerLabel_BG:UIView!
    @IBOutlet weak var submit_btn:GSBaseButton!
    @IBOutlet weak var mapRedirection_btn:GSBaseButton!
    
    @IBOutlet weak var invoice_btn: GSUnderlinedButton!
    @IBOutlet weak var submitBtnHeight_constraint:NSLayoutConstraint!

    var bottomSelection = NSMutableDictionary()
    
//    lazy var productsFromTheStore = [GSTrackOrderListProduct]()
//    var orderDetailsObject:GSTrackOrderListOrderDetail?
//    var orderedDateObject:GSTrackOrderListHeader?
    lazy var apiVerifyRequestBody_array = [VerifyItemsRequestModel]()
    
    var category_id = ""
    var store_id = ""
    var order_id = ""
    
    var indexForComplaintCell:Int = -1
    var selectedIndex:Int = -1
    var isIndexPathSelected = false
    
    var isComplaintSelected = false

    lazy var replacementConfig_array = [String]()
    
    var isProductsDelivered = false
    var imagesDictionary = [String:Any]()
    var maxImagesCount = 3
    var imageSelectionIndex = -1
//    var isUserCanTakeActionsOnOrders = false
    var isExpiryNeedToShow = false
    
    var picker:GSCustomPickerView!
    var toolTip:MKToolTip?
    
    var isAllDelivered = true
    
    // New Models
    
    var trackOrderObject: GSTrackOrderProductListOrder?
    var productsData: GSTrackOrderProductListData?
    var products_array = [GSTrackOrderProductListProduct]()
    var apiOrderStatusEnum:OrderStatusFromAPI = .other
    var isReplacementDaysLeft:ReplacementDaysLeftObject?
    
    var cancellationRequestPopup_view:GSOrderCancellationPopUpView!
    
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
        
        applyColors()
        addFewIntializers()
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
        
        submit_btn.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_submitBtn_BG)
        submit_btn.setTitleColor(UIColor(hexString: defaultTheme.verifyItems_submitBtn_title), for: .normal)
        
        orderCost_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_header_cost_text)
    }
    
    // MARK: User defined Methods
    
    func addFewIntializers() {
        
        navigationBarView.delegate = self
        navigationBarView.titleText = ""
        
        productTable.delegate = self
        productTable.dataSource = self
        
        productTable.estimatedRowHeight = 44.0
        productTable.rowHeight = UITableViewAutomaticDimension
        productTable.tableFooterView = UIView()
        
        let cellNib = UINib(nibName: GSString.NibNames.GSTrackPurchaseVerifyTableCell, bundle: nil)
        productTable.register(cellNib, forCellReuseIdentifier: GSString.CellIdentifier.commonCellForVerifyTrackorderPurchaseHistory)
        
        submit_btn.backgroundColor = UIColor.lightGray
        submit_btn.isUserInteractionEnabled = false
        
        navigationBarView.rightBarBtn.isHidden = true
    }
    
    // MARK: - Model For Maintaining to send request and to manage tableView
    
    struct VerifyItemsRequestModel {
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
    
    @IBAction func trackTheOrder(_ sender: UIButton) {
        
        if let trackInMapVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSTrackOrderMapViewController) as? GSTrackOrderMapViewController {
            
            trackInMapVC.configureWith(categoryId: category_id, storeId: store_id, orderId: order_id)
            navigationController?.pushViewController(trackInMapVC, animated: true)
        }
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        
        // Verify the request body
        
        if apiOrderStatusEnum == .delivered {
            
            for index in 0..<apiVerifyRequestBody_array.count {
                
                let requestBody = apiVerifyRequestBody_array[index]
                
                if requestBody.apiVerify_status == 0 {
                    
                    CustomAlert.showAlert(title: GSString.AppName, message: "Please verify \(requestBody.productName)", viewController: self)
                    return
                    
                }
                
                if requestBody.verify_status == TrackOrderConstants.VerifyStatus.replacement {
                    
                    let replacementValidation = validateReplacementRequest(for: index)
                    
                    if replacementValidation.0 == false {
                        CustomAlert.showAlert(title: GSString.AppName, message: "\(requestBody.productName)\n\(replacementValidation.1)", viewController: self)
                        return
                    }
                }
                
//                else if requestBody.apiVerify_status == TrackOrderConstants.VerifyStatus.replacement {
//                    let replacementValidation = validateReplacementRequest(for: index)
//
//                    if replacementValidation.0 == false {
//                        CustomAlert.showAlert(title: GSString.AppName, message: "\(requestBody.productName)\n\(replacementValidation.1)", viewController: self)
//                        return
//                    }
//                }
                
                
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
        
        guard let unwrappedOrderDetailsObject = trackOrderObject else { return }
        guard let orderStatus = unwrappedOrderDetailsObject.status else { return }
        
        var delivery_status = "NA"
        var isDeliveryStatusGoingGood = false
        var customerVerifyStatus = ""
        
        var isUserCanCancelTheProduct = true
        var isNeedToShowHelpButton = false
        var isNeedToShowMap = true
        
        apiOrderStatusEnum = .other
        
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
            isUserCanCancelTheProduct = false
            isNeedToShowMap = false
            break
        case TrackOrderConstants.NewOrderStatus.Cancelled.status:
            apiOrderStatusEnum = .cancelledOrRejected
            delivery_status = TrackOrderConstants.NewOrderStatus.Cancelled.name
            customerVerifyStatus = TrackOrderConstants.NewOrderStatus.Cancelled.name
            isDeliveryStatusGoingGood = false
            isUserCanCancelTheProduct = false
            isNeedToShowMap = false
            break
            
        case TrackOrderConstants.NewOrderStatus.Denied.status:
            apiOrderStatusEnum = .cancelledOrRejected
            delivery_status = TrackOrderConstants.NewOrderStatus.Denied.name
            customerVerifyStatus = TrackOrderConstants.NewOrderStatus.Denied.name
            isDeliveryStatusGoingGood = false
            isUserCanCancelTheProduct = false
            isNeedToShowMap = false
            break
            
        case TrackOrderConstants.NewOrderStatus.ReadyToShip.status:
            delivery_status = TrackOrderConstants.NewOrderStatus.ReadyToShip.name
            isDeliveryStatusGoingGood = true
            isUserCanCancelTheProduct = true
            break
        case TrackOrderConstants.NewOrderStatus.Shipping.status:
            delivery_status = TrackOrderConstants.NewOrderStatus.Shipping.name
            isDeliveryStatusGoingGood = true
            isExpiryNeedToShow = true
            isUserCanCancelTheProduct = false
            isNeedToShowHelpButton = true
            break
        case TrackOrderConstants.NewOrderStatus.Delivered.status:
            delivery_status = TrackOrderConstants.NewOrderStatus.Delivered.name
            isDeliveryStatusGoingGood = true
            isExpiryNeedToShow = true
            isUserCanCancelTheProduct = false
            apiOrderStatusEnum = .delivered
            isNeedToShowMap = false
            customerVerifyStatus = "Not Verified"
            isNeedToShowHelpButton = true
            break
        case TrackOrderConstants.NewOrderStatus.Verified.status:
            delivery_status = TrackOrderConstants.NewOrderStatus.Delivered.name
            customerVerifyStatus = TrackOrderConstants.NewOrderStatus.Verified.name
            isDeliveryStatusGoingGood = true
            isExpiryNeedToShow = true
            isUserCanCancelTheProduct = false
            isNeedToShowHelpButton = true
            apiOrderStatusEnum = .verified
            isNeedToShowMap = false
            break
        default:
            
            isUserCanCancelTheProduct = false
            break
        }
        
        deliveryStatus_lbl.text = delivery_status
        verifiedStaus_lbl.text = customerVerifyStatus
        deliveryStatus_lbl.textColor = isDeliveryStatusGoingGood ? UIColor(hexString: defaultTheme.verifyItems_delStatus_green_text) : UIColor(hexString: defaultTheme.verifyItems_delStatus_red_text)
        
        mapRedirection_btn.isHidden = !isNeedToShowMap
        
        navigationBarView.rightBarBtn.isHidden = false
        if isUserCanCancelTheProduct {
            navigationBarView.rightBtnTitle = GSConstant.cancelOrderButtonTitle
        } else if isNeedToShowHelpButton {
            navigationBarView.rightBtnTitle = GSConstant.helpButtonTitle
        } else {
            navigationBarView.rightBarBtn.isHidden = true
        }
        
        isSubmitButtonEnabled = false

        if apiOrderStatusEnum == .delivered {
            isSubmitButtonEnabled = true
        } else if apiOrderStatusEnum == .verified {
            isSubmitButtonEnabled = false
            submitBtnHeight_constraint.constant = 0
        }
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

extension GSVerifyItemsViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate {

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
        
        productTable.reloadData()
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - QB ImagePickerController Delegate

extension GSVerifyItemsViewController:QBImagePickerControllerDelegate {
    
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
                        
                        guard let infoDictionary = infoDict else { return }
                        guard let userInfo = infoDictionary["PHImageErrorKey"] as? NSError else { return }
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
                    self.productTable.reloadData()
                }
            }  // Main queue ends here...
            
        }  // Global queue ends here...
        
    }
    
}

// MARK: - UITableView Methods

extension GSVerifyItemsViewController:UITableViewDelegate,UITableViewDataSource {
    
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
        
        guard let cell = productTable.dequeueReusableCell(withIdentifier: identifier) as? GSTrackPurchaseVerifyTableCell else {
            return UITableViewCell()
        }
        
        let productItem = products_array[indexPath.row]
        cell.configureTheCellWithCommonData(productItem: productItem)
        
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
        
        if let offerObject = trackOrderObject?.offer, let offerType = offerObject.offerType, offerType == GSConstant.offer_discount_type {
            let actualOriginalPrice = (trackOrderObject?.prices?.netPrice ?? 0) + (trackOrderObject?.prices?.delivery ?? 0)
            
            let offerAmount = offerObject.offerAmount ?? 0
            percentage = ((offerAmount / actualOriginalPrice) * 100)
        }
        
        let offerOnThisProduct = (originalPrice * percentage)/100
        return originalPrice - offerOnThisProduct
    }
    
    private func updateReplacementUndeliveredDetailsOnUI(_ cell:GSTrackPurchaseVerifyTableCell, requestModel: VerifyItemsRequestModel, indexPath:IndexPath) {
        
        let requestModelAtIndex = apiVerifyRequestBody_array[indexPath.row]
        
        cell.expiryDateKey_lbl.isHidden = true
        cell.moreExpiryDates_btn.isHidden = true
        cell.expiryNotify_switch.isHidden = true
        cell.expiryNotifyInfo_btn.isHidden = true
        cell.expiryNotifyInfoIcon_imgView.isHidden = true
        cell.expiryDateKeyBg_view.isHidden = false
        
        cell.quantity_lbl.text = "\(requestModel.totalQty - requestModel.selectedQty)"
        
        if requestModelAtIndex.apiVerify_status == TrackOrderConstants.VerifyStatus.replacement {
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
    
    private func isReplaceMentExist(lastDateInString:String?)->GSVerifyItemsViewController.ReplacementDaysLeftObject {
        
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
    
    private func updatePricesFor(verifyStatus:Int, requestItemModel:VerifyItemsRequestModel, productItem: GSTrackOrderProductListProduct, cell:GSTrackPurchaseVerifyTableCell) {
        
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
        
//        if !isDelivered {           // Undelivered or Replacement
//            priceToShow = -(Double(qtyToShow) * priceOfProductWithOffer(originalPrice: (productItem.netPrice ?? 0)))
//            cell.daysLeftOrProductCost_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_delStatus_red_text)
//        } else {
//            cell.daysLeftOrProductCost_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderListVC_cell_cost_lbl_text)
//            priceToShow = (Double(totalQtyOrdered) * priceOfProductWithOffer(originalPrice: (productItem.netPrice ?? 0)))
//        }
        
        cell.quantity_lbl.text = "\(qtyToShow)"
        cell.daysLeftOrProductCost_lbl.text = GSCommonHelper.formattedPrice(price: priceToShow) //GSConstant.currency_symbol + "\(priceToShow)"
        
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
        
//        let actualOriginalPrice = (trackOrderObject?.prices?.netPrice ?? 0) + (trackOrderObject?.prices?.delivery ?? 0)
        
        let actualOriginalPrice = (trackOrderObject?.prices?.netPrice ?? 0)

        
        var percentage: Double = 0
        
        if let offerObject = trackOrderObject?.offer, let offerType = offerObject.offerType, offerType == GSConstant.offer_discount_type {
            
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
        
        let totalPriceToReturn = total_price + Double(trackOrderObject?.prices?.delivery ?? 0)
        
//        if let offerObject = trackOrderObject?.offer, let offerType = offerObject.offerType, offerType == GSConstant.offer_discount_type {
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
        productTable.reloadData()
        
        newVerifyOrderStatusAPI(for: sender.tag)
    }
    
    @objc func cell_UnDelivered_Action(_ sender:UIButton) {
        isIndexPathSelected = false
        indexForComplaintCell = -1
        selectedIndex = sender.tag
        apiVerifyRequestBody_array[sender.tag].verify_status = TrackOrderConstants.VerifyStatus.undelivered
        apiVerifyRequestBody_array[sender.tag].selectedQty = (apiVerifyRequestBody_array[sender.tag].selectedQty == 0) ? apiVerifyRequestBody_array[sender.tag].totalQty : apiVerifyRequestBody_array[sender.tag].selectedQty
        productTable.reloadData()
        
        newVerifyOrderStatusAPI(for: sender.tag)

    }
    
    @objc func cell_Replace_Action(_ sender:UIButton) {
        
        if isIndexPathSelected, sender.tag + 1 == indexForComplaintCell {       // Already Opened... Need to close
            isIndexPathSelected = false
            indexForComplaintCell = -1
            productTable.reloadData()
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
        productTable.reloadData()
    }

    @objc func cell_Help_Action(_ sender:UIButton) {
        indexForComplaintCell = sender.tag + 1
        selectedIndex = sender.tag
        
        pushToHelpScreen()
    }

    @objc func cell_writeReview_Action(_ sender:UIButton) {
        
        if sender.tag >= products_array.count { return }
        
        let productItem = products_array[sender.tag]
        
        if let feedBackVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSStoreFeedbackViewController) as? GSStoreFeedbackViewController {
            
            feedBackVC.configureForProductFeedBack(categoryId: category_id, orderId: order_id, productId: productItem.id ?? "", isFromTrackOrder: true)
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
                            self.productTable.reloadData()
                            return
                        }
                    }
                    self.newVerifyOrderStatusAPI(for: sender.tag)
                    self.productTable.reloadData()
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

extension GSVerifyItemsViewController:GSComplaintCellDelegate {

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
        productTable.reloadData()
        
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
                    self.productTable.reloadData()
                }

            }
        }
    }
}

// MARK: - API Methods

extension GSVerifyItemsViewController {
    
    func productListAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.viewTrackOrderProducts
        
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
                    weakSelf.productTable.reloadData()
                }
            }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSTrackOrderProductListModel.self, from: responseData)
                    
                    weakSelf.trackOrderObject = responseModel.data?.order
                    weakSelf.productsData = responseModel.data
//                    weakSelf.trackOrderObject = weakSelf.productsData?.order
                    
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
                            
                            if (weakSelf.trackOrderObject?.status ?? 0) == TrackOrderConstants.NewOrderStatus.Verified.status {
                                verifyStatus = 0
                            }
                            
                            let request = VerifyItemsRequestModel(productName: productItem.productName ?? "", product_id: productItem.id ?? "",verify_status: verifyStatus, apiVerify_status: productItem.verifyStatus ?? 0, previousSelectedVerify_status: 0, enable_expiry_date: productItem.notifications ?? false, title: "", message: "", selectedQty: productItem.escalatedQty ?? 0, totalQty: productItem.qty ?? 0, price: productItem.netPrice ?? 0)
                            weakSelf.apiVerifyRequestBody_array.append(request)
                        }
                    }
                    weakSelf.changesBasedOnOrderStatus()
                    weakSelf.productTable.reloadData()
                    
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
                        weakSelf.productTable.reloadData()
                    }
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }
    
    fileprivate func newVerifyOrderStatusAPI(for index:Int) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.verifyProducts
        
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
                        weakSelf.productTable.reloadData()
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
                self?.productTable.reloadData()
            }
            
        }  // API Method Brace ends here.......
    }
    
    fileprivate func verifyTotalOrderAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.verifyOrderStatus
        
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
                                
//                                let isEscalatedOrder = weakSelf.trackOrderObject?.isEscalatedProduct
//
//                                if isEscalatedOrder == true {
//                                    weakSelf.popToTrackOrderVC()
//                                    return
//                                }
                                
                                let isAllProductsDelivered = weakSelf.isAllProductsVerifiedAsDelivered()
                                
                                if weakSelf.trackOrderObject?.prices?.paymentFee != nil {     // Paid Order
                                    if isAllProductsDelivered {
                                        weakSelf.pushToStoreFeedBackVC()
                                    } else {
                                        weakSelf.popToTrackOrderVC()
                                    }
                                    
                                } else {                                                // Cash on delivery
                                    if let netPrice = weakSelf.trackOrderObject?.prices?.netPrice {
                                        let deliveryCharge = weakSelf.trackOrderObject?.prices?.delivery ?? 0
                                        var amountToPay = netPrice + deliveryCharge
                                        
                                        if let offerObject = weakSelf.trackOrderObject?.offer, let offerType = offerObject.offerType, offerType == GSConstant.offer_discount_type {
                                            // Offer type = 1 is for cash back,  2 is for discount
                                            let offerAmount = offerObject.offerAmount ?? 0
                                            
                                            amountToPay -= offerAmount
                                            
                                            if amountToPay < 0 {
                                                amountToPay = 0
                                            }
                                        }
                                        
                                        weakSelf.pushToCODPaymentMessageView(amountToPay: "\(GSCommonHelper.formattedDouble(double: amountToPay))", isAllDelivered: isAllProductsDelivered)
                                    } else {
                                        if isAllProductsDelivered {
                                            weakSelf.pushToStoreFeedBackVC()
                                        } else {
                                            weakSelf.popToTrackOrderVC()
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
    
    private func isAllProductsVerifiedAsDelivered() -> Bool {
        
        for verifyItem in apiVerifyRequestBody_array {
            if verifyItem.apiVerify_status != TrackOrderConstants.VerifyStatus.delivered {
                return false
            }
        }
        return true
    }
    
    private func manageVerifiedSubmitFailureResponse(with message:String) {
        
        if apiOrderStatusEnum == .verified || apiOrderStatusEnum == .delivered {
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
    
    // Pushing to VC to show COD details
    
    private func pushToCODPaymentMessageView(amountToPay:String, isAllDelivered:Bool) {
        
        if let codDetailVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSDetailMakePaymentViewController) as? GSDetailMakePaymentViewController {
            
            codDetailVC.configureWith(orderId: order_id, storeId: store_id, payingAmount: amountToPay, isAllDelivered:isAllDelivered, isFromTrack:true, store_name: navigationBarView.titleLable.text ?? "", apiDeliveryDate: trackOrderObject?.delivered ?? "")

            navigationController?.pushViewController(codDetailVC, animated: true)
        }
    }
    
    // Pushing to Store Feedback VC
    
    private func pushToStoreFeedBackVC() {
        
        if let storeFeedbackVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSStoreFeedbackViewController) as? GSStoreFeedbackViewController {
            storeFeedbackVC.configureForStoreFeedBack(orderId: order_id, storeId: store_id, isFromTrackOrder: true, isDeliveredProducts: true)
                navigationController?.pushViewController(storeFeedbackVC, animated: true)
        }
    }
    
    // Popping to TrackOrderViewController
    
    private func popToTrackOrderVC() {
        
        for vc in (self.navigationController?.viewControllers.reversed() ?? []) {
            if vc is GSTrackOrderListViewController {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Cancellation Pop up view delegate

extension GSVerifyItemsViewController:GSOrderConcellationPopUpViewDelegate {
    
    func cancelOrderResponse(isCancelled: Bool,message: String) {
        
        CustomAlert.showAlert(title: GSString.AppName, message: message, alertButtonsArray: ["Ok"], viewController: self) { [weak self] _ in
            
            if isCancelled {
                self?.selectedIndex = -1
                self?.productListAPI()
            }
        }
    }
}


// MARK: NavigationBar Methods

extension GSVerifyItemsViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender:UIButton) {
        
        if sender.title(for: .normal) == GSConstant.cancelOrderButtonTitle {
          
            let orderStatus = trackOrderObject?.status ?? 0
            let cancelSelectedStage = trackOrderObject?.cancelSelectedStage ?? 0
            
            if orderStatus >= cancelSelectedStage {
                CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.cancelRestriction, viewController: self)
                return
            }
            
            if cancellationRequestPopup_view != nil {
                if cancellationRequestPopup_view.isDescendant(of: self.view) {
                    return
                }
                cancellationRequestPopup_view = nil
            }
            
            
            var isPaidOrder = false
            
            if let paymentType = trackOrderObject?.paymentType, paymentType == 1 {
                isPaidOrder = true
            }
            
            if let isBayfayCashOrder = trackOrderObject?.isBayfayCash, isBayfayCashOrder == 1 {
                isPaidOrder = false
            }
            
            cancellationRequestPopup_view = GSOrderCancellationPopUpView()
            cancellationRequestPopup_view.delegate = self
            cancellationRequestPopup_view.isPaidOrder = isPaidOrder
            cancellationRequestPopup_view.configureCancellPopupWith(orderIdArray: [trackOrderObject?.id ?? ""], isEscalated: trackOrderObject?.isEscalatedProduct ?? false)
            
            view.addSubview(cancellationRequestPopup_view)
            cancellationRequestPopup_view.addConstraintsAndShow(on: view)
            
        } else {
            
            // Help
                pushToHelpScreen()
        }
    }
    
    
    fileprivate func pushToHelpScreen() {
        if let helpScreen = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSHelpViewController) as? GSHelpViewController {
            
            helpScreen.configureHelpWith(order_root_id: trackOrderObject?.id ?? "", is_combined_help: false, isDeliveredOrVerified: (apiOrderStatusEnum == .delivered || apiOrderStatusEnum == .verified))
            navigationController?.pushViewController(helpScreen, animated: true)
        }
    }
}
