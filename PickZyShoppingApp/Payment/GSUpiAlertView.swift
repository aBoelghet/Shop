//
//  GSUpiAlertView.swift
//  Shopor
//
//  Created by Ratheesh on 20/09/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import PayU_coreSDK_Swift

class GSUpiAlertView: NibView {

    @IBOutlet weak var upi_txtField: GSBaseTextField!
    @IBOutlet weak var cancel_btn: GSBaseButton!
    @IBOutlet weak var pay_btn: GSBaseButton!
    @IBOutlet weak var main_scrollView: UIScrollView!
    @IBOutlet weak var mainBG_view: GSCornerEdgeView!
    
    
    var paymentParams: PayUModelPaymentParams?
    let createRequest = PayUCreateRequest()
    
    let paymentWebService   = PayUWebService()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    private func setUpThisView() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChangeText(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: upi_txtField)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Text field  Notification Methods
    
    @objc func textFieldDidChangeText(_ notification: Notification) {
        
        guard let textField = notification.object as? UITextField else { return }
        
        let textField_text = textField.text ?? ""
        
        if textField_text.count > 0 {
            pay_btn.isUserInteractionEnabled = true
            pay_btn.backgroundColor = UIColor(hexString: "077DDB")
        } else {
            pay_btn.isUserInteractionEnabled = false
            pay_btn.backgroundColor = UIColor.lightGray
        }
    }
    
    //MARK: - KeyBoardWillShow And KeyBoardWillHide Methods
    @objc func keyBoardWillShow(notification:NSNotification) -> Void {
        
        let info = notification.userInfo
        let keyboardSize = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardSize.height
        print("KeyBoardHeightWillShow ---- \(keyboardHeight)")
        
//        main_scrollView.contentSize = CGSize(width: main_scrollView.frame.size.width, height: mainBG_view.frame.origin.y + mainBG_view.frame.size.height + keyboardHeight)
        
        main_scrollView.contentSize = CGSize(width: main_scrollView.frame.size.width, height: mainBG_view.frame.origin.y + mainBG_view.frame.size.height)
    }
    
    @objc func keyBoardWillHide(notification:NSNotification) -> Void {
        
        main_scrollView.contentSize = CGSize(width: main_scrollView.frame.size.width, height: mainBG_view.frame.origin.y + mainBG_view.frame.size.height)
    }
    
    @IBAction func pay_action(_ sender: UIButton) {
        
        let upiText = upi_txtField.text ?? ""
        
        if upiText.isValidUPI() == false {
            CustomAlert.showAlert(title: GSString.AppName, message: "Please enter valid UPI", viewController: GSTopViewController.topViewController())
            return
        }
        
        self.paymentParams?.vpa = upi_txtField.text
        self.paymentParams?.enableVerbose = true
        GSConstant.linearBar.startAnimation()
        
        paymentWebService.callVAS(paymentParamsforVas: paymentParams!)
        
        createRequest.createRequest(withPaymentParam: paymentParams!, forPaymentType: PAYMENT_PG_UPI) { [weak self] (request, error) in
            
            guard self != nil else { return }
            
            DispatchQueue.main.async {
                GSConstant.linearBar.stopAnimation()
            }
            
            if (error == "") {
                
                DispatchQueue.main.async {
                    if let paymentWebVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPaymentWebViewController) as? GSPaymentWebViewController {
                        paymentWebVC.paymentRequest = request as URLRequest
                        GSTopViewController.topViewController().navigationController?.pushViewController(paymentWebVC, animated: true)
                    }
                }
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: error as String, viewController: GSTopViewController.topViewController())
            }
        }
    }
    
    @IBAction func cancel_action(_ sender: UIButton) {
        removeFromSuperview()
    }
}
