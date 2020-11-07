//
//  GSNotificationsUpdatesTableViewCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh Mac Mini on 04/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSNotificationsUpdatesTableViewCell: UITableViewCell {

    @IBOutlet weak var updateText_lbl: GSBaseLabel!
    @IBOutlet weak var icon_imageView: UIImageView!
    @IBOutlet weak var Ad_ExpiryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
                
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
