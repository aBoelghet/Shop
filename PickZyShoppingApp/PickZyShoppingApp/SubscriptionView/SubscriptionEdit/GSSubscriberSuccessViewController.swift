//
//  GSSubscriberSuccessViewController.swift
//  Shopor
//
//  Created by Ratheesh on 29/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSSubscriberSuccessViewController: UIViewController {

    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var address_tableView:UITableView!
    @IBOutlet weak var continueShop_btn: GSBaseButton!
    @IBOutlet weak var subscription_btn: GSBaseButton!
    @IBOutlet weak var info_lbl: GSBaseLabel!
    @IBOutlet weak var transactionId_lbl: GSBaseLabel!
    @IBOutlet weak var amountPaid_lbl: GSBaseLabel!
    
    var section_array = ["Shop Address","Delivery Address"]
    var shopAddress_array = [ShopAddress]()
    
    let tableViewHeaderHeight:CGFloat = 40.0
    
    var placeOrderResponse: SubscriptionOrderData?

    var isCodOrder = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartCount.value = 0
        addFewIntializers()
        applyColors()
        
        // Removing the view controllers from navigation stack except this one and root view controller ...
        if var unwrappedNavigationStackVC = navigationController?.viewControllers {
            
            for index in stride(from: unwrappedNavigationStackVC.count - 2, to: 0, by: -1) {
                unwrappedNavigationStackVC.remove(at: index)
            }
            navigationController?.viewControllers = unwrappedNavigationStackVC
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        
        continueShop_btn.backgroundColor = UIColor(hexString: defaultTheme.OrderPlacedVC_continueShop_Btn_bg)
        continueShop_btn.setTitleColor(UIColor(hexString: defaultTheme.OrderPlacedVC_continueShop_Btn_title), for: .normal)
        subscription_btn.backgroundColor = UIColor(hexString: defaultTheme.OrderPlacedVC_trackOrder_Btn_bg)
        subscription_btn.setTitleColor(UIColor(hexString: defaultTheme.OrderPlacedVC_trackOrder_Btn_title), for: .normal)
        info_lbl.textColor = UIColor(hexString: defaultTheme.OrderPlacedVC_trackOrder_info_text)
    }
    
    // MARK: User defined Methods
    
    private func addFewIntializers() {
        
        navigationBar_view.delegate = self
        address_tableView.dataSource = self
        address_tableView.delegate = self

        let amount = Double(round(100*(placeOrderResponse?.amountPaid)! )/100)
        
        if isCodOrder {
            transactionId_lbl.isHidden = true
            amountPaid_lbl.text = "Amount to be paid : " + "₹\(String(describing: amount))"
        } else {
            transactionId_lbl.text = "Transaction id : " + "\(placeOrderResponse!.subscriptionID ?? "")"
            amountPaid_lbl.text = "Amount paid : " + "₹\(String(describing: amount))"
        }
        
        guard let unwrappedOrderPlaceResponse = placeOrderResponse else { return }
        guard let shops_array = unwrappedOrderPlaceResponse.shopAddress else { return }
        
        
        let selectedDelivery_type = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryType) as? Int ?? 1
        
        if selectedDelivery_type == GSConstant.defaultDeliveryMethod_id {           // Delivery By Shop
            
            section_array = ["Shop Address","Delivery Address"]
            
        } else {                                                                    // Take Away
            section_array = ["Shop Address","Your Address"]
        }
        shopAddress_array = shops_array
        address_tableView.reloadData()
        

    }
    
    private func mergeTheShopAddress(address_object: GSPlaceOrderResponseAddress) -> String {
        
        var shopAddress = ""
        
        if let street = address_object.street {
            shopAddress = street
        }
        if let city = address_object.city {
            if city != "" {
                shopAddress = (shopAddress == "") ? city : (shopAddress + ", " + city)
            }
        }
        
        if let state = address_object.state {
            if state != "" {
                shopAddress = (shopAddress == "") ? state : (shopAddress + ", " + state)
            }
        }
        if let country = address_object.country {
            if country != "" {
                shopAddress = (shopAddress == "") ? country : (shopAddress + ", " + country)
            }
        }
        if let zipCode = address_object.zipcode {
            if zipCode != "" {
                shopAddress = (shopAddress == "") ? zipCode : (shopAddress + ", " + zipCode)
            }
        }
        return shopAddress
    }
    
    // MARK: - IBAction Methods
    @IBAction func continueShoppingButtonAction(_ sender: UIButton) {
        
        if let homepageShopsVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSShopsViewController) as? GSShopsViewController {
            if let navigator = navigationController {
                navigator.pushViewController(homepageShopsVC, animated: false)
            }
        }
    }
    
    @IBAction func subscriptionListButtonAction(_ sender: Any) {
     
        if let subscribe = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSSubacriptionWalletViewController") as? GSSubacriptionWalletViewController {
          
            navigationController?.pushViewController(subscribe,animated: true)
        }
    }
   
}

// MARK: - UITableView Methods

extension GSSubscriberSuccessViewController:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return section_array.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return shopAddress_array.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShopAddressTableViewCell") as? ShopAddressTableViewCell else {
            return UITableViewCell()
        }
        var address = ""
        cell.selectionStyle = .none

        if indexPath.section == 0 {
            let shopName = shopAddress_array[indexPath.row].shopName ?? ""
            let shopStreet = shopAddress_array[indexPath.row].street ?? ""
            address = "\(shopName)\n\(shopStreet)"

        } else {
            let changeAbleAddress = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_changeable) as? String ?? ""
            let landmark = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_landMark) as? String ?? ""
            let unchangeableAddress = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_unchangeable_address) as? String ?? ""
            let zipCode = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_zipCode) as? String ?? ""
            
            if changeAbleAddress != "" {
                address += changeAbleAddress
            }
            
            if unchangeableAddress != "" {
                address = (address == "") ? unchangeableAddress : "\(address), \(unchangeableAddress)"
            }
            if zipCode != "" {
                address = (address == "") ? zipCode : "\(address), \(zipCode)"
            }
            
            if landmark != "" {
                address = (address == "") ? "Landmark: \(landmark)" : "\(address)\n\nLandmark: \(landmark)"
            }
        }
        
        cell.shopAddress_Label.text = address

        
        return cell
    }
    
    // MARK: - TableView Header Methods
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableViewHeaderHeight))
        
        let title_lbl = UILabel()
        headerView.addSubview(title_lbl)
        
        title_lbl.translatesAutoresizingMaskIntoConstraints = false
        title_lbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15).isActive = true
        title_lbl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        title_lbl.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        title_lbl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        title_lbl.font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont.boldSystemFont(ofSize: 17) : UIFont.boldSystemFont(ofSize: 15)
        title_lbl.textColor = UIColor(hexString: defaultTheme.OrderPlacedVC_header_title)
        
        title_lbl.text = section_array[section]

        headerView.backgroundColor = UIColor(hexString: defaultTheme.OrderPlacedVC_header_bg)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

// MARK:- NavigationBar Methods
extension GSSubscriberSuccessViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
    }
    
    func rightBarBtnPressed(sender:UIButton) {
    }
}
