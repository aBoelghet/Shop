//
//  GSCustomOrderProductDetailsTableCell.swift
//  Shopor-dev
//
//  Created by Ratheesh on 16/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSCustomOrderProductDetailsTableCell: UITableViewCell {
    
    @IBOutlet weak var billing_tableView:UITableView!
    
    var prices: GSCustomizeOrderPrices?
    var products = [GSCustomizeOrderProduct]()
    var isAutoSelected = false
    
    let footerHeight:CGFloat = 110
    let autoSelectedFooterHeight:CGFloat = 30

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Setting Up The Cell
    
    private func setUpCell() {
        
        billing_tableView.dataSource = self
        billing_tableView.delegate = self
        
        let cell_nib = UINib(nibName: GSString.NibNames.GSViewBillingTableCell, bundle: nil)
        billing_tableView.register(cell_nib, forCellReuseIdentifier: GSString.CellIdentifier.ViewBilling_tableCell)
        
        let footer_nib = UINib(nibName: GSString.NibNames.GSViewBillingFooterView, bundle: nil)
        billing_tableView.register(footer_nib, forHeaderFooterViewReuseIdentifier: GSViewBillingFooterView.identifier)
        
        backgroundColor = UIColor(hexString: defaultTheme.customOrder_shopCell_BG)
    }
    
    // MARK: - Intializing The Data
    
    func intializeTheDataWith(product_array:[GSCustomizeOrderProduct]?, price_item:GSCustomizeOrderPrices? , isAutoSelectedBool:Bool) {
        self.products = product_array ?? [GSCustomizeOrderProduct]()
        self.prices = price_item
        self.isAutoSelected = isAutoSelectedBool
        billing_tableView.reloadData()
    }

}

// MARK: - UITableView Methods

extension GSCustomOrderProductDetailsTableCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.ViewBilling_tableCell) as? GSViewBillingTableCell else {
            return UITableViewCell()
        }
        cell.configureTheCellForCustomizeOrder(product: products[indexPath.row])
        
        return cell
    }
    
    // MARK: - UITableView Footer View Methods
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let footer_view = tableView.dequeueReusableHeaderFooterView(withIdentifier: GSViewBillingFooterView.identifier) as? GSViewBillingFooterView else {
            return UIView()
        }
        
        if let unwrapped_prices = prices {
            footer_view.configureTheFooterViewForCustomOrder(prices: unwrapped_prices, isAutoSelected: isAutoSelected)
        }
        
        return footer_view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return isAutoSelected ? autoSelectedFooterHeight : footerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}
