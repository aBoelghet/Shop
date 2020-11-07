//
//  GSProductDetailsWithOfferTableCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 30/10/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductDetailsWithOfferTableCell: UITableViewCell {
    
    @IBOutlet weak var sellerName_lbl: GSBaseLabel!
    @IBOutlet weak var priceWithOffer_lbl: GSBaseLabel!
    @IBOutlet weak var quantity_lbl: GSBaseLabel!
    @IBOutlet weak var offer_lbl: GSBaseLabel!
    @IBOutlet weak var priceWithOfferFinal_lbl: GSBaseLabel!
    @IBOutlet weak var originalPriceStriked_lbl: GSBaseLabel!
    @IBOutlet weak var originalPriceStrikedLblBG_view: UIView!
    @IBOutlet weak var offerBG_view: GSCornerEdgeView!
    @IBOutlet weak var offer_stackView:UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
