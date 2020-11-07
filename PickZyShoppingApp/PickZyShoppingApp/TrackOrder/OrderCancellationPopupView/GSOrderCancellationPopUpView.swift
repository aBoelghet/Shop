//
//  GSOrderConcellationPopUpView.swift
//  Shopor
//
//  Created by Ratheesh on 29/03/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

protocol GSOrderConcellationPopUpViewDelegate:class {
    func cancelOrderResponse(isCancelled:Bool,message:String)
}

class GSOrderCancellationPopUpView: NibView {
    
    @IBOutlet weak var cancellationPopUp_tableView:UITableView!
    @IBOutlet weak var header_lbl:GSBaseLabel!
    @IBOutlet weak var top_constraint:NSLayoutConstraint!
    @IBOutlet weak var popupViewHeight_constraint:NSLayoutConstraint!
    @IBOutlet weak var main_scrollView:UIScrollView!
    @IBOutlet weak var popup_view:UIView!
    @IBOutlet weak var cancelRefundPopup_view: UIView!
    @IBOutlet weak var refundToBayfay_btn: GSBaseButton!
    @IBOutlet weak var refundToBank_btn: GSBaseButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var selectedIndex = -1
    
    weak var delegate:GSOrderConcellationPopUpViewDelegate?
    
    var orderId_array = [String]()
    var isEscalatedOrder = false
    var selectedTitle = ""
    var cancelMessage = ""
    
    var cancelTitles_array = [String]()
    
    let normalCellHeight:CGFloat = 44
    let feedBackCellHeight:CGFloat = 150
    
    var totalParentViewHeight:CGFloat = 0
    
    var isPaidOrder = false
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setting up this View
    
    private func setUpThisView() {
        applyColorsForUI()
        
        let radioButtonCell = UINib(nibName: GSString.NibNames.GSRadioButtonTableCell , bundle: nil)
        cancellationPopUp_tableView.register(radioButtonCell, forCellReuseIdentifier: GSString.CellIdentifier.cancelOrderPopup_radioBtnTableViewCell)
        let feedbackCell = UINib(nibName: GSString.NibNames.GSCancellationTextViewTableCell, bundle: nil)
        cancellationPopUp_tableView.register(feedbackCell, forCellReuseIdentifier: GSString.CellIdentifier.cancelOrderPopup_feedbackTableViewCell)
        
        cancellationPopUp_tableView.delegate = self
        cancellationPopUp_tableView.dataSource = self
        
        cancellationPopUp_tableView.estimatedRowHeight = 44.0
        
        header_lbl.text = GSConstant.AlertMessages.cancelOrderPopUpHeader
        
        addKeyBoardNotifications()
        
        cancelRefundPopup_view.isHidden = true
    }
    
    fileprivate func addKeyBoardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardDidShow(notification: Notification) {
        
        if popupViewHeight_constraint.constant == totalParentViewHeight {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let lastOffsetPoint = popup_view.frame.origin.y + popup_view.frame.size.height + frame.origin.y
            
            #if DEBUG
            print("Last Offset Point = \(lastOffsetPoint)")
            #endif
            
            let keyboardOriginYonView = keyboardSize.origin.y
            
            #if DEBUG
            print("Key Board Origin Y = \(keyboardOriginYonView)")
            #endif
            
            if lastOffsetPoint > keyboardOriginYonView {
                let remainingBottomSpaceHeight = frame.size.height - lastOffsetPoint
                let offsetToMove = keyboardSize.height - remainingBottomSpaceHeight
//                main_scrollView.contentSize = CGSize(width: 0, height: main_scrollView.frame.size.height + offsetToMove)
                main_scrollView.contentSize = CGSize(width: 0, height: popup_view.frame.size.height + popup_view.frame.origin.y)
                main_scrollView.setContentOffset(CGPoint(x: 0, y: offsetToMove), animated: true)
            }
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification) {
        
        if popupViewHeight_constraint.constant == totalParentViewHeight {
            return
        }
        main_scrollView.contentSize = CGSize(width: main_scrollView.frame.size.width, height: 0)
    }
    
    func addConstraintsAndShow(on parentView:UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: parentView.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        
        self.top_constraint.constant = parentView.frame.size.height
        self.layoutIfNeeded()
        self.top_constraint.constant = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            self.layoutIfNeeded()
        }) { _ in
            self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
        
        cancellationTitlesAPI()
    }
    
