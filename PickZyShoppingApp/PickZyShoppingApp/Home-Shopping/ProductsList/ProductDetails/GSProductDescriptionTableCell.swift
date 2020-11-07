//
//  GSProductDetailDescTableCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 22/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductDescriptionTableCell: UITableViewCell {
    
    @IBOutlet weak var key_lbl:GSBaseLabel!
    @IBOutlet weak var value_lbl:GSBaseLabel!
    
    @IBOutlet weak var lblBG_view:GSCornerEdgeView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureTheCell () {
        
    }
}
