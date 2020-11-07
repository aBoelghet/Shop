//
//  GSWishListViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh Mac Mini on 02/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSWishListViewController: GSLoggedInBaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var cartTable: UITableView!
    @IBOutlet var navigationBar_view: NavigationWithSearchBar!
    
    var tableArray   = NSMutableArray()
    let cartArray = cartItemsModel.cartItemsArray
    var dataTempArray = NSMutableArray()
    var cartlistCell = UITableViewCell()
    var selectedIdx = [true]
    
//    let productDetailView = GSProductDescriptionView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addFewIntializers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableArray = cartItemsModel.cartItemsArray
        
        for _ in 0..<tableArray.count {
            selectedIdx.append(true)
            
        }
    }
    
    // MARK: User defined Methods
    
    func addFewIntializers() {
        
        navigationBar_view.delegate = self
        navigationBar_view.navigSearchBar.delegate = self
        navigationBar_view.cartIconView.isHidden = true
        cartTable.tableFooterView = UIView()
    }
    
    func onsearchandSelect(_ index: IndexPath) {
        
        for itemObj in cartArray{
            let itemModel = itemObj as! cartItemsModel
            let selectedModel = tableArray[index.row] as! cartItemsModel
            if (itemModel.productName == selectedModel.productName){
                //                let status = selectionStatusArray[cartArray.index(of:tableArray[index.row])]
                //                selectionStatusArray[cartArray.index(of:tableArray[index.row])] = !status
                //                let cell = cartTable.cellForRow(at: index) as! GSCartListTableCell
                //                cell.btnSel.isSelected = !status
            }
        }
    }
    
    //MARK: - Button actions
    @IBAction func btnSelect(_ sender: Any) {
        let btn = sender as? GSCheckboxButton
        btn?.checkedState = !(btn?.checkedState)!
        selectedIdx[(btn?.tag)!] = (btn?.checkedState)!
        if (btn?.checkedState)! {
            btn?.setImage(UIImage(named: "Check_icon"), for: .normal)
        }
        else{
            btn?.setImage(UIImage(named: "Uncheck_icon"), for: .normal)
        }
        
    }
    
    
    @IBAction func payNow(_ sender: Any) {
        
        if let pushVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSMakePaymentViewController) as? GSMakePaymentViewController {
            if let navigator = navigationController {
                navigator.pushViewController(pushVC, animated: true)
            }
        }
    }
    
    @IBAction func selectPaymentBtn(_ sender: UIButton) {
        
        if let pushVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPaymentTypeViewController) as? GSPaymentTypeViewController {
            if let navigator = navigationController {
                navigator.pushViewController(pushVC, animated: true)
            }
        }
    }
    
    @IBAction func selectDeliveryOption(_ sender:Any){
        
        if let tempVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSDeliveryOptionViewController) as? GSDeliveryOptionViewController {
            if let navigator = navigationController {
                navigator.pushViewController(tempVC, animated: true)
            }
        }
    }
    
    @IBAction func commonAction(_ sender: UIButton) {
        
        if let tempVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSPaymentTypeViewController) as? GSPaymentTypeViewController {
            if let navigator = navigationController {
                navigator.pushViewController(tempVC, animated: true)
            }
        }
    }
    
    @IBAction func customizeOrder(_ sender: UIButton) {
        CustomAlert.showAlert(title: GSString.AppName, message: "Under Development", viewController: self)
    }
    
    
    // MARK: - tableView View delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 105.0
        }
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.CartVC_cartList_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSCartListTableCell else {
            return UITableViewCell()
        }
        
//        let itemModel = tableArray[indexPath.row] as! CartItemsModel
////        cell.configureTheCell(itemDetails: itemModel)
//        cell.btnSel.tag = indexPath.row
//        if selectedIdx[indexPath.row] {
//            cell.btnSel.setImage(UIImage(named: "Check_icon"), for: .normal)
//        }
//        else{
//            cell.btnSel.setImage(UIImage(named: "Uncheck_icon"), for: .normal)
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if !productDetailView.isPresented {
//
//            productDetailView.isPresented = true
//            productDetailView.showTheViewFromBottom(on: self.view, for: CGRect(x: 0 , y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), completionHandler: {})
//            //            self.view.addSubview(productDetailView)
//        }
        
        if let productDetailVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSProductDetailsViewController) as? GSProductDetailsViewController {
            GSCustomPushPop.doCustomPush(from: self, to: productDetailVC)
        }
    }
}

// MARK: NavigationBar Methods

extension GSWishListViewController: NavigationWithSearchBarDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        addSideMenu()
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSCartViewController) as? GSCartViewController {
            if let navigator = navigationController {
                tempVC.isWishListView = true
                navigator.pushViewController(tempVC, animated: true)
            }
        }
    }
}

extension GSWishListViewController: UISearchBarDelegate{
    
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
            let localArray = NSMutableArray(array:cartArray.filter({ (shopModel) -> Bool in
                let tmpShopModel = shopModel as! cartItemsModel
                let tmp = tmpShopModel.productName as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            }))
            tableArray = localArray.mutableCopy() as! NSMutableArray
        } else {
            tableArray = cartArray.mutableCopy() as! NSMutableArray
        }
        cartTable.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableArray = cartArray.mutableCopy() as! NSMutableArray
        cartTable.reloadData()
        
    }
}
