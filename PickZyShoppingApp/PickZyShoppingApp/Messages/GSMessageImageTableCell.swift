//
//  GSMessageImageTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 16/01/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSMessageImageTableCell: UITableViewCell {
    
    @IBOutlet weak var time_lbl:GSBaseLabel!
    @IBOutlet weak var bubble_imgView:UIImageView!
    @IBOutlet weak var product_imgView:UIImageView!
    @IBOutlet weak var preview_btn:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
