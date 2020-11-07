//
//  GSSupportContactTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 06/03/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSSupportContactTableCell: UITableViewCell {
    
    @IBOutlet weak var title_lbl:GSBaseLabel!
    @IBOutlet weak var contact_btn:GSBaseButton!
    @IBOutlet weak var availableTime_lbl: GSBaseLabel!
    
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
    }

}
