//
//  GSPaymentWebViewController.swift
//  Shopor
//
//  Created by Ratheesh on 01/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import WebKit

var _transaction_id = ""
var _amountPaid = ""
var _paymentHash = ""

class GSPaymentWebViewController: GSLoggedInBaseViewController, WKScriptMessageHandler {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    
    @IBOutlet weak var paymentWebView: WKWebView!

    var placeOrderHelper:GSPlaceOrderHelper?
    var isVerifyCard : Bool = false

    var paymentRequest:URLRequest?
    
    var transaction_id = ""
    var amountPaid = ""
    var paymentHash = ""
    var isOrderPlaced : Bool = false
    var paymentResponse: String!
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
        applyColors()

        paymentWebView.navigationDelegate = self
        
        paymentWebView.configuration.userContentController.add(self, name: "observe")

        if let unwrappedRequest = paymentRequest {
            paymentWebView.load(unwrappedRequest)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "observe" {
            
            let jsonData = try! JSONSerialization.data(withJSONObject: message.body, options: [])
            
            guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) else{return}
            
            if let dictionary = json as? [String: Any] {
                
                if let title = dictionary["onPayuSuccess"] as? String {
                    
                    var finalRespString = title.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil)
                    
                    finalRespString = (finalRespString.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil))

                    paymentResponse = finalRespString
                }
            }
         }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar_view.navigationBarReload()
        GSConstant.linearBar.startAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        
    }
    
    // MARK: User defined Methods
    private func addFewIntializers() {
        navigationBar_view.delegate = self
    }
}

extension String {
    
    init?(htmlEncodedString: String) {
        
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString.string)
    }
}

