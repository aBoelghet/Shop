//
//  GSPaymentBayFayCoinsTableViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 28/05/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPaymentBayFayCoinsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellIcon: UIImageView!
    @IBOutlet weak var topLabel: GSBaseLabel!
    @IBOutlet weak var bayFayCoins_lbl: GSBaseLabel!
    @IBOutlet weak var info_btn:GSBaseButton!
    @IBOutlet weak var selectionImage: UIImageView!
    
    @IBOutlet weak var iconImageWidth: NSLayoutConstraint!
    @IBOutlet weak var bg_view:UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(hexString: defaultTheme.paymentOpt_BorderC)
        bg_view.backgroundColor = UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
