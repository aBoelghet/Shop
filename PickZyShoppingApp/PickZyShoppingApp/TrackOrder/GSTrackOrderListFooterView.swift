//
//  GSTrackOrderListFooterView.swift
//  Shopor
//
//  Created by Ratheesh on 08/04/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSTrackOrderListFooterView: UITableViewHeaderFooterView {

    static let identifier = "trackOrderListFooterView"
    
    @IBOutlet weak var cancel_btn:GSBaseButton!
    @IBOutlet weak var help_btn:GSBaseButton!
    
    func applyColors() {
        
        backgroundColor = UIColor(hexString: defaultTheme.trackOrderListVC_Footer_BG)
        
        cancel_btn.backgroundColor = UIColor(hexString: defaultTheme.trackOrderListVC_Footer_btn_BG)
        cancel_btn.setTitleColor(UIColor(hexString: defaultTheme.trackOrderListVC_Footer_title), for: .normal)
        
        help_btn.setTitleColor(UIColor(hexString: defaultTheme.trackOrderListVC_Footer_btn_BG), for: .normal)
        help_btn.layer.borderWidth = 0.5
        help_btn.backgroundColor = UIColor.white
        help_btn.layer.borderColor = UIColor(hexString: defaultTheme.trackOrderListVC_Footer_btn_BG).cgColor
    }

}
