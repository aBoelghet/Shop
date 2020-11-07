//
//  GSMakePaymentViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 29/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import PayU_coreSDK_Swift
import IQKeyboardManagerSwift
import MKToolTip

class GSMakePaymentViewController: GSPaymentViewController {
    
    @IBOutlet weak var shadowStackview: UIView!
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var cvv_txtField: UITextField!
    @IBOutlet weak var expData_txtField: UITextField!
    
    @IBOutlet weak var cardIcon_imgView: UIImageView!
    @IBOutlet weak var totalCostKey_lbl:GSBaseLabel!
    @IBOutlet weak var costValue_txtField:UITextField!
    @IBOutlet weak var creditDebitHeading_lbl:GSBaseLabel!
    @IBOutlet weak var creditDebitNumber_lbl:GSBaseLabel!
    
    var paymentParams = PayUModelPaymentParams()
    let paymentRequest = PayUCreateRequest()
    
    var isPopping = false
    var toolTip:MKToolTip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyColors()
        addFewIntializers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done"
        cvv_txtField.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Cancel"
        cvv_txtField.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        totalCostKey_lbl.textColor = UIColor(hexString: defaultTheme.makePayment_totalCostKey_title)
        costValue_txtField.textColor = UIColor(hexString: defaultTheme.makePayment_totalCostValue_text)
        creditDebitHeading_lbl.textColor = UIColor(hexString: defaultTheme.makePayment_creditDebitHeading_text)
        creditDebitNumber_lbl.textColor = UIColor(hexString: defaultTheme.makePayment_creditDebitNumber_text)
        cvv_txtField.textColor = UIColor(hexString: defaultTheme.makePayment_txtField_text)
        expData_txtField.textColor = UIColor(hexString: defaultTheme.makePayment_txtField_text)
    }

    // MARK: - Add Few Initializers
    private func addFewIntializers() {
        
        let cardNumber = paymentParams.cardNumber ?? "    "
        creditDebitNumber_lbl.text = "*****" + cardNumber[cardNumber.index(cardNumber.endIndex, offsetBy: -4)...]
        let expiryYear = paymentParams.expiryYear ?? ""
//        expData_txtField.text = "Exp: **/" + expiryYear.substring(from:expiryYear.index(expiryYear.endIndex, offsetBy: -2))
        expData_txtField.text = "**/" + expiryYear[expiryYear.index(expiryYear.endIndex, offsetBy: -2)...]
        expData_txtField.isUserInteractionEnabled = false
        costValue_txtField.text = paymentParams.amount
        
        if let cardBrand = paymentParams.cardBrand {
            cardIcon_imgView.image = GSPaymentParametersHelper.imageForTheCardtypeWithObject(cardBrand: cardBrand)
        }
        
        creditDebitHeading_lbl.text = "Credit / Debit card"
        
        shadowStackview.layer.masksToBounds = false
        shadowStackview.layer.shadowColor = UIColor.lightGray.cgColor
        shadowStackview.layer.shadowOpacity = 1.0
        shadowStackview.layer.shadowOffset = CGSize(width: 0.0, height: 4)
        shadowStackview.layer.shadowRadius = 1.0
        navigationBarView.delegate = self
    }
    
    func sendCardInfoToServer() {
        // Card No: 4012001037141112 / "5123456789012346" // "4012001037141112" //
        // Exp:12/2020
        // CVV:123
        
        self.paymentParams.storeCardName = self.paymentParams.firstName
        self.paymentParams.CVV = cvv_txtField.text
        
        paymentRequest.createRequest(withPaymentParam: paymentParams, forPaymentType: PAYMENT_PG_STOREDCARD) { (request, error) in
            
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
                let alert = UIAlertController(title: "oops !", message: error as String, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cvvInfoAction(_ sender: UIButton) {
        
        addTooltip(sender, message: GSConstant.ToolTip.toolTip_addCard_cvv, title: "", arrowPosition: .bottom)
        
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

// MARK: UITextField delegate
extension GSMakePaymentViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        if let nextField = self.view?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        var numberOfCharAllowed: Int = 0
        var allowedCharacters  : String
        if textField == cvv_txtField {
            
            numberOfCharAllowed = 3
            allowedCharacters = "0123456789"
        } else {
            allowedCharacters = Validation.alphabets
        }
        
        if range.location >= numberOfCharAllowed {
            return false
        }
        
        let cs = CharacterSet(charactersIn: allowedCharacters).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == cvv_txtField && (cvv_txtField.text?.count)! >= 3 && !isPopping {
            
            view.endEditing(true)
            sendCardInfoToServer()
        }
    }
}

// MARK: Naviagtion Bar delegate
extension GSMakePaymentViewController : NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        isPopping = true
        cvv_txtField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
}
