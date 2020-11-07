//
//  GSGlobalSearchViewController.swift
//  Shopor
//
//  Created by Ratheesh on 13/09/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage
import MBProgressHUD

class GSGlobalSearchViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarGlobalSearch!
    @IBOutlet weak var products_tableView: UITableView!
    
    var globalSearchScan_view: GSGlobalSearchScanView!
    
    let disposeBag = DisposeBag()
    
    var productInfo_array = [GSGlobalProductsDataProductInfo]()
    
    var selectedCategory_id = ""
    var storeId_array = [String]()
    
    var clearCartSupport = GSClearCartSupport()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyColors()
        addFewIntializers()
        rxSetupForSearchBar()
    }
    
    
    // MARK: - Colors For UI
    private func applyColors() {
        
    }
    
    // MARK: User defined Methods
    private func addFewIntializers() {
        
        navigationBar_view.delegate = self
        
        products_tableView.dataSource = self
        products_tableView.delegate = self
        
        products_tableView.tableFooterView = UIView()
        
        guard let firstSubview = navigationBar_view.navigSearchBar.subviews.first else { return }
        firstSubview.subviews.forEach {
            ($0 as? UITextField)?.clearButtonMode = .never
        }
    }
    
    
    func rxSetupForSearchBar() {
        //productSearchbar
        
        navigationBar_view.navigSearchBar
            .rx
            .text
            .orEmpty
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (query) in
                
                if self.navigationBar_view.navigSearchBar.becomeFirstResponder() {
                    print("Searching...........")
                    
                    self.globalProductsAPI(searchText: query)
                }
                
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableView Methods

extension GSGlobalSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productInfo_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.globalSearchCell) as! GSGlobalSearchTableViewCell
        
        let productAtIndex = productInfo_array[indexPath.row]
        
        cell.productName_lbl.text = productAtIndex.products?.name ?? ""
        cell.unit_lbl.text = productAtIndex.products?.unit ?? ""
        cell.price_lbl.text = "Rs. \(productAtIndex.products?.netPrice ?? "")"
        
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        SDWebImageDownloader.shared.setValue(accessToken, forHTTPHeaderField: "Authorization")
        
        var imageEndPoint = ""
        
        if let image_array = productAtIndex.products?.images {
            if image_array.count > 0 {
                imageEndPoint = image_array[0].name ?? ""
            }
        }
        let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
        cell.product_imgView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewProductImage + imageEndPoint + imgHeight) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
        
        
        cell.plusMinus_view.isHidden = true
        cell.more_btn.isHidden = true
        
        cell.add_btn.tag = indexPath.row
        cell.add_btn.addTarget(self, action: #selector(cell_addProduct_action(_:)), for: .touchUpInside)
        
        cell.add_btn.isHidden = false
        if let cartItem = cartItemsDictionary[productAtIndex.products?.id ?? ""] {
            let qty = cartItem.stores?.first?.productDetails?.qty ?? 0
            cell.add_btn.isHidden = true
            cell.plusMinus_view.isHidden = false
            
            cell.qty_lbl.text = "\(qty)"
        }
        
        return cell
    }
    
    @objc private func cell_addProduct_action(_ sender: UIButton) {
        
        let product = productInfo_array[sender.tag]
        
        let category_id = product.id ?? ""
        let store_id = product.storeID ?? ""
        let product_id = product.products?.id ?? ""
        
        if selectedCategory_id != "", category_id != selectedCategory_id {
            
            CustomAlert.showAlert(title: GSString.AppName, message: "The product you are tying to add is from a different category. If you want to add this product, previous selected cart will be cleared. Do you want to continue?", alertButtonsArray: ["Cancel", "Continue"], isLastButtonDestructive: true, viewController: self) { btnIndex in
                
                
                if btnIndex == 1 {
                    
                    self.clearCartSupport.clearCartAPI()
                    self.clearCartSupport.clearSaveForLaterAPI()
                    
                    self.selectedCategory_id = category_id
                    self.storeId_array.removeAll()
                    self.addProductToCartAPI(categoryId: category_id, product_id: product_id, store_id: store_id, qty: 1)
                }
            }
            
            return
        }
        
        if storeId_array.contains(store_id) == false {
            storeId_array.append(store_id)
        }
        
        addProductToCartAPI(categoryId: category_id, product_id: product_id, store_id: store_id, qty: 1)
    }
    
    @objc private func cell_plus_action(_ sender: UIButton) {
        
        let product = productInfo_array[sender.tag]
        
        var selectedQty = 0
        let stock = Int(product.products?.stock ?? "") ?? 0
        
        if let cartItem = cartItemsDictionary[product.products?.id ?? ""] {
            selectedQty = cartItem.stores?.first?.productDetails?.qty ?? 0
        }
        
        if selectedQty < stock {
            addProductToCartAPI(categoryId: product.id ?? "", product_id: product.products?.id ?? "", store_id: product.storeID ?? "", qty: 1)
        } else {
            CustomAlert.showAlert(title: GSString.AppName, message: "You have reached maximum stock", viewController: self)
        }
    }
    
    @objc private func cell_minus_action(_ sender: UIButton) {
        
        let product = productInfo_array[sender.tag]
        
        var selectedQty = 0
        
        if let cartItem = cartItemsDictionary[product.products?.id ?? ""] {
            selectedQty = cartItem.stores?.first?.productDetails?.qty ?? 0
        }
        if selectedQty > 0 {
            addProductToCartAPI(categoryId: product.id ?? "", product_id: product.products?.id ?? "", store_id: product.storeID ?? "", qty: -1)
        }
        
    }
}

