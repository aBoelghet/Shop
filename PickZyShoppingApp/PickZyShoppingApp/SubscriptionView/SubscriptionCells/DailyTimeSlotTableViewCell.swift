//
//  DailyTimeSlotTableViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 24/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class DailyTimeSlotTableViewCell: UITableViewCell {

    @IBOutlet weak var dotView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dotView.layer.cornerRadius = dotView.frame.height / 2
        dotView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
