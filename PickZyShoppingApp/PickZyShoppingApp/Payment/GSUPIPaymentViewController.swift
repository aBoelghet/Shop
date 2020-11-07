//
//  GSUPIPaymentViewController.swift
//  Shopor
//
//  Created by Ratheesh on 12/02/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import PayU_coreSDK_Swift

class GSUPIPaymentViewController: GSPaymentViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var info_lbl:GSBaseLabel!
    @IBOutlet weak var upiInput_txtField:GSBaseTextField!
    @IBOutlet weak var payNow_btn:GSBaseButton!
    @IBOutlet weak var payNowBtnBottom :NSLayoutConstraint!
    
    var paymentParams: PayUModelPaymentParams?
    let createRequest = PayUCreateRequest()
    
    let paymentWebService   = PayUWebService()

    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
        applyColors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChangeText(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: upiInput_txtField)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - KeyBoardWillShow And KeyBoardWillHide Methods
    @objc func keyBoardWillShow(notification:NSNotification) -> Void {
        
        let info = notification.userInfo
        let keyboardSize = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardSize.height
        print("KeyBoardHeightWillShow ---- \(keyboardHeight)")
        
        self.payNowBtnBottom.constant = keyboardHeight
        UIView.animate(withDuration: 6) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyBoardWillHide(notification:NSNotification) -> Void {
        
        self.payNowBtnBottom.constant = 8
        UIView.animate(withDuration: 6) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        payNow_btn.backgroundColor = UIColor.lightGray
        payNow_btn.setTitleColor(UIColor.white, for: .normal)
    }
    
    // MARK: User defined Methods
    private func addFewIntializers() {
        
        info_lbl.text = "Enter your UPI in the field."
        navigationBar_view.delegate = self
        payNow_btn.isUserInteractionEnabled = false
    }
    
    // MARK: - View Controller Action Methods
    
    @IBAction private func payNow(_ sender: UIButton) {
        
        view.endEditing(true)
        self.paymentParams?.vpa = upiInput_txtField.text
        self.paymentParams?.enableVerbose = true
        GSConstant.linearBar.startAnimation()
        
        paymentWebService.callVAS(paymentParamsforVas: paymentParams!)

        createRequest.createRequest(withPaymentParam: paymentParams!, forPaymentType: PAYMENT_PG_UPI) { (request, error) in
            
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
    
    // MARK: - Text field  Notification Methods
    
    @objc func textFieldDidChangeText(_ notification: Notification) {
        
        guard let textField = notification.object as? UITextField else { return }
        
        let textField_text = textField.text ?? ""
        
        if textField_text.count > 0 {
            payNow_btn.isUserInteractionEnabled = true
            payNow_btn.backgroundColor = UIColor(hexString: defaultTheme.cart_MakePayment_BG)
        } else {
            payNow_btn.isUserInteractionEnabled = false
            payNow_btn.backgroundColor = UIColor.lightGray
        }
    }
}


// MARK: - Navigation Bar View Delegate Methods

extension GSUPIPaymentViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        
        upiInput_txtField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
    }
}
