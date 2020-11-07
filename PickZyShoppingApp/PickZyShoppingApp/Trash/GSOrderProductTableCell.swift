//
//  GSOrderProductTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 5/25/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSOrderProductTableCell: UITableViewCell {

    @IBOutlet weak var product_imageView: UIImageView!
    @IBOutlet weak var productTitle_label: GSBaseLabel!
    @IBOutlet weak var cost_label: GSBaseLabel!
    @IBOutlet weak var quantity_label: GSBaseLabel!
    @IBOutlet weak var bg_view:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bg_view.backgroundColor = UIColor(hexString: defaultTheme.shopDetails_itemCell_BG)
        
        let lbl_array = [productTitle_label,cost_label,quantity_label]
        
        for lbl in lbl_array {
            lbl?.textColor = UIColor(hexString: defaultTheme.shopDetails_cell_text)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureTheCell(_ model:OrderedProducts) {
        product_imageView.image = UIImage(named: model.imageName)
        productTitle_label.text = model.title
        cost_label.text = model.approxCost
        quantity_label.text = model.quantity
    }
}
