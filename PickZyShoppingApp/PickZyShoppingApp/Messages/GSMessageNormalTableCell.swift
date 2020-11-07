//
//  GSMessageNormalTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 20/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSMessageNormalTableCell: UITableViewCell {
    
    @IBOutlet weak var time_lbl:GSBaseLabel!
    @IBOutlet weak var message_lbl:GSBaseLabel!
    @IBOutlet weak var bubble_imgView:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        message_lbl.textColor = UIColor(hexString: defaultTheme.MessageVC_message_text)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
