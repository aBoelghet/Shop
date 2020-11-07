//
//  GSPurchasedProductsViewController.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 6/6/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSPurchasedProductsViewController: GSLoggedInBaseViewController {
    
    @IBOutlet var navigationBar_view: NavigationBarNormal!
    @IBOutlet var purchasedProducts_tableView: UITableView!
    
//    let headerHeight:CGFloat = 50
    
    var shopsArray = NSMutableArray()
    
//    var orderDetailItem: GSPurchasedListDataOrderDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: User defined methods
    
    private func addFewIntializers() {
        navigationBar_view.delegate = self
        purchasedProducts_tableView.delegate = self
        purchasedProducts_tableView.dataSource = self
        purchasedProducts_tableView.tableFooterView = UIView()
    }

}

extension GSPurchasedProductsViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if let product_array = orderDetailItem?.products {
//            return product_array.count
//        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = GSString.CellIdentifier.PurchasedProductsVC_tableCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GSPurchasedProductTableCell else {
            return UITableViewCell()
        }
        
//        if let product_array = orderDetailItem?.products {
//            let product = product_array[indexPath.row]
////            cell.configureTheCell(product: product)
//        }
        
        cell.review_btn.addTarget(self, action: #selector(cell_writeReview_Action(_:)), for: .touchUpInside)
        cell.review_btn.tag = indexPath.row
        
//        cell.bg_view.addShadowEffectWith(color: UIColor.gray, opacity: 0, shadowRadius: 0, shadowOffset: CGSize.init(width: 0.0, height: 0.0))
//        if indexPath.row == 2 {
//            cell.bg_view.addShadowEffectWith(color: UIColor.gray, opacity: 0.5, shadowRadius: 3.0, shadowOffset: CGSize.init(width: 0.0, height: 3.0))
//        }
//
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let verifyItemsVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSVerifyItemsViewController) as? GSVerifyItemsViewController {
            if let navigator = navigationController {
                verifyItemsVC.isProductsDelivered = true
                navigator.pushViewController(verifyItemsVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    //MARK:- Cell Action Methods
    
    @objc func cell_writeReview_Action(_ sender:UIButton) {
        
        if let feedBackVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSStoreFeedbackViewController) as? GSStoreFeedbackViewController {
            if let navigator = navigationController {
                navigator.pushViewController(feedBackVC, animated: true)
            }
        }
    }
    
}

extension GSPurchasedProductsViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
}
