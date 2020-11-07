//
//  GSMessagesRootTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 10/01/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class GSMessagesRootTableCell: UITableViewCell {
    
    @IBOutlet weak var product_imgView:UIImageView!
    @IBOutlet weak var title_lbl:GSBaseLabel!
    @IBOutlet weak var qty_lbl:GSBaseLabel!
    @IBOutlet weak var issue_lbl:GSBaseLabel!
    @IBOutlet weak var count_lbl:GSBaseLabel!
    @IBOutlet weak var countBG_view:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        applyColorsForUI()
        
        countBG_view.isHidden = true
        countBG_view.layer.masksToBounds = true
        countBG_view.layer.cornerRadius = 0.5 * countBG_view.frame.size.height
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Apply colors for UI
    
    private func applyColorsForUI() {
        
        title_lbl.textColor = UIColor(hexString: defaultTheme.MessageRootVC_cell_title)
        qty_lbl.textColor = UIColor(hexString: defaultTheme.MessageRootVC_cell_qty)
        issue_lbl.textColor = UIColor(hexString: defaultTheme.MessageRootVC_cell_issue)
        count_lbl.textColor = UIColor(hexString: defaultTheme.MessageRootVC_cell_count)
        
        backgroundColor = UIColor(hexString: defaultTheme.MessageRootVC_cell_BG)
        countBG_view.backgroundColor = UIColor(hexString: defaultTheme.MessageRootVC_cell_count_BG)
    }

    // MARK: - Configuring The Cell
    
    func configureTheCell(product:GSMessagesProductListDataProduct) {
        
        title_lbl.text = product.productName ?? ""
        qty_lbl.text = "\(product.qty ?? 1)"
        
        var verifyStatus = ""
        switch product.verifyStatus ?? 0 {
        case TrackOrderConstants.VerifyStatus.undelivered:
            verifyStatus = "Undelivered"
            break
        case TrackOrderConstants.VerifyStatus.replacement:
            verifyStatus = "Replacement"
            break
        default:
            break
        }
        
        issue_lbl.text = verifyStatus
        
        let imageLink = product.image?.name ?? ""
        let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        SDWebImageDownloader.shared.setValue(accessToken, forHTTPHeaderField: "Authorization")
        product_imgView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewProductImage + imageLink + imgHeight) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
    }
}
