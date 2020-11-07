//
//  GSEditAddressPopUpView.swift
//  Shopor
//
//  Created by Ratheesh on 26/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

protocol GSEditAddressPopViewDelegate:class {
//    func saveAddressWith(street:String, area:String, landMark:String, zipCode:String, addressId:String?, type:String)
    func saveAddressWith(editAddressObj:GSEditAddressModel)
}

struct GSEditAddressModel {
    let street: String
    let area: String
    let landMark:String
    let zipcode: String
    let coordinates:[Double]
    let addressId: String?
    let type: String
}

class GSEditAddressPopUpView: NibView {
    
    @IBOutlet weak var detailedAddress_txtField:UITextField!
    @IBOutlet weak var detailAddress_txtView: UITextView!
    @IBOutlet weak var location_txtField:UITextField!
    @IBOutlet weak var landMark_txtField:UITextField!
    @IBOutlet weak var other_txtField:UITextField!
    @IBOutlet weak var zipCode_txtField:UITextField!
    @IBOutlet weak var homeNwork_stackView:UIStackView!
    
    @IBOutlet weak var txtViewHeight_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var detailedAddressTF_BG:UIView!
    @IBOutlet weak var locationTF_BG:UIView!
    @IBOutlet weak var landMarkTF_BG:UIView!
    @IBOutlet weak var zipcode_BG:UIView!
    @IBOutlet weak var zipcodeMainBG:UIView!
    @IBOutlet weak var otherTextfield_BG:UIView!
    @IBOutlet weak var addressTypeBG_view:UIView!
    
    @IBOutlet weak var home_btn:UIButton!
    @IBOutlet weak var work_btn:UIButton!
    @IBOutlet weak var others_btn:UIButton!
    
    @IBOutlet weak var cancel_btn:GSBaseButton!
    @IBOutlet weak var save_btn:GSBaseButton!
    
    @IBOutlet weak var header_lbl:GSBaseLabel!
    @IBOutlet weak var topSeparatorLine_view:UIView!
    @IBOutlet weak var bottomSeparatorLine_view:UIView!
    
    @IBOutlet weak var main_scrollView:UIScrollView!
    
    @IBOutlet weak var popUp_view:GSShadowView!
    
    var coordinate_array = [Double]()
    
    weak var delegate:GSEditAddressPopViewDelegate?
    
    var addressObject: GSViewProfileAddressObject?
    
    var selectedAddressType = ""
    var isEditAddress = false
    var isFromAddressConfirmation = false

    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    // MARK: - Configuring With Data
    
    func configureWith(street:String, area:String, landMark:String, zipCode:String?, coordinate:[Double]?, isAddressConfirmation:Bool) {
        
        header_lbl.text = "Add address"
        detailAddress_txtView.text = street
        
        location_txtField.text = area
        landMark_txtField.text = landMark
        self.isFromAddressConfirmation = isAddressConfirmation
        zipCode_txtField.text = zipCode ?? ""
        
        setTextViewHeightBasedOnContent()
        
        coordinate_array = coordinate ?? [Double]()
    }
    
    // MARK: - Configuring with Address Object for editing purpose from profile view.
    
    func configureWith(addressObj: GSViewProfileAddressObject) {
        
        isEditAddress = true
        self.addressObject = addressObj
        header_lbl.text = "Edit address"
        
        detailAddress_txtView.text = addressObj.address?.street ?? ""
        location_txtField.text = addressObj.address?.area
        landMark_txtField.text = addressObj.address?.landmark ?? ""
        zipCode_txtField.text = ""
        
        setTextViewHeightBasedOnContent()
        
        if let unwrappedZipCode = addressObj.address?.zipcode, unwrappedZipCode != 0 {
            zipCode_txtField.text = "\(unwrappedZipCode)"
        }

        coordinate_array = addressObj.location?.coordinates ?? [Double]()
        
        let address_type = addressObj.type ?? "Home"
        
        switch address_type {
        case "Home":
            home_btn.sendActions(for: .touchUpInside)
            work_btn.isHidden = true
            others_btn.isHidden = true
            break
        case "Work":
            work_btn.sendActions(for: .touchUpInside)
            home_btn.isHidden = true
            others_btn.isHidden = true
            break
        default:
            others_btn.sendActions(for: .touchUpInside)
            selectedAddressType = address_type
            other_txtField.text = address_type
            other_txtField.isUserInteractionEnabled = false
            home_btn.isHidden = true
            work_btn.isHidden = true
            others_btn.isUserInteractionEnabled = false
            break
        }
    }
    
    
    func setTextViewHeightBasedOnContent() {
        
        let currentHeight = txtViewHeight_constraint.constant
        let currentViewHeightWithOutTxtView = popUp_view.frame.size.height - currentHeight
        
        let someSpaceToLeave: CGFloat = 100.0
        let contentHeight = detailAddress_txtView.contentSize.height
        
        let totalRequiredHeight = currentViewHeightWithOutTxtView + contentHeight
        let totalViewHeight = GSTopViewController.topViewController().view.frame.size.height
        
        if totalRequiredHeight + someSpaceToLeave < totalViewHeight {
            txtViewHeight_constraint.constant = contentHeight
        } else {
            txtViewHeight_constraint.constant = totalViewHeight - currentViewHeightWithOutTxtView - someSpaceToLeave
        }
    }
    
