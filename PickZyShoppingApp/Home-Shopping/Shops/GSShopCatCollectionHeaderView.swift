//
//  GSShopCatCollectionHeaderView.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 5/5/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSShopCatCollectionHeaderView: UITableViewHeaderFooterView {
        
    @IBOutlet weak var descLabel: GSBaseLabel!
    @IBOutlet weak var suggestionLabel: GSBaseLabel!
    
//    @IBOutlet weak var closeBtn: GSBaseButton!
    @IBOutlet weak var inviteBtn: GSBaseButton!
    
    @IBOutlet weak var titleLabel: GSBaseLabel!
    
    @IBOutlet weak var bgPopup_view: GSCornerEdgeView!
    
    @IBOutlet weak var info_btn:GSBaseButton!
    @IBOutlet weak var titleBg_view:UIView!
    
    @IBOutlet weak var clickHere_btn:GSBaseButton!
    @IBOutlet weak var close_btn: UIButton!
  
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        applyColors()
    }
    
    // MARK: User defined methods
    public func configureHeaderView(_ model:ShopTypeModel, rad : Int) {
        
        titleLabel.text = "  \(model.shopTypeDisplayName)"
        descLabel.text = GSConstant.suggestionMsg
        //suggestionLabel.text = "Below shops available with in next \(rad/GSConstant.meterToKm) kms"
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        
//      titleLabel.backgroundColor = UIColor(hexString: defaultTheme.shopVC_header_BG1)
        bgPopup_view.backgroundColor = UIColor(hexString: defaultTheme.alertBox)
        inviteBtn.backgroundColor = UIColor(hexString: defaultTheme.shopVC_inviteBtn_BG)
        suggestionLabel.textColor = UIColor(hexString: defaultTheme.shopVC_sugestionLabelText)
        titleLabel.textColor = UIColor(hexString: defaultTheme.shopVC_header_title)
        inviteBtn.setTitleColor(UIColor(hexString: defaultTheme.shopVC_inviteBtn_title), for: .normal)
    }
}
