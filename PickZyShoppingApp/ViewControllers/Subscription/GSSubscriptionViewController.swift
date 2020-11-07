//
//  GSSubscriptionViewController.swift
//  PickZyShoppingApp
//
//  Created by Purushoth on 03/09/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSSubscriptionViewController: GSLoggedInBaseViewController {

    @IBOutlet weak var productsTable: UITableView!
    @IBOutlet weak var payNowBtn : UIButton!
    @IBOutlet weak var navigationBar_view: NavigationWithSearchBar!
    @IBOutlet weak var bottomStackBg_view:UIView!
    @IBOutlet weak var customizeOrder_btn:UIButton!
    @IBOutlet weak var deliveryMode_btn:UIButton!
    @IBOutlet weak var payMentIcon_btn:UIButton!
    @IBOutlet weak var customizeOrder_lbl: GSBaseLabel!
    @IBOutlet weak var deliveryMode_lbl: GSBaseLabel!
    @IBOutlet weak var paymentIcon_view: GSCornerEdgeView!
    
    
    var tableArray   = NSMutableArray()
    let productsArray = cartItemsModel.cartItemsArray
    var dataTempArray = NSMutableArray()
    var cartlistCell = UITableViewCell()
    var itemSelectedIdx = [true]
    
    var popUp_view:GSSubscriptionPopupView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
        applyColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableArray = cartItemsModel.cartItemsArray
        for _ in 0..<tableArray.count {
            itemSelectedIdx.append(true)
        }
    }
    
    private func applyColors() {
        bottomStackBg_view.backgroundColor = UIColor(hexString: defaultTheme.cart_BottomStack_BG)
        payNowBtn.backgroundColor = UIColor(hexString: defaultTheme.cart_MakePayment_BG)
        payNowBtn.setTitleColor(UIColor(hexString: defaultTheme.cart_MakePaymentBtn_title), for: .normal)
        payNowBtn.layer.borderColor = UIColor(hexString: defaultTheme.cart_MakePaymentBtn_border).cgColor
        payNowBtn.layer.borderWidth = 1.0
        customizeOrder_lbl.backgroundColor = UIColor(hexString: defaultTheme.cart_customOrderBtn_BG)
        customizeOrder_lbl.textColor = UIColor(hexString: defaultTheme.cart_customOrderBtn_title)
        deliveryMode_lbl.backgroundColor = UIColor(hexString: defaultTheme.cart_deliveryModeBtn_BG)
        deliveryMode_lbl.textColor = UIColor(hexString: defaultTheme.cart_deliveryModeBtn_title)
        paymentIcon_view.backgroundColor = UIColor(hexString: defaultTheme.cart_paymentIconBtn_BG)
    }
    
    // MARK: User defined Methods
    private func addFewIntializers() {
        
        navigationBar_view.delegate = self
        navigationBar_view.navigSearchBar.delegate = self
        navigationBar_view.cartIconView.isHidden = true
        
        productsTable.tableFooterView = UIView()
        
        popUp_view = GSSubscriptionPopupView()
        popUp_view.delegate = self
    }
    
    fileprivate func addPopupView() {
        if popUp_view != nil {
            if popUp_view.isDescendant(of: self.view) {
                return
            }
            popUp_view = nil
        }
        popUp_view = GSSubscriptionPopupView()
        popUp_view.delegate = self
        popUp_view.showTheViewFromBottom(on: view, for: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom), completionHandler: {})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GSSubscriptionViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 110.0
        } else {
            return 120.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = GSString.CellIdentifier.CartVC_cartList_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSCartListTableCell else {
            return UITableViewCell()
        }
        
        cell.btnSel.tag = indexPath.row
        if itemSelectedIdx[indexPath.row] {
            cell.btnSel.setImage(UIImage(named: "Check_icon"), for: .normal)
        } else {
            cell.btnSel.setImage(UIImage(named: "Uncheck_icon"), for: .normal)
        }
        return cell
    }
}

extension GSSubscriptionViewController:NavigationWithSearchBarDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
    }
    
    func rightBarBtnPressed(sender: UIButton) {

        let alertController = UIAlertController.init(title: "Menu", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let options_array = ["Subscribe","Save"]
        
        for option in options_array {
            
            let alertAction = UIAlertAction.init(title: option, style: .default) { _ in
                
                if option == "Subscribe"{
                    self.addPopupView()
                }
            }
            alertController.addAction(alertAction)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if let currentPopoverpresentioncontroller = alertController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = navigationBar_view.rightBarBtn
                let btnFrame = navigationBar_view.rightBarBtn.frame
                currentPopoverpresentioncontroller.sourceRect = CGRect(x: 0, y: 0, width: btnFrame.size.width, height: btnFrame.size.height)
                currentPopoverpresentioncontroller.permittedArrowDirections = .up
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension GSSubscriptionViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            if tableArray.count > 0 {
                tableArray.removeAllObjects()
            }
            let localArray = NSMutableArray(array:productsArray.filter({ (shopModel) -> Bool in
                let tmpShopModel = shopModel as! cartItemsModel
                let tmp = tmpShopModel.productName as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            }))
            tableArray = localArray.mutableCopy() as! NSMutableArray
        } else {
            tableArray = productsArray.mutableCopy() as! NSMutableArray
        }
        productsTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableArray = productsArray.mutableCopy() as! NSMutableArray
        productsTable.reloadData()
    }
}

extension GSSubscriptionViewController : GSSubscriptionPopupDelegate {

    func durationAction(sender: UIButton) {
        
        let alertController = UIAlertController.init(title: "", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let options_array = ["Yearly","6 Months Once", "3 Months Once", "Monthly", "Weekly", "Daily"]
        
        for option in options_array {
            
            let alertAction = UIAlertAction.init(title: option, style: .default) { _ in
                
               self.popUp_view.duration_lbl.text = option
            }
            alertController.addAction(alertAction)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if let currentPopoverpresentioncontroller = alertController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = navigationBar_view.rightBarBtn
                let btnFrame = navigationBar_view.rightBarBtn.frame
                currentPopoverpresentioncontroller.sourceRect = CGRect(x: 0, y: 0, width: btnFrame.size.width, height: btnFrame.size.height)
                currentPopoverpresentioncontroller.permittedArrowDirections = .up
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func dateAction(sender: UIButton) {
    }
    
    func okAction(sender: UIButton) {
    }
}