    fileprivate func updateThePopupViewHeight() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let parentView = superview else { return }
        
        let topLayoutGuide = appDelegate.topSafeAreaInset
        let bottomLayoutGuide = appDelegate.bottomSafeAreaInset
        
        let constantHeightAboveTable = cancellationPopUp_tableView.frame.origin.y
        let tableContentHeight = cancellationPopUp_tableView.contentSize.height
        
        let totalEstmatedPopupHeight = constantHeightAboveTable + tableContentHeight
        totalParentViewHeight = parentView.frame.size.height - topLayoutGuide - bottomLayoutGuide
        
        if totalEstmatedPopupHeight > totalParentViewHeight {
            cancellationPopUp_tableView.isScrollEnabled = true
            popupViewHeight_constraint.constant = totalParentViewHeight
            
        } else {
            
            cancellationPopUp_tableView.isScrollEnabled = false
            let heightReq = (CGFloat(cancelTitles_array.count) * normalCellHeight) + feedBackCellHeight + constantHeightAboveTable
            popupViewHeight_constraint.constant = heightReq
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Configuring with Data
    
    func configureCancellPopupWith(orderIdArray:[String], isEscalated:Bool) {
        
        self.orderId_array = orderIdArray
        self.isEscalatedOrder = isEscalated
    }
    
    // MARK: - Applying Colors
    
    private func applyColorsForUI() {
        header_lbl.textColor = UIColor(hexString: defaultTheme.GSOrderCancellationPopUpView_headerText)
    }
    @IBAction func refundToBayfayCash(_ sender: UIButton) {
        
        cancelOrderAPI(cancelBtn: [refundToBayfay_btn, refundToBank_btn], btnOriginalColors: [UIColor(hexString: "57A4E5"), UIColor.red], toBayFayCash: true)
    }
    @IBAction func refundToBank(_ sender: UIButton) {
        cancelOrderAPI(cancelBtn: [refundToBayfay_btn, refundToBank_btn], btnOriginalColors: [UIColor(hexString: "57A4E5"), UIColor.red], toBayFayCash: false)
    }
    @IBAction func closeButtonAction(_ sender: Any) {
        
         self.removeFromSuperview()
    }
    
    
}

// MARK: - UITableView Methods

extension GSOrderCancellationPopUpView:UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cancelTitles_array.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < cancelTitles_array.count {
            return radioButtonCell(at: indexPath)
        } else {
            return feedBackCell(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < cancelTitles_array.count {
            selectedIndex = indexPath.row
            selectedTitle = cancelTitles_array[indexPath.row]
            tableView.reloadData()
        }
    }
    
    // MARK: - Creating Cells
    
    private func radioButtonCell(at indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = cancellationPopUp_tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.cancelOrderPopup_radioBtnTableViewCell) as? GSRadioButtonTableCell else {
            return UITableViewCell()
        }
        
        cell.icon_imgView.image = #imageLiteral(resourceName: "Radio_off")
        
        if indexPath.row == selectedIndex {
            cell.icon_imgView.image = #imageLiteral(resourceName: "Radio_on")
        }
        
        let itemAtIndex = cancelTitles_array[indexPath.row]
        let formattedString = itemAtIndex.replacingOccurrences(of: "_", with: " ").capitalized(with: Locale.current)
        
        cell.cell_lbl.text = formattedString
        return cell
    }
    
    private func feedBackCell(at indexPath:IndexPath) -> UITableViewCell {
        
        guard let cell = cancellationPopUp_tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.cancelOrderPopup_feedbackTableViewCell) as? GSCancellationTextViewTableCell else {
            return UITableViewCell()
        }
        
        cell.no_btn.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        cell.cancelOrder_Btn.addTarget(self, action: #selector(cancelOrderAction(_:)), for: .touchUpInside)
        
        cell.feedback_txtView.delegate = self
        
        return cell
    }
    
    // MARK: - Cell Button Actions
    
