//
//  GSMessageWithActionsTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 21/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSMessageWithActionsTableCell: UITableViewCell {
    
    @IBOutlet weak var remainingTime_lbl:GSBaseLabel!
    @IBOutlet weak var title_lbl:GSBaseLabel!
    @IBOutlet weak var message_lbl:GSBaseLabel!
    @IBOutlet weak var time_lbl:GSBaseLabel!
    
    @IBOutlet weak var okay_btn:UIButton!
    @IBOutlet weak var deny_btn:UIButton!
    @IBOutlet weak var actionStatus_btn:UIButton!
    @IBOutlet weak var bubble_imgView:UIImageView!
    
    @IBOutlet weak var twoBtnsBG_view:UIView!
    @IBOutlet weak var singleBtnBG_view:UIView!
    
    @IBOutlet weak var bg_view:GSCornerEdgeView!
    @IBOutlet weak var headerBg_view:UIView!
    
    @IBOutlet weak var timeIcon_imgView:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        message_lbl.textColor = UIColor(hexString: defaultTheme.MessageVC_message_text)
        deny_btn.backgroundColor = UIColor(hexString: defaultTheme.MessageVC_message_denyBtn_bg)
        remainingTime_lbl.textColor = UIColor(hexString: defaultTheme.MessageVC_message_denyBtn_bg)
        okay_btn.backgroundColor = UIColor(hexString: defaultTheme.MessageVC_message_acceptBtn_bg)
        bg_view.backgroundColor = UIColor(hexString: defaultTheme.MessageVC_actionMessage_bg)
        
        if timeIcon_imgView != nil {
            timeIcon_imgView.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
