//
//  GSTrackOrderListTableHeaderView.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 19/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSTrackOrderListTableHeaderView: UITableViewHeaderFooterView {
    
    static let headerIdentifier = "trackOrderHeader"
    
    @IBOutlet weak var bg_headerView:UIView!
    @IBOutlet weak var titleLabel:GSBaseLabel!
    @IBOutlet weak var sel_btn:UIButton!
    @IBOutlet weak var bgContent_view:UIView!
    @IBOutlet weak var accessoryIndicator_imgView:UIImageView!


//    override func draw(_ rect: CGRect) {
//        sel_btn.imageEdgeInsets = UIEdgeInsetsMake(0, sel_btn.frame.size.width - 50, 0, 10)
//        bgContent_view.backgroundColor = UIColor(hexString: defaultTheme.trackOrderListVC_Header_ContentBG)
//        bg_headerView.backgroundColor = UIColor(hexString: defaultTheme.trackOrderListVC_Header_BG)
//        titleLabel.textColor = UIColor(hexString: defaultTheme.trackOrderListVC_header_title)
//    }
    
    // MARK: - Apply Colors For UI
    
    func applyColorsForUI() {
        
//        sel_btn.imageEdgeInsets = UIEdgeInsetsMake(0, sel_btn.frame.size.width - 50, 0, 10)
        bgContent_view.backgroundColor = UIColor(hexString: defaultTheme.trackOrderListVC_Header_ContentBG)
        bg_headerView.backgroundColor = UIColor(hexString: defaultTheme.trackOrderListVC_Header_BG)
        titleLabel.textColor = UIColor(hexString: defaultTheme.purchaseHist_Header_title)
    }
}
