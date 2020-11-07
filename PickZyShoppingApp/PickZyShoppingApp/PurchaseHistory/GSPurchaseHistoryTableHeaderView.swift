//
//  GSPurchaseHistoryTableHeaderView.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 6/5/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPurchaseHistoryTableHeaderView: UITableViewHeaderFooterView {
    
    static let headerIdentifier = "purchaseHistoryHeader"

    @IBOutlet weak var title_lbl: GSBaseLabel!
    @IBOutlet weak var extra_lbl: GSBaseLabel!
    @IBOutlet weak var sel_btn: UIButton!
    @IBOutlet weak var BG_view:UIView!
    @IBOutlet weak var accessoryIcon_imgView:UIImageView!
    
    override func draw(_ rect: CGRect) {
        sel_btn.imageEdgeInsets = UIEdgeInsetsMake(0, sel_btn.frame.size.width - 50, 0, 10)
        BG_view.backgroundColor = UIColor(hexString: defaultTheme.purchaseHist_tableHeader_BG)
        title_lbl.textColor = UIColor(hexString: defaultTheme.purchaseHist_Header_title)
        extra_lbl.textColor = UIColor(hexString: defaultTheme.purchaseHist_ExtraLabel_title)
    }
    
}
