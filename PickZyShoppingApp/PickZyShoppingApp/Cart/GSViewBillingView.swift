//
//  GSViewBillingView.swift
//  Shopor
//
//  Created by Ratheesh on 14/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSViewBillingView: NibView {
    
    @IBOutlet weak var billing_tableView: UITableView!
    @IBOutlet weak var bgView_topConstraint: NSLayoutConstraint!
    
    var tableData_dictionary = [String:[GSViewBillingProduct]]()
    var tableData_array = [String]()
    
    var prices: GSViewBillingPrices?
    let footerHeight:CGFloat = 120  //180
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    // MARK: - Setting up this view
    
    private func setUpThisView() {
        
        billing_tableView.dataSource = self
        billing_tableView.delegate = self
        
        let cell_nib = UINib(nibName: GSString.NibNames.GSViewBillingTableCell, bundle: nil)
        billing_tableView.register(cell_nib, forCellReuseIdentifier: GSString.CellIdentifier.ViewBilling_tableCell)
        
        let footer_nib = UINib(nibName: GSString.NibNames.GSViewBillingFooterView, bundle: nil)
        billing_tableView.register(footer_nib, forHeaderFooterViewReuseIdentifier: GSViewBillingFooterView.identifier)
        
    }
    
    // MARK: - Intializing with Data
    
    func intializeWithDataModel( billing_data: GSViewBillingData?) {
        
        prices = billing_data?.prices
        
        guard let storeWithProducts = billing_data?.stores else { return }
        
        for storeItem in  storeWithProducts {
            
//            guard let products_array = storeItem.products else { continue }
            let products_array = storeItem.products
            
            for product in products_array {
                
                let product_id = product.id
                
                if tableData_dictionary[product_id] != nil {
                    guard var productArray_local = tableData_dictionary[product_id] else { continue }
                    productArray_local.append(product)
                    tableData_dictionary[product_id] = productArray_local
                    
                } else {
                    tableData_dictionary[product_id] = [product]
                }
                
            }
        }
        
        tableData_array = Array(tableData_dictionary.keys)
        
        billing_tableView.reloadData()
    }
    
    func showTheViewOn (_ parenView:UIView) {
        
        parenView.addSubview(self)
        
        initThisViewWithConstraints(parenView)
        
        let heightOfParent = parenView.frame.size.height
        bgView_topConstraint.constant = heightOfParent
        layoutIfNeeded()
        self.bgView_topConstraint.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.layoutIfNeeded()
            
        },completion: { _ in
            
        })
    }
    
    func initThisViewWithConstraints(_ parenView:UIView) {
        
        // Call this method after adding this class as subview
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let topLayoutGuideLength = GSTopViewController.topViewController().view.safeAreaInsets.top
        let bottomLayoutGuideLength = GSTopViewController.topViewController().view.safeAreaInsets.bottom
        
        let leading = NSLayoutConstraint.init(item: self, attribute: .leading, relatedBy: .equal, toItem: parenView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: parenView, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: parenView, attribute: .top, multiplier: 1, constant: topLayoutGuideLength)
        let bottom = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: parenView, attribute: .bottom, multiplier: 1, constant: -bottomLayoutGuideLength)
        NSLayoutConstraint.activate([leading,trailing,top,bottom])
    }
    
    
    // MARK: - Action Methods
    
    @IBAction func closeThisView(_ sender: UIButton) {
        
        let height = frame.size.height
        bgView_topConstraint.constant = 0
        layoutIfNeeded()
        self.bgView_topConstraint.constant = height
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundColor = UIColor.clear
            self.layoutIfNeeded()
            
        },completion: { _ in
            self.removeFromSuperview()
        })
    }
}

// MARK: - UITableView Methods

extension GSViewBillingView:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.ViewBilling_tableCell) as? GSViewBillingTableCell else {
            return UITableViewCell()
        }
        
        let idAtIndex = tableData_array[indexPath.row]
        
        if let valueAtIndex = tableData_dictionary[idAtIndex] {
            cell.configureTheCell(products: valueAtIndex)
        }
        
        return cell
    }
    
    
    // MARK: - UITableView Footer View Methods
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let footer_view = tableView.dequeueReusableHeaderFooterView(withIdentifier: GSViewBillingFooterView.identifier) as? GSViewBillingFooterView else {
            return UIView()
        }
        
        if let unwrapped_prices = prices {
            footer_view.configureTheFooterView(prices: unwrapped_prices)
        }
        
        return footer_view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}
