//
//  GSStoreFeedBackTableViewCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 30/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSStoreFeedBackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var feedBackoptionLbl: GSBaseLabel!
    @IBOutlet weak var radioImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submit_btn: GSBaseButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = UIColor(hexString: defaultTheme.storeFeedBack_cell_BG)
        
        if submit_btn != nil {
            submit_btn.backgroundColor = UIColor(hexString: defaultTheme.storeFeedBack_submitBtn_BG)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
