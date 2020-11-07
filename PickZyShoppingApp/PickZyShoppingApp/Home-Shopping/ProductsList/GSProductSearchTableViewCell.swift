//
//  GSProductSearchTableViewCell.swift
//  PickZyShoppingApp
//
//  Created by Purushoth on 16/10/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: GSBaseLabel!
    
    @IBOutlet weak var product_icon: UIImageView!
    
    @IBOutlet weak var quantityView: UIView!
    
    @IBOutlet weak var quantityViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var imageIconWidth: NSLayoutConstraint!
    
    @IBOutlet weak var background_View: GSCornerEdgeView!
    
    @IBOutlet weak var addCartButton: UIButton!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        background_View.layer.cornerRadius = 3
        background_View.clipsToBounds = true
        addCartButton.layer.cornerRadius = 3
        addCartButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
