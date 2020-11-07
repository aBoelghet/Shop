//
//  SubscriptionListTableViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 25/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class SubscriptionListTableViewCell: UITableViewCell {

    @IBOutlet weak var title_Label: UILabel!
    
    @IBOutlet weak var arrow_ImageIcon: UIImageView!
    
    @IBOutlet weak var subscriptionTypeLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
