//
//  GSProductListViewController.swift
//  Shopor
//
//  Created by Ratheesh on 26/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class GSProductListViewController: UIViewController {

    @IBOutlet weak var navigationbar_View: NavigationBarNormal!
    
    @IBOutlet weak var productList_Tableview: UITableView!
    
    @IBOutlet weak var productPriceButton: GSBaseButton!
        
    var arrayProductList        = [ProductListData]()
    var arrayLivedProductList   = [ProductData]()
    var arrayProductNewList     = [ProductData]()

    var shopDetails : productShop?

    var subscriptionId      = ""
    var subscriptionType    = ""
    
    var totalPrice = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBarMethod()
        self.viewInitializedMethod()
    }
    
    func navigationBarMethod()  {
        navigationbar_View.delegate = self
        navigationbar_View.titleLable.text = "Products"
        
        self.SendRequestSubscriptionProductListApi(subscriptionId: subscriptionId)
    }
    
    func viewInitializedMethod()  {
        
        productList_Tableview.delegate = self
        productList_Tableview.dataSource = self
        productPriceButton.isUserInteractionEnabled = true
    }
  
    @IBAction func putManualOrder(_ sender: Any) {
        
        CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.manualOrderAlert, alertButtonsArray: ["Cancel","Yes"], isLastButtonDestructive: true, viewController: self) { btnIndex in
            
            if btnIndex == 1 {
                self.subsMakeManualOrder(subscriptionId: self.subscriptionId)
            }
        }
    }
    
    // Make Manual Order
    fileprivate func subsMakeManualOrder(subscriptionId:String) {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionManualOrder
        let  params = ["subs_mongo_id" : subscriptionId,] as [String : Any]
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionManualOrder.self, from: responseData)
                    if let response = responseModel.success {
                        
                        if (response == true) {
                            CustomAlert.showAlert(title: GSString.AppName, message: "Order placed successfully. You can track the order on track order page.", viewController: weakSelf)                    }
                        }
                } catch {
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    // Common method to fetch the recharge wallet from server
    fileprivate func SendRequestSubscriptionProductListApi(subscriptionId:String) {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionProductList
        
        let  params = ["subs_mongo_id" : subscriptionId,] as [String : Any]
        arrayLivedProductList .removeAll()
        totalPrice = 0.0
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionProductListModel.self, from: responseData)
                    
                    if let typesArray = responseModel.data {
                        print(typesArray)
                        if typesArray.count > 0 {
                            weakSelf.arrayProductList.removeAll()
                            weakSelf.arrayProductList = typesArray
                        }
                    }
                    
                    for test in weakSelf.arrayProductList {
                        
                        weakSelf.arrayProductNewList = test.products!.filter({ (data) -> Bool in
                            return data.isChecked == true
                        })
                        
                        weakSelf.arrayLivedProductList += weakSelf.arrayProductNewList
                    }
                    
                    for test in weakSelf.arrayLivedProductList {
                        weakSelf.totalPrice += test.netPrice!
                        
                        let amount = Double(round(100*weakSelf.totalPrice )/100)
                        
                        weakSelf.productPriceButton .setTitle("Manually Place Order:₹\(String(describing: amount))", for: .normal)
                    }
                    
                    if let draftArray = responseModel.draftProducts {
                        print(draftArray)
                       
                        weakSelf.arrayProductList += draftArray
                    }
                    weakSelf.productList_Tableview.reloadData()
         
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
    
    // Common method to fetch the recharge wallet from server
    fileprivate func SendRequestSubscriptionProductActiveApi(subscriptionId:String, productId:String, cartId:String, isChecked:Bool ) {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionProductSaveProduct
        
        let  params = [
            "subs_mongo_id": subscriptionId,
            "is_checked": isChecked,
            "cart_id": cartId,
            "product_id": productId,
            "qty": 1
            ] as [String : AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionProductEditModel.self, from: responseData)
                    print(responseModel)
                    weakSelf.SendRequestSubscriptionProductListApi(subscriptionId: weakSelf.subscriptionId)
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

// MARK: - NavigationBar Methods
extension GSProductListViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender:UIButton) {
        
        if  arrayProductList.count > 0 {
            
            if subscriptionType == "Daily" || subscriptionType == "Weekly" {
                
                if let product = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSSubscribeDailyViewController") as? GSSubscribeDailyViewController {
                    product.subscribeType = subscriptionType
                    product.subscribeId = subscriptionId
                    product.subscriptionDetails = arrayProductList
                    navigationController?.pushViewController(product, animated: true)
                }
            } else if (subscriptionType == "Alternate days" ){
                
                if let product = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSSubscriptionAlternateViewController") as? GSSubscriptionAlternateViewController {
                    product.subscribeType = subscriptionType
                    product.subscribeId = subscriptionId
                    product.subscriptionDetails = arrayProductList
                    navigationController?.pushViewController(product, animated: true)
                }
            } else {
                if let product = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil).instantiateViewController(withIdentifier: "GSSubscriptiondaysEditViewController") as? GSSubscriptiondaysEditViewController {
                    product.subscribeType = subscriptionType
                    product.subscribeId = subscriptionId
                    navigationController?.pushViewController(product, animated: true)
                }
            }
        }
    }
}

