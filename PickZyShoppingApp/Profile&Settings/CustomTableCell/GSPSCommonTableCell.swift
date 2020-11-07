//
//  GSPSCommonTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 6/7/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPSCommonTableCell: UITableViewCell {
    
    @IBOutlet weak var icon_imageView:UIImageView!
    @IBOutlet weak var title_lbl:GSBaseLabel!
    @IBOutlet weak var right_imageView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        title_lbl.textColor = UIColor(hexString: defaultTheme.profileAndSettings_cell_text)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
