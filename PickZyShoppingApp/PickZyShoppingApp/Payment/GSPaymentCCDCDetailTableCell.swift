//
//  GSPaymentCCDCDetailTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 06/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPaymentCCDCDetailTableCell: UITableViewCell {
    
    @IBOutlet weak var cardNo_lbl:GSBaseLabel!
    @IBOutlet weak var expiry_lbl:GSBaseLabel!
    @IBOutlet weak var card_imgView:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyColorsForUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Apply Colors
    
    private func applyColorsForUI() {
        cardNo_lbl.textColor = UIColor(hexString: defaultTheme.CCDCDetailVC_cell_text)
        expiry_lbl.textColor = UIColor(hexString: defaultTheme.CCDCDetailVC_cell_text)
    }
}
