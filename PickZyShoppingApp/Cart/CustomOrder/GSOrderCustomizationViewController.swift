//
//  GSOrderCustomizationViewController.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 5/31/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

protocol GSRefreshCartDelegate :class {
    func refreshTheCart()
}

class GSOrderCustomizationViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var customOrder_tableView: UITableView!
    @IBOutlet weak var bottom_btn:UIButton!
    
    weak var delegate:GSRefreshCartDelegate?
    
    //    var autoSelectedShops_array = [Any]()
    //    var customShops_array = [Any]()
    
    static let autoShopSelection = -1
    var selectedShopIndex = GSOrderCustomizationViewController.autoShopSelection
    
    let tempStringToIdentifyExpandOrCollapse = ""
    var selectedIndexPath : IndexPath?
    
    var section_array = ["Products Selected Shops", "Details","Customize Order"]
    
    let normalProductItemCellHeight:CGFloat = 120
    let autoSelectedProductItemCellHeight:CGFloat = 40
    let detailsFooterViewHeight:CGFloat = 10.0
    let normalFooterViewHeight:CGFloat = 1.0
    
    var isDetailsSelected = false
    
    var autoSelectedTableFormat = [CustomOrderTableFormat]()
    var autoSelected_array = [CustomOrderCustomizedModel]()
    
    var customTableFormat = [CustomOrderTableFormat]()
    var customSelected_array = [CustomOrderCustomizedModel]()
    
    lazy var autoSelectedTotalProducts = [GSCustomizeOrderProduct]()
    var autoSelectedTotalProductsPrice_item: GSCustomizeOrderPrices?
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFewIntializers()
        applyColors()
        
        customizeOrderListAPI(isAutoSelected: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar_view.navigationBarReload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        
        bottom_btn.backgroundColor = UIColor(hexString: defaultTheme.customOrder_bottomBtn_BG)
        bottom_btn.setTitleColor(UIColor(hexString: defaultTheme.customOrder_bottomBtn_title), for: .normal)
        customOrder_tableView.backgroundColor = UIColor(hexString: defaultTheme.customOrder_table_bg)
    }
    
    //MARK:- User defined methods
    private func addFewIntializers() {
        
        navigationBar_view.delegate = self
        customOrder_tableView.delegate = self
        customOrder_tableView.dataSource = self
        
        customOrder_tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    
        
        let header_nib = UINib(nibName: GSString.NibNames.GSCustomOrderTableHeaderView, bundle: nil)
        customOrder_tableView.register(header_nib, forHeaderFooterViewReuseIdentifier: GSCustomOrderTableHeaderView.identifier)
        
        navigationBar_view.titleText = "Customize Order"
    }
    
    fileprivate func reloadTableViewWithAnimation() {
        
        UIView.transition(with: customOrder_tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.customOrder_tableView.reloadData()
        }, completion: nil)
    }
    
    //MARK:- View Controller Methods
    @IBAction func doneAction(_ sender: UIButton) {
        
        if selectedShopIndex != GSOrderCustomizationViewController.autoShopSelection {
            
            let format = customTableFormat[selectedShopIndex]
            let indexOfItem = format.indexPathItemToLoadForProductDetails
            let customItem = customSelected_array[indexOfItem]
            let store_id = customItem.data?.id ?? ""
            writeCustomOrderToCartAPI(store_id: store_id)
            
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension GSOrderCustomizationViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if customTableFormat.count > 0 {
            return 3
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return autoSelectedTableFormat.count
        case 1:
            return isDetailsSelected ? 1 : 0
        case 2:
            return customTableFormat.count // customSelected_array.count //
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.OrderCustomizationVC_shop_tableCell
        guard let cell = customOrder_tableView.dequeueReusableCell(withIdentifier: identifier) as? GSCustomOrderShopTableCell else {
            return GSCustomOrderShopTableCell()
        }
        
        if indexPath.section == 0 {
            
            let format = autoSelectedTableFormat[indexPath.row]
            
            if format.cellType == .storeCell {
                
                cell.orderCountakaSelection_btn.isUserInteractionEnabled = false
                
                if let itemAtIndex = autoSelected_array[format.indexPathItemToLoadForProductDetails].data {
                    cell.configureTheCell(itemAtIndex, isAutoSelectedShop: true, isSelectedShop: false)
                }
                
            } else {
                guard let itemCell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.OrderCustomizationVC_productsCell) as? GSCustomOrderProductDetailsTableCell else {
                    return UITableViewCell()
                }
                let previousIndexPath = format.indexPathItemToLoadForProductDetails
                if let itemAtIndex = autoSelected_array[previousIndexPath].data {
//                    itemCell.intializeTheDataWith(product_array: itemAtIndex.products, price_item: itemAtIndex.prices, isAutoSelectedBool: true)
                    itemCell.intializeTheDataWith(product_array: itemAtIndex.products, price_item: itemAtIndex.prices, isAutoSelectedBool: false)
                }
                return itemCell
            }
            
        } else if indexPath.section == 1 {
            
            guard let itemCell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.OrderCustomizationVC_productsCell) as? GSCustomOrderProductDetailsTableCell else {
                return UITableViewCell()
            }
            
            itemCell.intializeTheDataWith(product_array: autoSelectedTotalProducts, price_item: autoSelectedTotalProductsPrice_item, isAutoSelectedBool: false)
            return itemCell
            
        } else {
            
            let format = customTableFormat[indexPath.row]
            
            if format.cellType == .storeCell {
                
                cell.orderCountakaSelection_btn.isUserInteractionEnabled = true
                cell.orderCountakaSelection_btn.addTarget(self, action: #selector(cellAccessorySelection(_:)), for: .touchUpInside)
                cell.orderCountakaSelection_btn.tag = indexPath.row
                
                //if customSelected_array.count > indexPath.row {
                if customSelected_array.count > format.indexPathItemToLoadForProductDetails {
                    // Below line crash
                    if let itemAtIndex = customSelected_array[format.indexPathItemToLoadForProductDetails].data {
                        let isSelectedShop = (format.indexPathItemToLoadForProductDetails == selectedShopIndex)
                        cell.configureTheCell(itemAtIndex, isAutoSelectedShop: false, isSelectedShop: isSelectedShop)
                    }
                }
            } else {
                guard let itemCell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.OrderCustomizationVC_productsCell) as? GSCustomOrderProductDetailsTableCell else {
                    return UITableViewCell()
                }
                let previousIndexPath = format.indexPathItemToLoadForProductDetails
                if let itemAtIndex = customSelected_array[previousIndexPath].data {
                    itemCell.intializeTheDataWith(product_array: itemAtIndex.products, price_item: itemAtIndex.prices, isAutoSelectedBool: false)
                }
                return itemCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        isDetailsSelected = false       // To Collapse Total auto selected bill details when the auto selected or custom selected shop expanded...
        
        if indexPath.section == 0 {
            
            let format = autoSelectedTableFormat[indexPath.row]
            
            collapseAllAutoSelected(except: format.indexPathItemToLoadForProductDetails)
            
            autoSelected_array[format.indexPathItemToLoadForProductDetails].isExpanded = !autoSelected_array[format.indexPathItemToLoadForProductDetails].isExpanded
            prepareAutoSelectedTableViewFormat(reload: true)
        } else if indexPath.section == 2 /*&& customSelected_array.count > indexPath.row */ {
            
            let format = customTableFormat[indexPath.row]
            
            if customSelected_array.count > format.indexPathItemToLoadForProductDetails {
                
                collapseAllCustomSelected(except: format.indexPathItemToLoadForProductDetails)
                
                customSelected_array[format.indexPathItemToLoadForProductDetails].isExpanded = !customSelected_array[format.indexPathItemToLoadForProductDetails].isExpanded
                prepareCustomSelectedTableViewFormat(reload: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            let format = autoSelectedTableFormat[indexPath.row]
            
            if format.cellType == .storeCell {
                return UITableViewAutomaticDimension
            } else {
                let index = format.indexPathItemToLoadForProductDetails
                if let item = autoSelected_array[index].data {
                    
                    let products_count = item.products?.count ?? 0
                    
//                    return CGFloat(products_count * 30) + autoSelectedProductItemCellHeight
                    return CGFloat(products_count * 30) + normalProductItemCellHeight
                }
            }
        } else if indexPath.section == 2 {
            
            let format = customTableFormat[indexPath.row]
            
            if format.cellType == .storeCell {
                return UITableViewAutomaticDimension
            } else {
                let index = format.indexPathItemToLoadForProductDetails
                if let item = customSelected_array[index].data {
                    
                    let products_count = item.products?.count ?? 0
                    
                    return CGFloat(products_count * 30) + normalProductItemCellHeight
                }
            }
        } else {
            return CGFloat(autoSelectedTotalProducts.count * 30) + normalProductItemCellHeight
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: - UITableView Header and Footer Methods
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 1 && !isDetailsSelected {
            return detailsFooterViewHeight
        }
        return normalFooterViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header_view = tableView.dequeueReusableHeaderFooterView(withIdentifier: GSCustomOrderTableHeaderView.identifier) as? GSCustomOrderTableHeaderView else {
            return UIView()
        }
        
        header_view.title_lbl.text = section_array[section]
        header_view.radio_btn.addTarget(self, action: #selector(headerRadioBtn_action(_:)), for: .touchUpInside)
        
        header_view.setUpUIWithSection(section: section, selectedIndex: selectedShopIndex)
        
        if section == 1 {
            var totalPrice:Double = 0
            for item in autoSelected_array {
                
                guard let itemAtIndex = item.data else { continue }
                guard let prices_details = itemAtIndex.prices else { continue }
                
                totalPrice += (prices_details.netPrice ?? 0)
            }
            
            header_view.image_btn.setImage(#imageLiteral(resourceName: "down_arrow_icon"), for: .normal)
            header_view.totalKey_lbl.isHidden = false
            header_view.totalValue_lbl.isHidden = false
            if isDetailsSelected {
                header_view.image_btn.setImage(#imageLiteral(resourceName: "up_arrow_icon"), for: .normal)
                header_view.totalKey_lbl.isHidden = true
                header_view.totalValue_lbl.isHidden = true
            }
            
            header_view.totalKey_lbl.text = "To pay"
            header_view.totalValue_lbl.text = GSCommonHelper.formattedPrice(price: totalPrice)
        }
        return header_view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView()
        if section != 1 {
            footerView.backgroundColor = UIColor(hexString: defaultTheme.customOrder_table_footer_bg)
            footerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: normalFooterViewHeight)
        } else {
            footerView.backgroundColor = UIColor.clear
            footerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: detailsFooterViewHeight)
        }
        
        return footerView
    }
    
    // MARK: - Table View Action Methods
    
    @objc private func headerRadioBtn_action(_ sender:UIButton) {
        if sender.tag == 0 {
            selectedShopIndex = GSOrderCustomizationViewController.autoShopSelection
        } else if sender.tag == 1 {
            
            collapseAllCustomSelected(except: nil)
            collapseAllAutoSelected(except: nil)
            
            prepareAutoSelectedTableViewFormat(reload: false)
            prepareCustomSelectedTableViewFormat(reload: false)
            
            isDetailsSelected = !isDetailsSelected
        } else {
            return      // To Avoid unnecessary reload of tableView
        }
        reloadTableViewWithAnimation()
    }
    
    @objc private func cellAccessorySelection(_ sender:UIButton) {
        
        let format = customTableFormat[sender.tag]
        selectedShopIndex = format.indexPathItemToLoadForProductDetails
        reloadTableViewWithAnimation()
    }
    
    
    private func collapseAllAutoSelected(except:Int?) {
        
        for index in 0..<autoSelected_array.count {
            
            if let alreadySelectedIndex = except, alreadySelectedIndex == index {
                continue
            }
            autoSelected_array[index].isExpanded = false
        }
    }
    
    private func collapseAllCustomSelected(except:Int?) {
        
        for index in 0..<customSelected_array.count {
            
            if let alreadySelectedIndex = except, alreadySelectedIndex == index {
                continue
            }
            
            customSelected_array[index].isExpanded = false
        }
    }
}

// MARK: - API Methods
extension GSOrderCustomizationViewController {
    
    fileprivate func customizeOrderListAPI(isAutoSelected:Bool) {
        
        let urlString = isAutoSelected ? APIurl.baseURL + APIurl.subURL.autoSelectedShops : APIurl.baseURL + APIurl.subURL.customSelectedShops
        guard let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String else {
            return
        }
        guard let storesArray = SharedPersistence.getValue(key: UserDefaultKeys.Products.selecedStoreArray) as? [String] else {
            return
        }
        var parameters = [String:AnyObject]()
        
        if isAutoSelected {
            parameters = ["_id" : storeCategory_id] as [String:AnyObject]
        } else {
            parameters = ["_id" : storeCategory_id,
                          "stores": storesArray] as [String:AnyObject]
        }
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters ,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCustomizeOrderModel.self, from: responseData)
                    
                    guard let customizeListResponseData = responseModel.data else { return }
                    if isAutoSelected {
                        
                        if weakSelf.autoSelected_array.count > 0 {
                            weakSelf.autoSelected_array.removeAll()
                        }
                        for item in customizeListResponseData {
                            let customizedModel_item = CustomOrderCustomizedModel(data: item, isExpanded: false)
                            weakSelf.autoSelected_array.append(customizedModel_item)
                        }
                        weakSelf.createAutoSelectedProductTotalDetailsItem()
                        weakSelf.filterDuplicatesFromCustomOrder()
                        weakSelf.prepareAutoSelectedTableViewFormat(reload: true)
                        
                        weakSelf.customizeOrderListAPI(isAutoSelected: false)
                    } else {
                        if weakSelf.customSelected_array.count > 0 {
                            weakSelf.customSelected_array.removeAll()
                        }
                        for item in customizeListResponseData {
                            let customizedModel_item = CustomOrderCustomizedModel(data: item, isExpanded: false)
                            weakSelf.customSelected_array.append(customizedModel_item)
                        }
                        weakSelf.filterDuplicatesFromCustomOrder()
                        weakSelf.prepareCustomSelectedTableViewFormat(reload: true)
                    }
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    struct CustomOrderCustomizedModel {
        let data:GSCustomizeOrderData?
        var isExpanded:Bool
    }
    
    enum CustomOrderCellToLoad {
        case storeCell
        case productDetailCell
    }
    
    struct CustomOrderTableFormat {
        let cellType:CustomOrderCellToLoad
        let indexPathItemToLoadForProductDetails:Int
    }
    
    func prepareAutoSelectedTableViewFormat(reload:Bool) {
        
        if autoSelectedTableFormat.count > 0 {
            autoSelectedTableFormat.removeAll()
        }
        
        for index in 0..<autoSelected_array.count {
            
            let customModel = autoSelected_array[index]
            
            let item = CustomOrderTableFormat(cellType: .storeCell, indexPathItemToLoadForProductDetails: index)
            autoSelectedTableFormat.append(item)
            
            if customModel.isExpanded {
                let expanded_item = CustomOrderTableFormat(cellType: .productDetailCell, indexPathItemToLoadForProductDetails: index)
                autoSelectedTableFormat.append(expanded_item)
            }
        }
        
        if reload {
        reloadTableViewWithAnimation()
        }
    }
    
    func prepareCustomSelectedTableViewFormat(reload:Bool) {
        
        if customTableFormat.count > 0 {
            customTableFormat.removeAll()
        }
        
        for index in 0..<customSelected_array.count {
            
            let customModel = customSelected_array[index]
            
            let item = CustomOrderTableFormat(cellType: .storeCell, indexPathItemToLoadForProductDetails: index)
            customTableFormat.append(item)
            
            if customModel.isExpanded {
                let expanded_item = CustomOrderTableFormat(cellType: .productDetailCell, indexPathItemToLoadForProductDetails: index)
                customTableFormat.append(expanded_item)
            }
        }
        if reload {
            reloadTableViewWithAnimation()
        }
    }
    
    func createAutoSelectedProductTotalDetailsItem() {              // Total Auto Selected Products Caluculations
        
        if autoSelectedTotalProducts.count > 0 {
            autoSelectedTotalProducts.removeAll()
        }
        
        for autoSelectedCustomizedItem in autoSelected_array {
            
            guard let autoSelectedItem = autoSelectedCustomizedItem.data else { continue }
            
            guard let product_array = autoSelectedItem.products else { continue }
            guard let price_item = autoSelectedItem.prices else { continue }
            
            if autoSelectedTotalProductsPrice_item != nil {
                
                let newPrice_item = GSCustomizeOrderPrices(grossPrice: (autoSelectedTotalProductsPrice_item?.grossPrice ?? 0) + (price_item.grossPrice ?? 0),
                                                           taxes: (autoSelectedTotalProductsPrice_item?.taxes ?? 0) + (price_item.taxes ?? 0),
                                                           delivery: (autoSelectedTotalProductsPrice_item?.delivery ?? 0) + (price_item.delivery ?? 0),
                                                           netPrice: (autoSelectedTotalProductsPrice_item?.netPrice ?? 0) + (price_item.netPrice ?? 0))
                autoSelectedTotalProductsPrice_item = newPrice_item
                
            } else {
                autoSelectedTotalProductsPrice_item = price_item
            }
            
            for index in 0..<product_array.count {
                
                let singleProduct = product_array[index]
                
                if autoSelectedTotalProducts.contains(where: {$0.id == singleProduct.id}) {
                    
                    if autoSelectedTotalProducts.count > index {
                        // below line crashed
                        let alreadyUpdatedProduct = autoSelectedTotalProducts[index]
                        
                        let newCustomProduct = GSCustomizeOrderProduct(id: alreadyUpdatedProduct.id,
                                                                       qty: (alreadyUpdatedProduct.qty ?? 0) + (singleProduct.qty ?? 0),
                                                                       sellingPrice: (alreadyUpdatedProduct.sellingPrice ?? 0) + (singleProduct.sellingPrice ?? 0),
                                                                       grossPrice: (alreadyUpdatedProduct.grossPrice ?? 0) + (singleProduct.grossPrice ?? 0),
                                                                       taxPrice: (alreadyUpdatedProduct.taxPrice ?? 0) + (singleProduct.taxPrice ?? 0),
                                                                       netPrice: (alreadyUpdatedProduct.netPrice ?? 0) + (singleProduct.netPrice ?? 0),
                                                                       productName: alreadyUpdatedProduct.productName,
                                                                       images: alreadyUpdatedProduct.images)
                        autoSelectedTotalProducts[index] = newCustomProduct
                    }
                } else {
                    autoSelectedTotalProducts.append(singleProduct)
                }
            }
        }
    }
    
    private func filterDuplicatesFromCustomOrder() {
        
        if autoSelected_array.count == 1 {
            let autoSelectedProduct = autoSelected_array[0]
            for index in 0..<customSelected_array.count {
                let customProduct = customSelected_array[index]
                if autoSelectedProduct.data?.id == customProduct.data?.id {
                    customSelected_array.remove(at: index)
                    return
                }
            }
        }
    }
    
    fileprivate func writeCustomOrderToCartAPI(store_id:String) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.writeCustomOrderToCart
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        let parameters = ["_id" : storeCategory_id,
                          "store_id": store_id] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters ,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCustomizeOrderWriteCartModel.self, from: responseData)
                    
                    let status = responseModel.success ?? false
                    
                    if status {
                        weakSelf.delegate?.refreshTheCart()
                        weakSelf.navigationController?.popViewController(animated: true)
                    } else {
                        CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: weakSelf)
                    }
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
}

// MARK: NavigationBar Methods
extension GSOrderCustomizationViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    func rightBarBtnPressed(sender:UIButton) {
    }
}
