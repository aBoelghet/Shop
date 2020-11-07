//
//  GSOrderPlacedAddressTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 03/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSOrderPlacedAddressTableCell: UITableViewCell {
    
    @IBOutlet weak var address_lbl:GSBaseLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyColorsForUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Apply Colors for UI
    
    private func applyColorsForUI() {
        address_lbl.textColor = UIColor(hexString: defaultTheme.OrderPlacedVC_cell_text)
    }
    
    // MARK: - Configuring The Cell
    
    func configureTheCell(addressSting:String) {
        address_lbl.text = addressSting
    }
}
