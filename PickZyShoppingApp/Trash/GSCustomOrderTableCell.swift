//
//  GSCustomOrderTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 5/31/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSCustomOrderTableCell: UITableViewCell {

    @IBOutlet weak var product_imageView: UIImageView!
    @IBOutlet weak var productName_lbl: GSBaseLabel!
    @IBOutlet weak var productCost_lbl: GSBaseLabel!
    @IBOutlet weak var productQuantity_lbl: GSBaseLabel!
    @IBOutlet weak var productSelection_btn: GSCheckboxButton!
    
    @IBOutlet weak var bg_view:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUPCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private func setUPCell() {
        
        bg_view.backgroundColor = UIColor(hexString: defaultTheme.customOrder_itemCell_BG)
        
        let lbl_array = [productName_lbl,productCost_lbl,productQuantity_lbl]
        for lbl in lbl_array {
            lbl?.textColor = UIColor(hexString: defaultTheme.customOrder_itemCell_text)
        }
    }
}
