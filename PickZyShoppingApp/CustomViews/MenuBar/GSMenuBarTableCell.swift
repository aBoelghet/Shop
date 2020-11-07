//
//  GSMenuBarTableCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/5/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSMenuBarTableCell: UITableViewCell {
    
    @IBOutlet weak var menuIconView:UIImageView!
    @IBOutlet weak var menuName:GSBaseLabel!
    @IBOutlet weak var countLabel:GSBaseLabel!
    @IBOutlet weak var bg_view:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
