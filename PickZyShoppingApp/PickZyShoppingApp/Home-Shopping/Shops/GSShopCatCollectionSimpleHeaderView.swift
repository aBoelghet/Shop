//
//  GSShopCatCollectionSimpleHeaderView.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 5/8/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSShopCatCollectionSimpleHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: GSBaseLabel!
    @IBOutlet weak var suggestionLabel: GSBaseLabel!
    
    @IBOutlet weak var info_btn:GSBaseButton!
    @IBOutlet weak var titleBg_view:UIView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //titleLabel.backgroundColor = UIColor(hexString: defaultTheme.shopVC_header_BG1)
    }
    
    // MARK: User defined methods
    public func configureHeaderView(_ model:ShopTypeModel, rad : Int) {
        
        titleLabel.text = "  \(model.shopTypeDisplayName)"
        //suggestionLabel.text = "Below shops available with in next \(rad/1000) kms"
    }
}
