//
//  GSProductDetailsHeaderView.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 22/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSProductDetailsHeaderView: UITableViewHeaderFooterView {
    
    static let headerIdentifier = "productDetailsHeader"
    
    @IBOutlet weak var productTitle_lbl: GSBaseLabel!
    @IBOutlet weak var productMrp_lbl: GSBaseLabel!
    @IBOutlet weak var releaseDate_lbl: GSBaseLabel!
    
}
