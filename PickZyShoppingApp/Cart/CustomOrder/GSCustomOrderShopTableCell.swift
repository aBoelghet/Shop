//
//  GSCustomOrderShopTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 5/31/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSCustomOrderShopTableCell: UITableViewCell {

    @IBOutlet weak var shop_imageView: UIImageView!
    @IBOutlet weak var shopName_lbl: GSBaseLabel!
    @IBOutlet weak var rating_lbl: GSBaseLabel!
    @IBOutlet weak var ratingTitle_lbl:GSBaseLabel!
    @IBOutlet weak var totalPrice_lbl:GSBaseLabel!
    
    @IBOutlet weak var orderCountakaSelection_btn: GSBaseButton!
    @IBOutlet weak var bg_view:UIView!
    @IBOutlet weak var rating_view: FloatRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

//        orderCountakaSelection_btn.isUserInteractionEnabled = false
        
        backgroundColor = UIColor(hexString: defaultTheme.customOrder_shopCell_BG)
        let labelArray = [shopName_lbl,rating_lbl,ratingTitle_lbl]
        for lbl in labelArray {
            lbl?.textColor = UIColor(hexString: defaultTheme.customOrder_shopCell_text)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Configuring The Cell
    func configureTheCell(_ data:GSCustomizeOrderData, isAutoSelectedShop:Bool, isSelectedShop: Bool) {
        
        shopName_lbl.text = data.shop?.displayName
        
        orderCountakaSelection_btn.setTitle("", for: .normal)
        orderCountakaSelection_btn.setImage(nil, for: .normal)
        
        if isAutoSelectedShop {
            let products_count = data.products?.count ?? 0
            orderCountakaSelection_btn.setTitle("\(products_count)", for: .normal)
        } else {
            orderCountakaSelection_btn.setImage(#imageLiteral(resourceName: "Radio_off"), for: .normal)
            if isSelectedShop {
                orderCountakaSelection_btn.setImage(#imageLiteral(resourceName: "Radio_on"), for: .normal)
            }
        }
        
        rating_lbl.text = ""
        rating_view.rating = 0
        ratingTitle_lbl.text = "No ratings"
        
        if let rating = data.shop?.rating {

            let formattedRating = String(format:"%.1f", rating)
            rating_lbl.text = formattedRating
            rating_view.rating = rating
            ratingTitle_lbl.text = "Rating"
        }
        
        let total_price = String(format: "%.2f", data.prices?.netPrice ?? 0)
        totalPrice_lbl.text = "Total price: Rs \(total_price)"
    }
}
