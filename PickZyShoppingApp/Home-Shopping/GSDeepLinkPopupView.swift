//
//  GSDeepLinkPopupView.swift
//  Shopor
//
//  Created by Ratheesh on 17/09/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class GSDeepLinkPopupView: NibView {
    
    @IBOutlet weak var store_imgView: UIImageView!
    @IBOutlet weak var info_lbl: UILabel!
    @IBOutlet weak var cancel_btn: GSBaseButton!
    @IBOutlet weak var ok_btn: GSBaseButton!
    
    var urlSchemeShopObject: GSHomeDocsClass!
    var privateShop_id: Int!
    
    var shopIconUrl = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUpView()
    }
    
    private func setUpView() {
        
        
    }
    
    func updateData() {
        
        guard let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String else {
            print("Unique Id is nil...")
            return
        }
        
        SDWebImageDownloader.shared.setValue(accessToken, forHTTPHeaderField: "Authorization")
        
        let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
        store_imgView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewImage + (shopIconUrl) + imgHeight) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
    }
    
    
    @IBAction func cancel_action(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @IBAction func ok_action(_ sender: UIButton) {
        removeFromSuperview()
        let storeSelectionHelper = StoreSelectionHelper()
        storeSelectionHelper.pushToProductListPage(shopAtIndex: urlSchemeShopObject, tempSessionIndex: self.privateShop_id)
    }
}
