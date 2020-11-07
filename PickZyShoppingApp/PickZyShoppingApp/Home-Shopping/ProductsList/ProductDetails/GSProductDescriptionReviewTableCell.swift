//
//  GSProductDescriptionReviewTableCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 22/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductDescriptionReviewTableCell: UITableViewCell {
    
    @IBOutlet weak var userName_lbl:GSBaseLabel!
    @IBOutlet weak var date_lbl:GSBaseLabel!
    @IBOutlet weak var rating_view:FloatRatingView!
    @IBOutlet weak var reviewMsg_lbl:GSBaseLabel!
    @IBOutlet weak var lblBG_view:GSCornerEdgeView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        reviewMsg_lbl.backgroundColor = UIColor(hexString: defaultTheme.productDescVC_reviewsLabel_BG)
        lblBG_view.backgroundColor = UIColor(hexString: defaultTheme.productDescVC_reviewsLabel_BG)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Configuring The Cell
    func configureTheCell(reviewItem:[String:Any]) {
     
        let date:String? = reviewItem["at"] as? String
        date_lbl.text = GSCommonHelper.getDateTimeInTheSimpleFormat(dateStr: date, inputFormat: GSConstant.apiDateFormatter, reqFormat: GSConstant.appDateFormatter)
        
        reviewMsg_lbl.text = ""
        let message = reviewItem["message"] as? String ?? ""
        lblBG_view.isHidden = true
        
        if message != "" {
            lblBG_view.isHidden = false
            reviewMsg_lbl.text = message
        }
        
        let ratingGiven = reviewItem["rating"] as? Int ?? 0
        rating_view.rating = Double(ratingGiven)
        
        userName_lbl.text = reviewItem["name"] as? String ?? ""
    }
}
