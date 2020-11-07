//
//  GSReferOfferPopupView.swift
//  Shopor
//
//  Created by Venu Pendota on 28/08/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSReferOfferPopupView: NibView {
    
    @IBOutlet weak var info_lbl: UILabel!
    @IBOutlet weak var icon_imgView: UIImageView!
    

    var bayFayCash: Double = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupThisView()
    }
    
    private func setupThisView() {
        
    }
    
    func updateData() {
//        info_lbl.text = "\(GSConstant.currency_symbol)\(bayFayCash) Credited in Your \(GSString.AppName) Wallet"
        
        info_lbl.attributedText = String().attributedString(stringArray: ["\(GSConstant.currency_symbol)\(bayFayCash)", " Credited in Your \(GSString.AppName) Wallet."], foregroundColorArray: [UIColor.red, UIColor(hexString: "007AFF")])
    }
    
    
    @IBAction func wallet_action(_ sender: UIButton) {
        
        removeFromSuperview()
        if let shopVC = GSTopViewController.topViewController() as? GSShopsViewController {
            
            if let paymentTypeVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPaymentTypeViewController) as? GSPaymentTypeViewController {
                
                shopVC.navigationController?.pushViewController(paymentTypeVC, animated: false)
            }
        }
    }
    
    @IBAction func close_action(_ sender: UIButton) {
        removeFromSuperview()
    }
}
