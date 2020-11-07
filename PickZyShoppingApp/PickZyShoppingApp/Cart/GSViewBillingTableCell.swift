//
//  GSViewBillingTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 14/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSViewBillingTableCell: UITableViewCell {

    @IBOutlet weak var productName_lbl: GSBaseLabel!
    @IBOutlet weak var quantity_lbl: GSBaseLabel!
    @IBOutlet weak var price_lbl: GSBaseLabel!
    @IBOutlet weak var icon_imgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - Configuring The Cell
    
    func configureTheCell( products:[GSViewBillingProduct]) {
        
        if products.count > 0 {
            
            let product_item = products[0]
            productName_lbl.text = product_item.productName
            
            
            var total_price:Double = 0
            var total_quantity = 0
            for singleProduct in products {
                let price = singleProduct.grossPrice
                total_price += price
                total_quantity += (singleProduct.qty )
            }
            price_lbl.text = GSCommonHelper.formattedPrice(price: total_price)
            quantity_lbl.text = " X " + "\(total_quantity)"
        }
        
    }
    
    func configureTheCellForCustomizeOrder( product:GSCustomizeOrderProduct) {
        
            productName_lbl.text = product.productName
            quantity_lbl.text = " X " + "\(product.qty ?? 1)"
            let price = product.grossPrice ?? 0
            let total_price:Double = Double(price)
            price_lbl.text = GSCommonHelper.formattedPrice(price: total_price)
    }
}
