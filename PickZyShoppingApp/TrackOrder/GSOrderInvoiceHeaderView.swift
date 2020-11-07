//
//  GSOrderInvoiceHeaderView.swift
//  Shopor
//
//  Created by Ratheesh on 05/08/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSOrderInvoiceHeaderView: UITableViewHeaderFooterView {

    static let identifier = "orderInvoiceHeader"
    
    @IBOutlet weak var shopName_lbl: GSBaseLabel!
    @IBOutlet weak var shopAddress_lbl: GSBaseLabel!
    @IBOutlet weak var customerName_lbl: GSBaseLabel!
    @IBOutlet weak var customerAddress_lbl: GSBaseLabel!
    @IBOutlet weak var distance_lbl: GSBaseLabel!
    @IBOutlet weak var orderPlaced_lbl: GSBaseLabel!
    
    @IBOutlet weak var orderDelivered_lbl: GSBaseLabel!
    @IBOutlet weak var invoiceDetailsLblBG_view: UIView!
    @IBOutlet weak var cancelledOrRejected_lbl: UILabel!
}
