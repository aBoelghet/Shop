//
//  GSComplaintNestedComplaintLableTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 17/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSComplaintNestedComplaintLableTableCell: UITableViewCell {

    @IBOutlet weak var complaintTitle_lbl:GSBaseLabel!
    @IBOutlet weak var selection_imgView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        complaintTitle_lbl.textColor = UIColor(hexString: defaultTheme.verifyItems_cell_complaintRadio_title)
        contentView.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_complaintCell_BG)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
