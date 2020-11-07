//
//  GSCountryListTableCell.swift
//  PickZyShoppingApp
//
//  Created by Mac Mini 01 on 12/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSCountryListTableCell: UITableViewCell {
    
    @IBOutlet weak var countryIcon_imageView:UIImageView!
    @IBOutlet weak var countryName_lbl:GSBaseLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        countryName_lbl.textColor = UIColor(hexString: defaultTheme.countryList_cell_title)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
