//
//  GSStoreFeedbackCollectionFooterView.swift
//  Shopor
//
//  Created by Ratheesh on 16/04/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSStoreFeedbackCollectionFooterView: UICollectionReusableView {
    

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submit_btn: GSBaseButton!
    
    
    func appleColors() {
        
//        backgroundColor = UIColor(hexString: defaultTheme.storeFeedBack_cell_BG)
        
        submit_btn.backgroundColor = UIColor(hexString: defaultTheme.storeFeedBack_submitBtn_BG)
        submit_btn.layer.borderColor = UIColor(hexString: defaultTheme.LastOrderPopUpView_submitBtn_border).cgColor
        submit_btn.setTitleColor(UIColor(hexString: defaultTheme.LastOrderPopUpView_submitBtn_title), for: .normal)
    }
        
}

