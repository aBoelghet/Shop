//
//  ProductListTableViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 26/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class ProductListTableViewCell: UITableViewCell {

    @IBOutlet weak var product_ImageIcon: UIImageView!
    
    @IBOutlet weak var productTitle_Label: UILabel!
    
    @IBOutlet weak var productPrice_Label: UILabel!
    
    @IBOutlet weak var productQty_Label: UILabel!
    
    @IBOutlet weak var radio_Button: UIButton!
    
    @IBOutlet weak var separateLine: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