// MARK: - API Methods

extension GSGlobalSearchViewController {
    
    fileprivate func globalProductsAPI(searchText: String) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.globalSearch + searchText
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSGlobalProductsResponseModel.self, from: responseData)
                    
                    if let productsArray = responseModel.data?.productInfo {
                        
                        weakSelf.productInfo_array = productsArray
                        weakSelf.products_tableView.reloadData()
                    }
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
            
        }
    }
    
    
    func addProductToCartAPI(categoryId: String, product_id: String, store_id: String, qty: Int){
        
        let urlString = APIurl.baseURL + APIurl.subURL.addProductToCart
        
        let params = ["_id" : categoryId as Any ,
                      "product_id" : product_id as Any ,
                      "is_private" : false,
                      "stores"     : [["store_id" : store_id as Any ,
                                       "qty" : qty]] ] as [String : Any]
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] , urlString: urlString, withLoader:true) { [weak self] (responseData, error) in
            guard let weakSelf = self else { return }
            
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: weakSelf.view, animated: true)
            }
            
            if error == nil {
                weakSelf.handleAddCartResponse(response: responseData)
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func handleAddCartResponse(response: Data?) {
        
        do {
            guard let responseData = response else {return}
            let jsonDecoder = JSONDecoder()
            let responseModel = try jsonDecoder.decode(GSAddToCartModel.self, from: responseData)
            
            if !responseModel.success!  {
                #if DEBUG
                print("Error in adding to cart")
                #endif
            } else {
                if let cart_item = responseModel.data {
                    
                    if let product_id = cart_item.id {
                        cartItemsDictionary[product_id] = cart_item
                    }
                }
                cartCount.value = cartCount.value + 1
                #if DEBUG
                print("Added")
                #endif
            }
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
    
}

// MARK: - Navigation Bar Delegate Methods

extension GSGlobalSearchViewController: NavigationBarGlobalSearchDelegate, GlobalSearchScanDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        
        GSCustomPushPop.doCustomPop(from: self)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
    
    func barCodePressed(sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let topLength = appDelegate?.topSafeAreaInset ?? 0
        let bottomLength = appDelegate?.bottomSafeAreaInset ?? 0
        
        if globalSearchScan_view != nil, globalSearchScan_view.isDescendant(of: view) { return }
        globalSearchScan_view = GSGlobalSearchScanView()
        globalSearchScan_view.delegate = self
        view.addSubview(globalSearchScan_view)
        
        globalSearchScan_view.translatesAutoresizingMaskIntoConstraints = false
        globalSearchScan_view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        globalSearchScan_view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        globalSearchScan_view.topAnchor.constraint(equalTo: view.topAnchor, constant: topLength).isActive = true
        globalSearchScan_view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomLength).isActive = true
    }
    
    
    func scanCompletedWith(upc: String) {
        globalProductsAPI(searchText: upc)
    }
}




// MARK: - GSGlobalProductsResponseModel
struct GSGlobalProductsResponseModel: Codable {
    let success: Bool?
    let count: Int?
    let data: GSGlobalProductsData?
}

// MARK: - DataClass
struct GSGlobalProductsData: Codable {
    let productInfo: [GSGlobalProductsDataProductInfo]?
}

// MARK: - ProductInfo
struct GSGlobalProductsDataProductInfo: Codable {
    let id, storeID: String?
    let products: GSGlobalProductsDataProductInfoProducts?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case storeID = "store_id"
        case products
    }
}

// MARK: - Products
struct GSGlobalProductsDataProductInfoProducts: Codable {
    let name, sku, unit: String?
    let images: [GSGlobalProductsDataProductInfoProductsImage]?
    let id, stock, netPrice: String?
    
    enum CodingKeys: String, CodingKey {
        case name, sku, unit, images, id, stock
        case netPrice = "net_price"
    }
}

// MARK: - Image
struct GSGlobalProductsDataProductInfoProductsImage: Codable {
    let keyid, name: String?
    let width, height: Int?
}