    // MARK: - KeyBoard Notification
    
    fileprivate func addKeyBoardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardDidShow(notification: Notification) {
        
        return
        
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//
//            let lastOffsetPoint = popUp_view.frame.origin.y + popUp_view.frame.size.height + frame.origin.y
//
//            #if DEBUG
//            print("Last Offset Point = \(lastOffsetPoint)")
//            #endif
//
//            let keyboardOriginYonView = keyboardSize.origin.y
//
//            #if DEBUG
//            print("Key Board Origin Y = \(keyboardOriginYonView)")
//            #endif
//
//            if lastOffsetPoint > keyboardOriginYonView {
//            let remainingBottomSpaceHeight = frame.size.height - lastOffsetPoint
//            let offsetToMove = keyboardSize.height - remainingBottomSpaceHeight
//            main_scrollView.setContentOffset(CGPoint(x: 0, y: offsetToMove), animated: true)
//            }
//        }
    }
    
    @objc private func keyboardDidHide(notification: Notification) {
        
        main_scrollView.contentSize = CGSize(width: main_scrollView.frame.size.width, height: popUp_view.frame.origin.y + popUp_view.frame.size.height)
    }
    
    // MARK: - Setting Up This View
    
    private func setUpThisView() {
        applyColorsForUI()
        
        otherTextfield_BG.isHidden = true
        main_scrollView.contentSize = CGSize(width: main_scrollView.frame.size.width, height: popUp_view.frame.origin.y + popUp_view.frame.size.height)
        main_scrollView.delegate = self
        detailAddress_txtView.delegate = self
        
        zipCode_txtField.delegate = self
        
        let homeIcon = UIImage(named: "editAddressTypeHome_icon")?.withRenderingMode(.alwaysTemplate)
        let workIcon = UIImage(named: "editAddressTypeWork_icon")?.withRenderingMode(.alwaysTemplate)
        
        home_btn.setImage(homeIcon, for: .normal)
        work_btn.setImage(workIcon, for: .normal)
        
        main_scrollView.contentSize = CGSize.zero
        
        location_txtField.isUserInteractionEnabled = false
//        addKeyBoardNotifications()
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
    
    // MARK: - Adding Colors for UI
    
    private func applyColorsForUI() {
        
        for txtFieldBg in [detailedAddressTF_BG, locationTF_BG, landMarkTF_BG, zipcode_BG, otherTextfield_BG] {
            txtFieldBg?.backgroundColor = UIColor(hexString: defaultTheme.EditAddressView_txtField_BG)
        }
        header_lbl.textColor = UIColor(hexString: defaultTheme.EditAddressView_header_lbl)
        
        for separator in [topSeparatorLine_view, bottomSeparatorLine_view] {
            separator?.backgroundColor = UIColor(hexString: defaultTheme.EditAddressView_separatorLine)
        }
        
        for addressTypeBtn in [home_btn, others_btn, work_btn] {
            addressTypeBtn?.setTitleColor(UIColor(hexString: defaultTheme.EditAddressView_addressType_normal_title), for: .normal)
            addressTypeBtn?.setTitleColor(UIColor(hexString: defaultTheme.EditAddressView_addressType_selected), for: .selected)
        }
        
        changeTintColorsForButtons()
        
        // By default home is selected
        
//        home_btn.sendActions(for: .touchUpInside)
//        home_btn.setTitleColor(UIColor(hexString: defaultTheme.EditAddressView_addressType_selected), for: .normal)
        
        cancel_btn.layer.borderColor = UIColor(hexString: defaultTheme.EditAddressView_cancel_btn_border).cgColor
        cancel_btn.setTitleColor(UIColor(hexString: defaultTheme.EditAddressView_cancel_btn_title), for: .normal)
        
        save_btn.layer.borderColor = UIColor(hexString: defaultTheme.EditAddressView_save_btn_title).cgColor
        save_btn.backgroundColor = UIColor(hexString: defaultTheme.EditAddressView_save_btn_bg)
    }
    
    // MARK: - Action Methods
    @IBAction private func closeThisView(_ sender:UIButton) {
        removeThisViewWithAnimation()
    }
    
    // MARK: - Address Type Action Methods
    @IBAction private func homeAction(_ sender:UIButton) {
        sender.isSelected = true
        selectedAddressType = "Home"
        work_btn.isSelected = false
        others_btn.isSelected = false
        changeTintColorsForButtons()
    }
    
    @IBAction private func workAction(_ sender:UIButton) {
        sender.isSelected = true
        selectedAddressType = "Work"
        home_btn.isSelected = false
        others_btn.isSelected = false
        changeTintColorsForButtons()
    }
    
    @IBAction private func othersAction(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        
        otherTextfield_BG.isHidden = !sender.isSelected
        homeNwork_stackView.isHidden = sender.isSelected
        selectedAddressType = ""
        
        home_btn.isSelected = false
        work_btn.isSelected = false
        
        if !sender.isSelected {
            home_btn.sendActions(for: .touchUpInside)
        }
        changeTintColorsForButtons()
    }
    
    private func changeTintColorsForButtons() {
        home_btn.tintColor = UIColor(hexString: defaultTheme.EditAddressView_addressType_normal_title)
        work_btn.tintColor = UIColor(hexString: defaultTheme.EditAddressView_addressType_normal_title)
        others_btn.tintColor = UIColor(hexString: defaultTheme.EditAddressView_addressType_normal_title)
        
        if home_btn.isSelected {
            home_btn.tintColor = UIColor(hexString: defaultTheme.EditAddressView_addressType_selected)
            
        } else if work_btn.isSelected {
            work_btn.tintColor = UIColor(hexString: defaultTheme.EditAddressView_addressType_selected)
            
        } else if others_btn.isSelected {
            others_btn.tintColor = UIColor(hexString: defaultTheme.EditAddressView_addressType_selected)
        }
    }
    
    // MARK: - Other Action Methods
    @IBAction private func saveAction(_ sender:UIButton) {
        
        let topViewController = GSTopViewController.topViewController()
        
        if detailAddress_txtView.text == "" {
            CustomAlert.showAlert(title: GSString.AppName, message: "Detailed address cannot be empty", viewController: topViewController)
            return
        }
        
        for tf in [/*detailedAddress_txtField,*/ location_txtField, landMark_txtField, zipCode_txtField] {
            
            let text = tf?.text ?? ""
            
            if tf == zipCode_txtField {
                // Just check whether zipcode is present or not
                
                if zipCode_txtField.isHidden {
                    continue
                } else if text == "" {
                    CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.enterZipcode, viewController: topViewController)
                    return
                } else if !((zipCode_txtField.text ?? "").validZipCode()) {
                    CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.invalidZipcode, viewController: topViewController)
                    return
                } 
            } else if tf == landMark_txtField {
                continue            // Optional
            }
            
            if text == "" {
                let message = (tf?.placeholder ?? "One of text fields") + " " + "cannot be empty"
                CustomAlert.showAlert(title: GSString.AppName, message: message, viewController: topViewController)
                return
            }
        }
        
