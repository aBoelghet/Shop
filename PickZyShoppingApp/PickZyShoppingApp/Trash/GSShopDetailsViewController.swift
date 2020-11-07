//
//  GSShopDetailsViewController.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 5/25/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSShopDetailsViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationForShopDetails!

    @IBOutlet weak var leftHeader_lbl:GSBaseLabel!
    @IBOutlet weak var rightHeader_lbl:GSBaseLabel!
    @IBOutlet weak var shopDetails_tableView: UITableView!
    
    var shopDetailsArray = [OrderDetailsWithShops]()
    var expandedSections:NSMutableIndexSet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFewIntializers()
        applyColors()
        
        showPaymentStatusAlert()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        
        leftHeader_lbl.textColor = UIColor(hexString: defaultTheme.shopDetails_leftHeader_title)
        rightHeader_lbl.textColor = UIColor(hexString: defaultTheme.shopDetails_rightHeader_title)

        shopDetails_tableView.backgroundColor = UIColor(hexString: defaultTheme.shopDetails_Table_BG)
    }
    
    // MARK: User defined Methods
    
    func addFewIntializers() {
        
        navigationBar_view.delegate = self
        shopDetails_tableView.delegate = self
        shopDetails_tableView.dataSource = self
        
        let simpleRowCellNib = UINib.init(nibName: GSString.NibNames.GSOrderProductTableCell, bundle: nil)
        shopDetails_tableView.register(simpleRowCellNib, forCellReuseIdentifier: GSString.CellIdentifier.ShopDetailsVC_order_tableCell)
        
        shopDetailsArray = OrderDetailsWithShops.orderDetailsArray
        
        if expandedSections == nil {
            expandedSections =  NSMutableIndexSet()
        }
        shopDetails_tableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    fileprivate func showPaymentStatusAlert() {
        
        GSAlertController.initialization().showAlertWithDetails(title: "Payment Status", aStrMessage: "Payment made successfully", detailText: "RS:300",aCancelBtnTitle: "View Invoice", aOtherBtnTitle: "OK"){ (index, title) in
            #if DEBUG
                print(index,title)
            #endif
            if index == 1 {
            }
        }
        
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton){
        
        
        for vc in (self.navigationController?.viewControllers)!.reversed() {
            
            if vc is GSShopsViewController {
                
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
    }
    @IBAction func trackingButtonPressed(_ sender: UIButton){
        
        if let trackInMapVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSTrackOrderMapViewController) as? GSTrackOrderMapViewController {
            if let navigator = navigationController {
                navigator.pushViewController(trackInMapVC, animated: true)
            }
        }
    }
}


extension GSShopDetailsViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return shopDetailsArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if expandedSections.contains(section) {
            return shopDetailsArray[section].products.count + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionIdentifier = GSString.CellIdentifier.ShopDetailsVC_shop_tableCell
        let rowIdentifier = GSString.CellIdentifier.ShopDetailsVC_order_tableCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: sectionIdentifier) as? GSShopDetailsTableCell else {
            return UITableViewCell()
        }
        let shopDetailModel = shopDetailsArray[indexPath.section]
        cell.configureTheCell(shopDetailModel.shopAddress)
        cell.bg_view.addShadowEffectWith(color: UIColor.black, opacity: 0, shadowRadius: 0, shadowOffset: CGSize(width: 0, height: 0))
        if indexPath.section == shopDetailsArray.count - 1 && !expandedSections.contains(indexPath.section) {
            cell.bg_view.addShadowEffectWith(color: UIColor.black, opacity: 0.5, shadowRadius: 2.0, shadowOffset: CGSize(width: 0, height: 1))
        }
        
        if expandedSections.contains(indexPath.section) {
            let currentRow = indexPath.row - 1
            
            if currentRow >= 0 {
                
                guard let rowCell = tableView.dequeueReusableCell(withIdentifier: rowIdentifier) as? GSOrderProductTableCell else {
                    return UITableViewCell()
                }

                let products = shopDetailModel.products[currentRow]
                rowCell.configureTheCell(products)
                return rowCell
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section: Int = indexPath.section
        let currentlyExpanded: Bool = expandedSections.contains(section)
        var rows: Int
        var tmpArray = [Any]()
        
        if currentlyExpanded {
            rows = self.tableView(tableView, numberOfRowsInSection: section)
            
            if indexPath.row == 0 { // Section selected
                expandedSections.remove(section)
            } else {            // Row selected
                
                return
            }
        } else {
            expandedSections.add(section)
            rows = self.tableView(tableView, numberOfRowsInSection: section)
        }
        
        for i in 1..<rows {
            let tmpIndexPath = IndexPath(row: i, section: section)
            tmpArray.append(tmpIndexPath)
        }
        if currentlyExpanded {
            tableView.deleteRows(at: tmpArray as? [IndexPath] ?? [IndexPath](), with: .top)
        } else {
            tableView.insertRows(at: tmpArray as? [IndexPath] ?? [IndexPath](), with: .top)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            if expandedSections.contains(indexPath.section) {
                if indexPath.row == 0{
                    return 120.0
                }
                return 85.0
            }
            return 120.0
    }
}

 // MARK:- NavigationBar Methods

extension GSShopDetailsViewController:NavigationForShopDetailsDelegate {

    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender:UIButton) {
        
        for vc in (self.navigationController?.viewControllers)!.reversed() {
            
            if vc is GSShopsViewController {
                
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
    }
}

