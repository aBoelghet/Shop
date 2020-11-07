//
//  GSRadioButtonTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 29/03/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSRadioButtonTableCell: UITableViewCell {
    
    @IBOutlet weak var cell_lbl:GSBaseLabel!
    @IBOutlet weak var icon_imgView:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        applyColorsForUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Applying Colors For UI
    
    private func applyColorsForUI() {
        cell_lbl.textColor = UIColor(hexString: defaultTheme.GSOrderCancellationPopUpView_cell_label)
    }
}
