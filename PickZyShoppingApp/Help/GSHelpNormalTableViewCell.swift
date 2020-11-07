//
//  GSHelpTableViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 05/03/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSHelpNormalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var type_lbl:GSBaseLabel!

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
        type_lbl.textColor = UIColor(hexString: defaultTheme.SupportVC_text)
    }

}
