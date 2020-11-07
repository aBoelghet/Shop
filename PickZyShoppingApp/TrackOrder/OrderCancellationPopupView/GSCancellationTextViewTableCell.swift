//
//  GSCancellationTextViewTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 29/03/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSCancellationTextViewTableCell: UITableViewCell {
    
    @IBOutlet weak var feedback_txtView:GSBaseTextView!
    @IBOutlet weak var txtViewBG_view:GSCornerEdgeView!
    @IBOutlet weak var no_btn:GSBaseButton!
    @IBOutlet weak var cancelOrder_Btn:GSBaseButton!

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
        txtViewBG_view.layer.borderColor = UIColor(hexString: defaultTheme.GSOrderCancellationPopUpView_cell_Layer_border).cgColor
        txtViewBG_view.backgroundColor = UIColor(hexString: defaultTheme.GSOrderCancellationPopUpView_cell_txtView_bg)
        
//        for btn in [no_btn,cancelOrder_Btn] {
//            btn?.layer.borderColor = UIColor(hexString: defaultTheme.GSOrderCancellationPopUpView_cell_Layer_border).cgColor
//            btn?.setTitleColor(UIColor(hexString: defaultTheme.GSOrderCancellationPopUpView_cell_btn_title), for: .normal)
//        }
        
        no_btn.layer.borderColor = UIColor(hexString: defaultTheme.GSOrderCancellationPopUpView_cell_Layer_border).cgColor
        no_btn.setTitleColor(UIColor(hexString: defaultTheme.GSOrderCancellationPopUpView_cell_btn_title), for: .normal)
        
        cancelOrder_Btn.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_submitBtn_BG)
        cancelOrder_Btn.setTitleColor(UIColor(hexString: defaultTheme.verifyItems_submitBtn_title), for: .normal)
    }
}
