//
//  GSCusomOrderCategoryTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 5/31/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSCustomOrderCategoryTableCell: UITableViewCell {
    
    @IBOutlet weak var primary_lbl:GSBaseLabel!
    @IBOutlet weak var secondary_lbl:GSBaseLabel!

    @IBOutlet weak var secondaryLblWidth_constraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        primary_lbl.textColor = UIColor(hexString: defaultTheme.customOrder_catCell_left_title)
        secondary_lbl.textColor = UIColor(hexString: defaultTheme.customOrder_catCell_right_title)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureTheCell(_ data:String) {
        secondaryLblWidth_constraint.constant = 50.0
        primary_lbl.textAlignment = .left
        primary_lbl.font = UIFont.boldSystemFont(ofSize: 16.0)
        contentView.backgroundColor = UIColor(hexString: defaultTheme.customOrder_catCell_Content_BG)
        
        if (data.caseInsensitiveCompare("customize order") == ComparisonResult.orderedSame) {
            secondaryLblWidth_constraint.constant = 0.0
            primary_lbl.textAlignment = .center
            primary_lbl.font = UIFont.boldSystemFont(ofSize: 19.0)
        } else if (data.caseInsensitiveCompare("auto selected shops") == ComparisonResult.orderedSame) {
            primary_lbl.font = UIFont.boldSystemFont(ofSize: 19.0)
        } else {
            contentView.backgroundColor = UIColor(hexString: defaultTheme.customOrder_catCell_content_darkBG)
        }
        
        primary_lbl.text = data
    }

}
