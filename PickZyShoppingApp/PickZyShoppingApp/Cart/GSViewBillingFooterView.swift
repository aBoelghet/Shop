//
//  GSViewBillingFooterView.swift
//  Shopor
//
//  Created by Ratheesh on 14/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSViewBillingFooterView: UITableViewHeaderFooterView {

    static let identifier = "viewBilling_footer"
    
    @IBOutlet weak var itemTotal_lbl: GSBaseLabel!
    @IBOutlet weak var gst_lbl: GSBaseLabel!
    @IBOutlet weak var delivery_lbl: GSBaseLabel!
    @IBOutlet weak var total_lbl: GSBaseLabel!
    @IBOutlet weak var discount_lbl: GSBaseLabel!
    @IBOutlet weak var cashBack_lbl: GSBaseLabel!
    @IBOutlet weak var toPay_lbl: GSBaseLabel!
    @IBOutlet weak var toPay_stackView: UIStackView!
    @IBOutlet weak var cashBack_stackView: UIStackView!
    @IBOutlet weak var discount_stackView: UIStackView!
    @IBOutlet weak var itemTotalGstDelivery_stackView: UIStackView!
    @IBOutlet weak var totalCashbackDiscountStackView: UIStackView!
    
    // MARK: - Configuring Footer View
    
    func configureTheFooterView(prices:GSViewBillingPrices) {
        
        itemTotal_lbl.text = GSCommonHelper.formattedPrice(price: prices.grossPrice) + " " //GSConstant.currency_symbol + " \(prices.grossPrice )"
        gst_lbl.text = GSCommonHelper.formattedPrice(price: prices.taxes) + " " //GSConstant.currency_symbol + " \(prices.taxes )"
        delivery_lbl.text = GSConstant.currency_symbol + " \(prices.delivery )"
        total_lbl.text = GSCommonHelper.formattedPrice(price: prices.grossPrice) + " " //GSConstant.currency_symbol + " \(prices.grossPrice )"
        toPay_lbl.text = GSCommonHelper.formattedPrice(price: prices.netPrice)

    }
    
    func configureTheFooterViewForCustomOrder(prices:GSCustomizeOrderPrices, isAutoSelected:Bool) {
        
        for stack_view in [toPay_stackView,cashBack_stackView,discount_stackView] {
            stack_view?.isHidden = isAutoSelected
        }
        
        itemTotalGstDelivery_stackView.isHidden = isAutoSelected
        totalCashbackDiscountStackView.isHidden = !isAutoSelected
        
        itemTotal_lbl.text = GSCommonHelper.formattedPrice(price: prices.grossPrice ?? 0)
        gst_lbl.text = GSCommonHelper.formattedPrice(price: prices.taxes ?? 0)
        delivery_lbl.text = GSConstant.currency_symbol + " \(prices.delivery ?? 0)"
        total_lbl.text = GSCommonHelper.formattedPrice(price: prices.grossPrice ?? 0)
        toPay_lbl.text = GSCommonHelper.formattedPrice(price: prices.netPrice ?? 0)
    }
}
