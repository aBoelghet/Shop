//
//  GSProductListGifView.swift
//  Shopor
//
//  Created by Ratheesh on 12/08/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductListGifView: NibView {

    @IBOutlet weak var gif_imgView:UIImageView!
    @IBOutlet weak var info_lbl: GSBaseLabel!
    @IBOutlet weak var gotIt_btn: GSBaseButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUpThisView()
    }
    
    private func setUpThisView() {
        


    }
    
    func updateGIF() {
        
        var font = 14
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            font = 16
        }
        
        let htmlString =
        """
<!DOCTYPE html>

 <html>
 <head>  </head>
 <body>
    <strong>
        <ul>
             <font color="white">
                 <li style="font-family:Helvetica;font-size: \(font)px">Long press the product image, the product information tooltip will display.</li>
                 <li style="font-family:Helvetica;font-size: \(font)px">Drag the product to the top right over cart icon and release it so the product will add in the cart for purchase.</li>
             </font>
         </ul>
    </strong>
 </body>
 </html>
"""
        
        if let infoAttributedText = htmlString.html2AttributedString {
            
            info_lbl.attributedText = infoAttributedText
        }
        
//            let image = UIImage.gifImageWithName("productListPreview")
//            self.gif_imgView.image = image

    }

    
    @IBAction private func gotIt_action(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { _ in
            
            self.removeFromSuperview()
            if let productsVC = GSTopViewController.topViewController() as? GSProductsViewController {
                productsVC.offerPopupAPI()
            }
        }
    }
}
