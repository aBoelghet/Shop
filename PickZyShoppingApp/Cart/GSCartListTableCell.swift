//
//  CartListCell.swift
//  AKSwiftSlideMenu
//
//  Created by Ratheesh on 2/19/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import SDWebImage

protocol GSCartListTableCellDelegate:class {
    
    func cell_moreAction(_ sender:UIButton, checkBoxSender:UIButton)
    func cell_removeAction(_ sender:UIButton, checkBoxSender:UIButton)
    func cell_quantitySelection(_ sender:UIButton, checkBoxSender: UIButton)
    func cell_checkBoxAction(_ sender:UIButton)
}

class GSCartListTableCell: UITableViewCell {
    
    @IBOutlet var btnSel : GSCheckboxButton!
    @IBOutlet weak var bgView : UIView!
    @IBOutlet var productName : GSBaseLabel!
    @IBOutlet var rateLbl : GSBaseLabel!
    @IBOutlet var unitLbl : GSBaseLabel!
    @IBOutlet weak var quantity_lbl:GSBaseLabel!
    @IBOutlet var productImg : UIImageView!
    @IBOutlet weak var titleKey_lbl:GSBaseLabel!
    @IBOutlet weak var costKey_lbl:GSBaseLabel!
    @IBOutlet weak var quantityKey_lbl:GSBaseLabel!
    @IBOutlet weak var info_lbl: GSBaseLabel!
    @IBOutlet weak var price_lbl: GSBaseLabel!
    @IBOutlet weak var actualPrice_lbl: GSBaseLabel!
    @IBOutlet weak var strike_view: UIView!
    @IBOutlet weak var save_view: GSTransparentView!
    @IBOutlet weak var save_lbl: GSBaseLabel!
    @IBOutlet weak var remove_view: GSTransparentView!
    @IBOutlet weak var more_view: GSTransparentView!
    @IBOutlet weak var remove_btn:UIButton!
    @IBOutlet weak var more_btn:UIButton!
    @IBOutlet weak var quantitySelection_btn:UIButton!
    @IBOutlet weak var offerTagBG_view: GSTransparentView!
    @IBOutlet weak var offerTag_lbl: GSBaseLabel!
    @IBOutlet weak var quantityLblBG_view: GSTransparentView!
    
