//
//  GSDetailMakePaymentViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 30/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSDetailMakePaymentViewController: GSPaymentViewController {

    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var storeName_lbl: GSBaseLabel!
    @IBOutlet weak var deliveryDate_lbl: GSBaseLabel!
    @IBOutlet weak var totalCost_lbl: GSBaseLabel!
    
    @IBOutlet weak var storeNameKey_lbl:GSBaseLabel!
    @IBOutlet weak var deliveryDateKey_lbl: GSBaseLabel!
    @IBOutlet weak var paymentTop_lbl:GSBaseLabel!
    @IBOutlet weak var done_btn:GSBaseButton!
    @IBOutlet weak var alreadyPaid_btn:GSBaseButton!
    
    var amountToPay = ""
    var storeName = ""
    var deliveryDateFromAPI = ""
    var isAllDelivered = true
    var isFromTrackOrder = true
    
    var order_id = ""
    var store_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
        applyColors()
    }
 
    // MARK: - Configuring with data
    
    func configureWith(orderId:String, storeId:String,payingAmount:String, isAllDelivered:Bool, isFromTrack:Bool, store_name:String, apiDeliveryDate:String) {
        
        self.order_id = orderId
        self.store_id = storeId
        self.amountToPay = payingAmount
        self.isAllDelivered = isAllDelivered
        self.isFromTrackOrder = isFromTrack
        self.storeName = store_name
        self.deliveryDateFromAPI = apiDeliveryDate
    }
    
    //MARK:- User defined methods
    
    private func addFewIntializers() {
        navigationBar_view.delegate = self
        
        totalCost_lbl.text = amountToPay
        storeName_lbl.text = storeName
        deliveryDate_lbl.text = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: deliveryDateFromAPI, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        
        view.backgroundColor = UIColor(hexString: defaultTheme.detailedMakePayment_view_BG)
        storeName_lbl.textColor = UIColor(hexString: defaultTheme.detailedMakePayment_storeNameValue_text)
        storeNameKey_lbl.textColor = UIColor(hexString: defaultTheme.detailedMakePayment_storeNameKey_text)
        deliveryDateKey_lbl.textColor = UIColor(hexString: defaultTheme.detailedMakePayment_delDateKey_text)
        deliveryDate_lbl.textColor = UIColor(hexString: defaultTheme.detailedMakePayment_delDateValue_text)
        paymentTop_lbl.textColor = UIColor(hexString: defaultTheme.detailedMakePayment_paymentTop_text)
        
        totalCost_lbl.textColor = UIColor(hexString: defaultTheme.detailedMakePayment_cost_text)
        done_btn.setTitleColor(UIColor(hexString: defaultTheme.detailedMakePayment_doneBtn_title), for: .normal)
        done_btn.backgroundColor = UIColor(hexString: defaultTheme.detailedMakePayment_doneBtn_BG)
        alreadyPaid_btn.setTitleColor(UIColor(hexString: defaultTheme.detailedMakePayment_doneBtn_title), for: .normal)
        alreadyPaid_btn.backgroundColor = UIColor(hexString: defaultTheme.detailedMakePayment_doneBtn_BG)
    }


    // MARK:- View Controller Methods
    
    @IBAction func doneAction(_ sender: UIButton) {
        
        if isAllDelivered == false {
            
            if let vcStack_array = navigationController?.viewControllers {
                
                if isFromTrackOrder {
                    for vc in vcStack_array.reversed() {
                        if vc.isKind(of: GSTrackOrderListViewController.self) {
                            navigationController?.popToViewController(vc, animated: true)
                            return
                        }
                    }
                } else {
                    for vc in vcStack_array.reversed() {
                        if vc.isKind(of: GSPurchaseHistoryViewController.self) {
                            navigationController?.popToViewController(vc, animated: true)
                            return
                        }
                    }
                }
            }
            
            self.navigationController?.popToRootViewController(animated: true)
            
            return
        }
        
        if let storeFeedbackVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSStoreFeedbackViewController) as? GSStoreFeedbackViewController {
            
            storeFeedbackVC.configureForStoreFeedBack(orderId: order_id, storeId: store_id, isFromTrackOrder: isFromTrackOrder, isDeliveredProducts: true)
            navigationController?.pushViewController(storeFeedbackVC, animated: true)
        }
    }
}

// MARK: NavigationBar Methods

extension GSDetailMakePaymentViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {

    }
    func rightBarBtnPressed(sender:UIButton) {
        
    }
}
