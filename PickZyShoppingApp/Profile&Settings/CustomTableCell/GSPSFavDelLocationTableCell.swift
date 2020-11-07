//
//  GSPSFavDelLocationTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 6/7/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPSFavDelLocationTableCell: UITableViewCell {
    
    @IBOutlet weak var delLocIcon_imageView:UIImageView!
    @IBOutlet weak var delLocTitle_lbl:GSBaseLabel!
    @IBOutlet weak var delLocPlaceMarkName_lbl:GSBaseLabel!
    @IBOutlet weak var deleteAddress_btn:GSBaseButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        delLocTitle_lbl.textColor = UIColor(hexString: defaultTheme.profileAndSettings_cell_text)
        delLocPlaceMarkName_lbl.textColor = UIColor(hexString: defaultTheme.profileAndSettings_cell_subTitle)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