    @objc private func cancelOrderAction(_ sender:UIButton) {
        
        if selectedIndex != -1 {
            
            if isPaidOrder, isEscalatedOrder == false {
                self.view .endEditing(true)
                popup_view.isHidden = true
                cancelRefundPopup_view.isHidden = false
            } else {
                cancelOrderAPI(cancelBtn: [sender], btnOriginalColors: [UIColor(hexString: defaultTheme.GSOrderCancellationPopUpView_cell_btn_title)], toBayFayCash: nil)
            }
            
        } else {
            
            if cancelTitles_array.count == 0 {
                CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.cancelOrderFailed, alertButtonsArray: ["Cancel", "Retry"], viewController: GSTopViewController.topViewController()) { btnIndex in
                    
                    if btnIndex == 1 {
                        self.cancellationTitlesAPI()
                    }
                }
            } else {
                delegate?.cancelOrderResponse(isCancelled: false, message: GSConstant.AlertMessages.selectAnyCancellationReason)
            }
        }
    }
    
    @objc private func closeAction(_ sender:UIButton) {
        
        if let theSuperView = superview {
            
            self.top_constraint.constant = theSuperView.frame.size.height
            backgroundColor = UIColor.clear
            
            UIView.animate(withDuration: 0.4, animations: {
                self.layoutIfNeeded()
            }) { _ in
                
                self.removeFromSuperview()
            }
        }
    }
}

// MARK: - UITextViewDelegate Methods

extension GSOrderCancellationPopUpView:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        cancelMessage = textView.text ?? ""
    }
}

// MARK: - API Methods

extension GSOrderCancellationPopUpView {
    
    fileprivate func cancellationTitlesAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.cancelOrderTitles
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCancelOrderTitlesModel.self, from: responseData)
                    
                    if weakSelf.cancelTitles_array.count > 0 {
                        weakSelf.cancelTitles_array.removeAll()
                    }
                    
                    if let titlesArray = responseModel.data?.titles {
                        weakSelf.cancelTitles_array = titlesArray
                        weakSelf.cancellationPopUp_tableView.reloadData()
//                        weakSelf.cancellationPopUp_tableView.layoutIfNeeded()
//                        DispatchQueue.main.async {
//                            weakSelf.updateThePopupViewHeight()
//                        }
                        
                        
                        DispatchQueue.main.async(execute: {
                            weakSelf.updateThePopupViewHeight()
                            
                        })
                    }
                    
                } catch {
                    print(error)
                    weakSelf.delegate?.cancelOrderResponse(isCancelled: false, message: error.localizedDescription)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                weakSelf.delegate?.cancelOrderResponse(isCancelled: false, message: error?.localizedDescription ?? GSString.API.unknownError)
            }
            
        }
    }
    
    fileprivate func cancelOrderAPI(cancelBtn:[UIButton], btnOriginalColors: [UIColor], toBayFayCash: Bool?) {
        
        endEditing(true)
        
        var urlString = ""
        
        var parameters = [ "title": selectedTitle,
                           "order_id": orderId_array] as [String:AnyObject]
        
        if isEscalatedOrder {
            urlString = APIurl.baseURL + APIurl.subURL.cancelEscalatedOrders
        } else {
            urlString = APIurl.baseURL + APIurl.subURL.cancelOrder
        }
        
        if cancelMessage != "" {
            parameters["message"] = cancelMessage as AnyObject
        }
        
        if let refundToBayFayCash = toBayFayCash {
            parameters["to_bfCash"] = refundToBayFayCash as AnyObject
        }
        
        for index in 0..<cancelBtn.count {
            cancelBtn[index].setTitleColor(UIColor.lightGray, for: .normal)
            cancelBtn[index].isUserInteractionEnabled = false
        }
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            DispatchQueue.main.async {
                
                for index in 0..<cancelBtn.count {
                    cancelBtn[index].setTitleColor(btnOriginalColors[index], for: .normal)
                    cancelBtn[index].isUserInteractionEnabled = true
                }
            }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if responseModel.success == true {
                        
                        weakSelf.removeFromSuperview()
                        weakSelf.delegate?.cancelOrderResponse(isCancelled: true, message: responseModel.message ?? "")
                        
                    } else {
                        weakSelf.delegate?.cancelOrderResponse(isCancelled: false, message: responseModel.message ?? "")
                    }
                    
                    
                } catch {
                    print(error)
                    weakSelf.delegate?.cancelOrderResponse(isCancelled: false, message: error.localizedDescription)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                weakSelf.delegate?.cancelOrderResponse(isCancelled: false, message: error?.localizedDescription ?? GSString.API.unknownError)
            }
            
        }
    }
    
}


// MARK: - Models Class

struct GSCancelOrderTitlesModel: Codable {
    let success: Bool?
    let data: GSCancelOrderTitlesData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSCancelOrderTitlesData: Codable {
    let titles: [String]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        titles = values.decodeSafely(.titles)
    }
}


