//
//  GSNotificationSettingsTableViewCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 05/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSNotificationSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var imageIcon:UIImageView!
    @IBOutlet weak var optionLbl:GSBaseLabel!
    @IBOutlet weak var bg_view:UIView!
    @IBOutlet weak var selection_switch:UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bg_view.backgroundColor = UIColor(hexString: defaultTheme.notificationSettings_cell_BG)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
