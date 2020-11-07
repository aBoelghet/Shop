//
//  GSGlobalSearchTableViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 23/09/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSGlobalSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var product_imgView: UIImageView!
    @IBOutlet weak var offer_view: GSTransparentView!
    @IBOutlet weak var offer_lbl: GSBaseLabel!
    
    @IBOutlet weak var productName_lbl: GSBaseLabel!
    @IBOutlet weak var unit_lbl: GSBaseLabel!
    @IBOutlet weak var price_lbl: GSBaseLabel!
    @IBOutlet weak var strikeLabel_view: UIView!
    @IBOutlet weak var strike_lbl: GSBaseLabel!
    
    @IBOutlet weak var qty_lbl: UILabel!
    @IBOutlet weak var minus_btn: UIButton!
    @IBOutlet weak var plus_btn: UIButton!
    @IBOutlet weak var plusMinus_view: UIView!
    
    @IBOutlet weak var more_btn: UIButton!
    @IBOutlet weak var add_btn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
