//
//  GSPromoCodeTableViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 29/05/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPromoCodeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var store_imgView:UIImageView!
    @IBOutlet weak var storeName_lbl:GSBaseLabel!
    @IBOutlet weak var promoTitle_lbl:GSBaseLabel!
    @IBOutlet weak var promoBG_view:GSCornerEdgeView!
    @IBOutlet weak var promo_lbl:GSBaseLabel!
    @IBOutlet weak var promoExpiry_lbl:GSBaseLabel!
    
    @IBOutlet weak var limitType_lbl: GSBaseLabel!
    @IBOutlet weak var validType_lbl: GSBaseLabel!
    @IBOutlet weak var promoType_lbl: GSBaseLabel!
    @IBOutlet weak var topMost_view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyColorsForUI()
        
        store_imgView.layer.masksToBounds = true
        store_imgView.layer.cornerRadius = 5
        
        let promocodeView = CAShapeLayer()
        promocodeView.strokeColor = UIColor.red.cgColor
        promocodeView.lineDashPattern = [2, 2]

        promocodeView.frame = UIDevice.current.userInterfaceIdiom == .phone ? promoBG_view.bounds : CGRect(x: 15, y: 0, width: 175, height: 35)
        promocodeView.fillColor = nil
        promocodeView.path = UIBezierPath(rect: UIDevice.current.userInterfaceIdiom == .phone ? promoBG_view.bounds : CGRect(x: 15, y: 0, width: 175, height: 35) ).cgPath

        promoBG_view.layer.addSublayer(promocodeView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Applying Colors for UI
    private func applyColorsForUI() {
        
        // promoBG_view.layer.borderColor = UIColor(hexString: defaultTheme.paymentOpt_cellApplyPromoLable).cgColor
        promoExpiry_lbl.textColor = UIColor(hexString: defaultTheme.paymentOpt_cellApplyPromoLable)
        promo_lbl.textColor = UIColor(hexString: defaultTheme.paymentOpt_cellApplyPromoLable)
        limitType_lbl.textColor = UIColor(hexString: defaultTheme.PromoCodeView_limitType)
        validType_lbl.textColor = UIColor.lightGray
        promoType_lbl.textColor = UIColor.lightGray
    }
}
