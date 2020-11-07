//
//  GSProfileTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 6/7/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProfileTableCell: UITableViewCell {
    
    @IBOutlet weak var profIcon_imageView:UIImageView!
    @IBOutlet weak var cell_txtField:UITextField!
    @IBOutlet weak var placeHolder_lbl:GSBaseLabel!
    @IBOutlet weak var edit_btn:GSBaseButton!
    @IBOutlet weak var dialCode_lbl:GSBaseLabel!
    @IBOutlet weak var bg_view:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cell_txtField.textColor = UIColor(hexString: defaultTheme.profileEdit_bottomLabel)
        placeHolder_lbl.textColor = UIColor(hexString: defaultTheme.profileEdit_topLabel)
        dialCode_lbl.textColor = UIColor(hexString: defaultTheme.profileEdit_bottomLabel)
        bg_view.backgroundColor = UIColor(hexString: defaultTheme.profileEdit_cell_BG)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

