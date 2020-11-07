//
//  GSProfileSettingTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 6/7/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProfileSettingTableCell: UITableViewCell {
    
    @IBOutlet weak var profile_imageView:UIImageView!
    @IBOutlet weak var profileName_lbl:GSBaseLabel!
    @IBOutlet weak var phoneNo_lbl:GSBaseLabel!
    @IBOutlet weak var emailId_lbl:GSBaseLabel!
    
    @IBOutlet weak var bg_view:UIView!
    @IBOutlet weak var editBtn:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileName_lbl.textColor = UIColor(hexString: defaultTheme.profileAndSettings_cell_text)
        phoneNo_lbl.textColor = UIColor(hexString: defaultTheme.profileAndSettings_cell_text)
        emailId_lbl.textColor = UIColor(hexString: defaultTheme.profileAndSettings_cell_text)
        
        profile_imageView.layer.borderWidth = 0.5
        profile_imageView.layer.borderColor = UIColor(hexString: defaultTheme.NavBarBottomLine).cgColor
    }
    
    override func draw(_ rect: CGRect) {
        profile_imageView.layer.masksToBounds = true
        profile_imageView.layer.cornerRadius = 0.5 * profile_imageView.frame.size.height
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
