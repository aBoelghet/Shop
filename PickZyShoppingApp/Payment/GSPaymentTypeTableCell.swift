//
//  GSPaymentTypeTableCell.swift
//  SampleSwift
//
//  Created by Ratheesh TR on 20/02/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit

class GSPaymentTypeTableCell: UITableViewCell {
    
    @IBOutlet weak var cellIcon: UIImageView!
    @IBOutlet weak var topLabel: GSBaseLabel!
    @IBOutlet weak var selectionImage: UIImageView!
    
    @IBOutlet weak var iconImageWidth: NSLayoutConstraint!
    @IBOutlet weak var bg_view:UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(hexString: defaultTheme.paymentOpt_BorderC)
        bg_view.backgroundColor = UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
}