// MARK: - Web View Delegate Methods
extension GSPaymentWebViewController:WKNavigationDelegate {
    
     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    
        #if DEVELOPEMENT
            let scriptString = "PayU();"
        #elseif QA
            let scriptString = "PayU();"
        #else
            let scriptString = "payu_js_callback();"
        #endif
        webView.evaluateJavaScript(scriptString, completionHandler: { (html, error) in
            
            let finalRespString: String?
            if self.paymentResponse == nil {
                
                let bytes = String(describing: html).utf8
                
                let responseString = String(bytes: bytes, encoding: .utf8)?.removingPercentEncoding
                
                finalRespString = responseString?.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
            } else {
                finalRespString = self.paymentResponse
            }
            
            let orderResponse = finalRespString!.components(separatedBy: ",")
                                
            if (orderResponse.count) > 5 && self.isOrderPlaced == false {
                let orderSuccessResponse = NSMutableDictionary()
                for arrayValue in orderResponse {
                    
                    let keyValue = arrayValue.components(separatedBy: ":").first
                    let data = arrayValue.components(separatedBy: ":").last
                    orderSuccessResponse.setValue(data, forKey: keyValue!)
                }
                
                if (orderSuccessResponse.value(forKey: "status") as? String) == "success" && self.isVerifyCard == false {
                    
                    if let transaction_id = orderSuccessResponse.value(forKey: "txnid") as? String {
                        self.transaction_id = transaction_id
                    }
                    
                    if let amount_paid = orderSuccessResponse.value(forKey: "amount") as? String {
                        self.amountPaid = amount_paid
                    }
                    
                    if let hashFromResponse = orderSuccessResponse.value(forKey: "hash") as? String {
                        self.paymentHash = hashFromResponse
                    }
                    
                    let paymentObject:[String:AnyObject] = ["txnid":self.transaction_id as AnyObject,
                                                            "hash" : self.paymentHash as AnyObject]
                    self.isOrderPlaced = true
                    self.placeOrder(paymentObject: paymentObject)
                    
                } else if (orderSuccessResponse.value(forKey: "status") as? String) == "success" && self.isVerifyCard == true {
                    // Verifing the card and save card statements
                    
                    CustomAlert.showAlert(title: "Info !", message: GSConstant.AlertMessages.verifiedCard, alertButtonsArray: ["Ok"], viewController: self) { _ in
                        if let stackViewControllerArray = self.navigationController?.viewControllers {
                            
                            for vc in stackViewControllerArray.reversed() {
                                
                                if vc.isKind(of: GSPaymentTypeViewController.self) {
                                    GSConstant.linearBar.stopAnimation()
                                    self.navigationController?.popToViewController(vc, animated: true)
                                    return
                                }
                            }
                        }
                    }
                } else if (orderSuccessResponse.value(forKey: "status") as? String) == "failure" {
                    
                    CustomAlert.showAlert(title: "Info !", message: GSConstant.AlertMessages.transactionFailed, alertButtonsArray: ["Ok"], viewController: self) { _ in
                        GSConstant.linearBar.stopAnimation()
                        
                        if let transaction_id = orderSuccessResponse.value(forKey: "txnid") as? String {
                            self.transaction_id = transaction_id
                        }
                        
                        if let amount_paid = orderSuccessResponse.value(forKey: "amount") as? String {
                            self.amountPaid = amount_paid
                        }
                        
                        if let hashFromResponse = orderSuccessResponse.value(forKey: "hash") as? String {
                            self.paymentHash = hashFromResponse
                        }
                        
                        #if DEBUG
                        print("Amount: ", self.amountPaid)
                        print("Hash: ", self.paymentHash)
                        #endif
                        
                        // Check and Refund if payment successfull
                        self.placeOrderHelper = GSPlaceOrderHelper()
                        self.placeOrderHelper?.delegate = self
                        self.placeOrderHelper?.paidAmount = self.amountPaid
                        self.placeOrderHelper?.caseForPaidOrderNotPlaced(txnId: self.transaction_id, paymentHash: self.paymentHash)
                        
                        self.popToCartView()
                    }
                }
                
                #if DEBUG
                print("orderResponse 1 = ", orderSuccessResponse.value(forKey: "status") as Any)
                print("orderResponse 2 = ", orderResponse as Any)
                #endif
            }
        })
    }
    
    func placeOrder(paymentObject:[String:AnyObject]) {

        placeOrderHelper = GSPlaceOrderHelper()
        placeOrderHelper?.delegate = self
        placeOrderHelper?.paidAmount = amountPaid
        placeOrderHelper?.placeOrderAPI(paymentObject: paymentObject)
    }
    
    fileprivate func popToCartView() {
        
        if let viewControllerArray = self.navigationController?.viewControllers {
            
            for vc in viewControllerArray.reversed() {
                if vc is GSPaymentTypeViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Place Order Helper Delegate  Methods
extension GSPaymentWebViewController:GSPlaceOrderHelperDelegate {
    
    func orderPlacedWith(status: Bool, data: GSPlaceOrderResponseData?, message: String) {
        
        if status {
            if let orderPlacedVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSOrderPlacedViewController) as? GSOrderPlacedViewController {
                orderPlacedVC.placeOrderResponse = data
                orderPlacedVC.transaction_id = transaction_id
                orderPlacedVC.amountPaid = amountPaid
                    GSConstant.linearBar.stopAnimation()
                
                self.navigationController?.pushViewController(orderPlacedVC, animated: true)
            }
        } else {
            
            CustomAlert.showAlert(title: GSConstant.AlertMessages.transaction_failed_title, message: message, alertButtonsArray: ["Ok"], viewController: self) { _ in
                self.popToCartView()
            }
        }
    }
}

// MARK: - Navigation Bar View Delegate Methods
extension GSPaymentWebViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        CustomAlert.showAlert(title: "Cancel Order", message: GSConstant.AlertMessages.cancelTransaction, alertButtonsArray: ["No","Yes"], isLastButtonDestructive: true, viewController: self) { (btnIndex) in
            if btnIndex == 1 {
                
                GSConstant.linearBar.stopAnimation()
                
                if (self.amountPaid == "") {
                    self.amountPaid = self.placeOrderHelper?.paidAmount ?? "0"
                    self.transaction_id = self.placeOrderHelper?.txn_id ?? "0"
                    self.paymentHash = "0"
                }
                // Check and Refund if payment successfull
                self.placeOrderHelper = GSPlaceOrderHelper()
                self.placeOrderHelper?.delegate = self
                self.placeOrderHelper?.paidAmount = self.amountPaid
                let transId = SharedPersistence.getValue(key: UserDefaultKeys.Payment.transactionId) as? String ?? self.transaction_id
                self.placeOrderHelper?.caseForPaidOrderNotPlaced(txnId: transId, paymentHash: self.paymentHash)
                
                self.popToCartView()
            }
        }
    }
}
