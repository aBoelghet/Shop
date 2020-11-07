//
//  GSProductReportTextViewTableViewCell.swift
//  Shopor
//
//  Created by Ratheesh on 07/02/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductReportTextViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var report_txtView:UITextView!
    @IBOutlet weak var bottomLine_view:UIView!
    @IBOutlet weak var reportTxtViewBG_view:GSCornerEdgeView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = UIColor(hexString: defaultTheme.ProductReportsVC_tableBG)
        reportTxtViewBG_view.layer.borderColor = UIColor(hexString: defaultTheme.ProductReportsVC_textViewBorder).cgColor
        reportTxtViewBG_view.layer.borderWidth = 0.5
        bottomLine_view.backgroundColor = UIColor(hexString: defaultTheme.ProductReportsVC_bottomLine)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
