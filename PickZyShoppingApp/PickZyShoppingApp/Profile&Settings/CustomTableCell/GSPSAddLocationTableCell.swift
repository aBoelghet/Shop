//
//  GSPSAddLocationTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 6/7/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPSAddLocationTableCell: UITableViewCell {
    
    @IBOutlet weak var addMoreLoc_lbl:GSBaseLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addMoreLoc_lbl.textColor = UIColor(hexString: defaultTheme.profileAndSettings_cell_AddMoreLocbtn_text)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
