//
//  GSMenuTableHeaderCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/7/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSMenuTableHeaderCell: UITableViewCell {
    
    @IBOutlet var profileImage:UIImageView!
    @IBOutlet var profileName:GSBaseLabel!
    
    override func draw(_ rect: CGRect) {
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 0.5 * profileImage.frame.size.height
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.backgroundColor = UIColor(hexString: defaultTheme.sideMenuHeader)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
