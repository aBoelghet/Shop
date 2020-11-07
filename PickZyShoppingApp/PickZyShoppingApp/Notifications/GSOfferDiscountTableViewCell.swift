//
//  GSOfferDiscountTableViewCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh Mac Mini on 04/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSOfferDiscountTableViewCell: UITableViewCell {

    @IBOutlet weak var adText_lbl: UILabel!
    @IBOutlet weak var adImage_imageView: UIImageView!
    @IBOutlet weak var adOffer_label: UILabel!
    @IBOutlet weak var Ad_promoCodeView: UIView!
    @IBOutlet weak var ad_promocodeLabel: GSBaseLabel!
    @IBOutlet weak var ad_ExpiryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let promocodeView = CAShapeLayer()
        promocodeView.strokeColor = UIColor.red.cgColor
        promocodeView.lineDashPattern = [2, 2]
        promocodeView.frame = Ad_promoCodeView.bounds
        promocodeView.fillColor = nil
        promocodeView.path = UIBezierPath(rect: Ad_promoCodeView.bounds).cgPath
        Ad_promoCodeView.layer.addSublayer(promocodeView)
        
        adImage_imageView.layer.cornerRadius = 3
        adImage_imageView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
