//
//  GSMessagesViewController.swift
//  Shopor-dev
//
//  Created by Ratheesh on 20/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SDWebImage

class GSMessagesViewController: GSLoggedInBaseViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var message_tableView:UITableView!
    @IBOutlet weak var orderId_lbl:GSBaseLabel!
    @IBOutlet weak var product_imgView:UIImageView!
    @IBOutlet weak var orderInfoBG_view:UIView!
    @IBOutlet weak var line_view:UIView!
    @IBOutlet weak var chat_txtView:UITextView!
    @IBOutlet weak var toolBarBottom_constraint: NSLayoutConstraint!
    @IBOutlet weak var toolBar_view: UIView!
    @IBOutlet weak var atachment_btn:UIButton!
    @IBOutlet weak var sendMessage_btn:UIButton!
    @IBOutlet weak var template_btn:UIButton!
    @IBOutlet weak var toolbarHeight_constraint:NSLayoutConstraint!
    
//    static let outgoingBubbleImage = UIImage(named: "bubbleMine")?.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
//    static let incomingBubbleImage = UIImage(named: "bubbleSomeone")?.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let outgoingBubbleImage = UIImage(named: "bubbleMine")?.resizableImage(withCapInsets: UIEdgeInsetsMake(10, 10, 20, 20)).withRenderingMode(.alwaysTemplate)
    static let incomingBubbleImage = UIImage(named: "bubbleSomeone")?.resizableImage(withCapInsets: UIEdgeInsetsMake(10, 20, 20, 10)).withRenderingMode(.alwaysTemplate)
    
    var tableScrollOffsetY:CGFloat = 0
    
    var order_id = ""
    var idOfOrder = ""
    var categoryId = ""
    var product_id = ""
    var user_id = ""
    var store_id = ""
    var store_name = ""
    var user_name = ""
    
    let toolBarMax_height:CGFloat = 80
    let toolBarMin_height:CGFloat = 35
    
    var removableCache_array : [String]?
    
    var chat_array = [New_GSMessageChatListDataChat]()
    var keyBoardHeight:CGFloat = 0

    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applyColors()
        addFewIntializers()
        getChatList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Configuring with data
    
    func configureWith(categoryId:String, idOfTheOrder:String, storeId: String, productId:String) {
        self.categoryId = categoryId
        self.product_id = productId
        self.idOfOrder = idOfTheOrder
        self.store_id = storeId
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        
        orderInfoBG_view.backgroundColor = UIColor(hexString: defaultTheme.MessageVC_header_bg)
        orderId_lbl.textColor = UIColor(hexString: defaultTheme.MessageVC_header_title)
        line_view.backgroundColor = UIColor(hexString: defaultTheme.MessageVC_line_bg)
        
        chat_txtView.layer.borderColor = UIColor(hexString: defaultTheme.MessageVC_textView_border).cgColor
        toolBar_view.backgroundColor = UIColor(hexString: defaultTheme.MessageVC_toolBar_bg)
    }
    
    // MARK: User defined Methods
    
    private func addFewIntializers() {
        
        navigationBar_view.delegate = self
        message_tableView.dataSource = self
        message_tableView.delegate = self
        chat_txtView.delegate = self
        
        if let decodedLoginUserData = SharedPersistence.getValue(key: UserDefaultKeys.user.user_details) as? Data {
            if let loginUser_jsonObject = try? JSONDecoder().decode(GSLoginData.self, from: decodedLoginUserData) {
                self.user_id = loginUser_jsonObject.userProfile?.id ?? ""
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        if let decodedLoginUserData = SharedPersistence.getValue(key: UserDefaultKeys.user.user_details) as? Data {
            if let loginUser_jsonObject = try? JSONDecoder().decode(GSLoginData.self, from: decodedLoginUserData) {
                user_name = ((loginUser_jsonObject.userProfile?.firstName ?? "") + " " + (loginUser_jsonObject.userProfile?.lastName ?? ""))
            }
        }
    }
    
    fileprivate func updateTheUI(orderId:String, product: New_GSMessageChatListDataProduct?, shopName: String?) {
        
        orderId_lbl.text = "Order id: \(orderId)"
        navigationBar_view.titleText = product?.productName ?? ""
        store_name = shopName ?? ""
        
        let firstImageLink = product?.image?.name ?? ""

        if firstImageLink != "" {
            let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
            let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
            SDWebImageDownloader.shared.setValue(accessToken, forHTTPHeaderField: "Authorization")
            product_imgView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewProductImage + firstImageLink + imgHeight) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
            
        } else {
            product_imgView.image = #imageLiteral(resourceName: "blurImage")
        }
    }
    
    // MARK: - Gusture Recognizer Methods
    
    @objc private func tapGestureAction(_ gesture:UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - KeyBoard Notifications
    
    @objc private func keyboardDidShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if notification.name == NSNotification.Name.UIKeyboardWillShow {
                UIView.animate(withDuration: 0.15) {
                    self.toolBarBottom_constraint.constant = -keyboardSize.height
                    self.keyBoardHeight = keyboardSize.height
                    if self.message_tableView.contentSize.height > (self.message_tableView.frame.size.height - self.keyBoardHeight) {
                        self.message_tableView.setContentOffset(CGPoint(x: self.message_tableView.contentOffset.x, y: self.message_tableView.contentOffset.y + keyboardSize.height), animated: false)
                    }
                    self.view.layoutIfNeeded()
                }
            } else if notification.name == NSNotification.Name.UIKeyboardDidShow {
                self.toolBarBottom_constraint.constant = -keyboardSize.height
            }
        }
        
    }
    @objc private func keyboardDidHide(notification: Notification) {
        UIView.animate(withDuration: 0.15) {
            self.toolBarBottom_constraint.constant = 0
//            let remaining = self.message_tableView.contentSize.height - self.message_tableView.contentOffset.y
//            if remaining > self.keyBoardHeight {
//                self.message_tableView.setContentOffset(CGPoint(x: self.message_tableView.contentOffset.x, y: self.message_tableView.contentOffset.y - self.keyBoardHeight), animated: true)
//            }
            
            if self.message_tableView.contentSize.height > self.message_tableView.frame.size.height + self.keyBoardHeight {
                self.message_tableView.setContentOffset(CGPoint(x: self.message_tableView.contentOffset.x, y: self.message_tableView.contentOffset.y - self.keyBoardHeight), animated: false)
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - IBAction Methods
    @IBAction func attachmentSelection(_ sender: UIButton) {
        
        let isUserCanGoFurtherObject = isUserCanGoFurther()
        
        if isUserCanGoFurtherObject.0 == false {
            CustomAlert.showAlert(title: GSString.AppName, message: isUserCanGoFurtherObject.1, viewController: self)
            return
        }
        
        CustomAlert.showActionSheet(title: "Choose", message: nil, cancelTitle: "Cancel", optionArray: ["Camera","Photos"], sourceView: sender, in: self) { btn_index in
            if btn_index == 0 {
                // Camera
                self.intializeImagePickerController(sourceType: .camera)
            } else  if btn_index == 1 {
                // Photos
                self.intializeImagePickerController(sourceType: .photoLibrary)
            }
        }
    }
    
    private func intializeImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        
        if sourceType == .camera, !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        if GSCommonHelper.checkForUsagePermission(resourceType: sourceType, viewController: self) == false { return }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func thumbAction(_ sender: UIButton) {
        
        let isUserCanGoFurtherObject = isUserCanGoFurther()
        
        if isUserCanGoFurtherObject.0 == false {
            CustomAlert.showAlert(title: GSString.AppName, message: isUserCanGoFurtherObject.1, viewController: self)
            return
        }
        updateCorrespondanse(selectedImage: nil, isTemplate: true)
    }
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        if chat_txtView.text.count > 0 {
            
            let isUserCanGoFurtherObject = isUserCanGoFurther()
            if isUserCanGoFurtherObject.0 == false {

                makeTextViewEmpty()
                CustomAlert.showAlert(title: GSString.AppName, message: isUserCanGoFurtherObject.1, viewController: self)
                return
            }
            updateCorrespondanse(selectedImage: nil, isTemplate: false)
        }
    }
    
    fileprivate func makeTextViewEmpty() {
        DispatchQueue.main.async {
            self.chat_txtView.text = ""
            if self.atachment_btn.isHidden {
                UIView.animate(withDuration: 0.4) {
                    self.atachment_btn.isHidden = false
                    self.template_btn.isHidden = false
                }
            }
            if self.toolbarHeight_constraint.constant != self.toolBarMin_height {
                self.toolbarHeight_constraint.constant = self.toolBarMin_height
            }
        }
    }
    
    // MARK: - New escalation Permission
    
    private func isUserCanGoFurther() -> (Bool,String) {
        
        if let lastMessage = chat_array.last {
            
            let messageFrom_id = lastMessage.by ?? ""
            let isOutgoingMessage = (messageFrom_id == user_id)
            
            if lastMessage.isTemplate == true {
                
                if isOutgoingMessage {
                    
                    if let templateResponse = lastMessage.templateResponse {
                        print(templateResponse)
                        return (true,"")
                        
                    } else {
                        // Template Response key not available... means user has not selected anything
                        return (false, "A request has sent from you already... Please wait until you get response")
                    }
                    
                } else {
                    // We have to check for template status
                    
                    if let templateResponse = lastMessage.templateResponse {
                        print(templateResponse)
                        return (true,"")
                        
                    } else {
                        // Template Response key not available... means user has not selected anything
                        return (false, "Choose your decision for the merchant request...")
                    }
                }
                
            } else {
                return (true,"")
            }
        }
        return (true,"")
    }
}

// MARK: - UIImagePicker Controller Delegate Methods

extension GSMessagesViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
//        if var selected_image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//
//            if UIDevice.current.userInterfaceIdiom == .pad {
//                selected_image = GSCommonHelper.fixOrientation(img: selected_image)
//            }
//
//            updateCorrespondanse(selectedImage: selected_image, isTemplate: false)
//
//        } else {
//            // Need to manage this case
//        }
        
        if var selectedImage = UIImage.from(info: info) {
            
            selectedImage = GSCommonHelper.fixOrientation(img: selectedImage)
            
            updateCorrespondanse(selectedImage: selectedImage, isTemplate: false)
            
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

// MARK: - TextView Delegate Methods

extension GSMessagesViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        
        if text.count > 0 {
            if !atachment_btn.isHidden {
                UIView.animate(withDuration: 0.4) {
                    self.atachment_btn.isHidden = true
                    self.template_btn.isHidden = true
                }
            }
        } else {
            if atachment_btn.isHidden {
                UIView.animate(withDuration: 0.4) {
                    self.atachment_btn.isHidden = false
                    self.template_btn.isHidden = false
                }
            }
        }
        
        if textView.contentSize.height > toolBarMin_height {
            
            if textView.contentSize.height < toolBarMax_height - 5 {
                self.toolbarHeight_constraint.constant = textView.contentSize.height + 5
            } else {
                self.toolbarHeight_constraint.constant = toolBarMax_height
            }
            
        } else {
            if self.toolbarHeight_constraint.constant != toolBarMin_height {
                self.toolbarHeight_constraint.constant = toolBarMin_height
            }
        }
    }
}

