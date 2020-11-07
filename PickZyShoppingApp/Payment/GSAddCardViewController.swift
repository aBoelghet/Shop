//
//  GSAddCardViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ratheesh on 3/31/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SDWebImage
import PayU_coreSDK_Swift
import MKToolTip

class GSAddCardViewController: GSPaymentViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var cardnumberTxtField:UITextField!
    @IBOutlet weak var expDateTxtField:UITextField!
    @IBOutlet weak var cvvTxtField:UITextField!
    @IBOutlet weak var countryName_lbl:UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var scrollView :UIScrollView!
    @IBOutlet weak var selCountry_imageView:UIImageView!
    @IBOutlet weak var saveBtnBottom :NSLayoutConstraint!
    
    @IBOutlet weak var header_lbl:GSBaseLabel!
    @IBOutlet weak var saveCardSelection_imgView: UIImageView!
    @IBOutlet weak var saveCardBG_view: UIView!
    @IBOutlet weak var camera_btn: UIButton!
    
    @IBOutlet weak var card_imgView:UIImageView!
    
    var paymentParams = PayUModelPaymentParams()
    let paymentRequest = PayUCreateRequest()
    
    var paymentParamHelper  = GSPaymentParametersHelper()
    
    let paymentWebService   = PayUWebService()
    
    var isSavedCard : Bool = false
    var currentTxtField : UITextField? = nil
    var onTap = Bool()
    
    var isGoingToOrder = false
    var isSaveThisCardSelected = true
    
    var toolTip:MKToolTip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFewIntializers()
        applyColors()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: User defined Methods
    override func viewWillAppear(_ animated: Bool) {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(TapGestureAction))
        tapGesture.delegate = self
        scrollView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: .UITextFieldTextDidChange, object: cardnumberTxtField)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: .UITextFieldTextDidChange, object: expDateTxtField)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: .UITextFieldTextDidChange, object: cvvTxtField)
        
        if isSavedCard == true {
            
            camera_btn.isHidden = true
            saveCardBG_view.isHidden = true
            cardnumberTxtField.text = paymentParams.cardNumber
            let expiryYear = paymentParams.expiryYear!
//            expDateTxtField.text    = paymentParams.expiryMonth! + "/" + expiryYear.substring(from:expiryYear.index(expiryYear.endIndex, offsetBy: -2))
            expDateTxtField.text    = paymentParams.expiryMonth! + "/" + expiryYear[expiryYear.index(expiryYear.endIndex, offsetBy: -2)...]
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        
        scrollView.contentSize = CGSize.init(width: self.view.frame.size.width, height: self.nextBtn.frame.origin.x + self.nextBtn.frame.size.height + 20)
    }
    
    func addFewIntializers() {
        
        navigationBarView.delegate = self
        

        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        
        if isGoingToOrder {
            saveCardBG_view.isHidden = false
            nextBtn.setTitle("Make Order", for: .normal)
            navigationBarView.titleText = "Make Order"
        } else {
            saveCardBG_view.isHidden = true
            nextBtn.setTitle("SAVE", for: .normal)
            navigationBarView.titleText = "Add Card"
        }
        
        if !isSaveThisCardSelected {
            saveCardSelection_imgView.image = #imageLiteral(resourceName: "Uncheck_icon")
        } else {
            saveCardSelection_imgView.image = #imageLiteral(resourceName: "Check_icon")
        }
        
        nextBtn.isUserInteractionEnabled = false
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        let tfArray = [cardnumberTxtField,expDateTxtField,cvvTxtField]
        
        for tf in tfArray {
            tf?.textColor = UIColor(hexString: defaultTheme.addNewCard_textField_text)
            tf?.setValue(UIColor(hexString: defaultTheme.addNewCard_placeHolder), forKeyPath: "placeholderLabel.textColor")
        }
        header_lbl.textColor = UIColor(hexString: defaultTheme.addNewCard_header_text)
        countryName_lbl.textColor = UIColor(hexString: defaultTheme.addNewCard_country_title)
        nextBtn.backgroundColor = UIColor(hexString: defaultTheme.AddCardVC_saveButton_NoInteraction_BG)
    }
    
    //MARK: - KeyBoardWillShow And KeyBoardWillHide Methods
    @objc func keyBoardWillShow(notification:NSNotification) -> Void {
        
        let info = notification.userInfo
        let keyboardSize = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardSize.height
        print("KeyBoardHeightWillShow ---- \(keyboardHeight)")
        
        scrollView.contentSize = CGSize(width: 0, height: saveCardBG_view.frame.origin.y + saveCardBG_view.frame.size.height - keyboardHeight)
        
        self.saveBtnBottom.constant = keyboardHeight
        UIView.animate(withDuration: 6) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyBoardWillHide(notification:NSNotification) -> Void {
        
        //        let info = notification.userInfo
        //        let keyboardSize = (info![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        //        let keyboardHeight = keyboardSize.height
        //        print("KeyBoardHeightWillHide ---- \(keyboardHeight)")
        //
        
        self.saveBtnBottom.constant = 0
        scrollView.contentSize = CGSize(width: 0, height: saveCardBG_view.frame.origin.y + saveCardBG_view.frame.size.height)

        UIView.animate(withDuration: 6) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: Button Actions
    @IBAction func SaveButtonPressed(_ sender: UIButton) {

        view.endEditing(true)
        sendCardInfoToServer()
    }
    
    @IBAction func addCountry_Action(_ sender:UIButton) {
        
        if let countryListVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSCountryViewController) as? GSCountryViewController {
            countryListVC.delegate = self
            GSCustomPushPop.doCustomPush(from: self, to: countryListVC)
        }
    }
    
    @IBAction func saveTheCardAction(_ sender: UIButton) {
        
        if isSaveThisCardSelected {
            saveCardSelection_imgView.image = #imageLiteral(resourceName: "Uncheck_icon")
        } else {
            saveCardSelection_imgView.image = #imageLiteral(resourceName: "Check_icon")
        }
        isSaveThisCardSelected = !isSaveThisCardSelected
    }
    
    @IBAction func cameraBtn_action(_ sender: UIButton) {
        
    }
    
    @IBAction func expiryDateInfoAction(_ sender: UIButton) {
        addTooltip(sender, message: GSConstant.ToolTip.toolTip_addCard_expiryDate, title: "", arrowPosition: .bottom)
    }
    
    @IBAction func cvvInfoAction(_ sender: UIButton) {
        addTooltip(sender, message: GSConstant.ToolTip.toolTip_addCard_cvv, title: "", arrowPosition: .bottom)
    }
    
    @objc func TapGestureAction(){
        
        onTap = true
        if currentTxtField != nil {
            currentTxtField?.resignFirstResponder()
        }
    }
    
    func sendCardInfoToServer() {
        // Card No: 4012001037141112 / "5123456789012346" // "4012001037141112" // 5100018609086541 / 01/20
        // Exp:12/2020
        // CVV:123
        //        5100013960913581
        //        01/2020
        //        123-cvv
        //        https://help.payu.co.za/display/developers/Test+Credentials

        self.paymentParams.cardNumber = cardnumberTxtField.text
        self.paymentParams.expiryMonth = expDateTxtField.text?.components(separatedBy: "/").first
        self.paymentParams.expiryYear =  "20" + (expDateTxtField.text?.components(separatedBy: "/").last)!

        self.paymentParams.CVV = cvvTxtField.text

        if isSaveThisCardSelected || !isGoingToOrder {
            paymentParams.storeCardName = paymentParams.firstName
        }
        
        paymentRequest.createRequest(withPaymentParam: paymentParams, forPaymentType: PAYMENT_PG_CCDC) { (request, error) in
            
            if (error == "") {
                
                DispatchQueue.main.async {
                    if let paymentWebVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPaymentWebViewController) as? GSPaymentWebViewController {
                        paymentWebVC.paymentRequest = request as URLRequest
                        paymentWebVC.isVerifyCard = !self.isGoingToOrder
                        if let navigator = self.navigationController {
                            navigator.pushViewController(paymentWebVC, animated: true)
                        }
                    }
                }
            } else {
                CustomAlert.showAlert(title: "oops !", message: error as String, viewController: self)
            }
        }
    }
    
    // MARK: - UITexfield Notification - Text Did Change
    @objc func textDidChange(_ notification:Notification) {
        
        let cardNumber = cardnumberTxtField.text ?? ""
        let expDate = expDateTxtField.text ?? ""
        let cvv = cvvTxtField.text ?? ""
        
        nextBtn.isUserInteractionEnabled = false
        nextBtn.backgroundColor = UIColor(hexString: defaultTheme.AddCardVC_saveButton_NoInteraction_BG)
        
        if let textField = notification.object as? UITextField, textField == cardnumberTxtField, cardNumber.count == 16 {
            expDateTxtField.becomeFirstResponder()
        } else if let textField = notification.object as? UITextField, textField == expDateTxtField, expDate.count == 5 {
            cvvTxtField.becomeFirstResponder()
        }
        
        setCardImage(cardNo: cardNumber)
        
        if cardNumber.count != 16 || expDate.count != 5 || cvv.count != 3 {
            return
        }
        
        nextBtn.isUserInteractionEnabled = true
        nextBtn.backgroundColor = UIColor(hexString: defaultTheme.AddCardVC_saveButton_withInteraction_BG)
        
    }
    
    private func setCardImage(cardNo:String) {
        
        let typeOfCard = validateCardType(testCard: cardNo)
        
        var cardImage = #imageLiteral(resourceName: "Card")
        
        switch typeOfCard {
        case .Visa:
            
            cardImage = #imageLiteral(resourceName: "visa_icon")
            break
            
        case .MasterCard:
            
            cardImage = #imageLiteral(resourceName: "masterCard_icon")
            break
            
        case .Maestro:
            
            cardImage = #imageLiteral(resourceName: "maestroCard_icon")
            break
            
        case .DinersClub:
            
            cardImage = #imageLiteral(resourceName: "dinerCard_icon")
            break
            
        case .AmericanExpress:
            
            cardImage = #imageLiteral(resourceName: "amexCard_icon")
            break
        default:
            break
        }
        
        card_imgView.image = cardImage
    }
    
    func validateCardType(testCard: String) -> CreditCardType {
        
        let regVisa = "^4[0-9]{6,}$" //"^4[0-9]{12}(?:[0-9]{3})?$"
        let regMaster = "^5[1-5][0-9]{5,}$" //"^5[1-5][0-9]{14}$"
        let regExpress = "^3[47][0-9]{13}$" //"^3[47][0-9]{13}$"
        let regDiners = "^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
        let regDiscover = "^6(?:011|5[0-9]{2})[0-9]{12}$" //"^6(?:011|5[0-9]{2})[0-9]{12}$"
        let regJCB = "^(?:2131|1800|35\\d{3})\\d{11}$"
        let maestro = "^(5018|5020|5038|6304|6759|6761|6763)[0-9]{8,15}$"
        
        
        let regVisaTest = NSPredicate(format: "SELF MATCHES %@", regVisa)
        let regMasterTest = NSPredicate(format: "SELF MATCHES %@", regMaster)
        let regExpressTest = NSPredicate(format: "SELF MATCHES %@", regExpress)
        let regDinersTest = NSPredicate(format: "SELF MATCHES %@", regDiners)
        let regDiscoverTest = NSPredicate(format: "SELF MATCHES %@", regDiscover)
        let regJCBTest = NSPredicate(format: "SELF MATCHES %@", regJCB)
        let maestroTest = NSPredicate(format: "SELF MATCHES %@", maestro)
        
        if regVisaTest.evaluate(with: testCard){
            return .Visa
        } else if regMasterTest.evaluate(with: testCard){
            return .MasterCard
        } else if regExpressTest.evaluate(with: testCard){
            return .AmericanExpress
        } else if regDinersTest.evaluate(with: testCard){
            return .DinersClub
        } else if regDiscoverTest.evaluate(with: testCard){
            return .Discover
        } else if regJCBTest.evaluate(with: testCard){
            return .JCB
        } else if maestroTest.evaluate(with: testCard){
            return .Maestro
        }
        
        return .NotRecognized
        
    }
    
    
    enum CreditCardType: Int {
        case AmericanExpress
        case Dankort
        case DinersClub
        case Discover
        case JCB
        case Maestro
        case MasterCard
        case UnionPay
        case VisaElectron
        case Visa
        case NotRecognized
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
            toolTip = button.showToolTip(identifier: "", title: title, message: message, arrowPosition: arrowPosition, preferences: preference, delegate: self)
        } else {
            toolTip = button.showToolTip(identifier: "", message: message, arrowPosition: arrowPosition, preferences: preference, delegate: self)
        }
    }
}