        if others_btn.isSelected && other_txtField.text == "" {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.addressType, viewController: topViewController)
            return
        } else if others_btn.isSelected {
            selectedAddressType = other_txtField.text ?? ""
        }
        
        if isFromAddressConfirmation && selectedAddressType == "" {

            // Will save the address locally as no address category is selected
            let editAddressObj = GSEditAddressModel(street: detailAddress_txtView.text ?? "", area: location_txtField.text ?? "", landMark: landMark_txtField.text ?? "", zipcode: zipCode_txtField.text ?? "", coordinates: coordinate_array, addressId: nil, type: "")
            delegate?.saveAddressWith(editAddressObj: editAddressObj)
            self.removeThisViewWithAnimation()
            return
        }
        
        if selectedAddressType == "" {
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.emptyAddressType, viewController: topViewController)
            return
        }
        
        addAddressAPI(street: detailAddress_txtView.text ?? "", area: location_txtField.text ?? "", landMark: landMark_txtField.text ?? "", zipCode: zipCode_txtField.text ?? "", type: selectedAddressType)
    }
    
    @IBAction private func editDetailedAddressAction(_ sender:UIButton) {
    }
    
    @IBAction private func editLocationAction(_ sender:UIButton) {
    }
    
    @IBAction private func editLandMarkAction(_ sender:UIButton) {
    }
    
    // MARK: - User Defined Methods
    fileprivate func removeThisViewWithAnimation() {
        if let unwrappedSuperView = superview {
            removeTheViewFrom(view: unwrappedSuperView)
        }
    }
}