// MARK:- TableView Delegates
extension GSProductListViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayProductList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100 //UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayProductList[section].products!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
     
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        
        let title_lable = UILabel()
        title_lable.text = arrayProductList[section].shop?.displayName ?? ""
        title_lable.font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont(name: "HelveticaNeue-Medium", size: 16) : UIFont(name: "HelveticaNeue-Medium", size: 14)
        title_lable.textColor = UIColor(hexString: defaultTheme.cart_header_title)
        headerView.backgroundColor = UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND)
        headerView.addSubview(title_lable)
        
        title_lable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: title_lable, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier:"ProductListTableViewCell" ) as? ProductListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        let productData = arrayProductList[indexPath.section].products![indexPath.row]
        cell.productTitle_Label.text = productData.productName
        cell.productPrice_Label.text = "\(productData.netPrice ?? 0.0)"
        cell.productQty_Label.text = "\(productData.qty ?? 0)"
        
        cell.productQty_Label.text = "\(productData.qty ?? 0)"

        cell.radio_Button.tag = indexPath.row
        cell.radio_Button .addTarget(self, action: #selector(actionActiveButtonAction(sender:)), for: .touchUpInside)
        if productData.isChecked == true {
            cell.radio_Button .setImage(UIImage(named: "checkedBox_Active"), for: .normal)

        } else {
            cell.radio_Button .setImage(UIImage(named: "checkBox_InActive"), for: .normal)

        }
        
        var imageEndPoint = ""

        if let image_array = productData.images {
            if image_array.count > 0 {
                imageEndPoint = image_array[0].name ?? ""
            }
        }
        
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        SDWebImageDownloader.shared.setValue(accessToken, forHTTPHeaderField: "Authorization")

        let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight

        cell.product_ImageIcon.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewProductImage + imageEndPoint + imgHeight) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
        
        let lastRowIndex =  arrayProductList[indexPath.section].products!.count - 1
        
        if lastRowIndex == indexPath.row {
            cell.separateLine.isHidden = true
        } else {
            cell.separateLine.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
    }
    
    @objc func actionActiveButtonAction(sender:UIButton) {
      
        let buttonPosition = sender.convert(CGPoint.zero, to: self.productList_Tableview)
        let indexPath = self.productList_Tableview.indexPathForRow(at:buttonPosition)
        
        let checked = arrayProductList[indexPath!.section].products![indexPath!.row].isChecked
        
        if  arrayLivedProductList.count == 1 &&  checked == true {

            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.subscriptionMessage, viewController: self)
        } else {
            
            let cartid = arrayProductList[indexPath!.section].cartID ?? ""
            let productid = arrayProductList[indexPath!.section].products![indexPath!.row].id ?? ""
            
            if checked == true {
                self.SendRequestSubscriptionProductActiveApi(subscriptionId: subscriptionId, productId: productid, cartId: cartid, isChecked: false)
            } else {
                self.SendRequestSubscriptionProductActiveApi(subscriptionId: subscriptionId, productId: productid, cartId: cartid, isChecked: true)
            }
        }
    }
}

// MARK: - Make Manual Order
struct SubscriptionManualOrder: Codable {
    let success: Bool?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success, message
    }
}

// MARK: - SubscriptionProductListModel
struct SubscriptionProductListModel: Codable {
    let success: Bool?
    let data, draftProducts: [ProductListData]?
    
    enum CodingKeys: String, CodingKey {
        case success, data
        case draftProducts = "draft_products"
    }
}

// MARK: - Datum
struct ProductListData: Codable {
    let id: String?
    let products: [ProductData]?
    let cartID: String?
    let shop: productShop?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case products
        case cartID = "cart_id"
        case shop
    }
}

// MARK: - Product
struct ProductData: Codable {
    let id: String?
    let qty: Int?
    let isChecked: Bool?
    let sellingPrice, grossPrice, taxPrice, netPrice: Double?
    let serviceFee: Double?
    let productName: String?
    let images: [Image]?
    
    enum CodingKeys: String, CodingKey {
        case id, qty
        case isChecked = "is_checked"
        case sellingPrice = "selling_price"
        case grossPrice = "gross_price"
        case taxPrice = "tax_price"
        case netPrice = "net_price"
        case serviceFee = "service_fee"
        case productName = "product_name"
        case images
    }
}

// MARK: - Image
struct Image: Codable {
    let keyid: Keyid?
    let name: String?
    let width, height: Int?
}

enum Keyid: String, Codable {
    case image1 = "image1"
    case image2 = "image2"
    case image3 = "image3"
    case image4 = "image4"
}

// MARK: - Shop
struct productShop: Codable {
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
    }
}

