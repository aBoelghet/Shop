//
//  GSDeliveryOptionViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh Mac Mini on 31/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSDeliveryOptionViewController: GSPaymentViewController {

    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var deliveryOptionTableView: UITableView!
    
    var deliveryTypeImage = [#imageLiteral(resourceName: "DeliveryByShop"),#imageLiteral(resourceName: "TakeAwayIcon")]
    var sectionArray = ["Delivery Method"]
    var selectionArray = NSMutableArray()
    var selectedIndex:Int = 0
    var previosSelectedIndex:Int = 0
    
    let headerHeight:CGFloat = 40.0
    var deliveryType_array = [GSDeliveryType]()
    
//    var selectedDeliveryDisplayName:String?
    
    weak var delegate:GSRefreshCartDelegate?
    
    //MARK: View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFewIntializers()
        deliveryTypesAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarView.navigationBarReload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: User defined Methods
    func addFewIntializers() {
        
        navigationBarView.delegate = self
        selectionArray = [50,50]
        deliveryOptionTableView.delegate = self
        deliveryOptionTableView.dataSource = self
        deliveryOptionTableView.tableFooterView = UIView()
        deliveryOptionTableView.backgroundColor = UIColor(hexString: defaultTheme.paymentOpt_table_BG)
        
        
        let deliveryLongitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong) as? Double ?? 0
        let deliveryLattitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLat) as? Double ?? 0
        let searchLongitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLongitude) as? Double ?? 0
        let searchLattitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLatitude) as? Double ?? 0
        
        if deliveryLattitude != searchLattitude || deliveryLongitude != searchLongitude {       // Based on the latitude and longitude will decide the locations... whether other locations or same locations
            
            
        }
        
//        selectedIndex = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryType) as? Int ?? 1
//        selectedDeliveryDisplayName = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryTypeDisplayName) as? String ?? ""
        
        deliveryOptionTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
    }
    
}

extension GSDeliveryOptionViewController : UITableViewDelegate,UITableViewDataSource {
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return deliveryType_array.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArray[0]
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.DeliveryOptionVC_delivery_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSPaymentTypeTableCell else {
            return UITableViewCell()
        }
        
        let itemAtIndex = deliveryType_array[indexPath.row]
        cell.topLabel.text = itemAtIndex.name ?? ""

        cell.selectionImage.image = nil
        cell.cellIcon.image = deliveryTypeImage[indexPath.row]

        let idOfOption = itemAtIndex.id ?? 1

        if selectedIndex == idOfOption {
            cell.selectionImage.image = #imageLiteral(resourceName: "VerifiedTickIcon")
        }
        
        cell.bg_view.addShadowEffectWith(color: UIColor(hexString: defaultTheme.paymentOpt_BorderC), opacity: 1.0, shadowRadius: 0, shadowOffset: CGSize(width: 0.0, height: 1.0))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerHeight))
        let headerLabel = UILabel.init(frame: CGRect(x: 10, y: 0, width: headerView.frame.size.width - 10, height: headerHeight))
        headerLabel.textColor = UIColor(hexString: defaultTheme.deliveryOptionsVC_header_title)
        let normalStr = sectionArray[section]
        headerLabel.font = headerLabel.font.withSize(14)
        headerLabel.text = normalStr
        headerView.addSubview(headerLabel)
        headerView.backgroundColor = UIColor.init(hexString: defaultTheme.deliveryOptionsVC_header_BG)
        headerView.addShadowEffectWith(color: UIColor(hexString: defaultTheme.paymentOpt_BorderC), opacity: 1.0, shadowRadius: 0, shadowOffset: CGSize(width: 0.0, height: 1.0))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let itemAtIndex = deliveryType_array[indexPath.row]
        updateDeliveryMethodAPI(selectedType: itemAtIndex)
    }
    
    private func pushToAddressConfirmationVC() {
        if let addressConfirmationVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSOrderConfirmationViewController) as? GSOrderConfirmationViewController {
            if let navigator = navigationController {
                navigator.pushViewController(addressConfirmationVC, animated: true)
            }
        }
    }

}

// MARK: - API Methods

extension GSDeliveryOptionViewController {
    
    func deliveryTypesAPI () {
        
        let urlString = APIurl.baseURL + APIurl.subURL.deliveryTypes
        
        let storesArray = SharedPersistence.getValue(key: UserDefaultKeys.Products.selecedStoreArray) as? [String] ?? [String]()
        
        let params = ["stores" : storesArray] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:true) { [weak self]  (response, error) in
            
           // Making sure the next code will not execute if the view controller not exists in memory
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSDeliveryTypeModel.self, from: responseData)
                    
                    if let deliveryTypeArray = responseModel.data?.type {
                        self?.deliveryType_array = deliveryTypeArray
                        
                        for type in deliveryTypeArray {
                            if let selectedDelType = responseModel.data?.deliveryType, selectedDelType == type.id {
                                self?.selectedIndex = selectedDelType
                                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.selectedDeliveryType, value: selectedDelType)
                                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.selectedDeliveryTypeDisplayName, value: type.name ?? "")
                                break
                            }
                        }
                        
                        self?.deliveryOptionTableView.reloadData()
                    }
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? "")
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func updateDeliveryMethodAPI (selectedType:GSDeliveryType) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.deliveryTypeEdit
        
        let parameters = ["delivery_type": selectedType.id ?? 1] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters, urlString: urlString, withLoader:true) { (response, error) in
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if responseModel.success == true {
                        self.selectedIndex = selectedType.id ?? 1
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.selectedDeliveryType, value: self.selectedIndex)
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.selectedDeliveryTypeDisplayName, value: selectedType.name ?? "")
                        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.isDeliveryConfigured, value: true)
                        if self.deliveryOptionTableView != nil {
                            self.deliveryOptionTableView.reloadData()
                        }
                    }
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: self)
                }
            } else {
                print(error?.localizedDescription ?? "")
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: self)
            }
        }
    }
    
}

//MARK: Naviagtion Bar delegate

extension GSDeliveryOptionViewController :NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        delegate?.refreshTheCart()
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
    }
}

