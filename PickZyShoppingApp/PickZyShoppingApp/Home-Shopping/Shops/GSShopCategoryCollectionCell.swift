//
//  GSShopCategoryCollectionCell.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/22/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit
import SDWebImage

class GSShopCategoryCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: GSBaseLabel!
    @IBOutlet weak var categoryNotCount: GSBaseLabel!
    @IBOutlet weak var countWidth: NSLayoutConstraint! //Normally 25.0 for iPhone 40.0 for iPad
    @IBOutlet weak var imageBG_view: UIView!
    @IBOutlet weak var rating_imgView: UIImageView!
    @IBOutlet weak var ratingBg_view: GSCornerEdgeView!
    @IBOutlet weak var rating_lbl: UILabel!
    @IBOutlet weak var offerBg_view: UIView!
    @IBOutlet weak var offerText_lbl: UILabel!
    
    func configureTheCell(shopModel : GSHomeDocsClass) {
        
        clipsToBounds = false
        categoryName.text = shopModel.display_name
        categoryNotCount.text = "\(shopModel.stores!.count)"
        
        guard let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String else {
            print("Unique Id is nil...")
            return
        }

        SDWebImageDownloader.shared().setValue(accessToken, forHTTPHeaderField: "Authorization")
        
        var isShopOpen = 0
        if (shopModel.is_open == false) {
            isShopOpen = 1
        }
        
        let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight + "&off=" + String(isShopOpen)
                
        categoryImage.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewImage + (shopModel.image ?? "") + imgHeight) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
        
        categoryNotCount.layer.masksToBounds = true
        categoryNotCount.layer.cornerRadius = 0.5 * categoryNotCount.frame.size.height
        
        applyColors()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        imageBG_view.backgroundColor = UIColor(hexString: defaultTheme.shopVC_shopImg_BG)
        categoryNotCount.backgroundColor = UIColor(hexString: defaultTheme.shopVC_shopIconBadge)
        categoryName.textColor = UIColor(hexString: defaultTheme.shopVC_market_title)
    }
}
