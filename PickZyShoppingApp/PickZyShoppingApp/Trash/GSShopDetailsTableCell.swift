//
//  GSShopDetailsTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 5/25/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSShopDetailsTableCell: UITableViewCell {

    @IBOutlet weak var bg_view: UIView!
    @IBOutlet weak var shop_imageView: UIImageView!
    @IBOutlet weak var shopDetails_label: GSBaseLabel!
    @IBOutlet weak var orderCount_label: GSBaseLabel!
    @IBOutlet weak var track_btn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bg_view.backgroundColor = UIColor(hexString: defaultTheme.shopDetails_DetailsCell_BG)
        shopDetails_label.textColor = UIColor(hexString: defaultTheme.shopDetails_cell_text)
        orderCount_label.textColor = UIColor(hexString: defaultTheme.shopDetails_orderCount_title)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configureTheCell(_ address:String) {
        shopDetails_label.text = "Address: \n\(address)"
    }
}
