//
//  GSProductReviewHeaderView.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 22/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductReviewHeaderView: UITableViewHeaderFooterView {
    
    static let headerIdentifier = "productReviewHeader"
    
    @IBOutlet weak var reviewCount_lbl:GSBaseLabel!
    @IBOutlet weak var reviewKey_lbl:GSBaseLabel!
    @IBOutlet weak var rating_view:FloatRatingView!

}
