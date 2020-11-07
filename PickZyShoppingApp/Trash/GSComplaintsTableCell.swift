//
//  GSReportOnDeliveryTableCell.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 5/30/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSComplaintsTableCell: UITableViewCell {
    
    @IBOutlet weak var submit_btn: GSBaseButton!
    @IBOutlet weak var feed_txtView: GSBaseTextView!
    
    @IBOutlet weak var first_btn: GSBaseButton!
    @IBOutlet weak var second_btn: GSBaseButton!
    @IBOutlet weak var third_btn: GSBaseButton!
    @IBOutlet weak var fourth_btn: GSBaseButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let btn_array = [first_btn,second_btn,third_btn,fourth_btn]
        
        for btn in btn_array {
            btn?.setTitleColor(UIColor(hexString: defaultTheme.verifyItems_cell_complaintRadio_title), for: .normal)
        }
        
        contentView.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_complaintCell_BG)
//        submit_btn.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_complaintCell_submitBtn_BG)
        submit_btn.setTitleColor(UIColor(hexString: defaultTheme.verifyItems_complaintCell_submitBtn_title), for: .normal)
        submit_btn.layer.borderWidth = 1.0
        submit_btn.layer.borderColor = UIColor(hexString: defaultTheme.verifyItems_complaintCell_border).cgColor
        feed_txtView.layer.borderColor = UIColor(hexString: defaultTheme.verifyItems_complaintCell_border).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureTheCell(_ categories:[String]) {
        if categories.count > 3 {
            first_btn.setTitle(categories[0], for: .normal)
            second_btn.setTitle(categories[1], for: .normal)
            third_btn.setTitle(categories[2], for: .normal)
            fourth_btn.setTitle(categories[3], for: .normal)
        }
    }
}