// MARK: - UITableView Methods

extension GSMessagesViewController:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message_item = chat_array[indexPath.row]
        
        let messageFrom_id = message_item.by ?? ""
        let isOutgoingMessage = (messageFrom_id == user_id)
        
        if message_item.isTemplate == true {
            return actionMessageCell(at: indexPath, message_status: 1, isOutgoingMessage: isOutgoingMessage)
        } else if let image = message_item.image {
            return imageMessageCell(at: indexPath, images_item: image, isOutgoingMessage: isOutgoingMessage)
        } else {
            return normalMessageCell(at: indexPath, isOutgoingMessage: isOutgoingMessage)
        }
    }
    
    // MARK: - Message Table View Cells
    
    private func normalMessageCell(at indexPath:IndexPath, isOutgoingMessage:Bool) -> UITableViewCell {
        
        var cell_identifier = GSString.CellIdentifier.messageNormalIncomingTableCell
        var bubble_image = GSMessagesViewController.incomingBubbleImage
        var bubble_color = UIColor(hexString: defaultTheme.MessageVC_normalMessage_incomingBG)
        
        if isOutgoingMessage {
            cell_identifier = GSString.CellIdentifier.messageNormalOutgoingTableCell
            bubble_image = GSMessagesViewController.outgoingBubbleImage
            bubble_color = UIColor(hexString: defaultTheme.MessageVC_normalMessage_outgoingBG)
        }
        
        guard let cell = message_tableView.dequeueReusableCell(withIdentifier: cell_identifier) as? GSMessageNormalTableCell else {
            return UITableViewCell()
        }
        let messageObject = chat_array[indexPath.row]
        cell.time_lbl.text = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: messageObject.at, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter) + " " + GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: messageObject.at, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appTimeFormatter)
        cell.message_lbl.text = messageObject.message ?? ""
        
        cell.message_lbl.font = UIFont.systemFont(ofSize: cell.message_lbl.font.pointSize)
        if messageObject.isDeleted == true {
            cell.message_lbl.font = UIFont.italicSystemFont(ofSize: cell.message_lbl.font.pointSize)
            cell.message_lbl.text = "This message has been deleted"
        }
        
        cell.bubble_imgView.image = bubble_image
        cell.bubble_imgView.tintColor = bubble_color
        
        return cell
    }
    
    private func actionMessageCell(at indexPath:IndexPath, message_status:Int, isOutgoingMessage:Bool) -> UITableViewCell {
        
        var cell_identifier = GSString.CellIdentifier.messageActionIncomingTableCell
        var headerBG_color = UIColor(hexString: defaultTheme.MessageVC_actionMessageIncomingHeader_bg)
        
        if isOutgoingMessage {
            cell_identifier = GSString.CellIdentifier.messageActionOutgoingTableCell
            headerBG_color = UIColor(hexString: defaultTheme.MessageVC_actionMessageOutgoingHeader_bg)
        }
        
        guard let cell = message_tableView.dequeueReusableCell(withIdentifier: cell_identifier) as? GSMessageWithActionsTableCell else {
            return UITableViewCell()
        }
        
        cell.title_lbl.text = isOutgoingMessage ? user_name : store_name
        
        let message = chat_array[indexPath.row]
        cell.time_lbl.text = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: message.at, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter) + " " + GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: message.at, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appTimeFormatter)
        cell.message_lbl.text = message.message ?? ""
        
        cell.headerBg_view.backgroundColor = headerBG_color
        
        updateActionCellUIBasedUponStatus(cell: cell, message_status: message_status, indexPath: indexPath, isOutgoingMessage: isOutgoingMessage)
        
        return cell
    }
    
    private func updateActionCellUIBasedUponStatus(cell:GSMessageWithActionsTableCell, message_status:Int , indexPath:IndexPath, isOutgoingMessage:Bool) {
        cell.singleBtnBG_view.isHidden = true
        cell.twoBtnsBG_view.isHidden = true
        cell.actionStatus_btn.layer.borderColor = UIColor(hexString: defaultTheme.MessageVC_message_cancel_border).cgColor
        cell.actionStatus_btn.layer.borderWidth = 0
        cell.actionStatus_btn.setTitleColor(UIColor(hexString: defaultTheme.MessageVC_message_cancel_border), for: .normal)
        
        let message = chat_array[indexPath.row]
        
        if let templateResponse = message.templateResponse, templateResponse == GSMessagesConstants.MessageTemplateStatus.accepted || templateResponse == GSMessagesConstants.MessageTemplateStatus.denied {
            cell.singleBtnBG_view.isHidden = false
            let button_title = (templateResponse == GSMessagesConstants.MessageTemplateStatus.denied) ? "Denied" : "Accepted"
            cell.actionStatus_btn.setTitle(button_title, for: .normal)
            cell.actionStatus_btn.isUserInteractionEnabled = false
        } else {
            
            if isOutgoingMessage {
                
                cell.singleBtnBG_view.isHidden = false
                cell.actionStatus_btn.setTitle("Cancel", for: .normal)
                cell.actionStatus_btn.layer.borderWidth = 0.5
                cell.actionStatus_btn.isUserInteractionEnabled = true
                cell.actionStatus_btn.tag = indexPath.row
                cell.actionStatus_btn.addTarget(self, action: #selector(messageCell_cancelAction(_:)), for: .touchUpInside)
                
            } else {
                
                cell.twoBtnsBG_view.isHidden = false
                cell.okay_btn.tag = indexPath.row
                cell.deny_btn.tag = indexPath.row
                cell.okay_btn.addTarget(self, action: #selector(messageCell_acceptAction(_:)), for: .touchUpInside)
                cell.deny_btn.addTarget(self, action: #selector(messageCell_denyAction(_:)), for: .touchUpInside)
                
                //                var remainingTimeToShow = ""
                //                let dateFormatter = DateFormatter()
                //                dateFormatter.dateFormat = GSConstant.apiDateFormatter
                //                if let remainDate = dateFormatter.date(from: message.timer ?? "") {
                //                    remainingTimeToShow = GSCommonHelper.getTheDifferentiatedString(from: Date(), toDate: remainDate)
                //                }
                //
                //                if remainingTimeToShow == "" {
                //                    cell.twoBtnsBG_view.isHidden = true
                //                }
                //                cell.remainingTime_lbl.text = (remainingTimeToShow == "") ? "" : "Time left: \(remainingTimeToShow)"
                //            }
                
            }
        }
    }
    
    @objc private func messageCell_cancelAction(_ sender:UIButton) {
        // Will Cancel the request
        let message_item = chat_array[sender.tag]
        deleteCorrespondenceOrDenyRequest(message_item.id ?? "", isDenyRequest: false)
    }
    @objc private func messageCell_acceptAction(_ sender:UIButton) {
        let message_item = chat_array[sender.tag]
        acceptTemplate(message_item.id ?? "")
    }
    
    @objc private func messageCell_denyAction(_ sender:UIButton) {
        let message_item = chat_array[sender.tag]
        deleteCorrespondenceOrDenyRequest(message_item.id ?? "", isDenyRequest: true)
    }
    
    private func imageMessageCell(at indexPath:IndexPath, images_item: New_GSMessageChatListDataImage, isOutgoingMessage:Bool) -> UITableViewCell {
        
        var cell_identifier = GSString.CellIdentifier.messageAlbumPhotoIncomingTableCell
        var bubble_image = GSMessagesViewController.incomingBubbleImage
        var bubble_color = UIColor(hexString: defaultTheme.MessageVC_normalMessage_incomingBG)
        
        if isOutgoingMessage {
            cell_identifier = GSString.CellIdentifier.messageAlbumPhotoOutgoingTableCell
            bubble_image = GSMessagesViewController.outgoingBubbleImage
            bubble_color = UIColor(hexString: defaultTheme.MessageVC_normalMessage_outgoingBG)
        }
        
        guard let cell = message_tableView.dequeueReusableCell(withIdentifier: cell_identifier) as? GSMessageImageTableCell else {
            return UITableViewCell()
        }
        let message = chat_array[indexPath.row]
        cell.time_lbl.text = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: message.at, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter) + " " + GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: message.at, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appTimeFormatter)

        cell.bubble_imgView.image = bubble_image
        cell.bubble_imgView.tintColor = bubble_color
        
        let image_link = images_item.name ?? ""
        let imgHeight : String = "&height=" + "\(0.5 * max(view.frame.size.height, view.frame.size.width))"
        let linkToLoad = APIurl.baseURL + APIurl.subURL.message_viewAlbum + image_link + imgHeight
        
        if removableCache_array == nil {
            removableCache_array = [String]()
        }
        if removableCache_array?.contains(linkToLoad) == false {
            removableCache_array?.append(linkToLoad)
        }
        
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        SDWebImageDownloader.shared.setValue(accessToken, forHTTPHeaderField: "Authorization")
        cell.product_imgView.sd_setImage(with: URL(string: linkToLoad), placeholderImage: #imageLiteral(resourceName: "blurImage"), options: .progressiveLoad) { (image, error, cache_type, url) in
            cell.product_imgView.image =  GSCommonHelper.cropToBounds(image: cell.product_imgView.image!, width: Double(cell.product_imgView.frame.width), height: Double(cell.product_imgView.frame.height))
        }
        
        cell.preview_btn.tag = indexPath.row
        cell.preview_btn.addTarget(self, action: #selector(previewImageAction(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - Image Actions
    
    @objc private func previewImageAction(_ sender:UIButton) {
        
        view.endEditing(true)
        
        let message = chat_array[sender.tag]
        
        guard let images_item = message.image else { return }
        let imageLink = images_item.name ?? ""
        
        if let previewVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSMessagesAlbumPhotoViewController) as? GSMessagesAlbumPhotoViewController {
            previewVC.imageLink = imageLink
            navigationController?.pushViewController(previewVC, animated: true)
        }
    }
}

// MARK: - API Methods

extension GSMessagesViewController {
    
    func getChatList() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.messages_chatList
        let parameters = ["category_id": categoryId,
                          "shop_id": store_id,
                          "order_id": idOfOrder,
                          "product_id": product_id] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:false) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(New_GSMessageChatListModel.self, from: responseData)
                    
                    if weakSelf.chat_array.count > 0 {
                        weakSelf.chat_array.removeAll()
                    }
                    
                    if let chatArrayObject = responseModel.data?.chat?.chat {
                        
                        weakSelf.chat_array = chatArrayObject
                        weakSelf.message_tableView.reloadData()
                        weakSelf.scrollToLastMessage()
                    }

                    weakSelf.updateTheUI(orderId: responseModel.data?.order ?? "", product: responseModel.data?.product, shopName: responseModel.data?.shop)
                    
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
    
    private func scrollToLastMessage() {
        DispatchQueue.main.async {
            let lastSectionIndex = self.message_tableView.numberOfSections - 1 // last section
            if lastSectionIndex < 0 { return }
            let lastRowIndex = self.message_tableView.numberOfRows(inSection: lastSectionIndex) - 1 // last row
            if lastRowIndex < 0 { return }
            self.message_tableView.scrollToRow(at: IndexPath(row: lastRowIndex, section: lastSectionIndex), at: .bottom, animated: false)
        }
    }
    
    
    fileprivate func updateCorrespondanse(selectedImage:UIImage?, isTemplate:Bool) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.updateCorrespondance
        
        var parameters = [ "category_id" : categoryId.data(using: .utf8) ?? Data(),
                           "shop_id" : store_id.data(using: .utf8) ?? Data(),
                           "order_id": idOfOrder.data(using: .utf8) ?? Data(),
                           "product_id" : product_id.data(using: .utf8) ?? Data()] as [String:Data]
        
        var imageValue_array = [Data]()
        var imageKey_array = [String]()
        
        if isTemplate {
            parameters["message"] = GSConstant.messageTemplate.data(using: .utf8) ?? Data()
            parameters["is_template"] = isTemplate.description.data(using: .utf8) ?? Data()
            
        } else if let unwrappedSeletedImage = selectedImage {
            imageValue_array.append(UIImageJPEGRepresentation(unwrappedSeletedImage, 0.5)!)
            imageKey_array.append("image")
            
        } else {
            parameters["message"] = chat_txtView.text.data(using: .utf8) ?? Data()
        }
        
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        let headers = ["Authorization": accessToken,
                       "Content-Type":"multipart/form-data"]
        
        
        APIHandler.multiPartNetworkRequestWith(method: .post, multiPartItems: imageValue_array, keyNames: imageKey_array, fileName: "test.doc", params: parameters, urlString: urlString, headers: headers, needToResignKeyboard: false) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSMessageSuccessSendingMessageModel.self, from: responseData)
                    
                    DispatchQueue.main.async {
                        weakSelf.chat_txtView.text = ""
                        if weakSelf.atachment_btn.isHidden {
                            UIView.animate(withDuration: 0.4) {
                                weakSelf.atachment_btn.isHidden = false
                                weakSelf.template_btn.isHidden = false
                            }
                        }
                        if weakSelf.toolbarHeight_constraint.constant != weakSelf.toolBarMin_height {
                            weakSelf.toolbarHeight_constraint.constant = weakSelf.toolBarMin_height
                        }
                    }
                    
                    if let chatObject = responseModel.data {
                        weakSelf.chat_array.append(chatObject)
                        weakSelf.message_tableView.reloadData()
                        weakSelf.scrollToLastMessage()
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
    
    fileprivate func deleteCorrespondenceOrDenyRequest(_ messageId:String, isDenyRequest:Bool) {
        
        var urlString = APIurl.baseURL + APIurl.subURL.deleteCorrespondence
        let parameters = ["category_id": categoryId,
                          "shop_id": store_id,
                          "order_id": idOfOrder,
                          "product_id": product_id,
                          "correspondence_id":messageId] as [String:AnyObject]
        
        
        
        if isDenyRequest {
            urlString = APIurl.baseURL + APIurl.subURL.denyTemplateRequest
        }
        
        APIHandler.NetworkSetupRequest(method: (isDenyRequest ? .post : .delete), params: parameters, urlString: urlString, withLoader:false) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSMessageSuccessSendingMessageModel.self, from: responseData)
                    
                    if let chatObject = responseModel.data {
                        weakSelf.chat_array[weakSelf.chat_array.count - 1] = chatObject
                        weakSelf.message_tableView.reloadData()
                        weakSelf.scrollToLastMessage()
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
    
    
    fileprivate func acceptTemplate(_ messageId:String) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.acceptTemplateRequest
        let parameters = ["category_id": categoryId,
                          "shop_id": store_id,
                          "order_id": idOfOrder,
                          "product_id": product_id,
                          "correspondence_id":messageId] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:false) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if responseModel.success == true {
                        
                        CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", alertButtonsArray: ["Ok"], viewController: weakSelf, completion: { _ in
                            weakSelf.navigationController?.popViewController(animated: true)
                        })
                        
                    } else {
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
    }  // API Method brace ends here.....
}

// MARK:- NavigationBar Methods

extension GSMessagesViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
        
        if let unwrappedRemovableCacheLink_array = removableCache_array, unwrappedRemovableCacheLink_array.count > 0 {
            for cacheLink in unwrappedRemovableCacheLink_array {
                SDImageCache.shared.removeImage(forKey: cacheLink, fromDisk: true, withCompletion: nil)
            }
        }
    }
    
    func rightBarBtnPressed(sender:UIButton) {
    }
}
