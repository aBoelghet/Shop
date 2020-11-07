//
//  GSOrderInvoiceFooterView.swift
//  Shopor
//
//  Created by Ratheesh on 06/08/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSOrderInvoiceFooterView: UITableViewHeaderFooterView {

    static let identifier = "orderInvoice_footerView"

    @IBOutlet weak var itemTotal_lbl: GSBaseLabel!
    @IBOutlet weak var gst_lbl: GSBaseLabel!
    @IBOutlet weak var delivery_lbl: GSBaseLabel!
    
    @IBOutlet weak var discountKey_lbl: GSBaseLabel!
    @IBOutlet weak var discount_lbl: GSBaseLabel!
    
    @IBOutlet weak var totalAmount_lbl: UILabel!
    @IBOutlet weak var totalAmountKey_lbl: UILabel!
    @IBOutlet weak var cashBackKey_lbl: GSBaseLabel!
    @IBOutlet weak var cashBack_lbl: GSBaseLabel!
    
    @IBOutlet weak var GST_stackView: UIStackView!
    @IBOutlet weak var deliveryCharges_stackView: UIStackView!
    @IBOutlet weak var discount_stackView: UIStackView!
    @IBOutlet weak var cashBack_stackView: UIStackView!
    @IBOutlet weak var normalDiscount_stackView: UIStackView!
    @IBOutlet weak var normalDiscount_lbl: GSBaseLabel!
}