// MARK: - Tooltip Delegate

extension GSAddCardViewController: MKToolTipDelegate {
    
    func toolTipViewDidDisappear(for identifier: String, with timeInterval: TimeInterval) {

    }
    
    func toolTipViewDidAppear(for identifier: String) {

    }
}

//MARK:- Country Selection Delegate
extension GSAddCardViewController:CountrySelectedDelegate {
    
    func countrySelectedWith(_ name: String, imageUrl: String) {
        countryName_lbl.text = name
        guard let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String else {
            print("Unique Id is nil...")
            return
        }
        SDWebImageDownloader.shared.setValue(accessToken, forHTTPHeaderField: "Authorization")
        selCountry_imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: nil, options: .progressiveLoad, completed: nil)
    }
}

//MARK: Naviagtion Bar delegate
extension GSAddCardViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        
        if currentTxtField != nil {
            currentTxtField?.resignFirstResponder()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
}

//MARK: UITextField delegate
extension GSAddCardViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        if string == "" {
            return true
        }
        
        var numberOfCharAllowed: Int
        var allowedCharacters  : String
        if textField == expDateTxtField {
            
            if string == "/" {
                return false
            }
            
            numberOfCharAllowed = 5
            allowedCharacters = "0123456789"
            let text = textField.text ?? ""
            if range.location == 2  && string != "" && !text.contains("/") {
//                textField.text?.append("/")
                textField.text?.insert("/", at: text.index(text.startIndex, offsetBy: 2))
            } else if range.location == 2 {
                return false
            }
            
            let textBeforeSlash = (textField.text ?? "").components(separatedBy: "/").first ?? ""
            
            if range.location < 2, textBeforeSlash.count >= 2 {
                return false
            }
            
        } else if textField == cardnumberTxtField {
            
            numberOfCharAllowed = 16
            allowedCharacters = "0123456789"
        } else if textField == cvvTxtField {
            
            numberOfCharAllowed = 3
            allowedCharacters = "0123456789"
        } else {
            numberOfCharAllowed = 25
            allowedCharacters = Validation.alphabets
        }
        
        if (textField.text?.count ?? 0) >= numberOfCharAllowed {
            
            return false
        }
        
        let cs = CharacterSet(charactersIn: allowedCharacters).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        
        
//        let currentTag: Int = textField.tag
//        let nextTextField = view.viewWithTag(currentTag + 1) as? UITextField
//        if !onTap {
//            if nextTextField != nil {
//                nextTextField?.becomeFirstResponder()
//            }
//            else {
//                textField.resignFirstResponder()
//                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//            }
//        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTxtField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        onTap = false
        let currentTag: Int = textField.tag
        let nextTextField = view.viewWithTag(currentTag + 1) as? UITextField
        if !onTap {
            if nextTextField != nil {
                nextTextField?.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
        }
        return true
    }
}


