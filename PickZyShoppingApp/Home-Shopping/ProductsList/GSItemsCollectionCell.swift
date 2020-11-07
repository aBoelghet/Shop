//
//  GSItemsCollectionCell.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/9/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit
import SDWebImage

class GSItemsCollectionCell: UICollectionViewCell {
    
    static let identifier = "GSItemsCollectionCell"
    
    @IBOutlet weak var priceLabelBG_view: GSTransparentView!
    @IBOutlet weak var offer_lbl:GSBaseLabel!
    @IBOutlet weak var itemsImageView: UIImageView!
    @IBOutlet weak var quanBG_view: GSTransparentView!
    @IBOutlet weak var angleLabelBG_view: GSTransparentView!
    
    @IBOutlet var transparent_view: UIView!
    
    @IBOutlet var quantity_lbl: GSBaseLabel!
    
    @IBOutlet weak var bg_view:UIView!
    
    override func draw(_ rect: CGRect) {
        
        angleLabelBG_view.layer.masksToBounds = true
        let degrees:Double = 45; //the value in degrees
        angleLabelBG_view.layer.cornerRadius = 0.5 * angleLabelBG_view.bounds.size.height
        angleLabelBG_view.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/180))
    }
    
    func configureTheCell(items:GSProductsList, selectedSizeClass:CGFloat) {
        
        guard let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String else {
            print("Unique Id is nil...")
            return
        }
        SDWebImageDownloader.shared.setValue(accessToken, forHTTPHeaderField: "Authorization")
        if let imageArr = items.productInfo!.images {
            if imageArr.count > 0 {
                
                var lowQualityHeight = GSConstant.tumbnailLQImgHeight
                var highQualityHeight = GSConstant.tumbnailImgHeight
                
                
                itemsImageView.image = nil
                itemsImageView.sd_cancelCurrentImageLoad()
                
                if selectedSizeClass == GSProductFrameType.Values.fullScreen_iPhone || selectedSizeClass == GSProductFrameType.Values.fullScreen_iPad {
                    
                    lowQualityHeight = GSConstant.thumbnailFullscreenLQ
                    highQualityHeight = GSConstant.thumbnailFullscreenHQ
                }
                
                let imgWidth : String = "&height=" + lowQualityHeight
                let imageUrlString = APIurl.baseURL + APIurl.subURL.viewProductImage + (imageArr[0].name ?? "") + imgWidth

                itemsImageView.sd_setImage(with: URL(string: imageUrlString), placeholderImage: #imageLiteral(resourceName: "blurImage"), options: .progressiveLoad) { ( image, error, _ , _ ) in
                    if error == nil {
                        
                        let imgWidth : String = "&height=" + highQualityHeight
                        self.itemsImageView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewProductImage + (imageArr[0].name ?? "") + imgWidth) , placeholderImage: image , completed: nil)
                    }
                }
            }
        }
        
        let offerSellingPrice = items.stores?[0].product_details?.selling_price ?? 0.0

        if selectedSizeClass != GSProductFrameType.Values.oneX_iPhone && selectedSizeClass != GSProductFrameType.Values.oneX_iPad {
            
//            var productName = ""
//
//            if let unit = items.productInfo?.unit?.lowercased(), unit != "" {
//                productName = "\(unit)\n"
//            }
            
            quantity_lbl.attributedText = String().attributedString(stringArray: ["₹\(offerSellingPrice)"," | ",(items.productInfo?.unit ?? "") + "\n", items.productInfo?.product_name ?? ""], foregroundColorArray: [UIColor.black,UIColor.black,UIColor.black, UIColor(hexString: "555555")])
            
//            productName += (items.productInfo?.product_name ?? "").removeEnclosedWhieteSpace()
//            quantity_lbl.text = productName
        } else {
            quantity_lbl.text = "\(items.productInfo?.unit ?? "")"
            quantity_lbl.textColor = UIColor.black
        }

        if let offer = items.stores?[0].product_details?.offer {
            
            if offer != 0 {
                angleLabelBG_view.isHidden = false
                offer_lbl.text = "\(offer)" + "%"
            } else {
                angleLabelBG_view.isHidden = true
            }
        } else {
            angleLabelBG_view.isHidden = true
        }
    }
}