    weak var delegate:GSCartListTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUpCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let degrees:Double = 45; //the value in degrees
        offerTagBG_view.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/180))
        offerTagBG_view.layer.masksToBounds = true
        offerTagBG_view.layer.cornerRadius = 0.5 * offerTagBG_view.bounds.size.height
    }
    
    func setUpCell() {

        applyColors()
        
        if btnSel.frame.size.height > 20 {
            
            let inset = (btnSel.frame.size.height - 20) / 2
            
            btnSel.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        } else {
            btnSel.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        
        let keyLabel_array = [titleKey_lbl,costKey_lbl,quantityKey_lbl]
        for label in keyLabel_array {
            label?.textColor = UIColor(hexString: defaultTheme.cart_cell_key_label_text)
        }
        
        let valueLabel_array = [productName,rateLbl,quantity_lbl]
        for lbl in valueLabel_array {
            lbl?.textColor = UIColor(hexString: defaultTheme.cart_cell_value_label_text)
        }
        
        save_view.backgroundColor = UIColor(hexString: defaultTheme.cart_cell_save_bg)
        save_view.layer.borderColor = UIColor(hexString: defaultTheme.cart_cell_save_border).cgColor
        
        save_lbl.textColor = UIColor(hexString: "5F625B")
    }
    
    
    // MARK: - Action Methods
    
    @IBAction private func removeAction(_ sender:UIButton) {
        delegate?.cell_removeAction(sender, checkBoxSender: btnSel)
    }
    
    @IBAction private func moreAction(_ sender:UIButton) {
        delegate?.cell_moreAction(sender, checkBoxSender: btnSel)
    }
    @IBAction private func checkBoxAction(_ sender:UIButton) {
        delegate?.cell_checkBoxAction(sender)
    }
    
    @IBAction private func qunatitySelection(_ sender:UIButton) {
        delegate?.cell_quantitySelection(sender, checkBoxSender: btnSel)
    }
    
    fileprivate func caluculatePriceWithOffer(_ original_price:Double, offer: Double) -> Double {
        if offer == 0 {
            return original_price
        }
        let costOfOffer = (original_price) * (offer/100)
        return (original_price) - costOfOffer
    }
    
    
    
    func configureTheCellWithNewModel(model_item:GSCartListNewData) {
        
        guard let store_array = model_item.stores else { return }
        
        info_lbl.text = ""
        
        if store_array.count > 1 {
            info_lbl.text = "Stocks selected from multiple shops, so offer % may vary."
        }

        productName.text = model_item.productInfo?.productName ?? ""
        unitLbl.text = model_item.productInfo?.unit ?? "NA"
        
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        SDWebImageDownloader.shared.setValue(accessToken, forHTTPHeaderField: "Authorization")
        
        var imageEndPoint = ""
        
        if let image_array = model_item.productInfo?.images {
            if image_array.count > 0 {
                imageEndPoint = image_array[0].name ?? ""
            }
        }
        let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
        productImg.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewProductImage + imageEndPoint + imgHeight) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
        
        var original_price:Double = 0
        var final_price:Double = 0
        var quantity:Int = 0
        
        for store_item in store_array {
            
            let curreny_quantity = store_item.productDetails?.qty ?? 0
            let singleItem_originalPrice = (store_item.productDetails?.sellingPrice ?? 0)
            original_price += (singleItem_originalPrice * Double(curreny_quantity))
            
//            let offer = store_item.productDetails?.offer ?? 0
//            final_price += (caluculatePriceWithOffer(singleItem_originalPrice, offer: offer) * Double(curreny_quantity))
            
            final_price += ((store_item.productDetails?.offerSellingPrice ?? 0) * Double(curreny_quantity))
            quantity += curreny_quantity
        }
        
        offerTagBG_view.isHidden = true
        if store_array.count == 1 && store_array[0].productDetails?.offer != 0 {
            // We have to show offer tag
            
            offerTagBG_view.isHidden = false
            offerTag_lbl.text = "\(store_array[0].productDetails?.offer ?? 0)%"
        }
        
        quantity_lbl.text = "\(quantity)"
        
        strike_view.isHidden = false
        actualPrice_lbl.isHidden = false
        save_view.isHidden = false
        
        if final_price != original_price {
            
            price_lbl.text = GSCommonHelper.formattedPrice(price: final_price) //GSConstant.currency_symbol + " \(final_price)"
            actualPrice_lbl.text = GSCommonHelper.formattedPrice(price: original_price) //GSConstant.currency_symbol + " \(original_price)"
            
//            let saveString = "Save "
//            let myMutableString = NSMutableAttributedString()
//            let attrs1 = [NSFontAttributeName : UIFont.systemFont(ofSize: 8)]
//            let saveAttributedStr = NSMutableAttributedString(string: saveString as String, attributes: attrs1)
//
//            let priceString = "\(original_price - final_price)"
//            let labelFontSize:CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 15 : 12
//            let priceAttrs = [NSFontAttributeName : UIFont.systemFont(ofSize: labelFontSize)]
//            let priceAttributedStr = NSMutableAttributedString(string: priceString as String, attributes: priceAttrs)
//
//            myMutableString.append(saveAttributedStr)
//            myMutableString.append(priceAttributedStr)
            let saved_price = original_price - final_price
            let roundedSaved_price = round(saved_price)
            let int_savedValue = Int(roundedSaved_price)
            save_lbl.text = "Save: \(GSConstant.currency_symbol)\(int_savedValue)"
            
        } else {
            actualPrice_lbl.isHidden = true
            strike_view.isHidden = true
            save_view.isHidden = true
            price_lbl.text = GSCommonHelper.formattedPrice(price: final_price) //GSConstant.currency_symbol + " \(final_price)"
        }
    }
    
}


