//
//  GSProductDesTableViewswift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 16/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductDetailsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var plusMinusView: UIView!
    @IBOutlet weak var detailValue_lbl: GSBaseLabel!
    @IBOutlet weak var quantity_lbl: GSBaseLabel!
    @IBOutlet weak var detailKey_lbl: GSBaseLabel!
    
    @IBOutlet weak var plus_btn:UIButton!
    @IBOutlet weak var minus_btn:UIButton!
    
    @IBOutlet weak var extra_btn: GSBaseButton!
    @IBOutlet weak var orignalPriceWithStrikedLineBg_view: UIView!
    @IBOutlet weak var originalPriveWithStrikedLine_lbl: GSBaseLabel!
    @IBOutlet weak var detailsValue_stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyColorsForUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Apply colours for UI
    
    private func applyColorsForUI() {
        detailKey_lbl.textColor = UIColor(hexString: defaultTheme.productDescriptionView_cell_text)
    }
    
    // MARK: - Configuring the cell
    
    func configureTheCell(productDetails: [String : Any]?, sorted_stores:[Any] , indexPath:IndexPath) {
        
        var productInfo : [String: Any]?
        var store : [String : Any]?
        
        if sorted_stores.count > 0 {
            store = sorted_stores[0] as? [String : Any]
        }
        
        if productDetails != nil{
            
            //            let stores = productDetails!["stores"] as! [Any]
            //            store = stores[0] as? [String : Any]
            productInfo = productDetails!["productInfo"] as? [String : Any]
            
        }
        
        quantity_lbl.text = "0"
        
        extra_btn.isHidden = (indexPath.row == 0)
        orignalPriceWithStrikedLineBg_view.isHidden = true
        
        plusMinusView.isHidden = true
        detailsValue_stackView.isHidden = false
        
        if indexPath.row == 0 {
            detailKey_lbl.text = "Unit:"
            if productInfo != nil{
                detailValue_lbl.text = productInfo!["unit"] as? String ?? ""
            }
            
        } else if indexPath.row == 1 {
            
            detailKey_lbl.text = "Price:"
            orignalPriceWithStrikedLineBg_view.isHidden = false
            
            extra_btn.setTitleColor(UIColor.white, for: .normal)
            extra_btn.backgroundColor = UIColor(hexString: "4DC2F6")
            extra_btn.layer.borderColor = UIColor(hexString: "1AB1F5").cgColor
            
            originalPriveWithStrikedLine_lbl.text = ""
            extra_btn.isHidden = true
            
            detailValue_lbl.text = "NA"
            
            if store != nil {
                guard let prod_details = store?["product_details"] as? [String:Any] else { return }
                if let price = prod_details["selling_price"] as? Double {


                    var offer:Double = 0
                    if let offer_value = prod_details["offer"] as? Double {
                        offer = offer_value
                    }

                    if offer == 0 {
                        detailValue_lbl.text = GSCommonHelper.formattedPrice(price: price) //GSConstant.currency_symbol + " \(price)"
                    } else {
                        extra_btn.isHidden = false
                        originalPriveWithStrikedLine_lbl.text = GSCommonHelper.formattedPrice(price: price) //GSConstant.currency_symbol + " \(price)"
                        let final_price = caluculatePriceWithOffer(price, offer: offer)
                        detailValue_lbl.text = GSCommonHelper.formattedPrice(price: final_price) //GSConstant.currency_symbol + " \(final_price)"
                        let roundedSaved_price = round(price - final_price)
                        let int_savedValue = Int(roundedSaved_price)
                        extra_btn.setTitle("Save \(int_savedValue)", for: .normal)
                        
                        extra_btn.backgroundColor = UIColor(hexString: defaultTheme.cart_cell_save_bg)
                        extra_btn.layer.borderColor = UIColor(hexString: defaultTheme.cart_cell_save_border).cgColor
                        extra_btn.setTitleColor(UIColor.darkGray, for: .normal)
                    }

                } else{
                    originalPriveWithStrikedLine_lbl.text = ""
                }
            }
            
        } else if indexPath.row == 2 {
            plusMinusView.isHidden = false
            detailsValue_stackView.isHidden = true
            quantity_lbl.layer.borderColor = UIColor.lightGray.cgColor
            quantity_lbl.layer.borderWidth = 1.0
            quantity_lbl.layer.cornerRadius = 4
            
            extra_btn.isHidden = true
            extra_btn.setTitle("More", for: .normal)
            extra_btn.setTitleColor(UIColor.black, for: .normal)
            extra_btn.backgroundColor = UIColor.clear
            extra_btn.layer.borderColor = UIColor.black.cgColor
            
            detailKey_lbl.text = "Qty:"
        }
        
    }
    
    
    private func caluculatePriceWithOffer(_ original_price:Double, offer: Double) -> Double {
        if offer == 0 {
            return original_price
        }
        let costOfOffer = (original_price) * (offer/100)
        return (original_price) - costOfOffer
    }
}
