//
//  GSComplaintsNestedComplaintActionTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 17/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSComplaintsNestedComplaintActionTableCell: UITableViewCell {
    
    @IBOutlet weak var submit_btn: GSBaseButton!
    @IBOutlet weak var feed_txtView: GSBaseTextView!
    
    @IBOutlet weak var attachment_btn:UIButton!
    @IBOutlet weak var first_imgView:UIImageView!
    @IBOutlet weak var second_imgView:UIImageView!
    @IBOutlet weak var third_imgView:UIImageView!
    
    @IBOutlet weak var first_btn:UIButton!
    @IBOutlet weak var second_btn:UIButton!
    @IBOutlet weak var third_btn:UIButton!
    
    @IBOutlet weak var charactersCount_lbl:GSBaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        contentView.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_complaintCell_BG)

//        submit_btn.setTitleColor(UIColor(hexString: defaultTheme.verifyItems_complaintCell_submitBtn_title), for: .normal)
//        submit_btn.layer.borderWidth = 1.0
//        submit_btn.layer.borderColor = UIColor(hexString: defaultTheme.verifyItems_complaintCell_border).cgColor
        feed_txtView.layer.borderColor = UIColor(hexString: defaultTheme.verifyItems_complaintCell_border).cgColor
        
        submit_btn.setTitle("Done", for: .normal)
        
        submit_btn.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_submitBtn_BG)
        submit_btn.setTitleColor(UIColor(hexString: defaultTheme.verifyItems_complaintCell_submitBtn_title), for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
