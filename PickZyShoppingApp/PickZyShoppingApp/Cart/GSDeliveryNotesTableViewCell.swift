//
//  GSDeliveryNotesTableViewCell.swift
//  Shopor
//
//  Created by Sravan Kumar on 5/9/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSDeliveryNotesTableViewCell: UITableViewCell {
    
    static let identifier = "deliveryNotesCell"
    
    @IBOutlet weak var info_lbl:GSBaseLabel!
    @IBOutlet weak var txtViewBG_view:GSCornerEdgeView!
    @IBOutlet weak var notes_txtView:UITextView!
    @IBOutlet weak var attachment_btn:UIButton!
    @IBOutlet weak var selected_imgView:UIImageView!
    @IBOutlet weak var uploadBg_view:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        applyColorsForUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Apply colors for UI
    
    func applyColorsForUI() {
        txtViewBG_view.layer.borderColor = UIColor(hexString: defaultTheme.NAVIGATION_BOTTOM_LINE).cgColor
        info_lbl.textColor = UIColor(hexString: defaultTheme.OrderAddressConfirmationVC_cell_header)
        notes_txtView.textColor = UIColor(hexString: "000000")
    }
}
