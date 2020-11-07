//
//  GSNotificationTableCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/27/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSNotificationTableCell: UITableViewCell {
    
    @IBOutlet var notifyLabel:GSBaseLabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setUpCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell() {
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
    }
    
    func configureTheCell(_ model:NotificationModel) {
        notifyLabel.text = model.notifText
    }
}
