//
//  GSCustomOrderTableHeaderView.swift
//  Shopor
//
//  Created by Ratheesh on 15/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSCustomOrderTableHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var title_lbl:GSBaseLabel!
    @IBOutlet weak var radio_btn:UIButton!
    @IBOutlet weak var image_btn:UIButton!
    @IBOutlet weak var totalKey_lbl:GSBaseLabel!
    @IBOutlet weak var totalValue_lbl:GSBaseLabel!
    @IBOutlet weak var mainBG_view: UIView!
    @IBOutlet weak var bg_view: UIView!
    
    static let identifier = "customOrderTableHeaderView"
    
    func setUpUIWithSection(section:Int, selectedIndex:Int) {
        
        mainBG_view.backgroundColor = UIColor(hexString: defaultTheme.customOrder_shopCell_BG)
        
        image_btn.isHidden = (section == 2)
        radio_btn.isHidden = (section == 2)
        radio_btn.tag = section
        
        for autoSelectedDetailsLabel in [totalKey_lbl, totalValue_lbl] {
            autoSelectedDetailsLabel?.isHidden = true
            if section == 1 {
                autoSelectedDetailsLabel?.isHidden = false
            }
        }
        
        if section == 0 {           // Auto Selected Shops
            
            image_btn.setImage(#imageLiteral(resourceName: "Radio_off"), for: .normal)
            if selectedIndex == GSOrderCustomizationViewController.autoShopSelection {
                image_btn.setImage(#imageLiteral(resourceName: "Radio_on"), for: .normal)
            }
            
        } else if section == 1 {           // Auto Selected Shops Details
            image_btn.setImage(#imageLiteral(resourceName: "downArrow"), for: .normal)
        }
    }
}
