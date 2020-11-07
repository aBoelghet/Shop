//
//  GSMenuTableHeaderView.swift
//  Shopor
//
//  Created by Ratheesh on 31/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSMenuTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var profileName:GSBaseLabel!
    @IBOutlet weak var bg_view:UIView!
    @IBOutlet weak var signupLogin_btn:UIButton!
    
    static let identifier = "menuHeaderView"
    
    override func draw(_ rect: CGRect) {
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 0.5 * profileImage.frame.size.height
        
        bg_view.backgroundColor = UIColor(hexString: defaultTheme.sideMenuHeader)
    }

}
