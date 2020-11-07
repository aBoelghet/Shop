//
//  DeliveredCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/5/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class GSDeliveredTableCell: UITableViewCell {
    
    @IBOutlet weak var productImg: UIImageView!

    @IBOutlet weak var title_lbl: GSBaseLabel!
    @IBOutlet weak var cost_lbl: GSBaseLabel!
    @IBOutlet weak var quantity_lbl: GSBaseLabel!
    @IBOutlet weak var expiryDate_lbl: GSBaseLabel!
    
    @IBOutlet weak var deliverd_btn: GSBaseButton!
    @IBOutlet weak var undelivered_btn: GSBaseButton!
    @IBOutlet weak var replacement_btn: GSBaseButton!
    @IBOutlet weak var help_btn: GSBaseButton!
    
    @IBOutlet weak var expiryNotify_switch: UISwitch!
    @IBOutlet weak var expiryNotifyInfo_btn: UIButton!
    @IBOutlet weak var expiryDateKey_lbl: GSBaseLabel!
    @IBOutlet weak var qtyKey_lbl: GSBaseLabel!
    @IBOutlet weak var productId_lbl: GSBaseLabel!
    
    @IBOutlet weak var productCost_lbl:GSBaseLabel!
    @IBOutlet weak var qtyDropDownBG_view: GSCornerEdgeView!
    @IBOutlet weak var qtyDropDown_imgView: UIImageView!
    @IBOutlet weak var qtyDropDown_btn: UIButton!
    @IBOutlet weak var dropDownInfo_lbl: GSBaseLabel!
    @IBOutlet weak var moreExpiryDates_btn:GSUnderlinedButton!
    
    @IBOutlet weak var bottomButtons_view:UIView!
    @IBOutlet weak var expiryNotifyInfoIcon_imgView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUpCell()
        setUPButtonsForShrinking()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell() {
        
        expiryNotify_switch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        let normalLables = [cost_lbl,quantity_lbl,qtyKey_lbl,expiryDateKey_lbl,productId_lbl]
        for lbl in normalLables {
            lbl?.textColor = UIColor(hexString: defaultTheme.verifyItems_cell_defaultInfo_titles)
        }
        
        title_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_cell_productName_lbl)
        
        expiryDate_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_cell_highlightInfo_titles)
        let radioBtn_array = [deliverd_btn,undelivered_btn,replacement_btn,help_btn]
        for btn in radioBtn_array {
            btn?.setTitleColor(UIColor(hexString: defaultTheme.verifyItems_cell_complaintRadio_title), for: .normal)
            btn?.tintColor = UIColor(hexString: defaultTheme.verifyItems_cell_complaintRadio_title)
        }
        help_btn.layer.borderColor = UIColor(hexString: defaultTheme.verifyItems_cell_helpBtn_border).cgColor
        productCost_lbl.textColor = UIColor(hexString: defaultTheme.trackOrderListVC_cell_cost_lbl_text)

        dropDownInfo_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_cell_highlightInfo_titles)
    }
    
    // MARK: - Configuring The Cell
    
    func configureTheCellWithCommonData(productItem: GSTrackOrderProductListProduct) {
        
        title_lbl.text = productItem.productName ?? ""
        cost_lbl.text = productItem.unit ?? ""
        
        let firstImageLink = productItem.image?.name ?? ""

        let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        SDWebImageDownloader.shared().setValue(accessToken, forHTTPHeaderField: "Authorization")
        productImg.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewProductImage + firstImageLink + imgHeight) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
    }
    
    //MARK: - Some Private methods
    
    private func setUPButtonsForShrinking () {
        let btn_array = [deliverd_btn,undelivered_btn,replacement_btn,help_btn]
        
        for btn in btn_array {
            btn?.titleLabel?.adjustsFontSizeToFitWidth = true
            btn?.titleLabel?.minimumScaleFactor = 0.5
        }
        
        changeButtonTitleSize()
    }
    
    private func changeButtonTitleSize() {
        
        let requiredFontSize = min((deliverd_btn.titleLabel?.font.pointSize)! * (deliverd_btn.titleLabel?.contentScaleFactor)!,(undelivered_btn.titleLabel?.font.pointSize)! * (undelivered_btn.titleLabel?.contentScaleFactor)!,(replacement_btn.titleLabel?.font.pointSize)! * (replacement_btn.titleLabel?.contentScaleFactor)!,(help_btn.titleLabel?.font.pointSize)! * (help_btn.titleLabel?.contentScaleFactor)!)
                
        let btn_array = [deliverd_btn,undelivered_btn,replacement_btn,help_btn]
        
        for btn in btn_array {
            btn?.titleLabel?.font = UIFont.systemFont(ofSize: requiredFontSize)
        }
    }
    
    
    // Have to remove it later
    
    func configureTheCell(itemDetails:ItemDetailModel){
        
        productImg.image = UIImage.init(named: itemDetails.productImg)
        
        title_lbl.text = "Product Name"
        cost_lbl.text = "Rs.120"
        quantity_lbl.text = "5"
        expiryDate_lbl.text = "01/01/2011"
        
    }
}
