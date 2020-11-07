//
//  GSPaymentPromoCodeTableViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 28/05/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPaymentPromoCodeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellIcon: UIImageView!
    @IBOutlet weak var topLabel: GSBaseLabel!
    @IBOutlet weak var promocodeStatus_lbl:GSBaseLabel!
    @IBOutlet weak var promocodeBG_view:UIView!
    @IBOutlet weak var promocodeStatus_imgView:UIImageView!
    @IBOutlet weak var removePromoCodeBG_view: UIView!
    @IBOutlet weak var removePromo_btn: UIButton!
    
    @IBOutlet weak var bg_view:UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(hexString: defaultTheme.paymentOpt_BorderC)
        bg_view.backgroundColor = UIColor.white
        
        promocodeBG_view.layer.masksToBounds = true
        promocodeBG_view.layer.cornerRadius = 3
        promocodeBG_view.layer.borderWidth = 0.5
        promocodeBG_view.layer.borderColor = UIColor.red.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
