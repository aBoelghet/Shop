//
//  GSDeliveryPreferenceTableCell.swift
//  Shopor
//
//  Created by Sravan Kumar on 5/9/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSDeliveryPreferenceTableCell: UITableViewCell {
    
    
    static let identifier = "orderconfirmationFooterView"
    
    @IBOutlet weak var info_lbl:GSBaseLabel!
    @IBOutlet weak var date_lbl:GSBaseLabel!
    @IBOutlet weak var timeSlot_lbl:GSBaseLabel!
    @IBOutlet weak var dateBG_view:GSCornerEdgeView!
    @IBOutlet weak var timeSlotBG_view:GSCornerEdgeView!
    @IBOutlet weak var dateSelection_btn:UIButton!
    @IBOutlet weak var timeSlotSelection_btn:UIButton!
    @IBOutlet weak var checkBox_btn:UIButton!
    @IBOutlet weak var preferenceTimeSelectionBG_view:UIView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let heightOfBtn = checkBox_btn.frame.size.height      // This is the original height of the stack view
        
        if heightOfBtn > 15 {
            let insetRequired = (heightOfBtn - 15) / 2
            checkBox_btn?.imageEdgeInsets = UIEdgeInsetsMake(insetRequired, insetRequired, insetRequired, insetRequired)
            checkBox_btn?.imageView?.contentMode = .scaleAspectFit
        }
    }

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
        dateBG_view.layer.borderColor = UIColor(hexString: defaultTheme.NAVIGATION_BOTTOM_LINE).cgColor
        timeSlotBG_view.layer.borderColor = UIColor(hexString: defaultTheme.NAVIGATION_BOTTOM_LINE).cgColor
        info_lbl.textColor = UIColor(hexString: "000000")
        date_lbl.textColor = UIColor(hexString: "000000")
        timeSlot_lbl.textColor = UIColor(hexString: "000000")
    }
}
