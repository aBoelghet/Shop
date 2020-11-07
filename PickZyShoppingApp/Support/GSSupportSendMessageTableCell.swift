//
//  GSSupportSendMessageTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 06/03/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSSupportSendMessageTableCell: UITableViewCell {
    
    @IBOutlet weak var title_lbl:GSBaseLabel!
    @IBOutlet weak var email_txtField:GSBaseTextField!
    @IBOutlet weak var message_txtView:GSBaseTextView!
    @IBOutlet weak var submit_btn:GSBaseButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        applyColorsForUI()
        settingUpCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Setting up Cell
    
    private func settingUpCell() {
        
    }
    
    // MARK: - Apply Colors for Cell
    
    private func applyColorsForUI() {
        title_lbl.textColor = UIColor(hexString: defaultTheme.SupportVC_text)
        email_txtField.layer.borderColor = UIColor(hexString: defaultTheme.SupportVC_border).cgColor
        message_txtView.layer.borderColor = UIColor(hexString: defaultTheme.SupportVC_border).cgColor
        submit_btn.layer.borderColor = UIColor(hexString: defaultTheme.SupportVC_border).cgColor
        submit_btn.setTitleColor(UIColor(hexString: defaultTheme.SupportVC_submitBtn_title), for: .normal)
    }

}
