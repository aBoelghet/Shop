//
//  GSCategoryMenuTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 07/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSCategoryMenuTableCell: UITableViewCell {
    
    @IBOutlet weak var categoryName_lbl: GSBaseLabel!
    @IBOutlet weak var accessory_btn: UIButton!
    @IBOutlet weak var accessoryBtn_imgView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