// MARK: - UITextView Delegate Methods
extension GSEditAddressPopUpView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        setTextViewHeightBasedOnContent()
    }
}

// MARK: - UITextField Delegate Methods
extension GSEditAddressPopUpView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "" {
            return true
        }
        
        if textField == zipCode_txtField {
            
            let validCharacters = GSConstant.numericCharacters
            
            if (textField.text?.count ?? 0) < GSConstant.pincodeMaxAllowedCharacters, validCharacters.contains(string) == true {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
}

// MARK: - API Methods

extension GSEditAddressPopUpView {
    
    fileprivate func addAddressAPI(street:String, area:String, landMark:String, zipCode:String, type:String) {
        
        let urlString = isEditAddress ? APIurl.baseURL + APIurl.subURL.editSavedAddress : APIurl.baseURL + APIurl.subURL.addAddressToProfile
        
        if coordinate_array.count < 2 {
            return
        }
        
        let lattitude = coordinate_array[1]
        let longitude = coordinate_array[0]
        
        let localStreet = street

        var params = [String:AnyObject]()
        var address_object = ["street": localStreet.removeEnclosedWhieteSpace(),
                              "area": area,
                              "zipcode": zipCode] as [String:AnyObject]
        
        if landMark != "" {
            address_object["landmark"] = landMark as AnyObject
        }
        
        if isEditAddress {
            
            params = ["id": addressObject?.id ?? "",
                      "deliveryAddress": ["location": ["type": "Point",
                                                       "coordinates": [longitude,lattitude]],
                                          "address": address_object,
                                          "is_default": addressObject?.isDefault ?? false,
                                          "type": type]] as [String:AnyObject]
            
        } else {
            params = ["deliveryAddress": ["location": ["type": "Point",
                                                       "coordinates": [longitude,lattitude]],
                                          "address": address_object,
                                          "is_default": false,
                                          "type": type]] as [String:AnyObject]
        }
        
        
        let topVC = GSTopViewController.topViewController()
        
        APIHandler.NetworkSetupRequest(method: .post, params: params,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSAddAddressModel.self, from: responseData)
                    
                    let status = responseModel.success ?? false
                    
                    if status {
                        
                        let editAddressObj = GSEditAddressModel(street: street, area: area, landMark: landMark, zipcode: zipCode, coordinates: weakSelf.coordinate_array, addressId: responseModel.id, type: type)
                        
//                        weakSelf.delegate?.saveAddressWith(street: street, area: area, landMark: landMark, zipCode: zipCode, addressId: responseModel.id, type: type)
                        weakSelf.delegate?.saveAddressWith(editAddressObj: editAddressObj)
                        
                        weakSelf.removeThisViewWithAnimation()
                    } else {
                        CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: topVC)
                    }
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: topVC)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? GSString.API.unknownError, viewController: topVC)
            }
        }
    }
}

// MARK: - UIScrollView Delegate Methods

extension GSEditAddressPopUpView:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let lastOffsetPoint = popUp_view.frame.origin.y + popUp_view.frame.size.height
//        main_scrollView.contentSize = CGSize(width: main_scrollView.frame.size.width, height: lastOffsetPoint)
    }
}
