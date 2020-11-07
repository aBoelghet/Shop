//
//  GSPurchaseHistoryTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 6/5/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPurchaseHistoryTableCell: UITableViewCell {
    
    @IBOutlet weak var shopCat_imageView:UIImageView!
    @IBOutlet weak var shopCatName_lbl:GSBaseLabel!
    @IBOutlet weak var ordersCount_lbl:GSBaseLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ordersCount_lbl.textColor = UIColor(hexString: defaultTheme.purchaseHist_OrderCount_title)
        shopCatName_lbl.textColor = UIColor(hexString: defaultTheme.purchaseHist_cell_title)
        contentView.backgroundColor = UIColor(hexString: defaultTheme.purchaseHist_cell_BG)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
//    func configureTheCell(_ model: GSPurchasedListDataOrderDetail) {
//        shopCatName_lbl.text = model.store?.displayName ?? ""
//        ordersCount_lbl.text = "\(model.order?.prices?.netPrice ?? 0)"
//    }

}
