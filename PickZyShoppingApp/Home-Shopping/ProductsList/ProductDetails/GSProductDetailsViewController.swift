//
//  GSProductDetailsViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 18/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//  Reviewing inprogress

import UIKit

struct GSAddToCartModel: Codable {
    let success: Bool?
    let data: GSCartListNewData?
}

class GSProductDetailsViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarWithCart!
    @IBOutlet weak var product_imageView: UIImageView!
    @IBOutlet weak var info_tableView: UITableView!
    @IBOutlet weak var infoTableHeight_constraint: NSLayoutConstraint!
    @IBOutlet weak var swipe_view: UIView!
    
    @IBOutlet weak var reviews_btn: GSBaseButton!
    @IBOutlet weak var productDetail_btn: GSBaseButton!
    @IBOutlet weak var addToCart_btn:GSBaseButton!
    @IBOutlet weak var productDesc_tableView:UITableView!
    
    @IBOutlet weak var main_scrollView:UIScrollView!
    @IBOutlet weak var btn_stackView:UIStackView!
    @IBOutlet weak var desTableHeight_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextProductImage_btn:GSBaseButton!
    @IBOutlet weak var previousProductImage_btn:GSBaseButton!
    @IBOutlet weak var nextProduct_btn:GSBaseButton!
    @IBOutlet weak var previousProduct_btn:GSBaseButton!
    @IBOutlet weak var offerAngle_view:UIView!
    @IBOutlet weak var offer_lbl:GSBaseLabel!
    @IBOutlet weak var addToCartHeight_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var report_imgView: UIImageView!
    @IBOutlet weak var report_btn: UIButton!
    var zoomView:GSProductImageView! = nil
    var detailsWithOfferPopup:GSProductDetailsWithOfferPopUpView! = nil
    
    let productInfoTableViewCellHeight:CGFloat = 38
    
    var prodDesTableHeight = 0
    var imageIndex = Int()
    var detailsText_array = [String]()
    var detailsValues_array = [String]()
    var selectedBtnIndex = 0
    
    var catId : String?
    var storesArray : [String]?
    var productId : String?
    var selectedProductIndex : Int?
    
    var totalStock = 0
    
    var productDetails : [String: Any]?
    var imageArray : [Any]? = nil

    var selectedProductItem : GSProductsList?

    var productListArray : [GSProductsList]? = nil
    var templateArray : [GSProductDetailsKeyTemplate]? = nil
    
    var reviewsObject = [String:Any]()
    
    var stores = [Any]()
    var selectedProducts_array = [[String:Any]]()
    fileprivate var selectedProducts_dictionary = [String:Int]()
    
    var tableViewContentOffsetY:CGFloat = 0
    
    var isFromOrdersToSeeInfo = false
    
    var productReviewsClosure_instance : ((_ response: Data?, _ error: NSError?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar_view.navigationBarReload()
        addFewInitializers()
        addSwipeGesture()
        applyColors()
        getProductDetailsAPI()
        main_scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar_view.navigationBarReload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        infoTableHeight_constraint.constant = CGFloat(detailsText_array.count) * productInfoTableViewCellHeight
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            var combined = (view.safeAreaInsets.top + navigationBar_view.frame.size.height) + (infoTableHeight_constraint.constant + btn_stackView.frame.size.height)
            combined += (addToCart_btn.frame.size.height + 13)
                
            desTableHeight_constraint.constant = view.frame.size.height - combined
        } else {
            let combined = (view.safeAreaInsets.top + navigationBar_view.frame.size.height +  addToCart_btn.frame.size.height + swipe_view.frame.height + 13)
            desTableHeight_constraint.constant = view.frame.size.height - combined
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        main_scrollView.contentSize = CGSize(width: main_scrollView.frame.size.width, height: btn_stackView.frame.origin.y + btn_stackView.frame.size.height + productDesc_tableView.frame.height                            )
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        
        info_tableView.backgroundColor = UIColor(hexString: defaultTheme.productDescVC_detailTable_BG)
        info_tableView.layer.borderWidth = 1.0
        info_tableView.layer.borderColor = UIColor(hexString: defaultTheme.productDescVC_detailTable_border).cgColor
        
        productDetail_btn.backgroundColor = UIColor(hexString: defaultTheme.productDescVC_tabBtn_selection_BG)
        productDetail_btn.layer.borderWidth = 1.0
        productDetail_btn.layer.borderColor = UIColor(hexString: defaultTheme.productDescVC_tabBtn_border).cgColor
        
        reviews_btn.backgroundColor = UIColor(hexString: defaultTheme.productDescVC_tabBtn_BG)
        reviews_btn.layer.borderWidth = 1.0
        reviews_btn.layer.borderColor = UIColor(hexString: defaultTheme.productDescVC_tabBtn_border).cgColor
        
        addToCart_btn.backgroundColor = UIColor(hexString: defaultTheme.productDescVC_addCartBtn_BG)
    }
    
    //MARK: - User defined methods
    private func addFewInitializers() {
        
        navigationBar_view.delegate = self
        
        info_tableView.dataSource = self
        info_tableView.delegate = self
        info_tableView.isScrollEnabled = false
        
        productDesc_tableView.dataSource = self
        productDesc_tableView.delegate = self
        
        offerAngle_view.layer.masksToBounds = true
        offerAngle_view.layer.cornerRadius = 0.5 * offerAngle_view.frame.size.height
        offerAngle_view.transform = CGAffineTransform(rotationAngle: CGFloat(45.0))
        
        let reviewsHeaderNib = UINib.init(nibName: GSString.NibNames.GSProductReviewHeaderView, bundle: nil)
        productDesc_tableView.register(reviewsHeaderNib, forHeaderFooterViewReuseIdentifier: GSProductReviewHeaderView.headerIdentifier)
        
        detailsText_array = ["Unit", "Price", "Qty"]
        
        if isFromOrdersToSeeInfo {
            
            nextProduct_btn.setImage(nil, for: .normal)
            previousProduct_btn.setImage(nil, for: .normal)
            
            navigationBar_view.rightBarBtn.isHidden = true
            navigationBar_view.cartIconView.isHidden = true
            
            addToCartHeight_constraint.constant = 0
            addToCart_btn.isHidden = true
            
            detailsText_array = ["Unit", "Price"]
            
            report_imgView.isHidden = true
            report_btn.isHidden = true
        }
        
        detailsValues_array = ["","",""]
        
        productDesc_tableView.tableFooterView = UIView()
        
        addToCart_btn.backgroundColor = UIColor.lightGray
        addToCart_btn.isEnabled = false
        
        imageIndex = 0
    }
    
    // MARK: - API Methods
    func getProductDetailsAPI() {
        
        if reviewsObject.count > 0 {
            reviewsObject.removeAll()
            if selectedBtnIndex == 1 {
                productDesc_tableView.reloadData()
            }
        }
        
        productReviewsClosure_instance = nil
        
        if (imageArray?.count ?? 0) > 0 {
            imageArray?.removeAll()
        }
        
        let params = [APIKeys.ProductDetails.Request.id_req : (catId ?? "") as Any,
                      APIKeys.ProductDetails.Request.stores : storesArray as Any,
                      APIKeys.ProductDetails.Request.product : (productId ?? "") as  Any] as [String : AnyObject]
        
        let product_details_Url = APIurl.baseURL + APIurl.subURL.productDetails
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject],urlString: product_details_Url, withLoader:true){ [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                
                do {
                    guard let responseData = response else {return}
                    let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: [])
                    #if DEBUG
                    print(jsonResponse) //Response result
                    #endif
                    guard let dataDictionary = jsonResponse as? [String:Any] else {return}
                    guard let product_details_dictionary = dataDictionary["data"] as? [String:Any] else {return}
                    
                    if let reviews = product_details_dictionary["reviews"] as? [String:Any] {
                        weakSelf.reviewsObject = reviews
                    }
                    
                    weakSelf.productDetails = product_details_dictionary
                    
                    weakSelf.info_tableView.reloadData()
                    weakSelf.productDesc_tableView.reloadData()
                    weakSelf.loadProductDetails()
                    if weakSelf.selectedBtnIndex == 1 {
                        weakSelf.getProductReviewsAPI()     // If we get product details we will go for reviews
                    }
                } catch {
                    print(error.localizedDescription)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func getProductReviewsAPI() {
        
        productReviewsClosure_instance = nil
        
        let params = [APIKeys.ProductDetails.Request.id_req : (catId ?? "") as Any,
                      APIKeys.ProductDetails.Request.stores : storesArray as Any,
                      APIKeys.ProductDetails.Request.product : (productId ?? "") as  Any] as [String : AnyObject]
        
        let product_details_Url = APIurl.baseURL + APIurl.subURL.productReviews
        
        productReviewsClosure_instance = APIHandler.BackGroundNetworkSetupRequest(method: .post, params: params as [String : AnyObject],urlString: product_details_Url, withLoader:true){ [weak self] (response, error) in
            
            if self?.productReviewsClosure_instance == nil { return }
            if self == nil { return }
            
            if error == nil {
                
                do {
                    guard let responseData = response else { return }
                    let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: [])
                    #if DEBUG
                    print(jsonResponse) //Response result
                    #endif
                    guard let dataDictionary = jsonResponse as? [String:Any] else { return }
                    guard let reviewsData = dataDictionary["data"] as? [String:Any] else { return }
                    
                    self?.reviewsObject = reviewsData
                    self?.productDesc_tableView.reloadData()
                    
                } catch {
                    print(error.localizedDescription )
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: self!)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: self!)
            }
        }
    }
    
    func addToCartApi(store_item:[[String:Any]]) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.addProductToCart
        
        var product_id = ""
        
        if let prodDetails = productDetails {
            product_id = prodDetails[APIKeys.ProductDetails.Response.id_res] as? String ?? ""
        }
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        
        let params = ["_id" : storeCategory_id as AnyObject ,
                      "product_id" : product_id as AnyObject ,
                      "is_private" : SharedPersistence.getValue(key: UserDefaultKeys.Products.isPrivateShop) as? Bool ?? false,
                      "stores" : store_item as AnyObject] as [String : AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:true) { [weak self]  (response, error) in
            
            // Making sure the next code will not execute if the view controller not exists in memory
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSAddToCartModel.self, from: responseData)
                    
                    if responseModel.success ?? false {
                        
                        if let cart_item = responseModel.data {
                            if let product_id = cart_item.id {
                                cartItemsDictionary[product_id] = cart_item
                            }
                        }
                        print("Added")
                        GSCustomPushPop.doCustomPop(from: self!)
                    } else {
                        print("Error in adding to cart")
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
    
    func selectMatchingStore(_storeCartArray : [GSCartListNewStore], productStoreId : String) -> GSCartListNewStore? {
        
        for storeCart in _storeCartArray {
            
            if storeCart.storeID == productStoreId {
                return storeCart
            }
        }
        return nil
    }

    private func reduceCartQtyWithProductArray(product_id:String, productStoresArray:[Any]) -> [Any] {
        
        if let productCartItem = cartItemsDictionary[product_id] {
            
            guard let cartStoreItems = productCartItem.stores else { return productStoresArray }
            var _productStoresArray = [Any]()

            var totalCart : Int = 0
            var storeQty : Int = 0
            for index in 0..<productStoresArray.count {
                
                if index < cartStoreItems.count {
                    
                    var productStore = productStoresArray[index] as? [String:Any]
                    
                    let storeCartArray = selectMatchingStore(_storeCartArray: cartStoreItems, productStoreId: productStore!["store_id"] as! String)
                    if storeCartArray == nil {
                        continue
                    }
                    let _cartQty : Int = (storeCartArray?.productDetails?.qty ?? 0) + totalCart
                    
                    if var product_store = productStoresArray[index] as? [String:Any] {
                        
                        var productInfo = product_store["product_details"] as? [String:Any]
                        let productQty : Int = productInfo!["stock"] as! Int
                        
                        if productQty >= _cartQty {

                            productInfo!["stock"] =  productQty - _cartQty
                            storeQty = productQty - _cartQty
                        } else {
                            productInfo!["stock"] = 0
                            totalCart = _cartQty - productQty
                        }
                        if storeQty != 0 {
                            product_store["product_details"] = productInfo
                            _productStoresArray.append(product_store as Any)
                        }

                        #if DEBUG
                            print("product_details = ", productInfo!["stock"] as Any)
                            print("Copy product_store = ", _productStoresArray as Any)
                            print("Original product_store = ", productStoresArray as Any)
                        #endif
                    }
                } else {
                    if let product_store = productStoresArray[index] as? [String:Any] {
                        _productStoresArray.append(product_store as Any)
                    }
                }
            }
            return _productStoresArray
        }
        return productStoresArray
    }
    
    func loadProductDetails() {
        
        if let prodDetails = productDetails {
            
            let prodInfo =  prodDetails[APIKeys.ProductDetails.Response.productInfo] as? [String : Any]
            let product_id = prodDetails[APIKeys.ProductDetails.Response.id_res] as? String ?? ""
            
            imageArray = prodInfo?[APIKeys.ProductDetails.Response.images] as? [Any]
            product_imageView.image = #imageLiteral(resourceName: "Pickzy_logo")
            
            previousProduct_btn.setImage(#imageLiteral(resourceName: "Double_Left_arrow"), for: .normal)
            nextProduct_btn.setImage(#imageLiteral(resourceName: "Double_Right_arrow"), for: .normal)
            
            nextProductImage_btn.setImage(nil, for: .normal)
            previousProductImage_btn.setImage(nil, for: .normal)
            
            if selectedProductIndex == 0 {
                previousProduct_btn.setImage(nil, for: .normal)
            }
            if selectedProductIndex == ((productListArray?.count ?? 0) - 1) {
                nextProduct_btn.setImage(nil, for: .normal)
            }
            
            
            if isFromOrdersToSeeInfo {
                previousProduct_btn.setImage(nil, for: .normal)
                nextProduct_btn.setImage(nil, for: .normal)
            }
            
            imageIndex = 0
            
            if let unwrappedimages_array = imageArray {
                
                if unwrappedimages_array.count > 0 {
                    
                    if unwrappedimages_array.count > 1 {
                        nextProductImage_btn.setImage( #imageLiteral(resourceName: "RightArrow"), for: .normal)
                    }
                    
                    if let firstImage = unwrappedimages_array[0] as? [String: Any] {
                        let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
                        let imageUrl = APIurl.baseURL + APIurl.subURL.viewProductImage + "\(firstImage[APIKeys.ProductDetails.Response.image_name] ?? "")"
                        product_imageView.sd_setImage(with: URL(string:imageUrl+imgHeight), placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
                    }
                }
            }
            
            navigationBar_view.titleLable.text = prodInfo?[APIKeys.ProductDetails.Response.product_name] as? String ?? ""
            
            guard var stores =  prodDetails[APIKeys.ProductDetails.Response.stores] as? [Any] else { return }
            
            
            for index in stride(from: stores.count - 1, through: 0, by: -1) {
                
                guard let unwrapped_store = stores[index] as? [String:Any] else { continue }
                guard let details = unwrapped_store[APIKeys.ProductDetails.Response.product_details] as? [String : Any] else { continue }
                guard let stock = details[APIKeys.ProductDetails.Response.stock] as? Int else { continue }
                
                if stock == 0 {
                    stores.remove(at: index)
                }
            }
            
            
            stores = reduceCartQtyWithProductArray(product_id: product_id,productStoresArray: stores)
            
            stores = stores.sorted(by: { (firstItem, secondItem) -> Bool in
                
                if let firstStore = firstItem as? [String: Any], let secondStore = secondItem as? [String:Any],
                    let firstStoreDetails = firstStore[APIKeys.ProductDetails.Response.product_details] as? [String:Any], let secondStoreDetails = secondStore[APIKeys.ProductDetails.Response.product_details] as? [String: Any] {
                    
                    
                    if let firstStoreNetPrice = firstStoreDetails["net_price"] as? Double, let secondStoreNetPrice = secondStoreDetails["net_price"] as? Double {
                        return firstStoreNetPrice < secondStoreNetPrice
                    }
                    
                }
                
                return true
            })
            
            totalStock = 0
            
            if selectedProducts_array.count > 0 {
                selectedProducts_array.removeAll()
            }
            
            // Now we will check for the total Stock
            for index in 0..<stores.count {
                // Will count stocks from all stores in which the current product available
                guard let unwrapped_store = stores[index] as? [String:Any] else { continue }
                guard let details = unwrapped_store[APIKeys.ProductDetails.Response.product_details] as? [String : Any] else { continue }
                guard let stock = details[APIKeys.ProductDetails.Response.stock] as? Int else { continue }
                
                totalStock += stock
            }
            addToCart_btn.backgroundColor = UIColor.lightGray
            addToCart_btn.isEnabled = false
            if stores.count > 0 {
                if let first_item = stores[0] as? [String:Any] {
                    selectedProducts_array.append(first_item)        // To have quantity 1 for the first time
                    
                    let store_id = first_item[APIKeys.ProductDetails.Response.store_id] as? String ?? ""
                    
                    if selectedProducts_dictionary.count > 0 {
                        selectedProducts_dictionary.removeAll()
                    }
                    if totalStock > 0 {
                        selectedProducts_dictionary[store_id] = 1
                    } else {
                        selectedProducts_dictionary[store_id] = 0
                    }
                }
            }

            self.stores = stores
            
            if stores.count == 0 {
                addToCart_btn.backgroundColor = UIColor.lightGray
                addToCart_btn.isUserInteractionEnabled = false
                CustomAlert.showAlert(title: "Info", message: GSConstant.AlertMessages.productDetailsView_stockUnavailable, viewController: self)
                return
            }
            let store = stores[0] as? [String: Any]
            let storeDetails = store![APIKeys.ProductDetails.Response.product_details] as? [String : Any]
            if let offer = storeDetails?[APIKeys.ProductDetails.Response.offer] as? Int {
                if offer != 0 {
                    offerAngle_view.isHidden = false
                    offer_lbl.text = "\(offer)" + "% Off"
                } else {
                    offerAngle_view.isHidden = true
                }
            } else {
                offerAngle_view.isHidden = true
            }
        }
    }
    
    fileprivate func caluculatePriceWithOffer(_ original_price:Double, offer: Double) -> Double {
        if offer == 0 {
            return original_price
        }
        let costOfOffer = (original_price) * (offer/100)
        return (original_price) - costOfOffer
    }
    
    //MARK: - SwipeGestureMethods
    func addSwipeGesture() -> Void {
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipe_view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        swipe_view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func respondToSwipeGesture(gesture:UIGestureRecognizer) -> Void {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.right:
                self.scrollImageLeftSide()
            case UISwipeGestureRecognizerDirection.left:
                self.scrollImageRightSide()
            default:
                break
            }
        }
    }
    
    //MARK: - ChangeImageBasedOn Right And Left side
    func scrollImageRightSide() -> Void {
        
        // Noted crash below line
        if imageArray == nil {
            return
        }
        if imageIndex < (imageArray?.count)! - 1  {
            imageIndex += 1
            
            previousProductImage_btn.setImage(#imageLiteral(resourceName: "LeftArrow"), for: .normal)
            if imageIndex == (imageArray?.count)! - 1 {
                nextProductImage_btn.setImage(nil, for: .normal)
            }
            
            UIView.transition(with: self.product_imageView, duration: 0.2, options: .transitionFlipFromLeft, animations: {
                
                let currentImage = self.imageArray![self.imageIndex] as? [String: Any]
                let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
                let imageUrl = APIurl.baseURL + APIurl.subURL.viewProductImage + "\(currentImage?[APIKeys.ProductDetails.Response.image_name] ?? "")"
                self.product_imageView.sd_setImage(with: URL(string:imageUrl+imgHeight), placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
            }, completion: nil)
        }
    }
    
    func scrollImageLeftSide() -> Void {
        
        if imageIndex > 0 {
            imageIndex -= 1
            
            nextProductImage_btn.setImage(#imageLiteral(resourceName: "RightArrow"), for: .normal)
            if imageIndex == 0 {
                previousProductImage_btn.setImage(nil, for: .normal)
            }
            
            UIView.transition(with: self.product_imageView, duration: 0.2, options: .transitionFlipFromLeft, animations: {
                
                if let currentImage = self.imageArray?[self.imageIndex] as? [String: Any] {
                    
                    let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
                    let imageUrl = APIurl.baseURL + APIurl.subURL.viewProductImage + "\(currentImage[APIKeys.ProductDetails.Response.image_name] ?? "")" + imgHeight
                    self.product_imageView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
                }
            }, completion: nil)
        }
    }
    
    func scrollProductLeft() {
        
        if selectedProductIndex != nil, selectedProductIndex! > 0 {
            selectedProductIndex! -= 1
            productId = productListArray![selectedProductIndex!]._id
            getProductDetailsAPI()
        }
    }
    
    func scrollProductRight() {
        
        if selectedProductIndex != nil, selectedProductIndex! < (productListArray?.count)! - 1  {
            
            selectedProductIndex! += 1
            productId = productListArray![selectedProductIndex!]._id
            getProductDetailsAPI()
        }
    }
    
    // MARK: - View controller Action methods
    @IBAction func reportProduct_action(_ sender: UIButton) {
        
        if let productReportVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSProductReportViewController) as? GSProductReportViewController {
            var product_id = ""
            
            if let prodDetails = productDetails {
                product_id = prodDetails[APIKeys.ProductDetails.Response.id_res] as? String ?? ""
            }
            productReportVC.configureReportViewWith(productName: navigationBar_view.titleLable.text ?? "", product_id: product_id)
            GSCustomPushPop.doCustomPush(from: self, to: productReportVC)
        }
    }
    
    @IBAction func rateProduct_Action(_ sender: UIButton) {
    }
    
    @IBAction func addToFavourite_Action(_ sender: UIButton) {
    }
    
    @IBAction func zoom_Action(_ sender: UIButton) {
        
        if zoomView != nil {
            if zoomView.isDescendant(of: self.view) {
                return
            }
            zoomView = nil
        }
        
        if (imageArray?.count ?? 0) <= 0 {
            return
        }
        
        zoomView = GSProductImageView()
        zoomView.imageIndex = imageIndex
        zoomView.imagesArray =  imageArray
        zoomView.currentPage = selectedProductIndex ?? 0
        zoomView.showTheViewOn(self.view)
        
//        zoomView.showTheViewFromBottom(on: view, for: CGRect(x: 0, y: topLayoutGuide.length, width: view.frame.size.width, height: view.frame.size.height - topLayoutGuide.length - bottomLayoutGuide.length), completionHandler: {})
    }
    
    @IBAction func nextProduct_Action(_ sender: UIButton) {
        scrollProductRight()
    }
    
    @IBAction func previousProduct_Action(_ sender: UIButton) {
        scrollProductLeft()
    }
    
    @IBAction func nextImage_Action(_ sender: UIButton) {
        self.scrollImageRightSide()
    }
    @IBAction func previousImage_Action(_ sender: UIButton) {
        self.scrollImageLeftSide()
    }
    
    @IBAction func detailAndReviewAction(_ sender: UIButton) {
        
        if selectedBtnIndex == sender.tag {
            return
        }
        
        reviews_btn.backgroundColor = UIColor(hexString: defaultTheme.productDescVC_tabBtn_BG)
        productDetail_btn.backgroundColor = UIColor(hexString: defaultTheme.productDescVC_tabBtn_BG)
        sender.backgroundColor = UIColor(hexString: defaultTheme.productDescVC_tabBtn_selection_BG)
        selectedBtnIndex = sender.tag
        
        if selectedBtnIndex == 1 && reviewsObject.count == 0 {
            getProductReviewsAPI()
        }
        productDesc_tableView.reloadData()
    }
    
    @IBAction func addToCart_Action(_ sender: UIButton) {
        
        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
        
        if isGuestLogin {
            
            if let welcomeViewController = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSWelcomeScreenViewController) as? GSWelcomeScreenViewController {
                welcomeViewController.isShowingForGuestUser = true
                
                GSCustomPushPop.doCustomPush(from: self, to: welcomeViewController)
            }
            return
        }
        
        guard let unwrappedSelectedProductIndex = selectedProductIndex else { return }
        
        if self.isProductExists(index : unwrappedSelectedProductIndex){
            self.addProductToCart(index: unwrappedSelectedProductIndex, exists: true)
        } else {
            self.addProductToCart(index: unwrappedSelectedProductIndex, exists: false)
        }

        var storesArrayForApiRequest = [[String:Any]]()
        
        for (key_id,value_quantity) in selectedProducts_dictionary {
            
            let apiRequestDict = ["store_id": key_id,
                                  "qty":value_quantity] as [String : Any]
            storesArrayForApiRequest.append(apiRequestDict)
        }
        addToCartApi(store_item: storesArrayForApiRequest)
    }
    
    func isProductExists(index: Int) -> Bool {

        guard let unwrappedProductListArray = productListArray, unwrappedProductListArray.count > index else { return false }
        
        let selectedItem = unwrappedProductListArray[index]
        for item in cartItems {
            if item.product_id == selectedItem._id{
                return true
            }
        }
        return false
    }
    
    func getTheCartItemModel(product_id:String) -> CartItemsModel? {
        
        for item in cartItems {
            if item.product_id == product_id {
                return item
            }
        }
        return nil
    }
    
    func addProductToCart(index : Int, exists: Bool) {

        //let prodPrice = (productListArray![index].stores![0].product_details?.selling_price != nil) ? productListArray![index].stores![0].product_details?.selling_price! : 0
        
        let indexPath = IndexPath(row: 2, section: 0)

        guard let cell = info_tableView.cellForRow(at: indexPath) as? GSProductDetailsTableViewCell else {
            return
        }
        let quantity = Int(cell.quantity_lbl.text ?? "")
        cartCount.value = cartCount.value + (quantity ?? 0)
    }
    
    //MARK: - Orientation method
    private func doSomethingAfterOrientation() {
        
        infoTableHeight_constraint.constant = CGFloat(detailsText_array.count) * productInfoTableViewCellHeight
        desTableHeight_constraint.constant = main_scrollView.frame.size.height - info_tableView.frame.size.height - btn_stackView.frame.size.height
        main_scrollView.contentSize = CGSize(width: main_scrollView.frame.size.width, height: main_scrollView.frame.size.height + swipe_view.frame.origin.y + swipe_view.frame.size.height)
    }
    
    private func refreshZoomViewAfterOrientation () {
        if zoomView != nil {
            if zoomView.isDescendant(of: view) {
                zoomView.refreshPageControlAndOffset()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
        }) { [weak self] (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            self?.doSomethingAfterOrientation()
            self?.view.layoutIfNeeded()
            self?.refreshZoomViewAfterOrientation()
        }
    }
}

extension GSProductDetailsViewController:UITableViewDelegate,UITableViewDataSource {
    //MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == info_tableView {
            return detailsText_array.count
        } else {
            if selectedBtnIndex == 0 {
                if templateArray != nil {
                    return templateArray!.count
                }
                return 0
            }
            
            // Reviews
            
            if let review_array = reviewsObject["customer"] as? [Any] {
                return review_array.count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == info_tableView {
            return productDetailCell(tableView, forRowAt: indexPath)
        } else {
            return productDescriptionCell(tableView, forRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == productDesc_tableView {
            
            if selectedBtnIndex == 1 {
                return UITableViewAutomaticDimension
            }
            
            let theKey = templateArray?[indexPath.row].key_name ?? ""

            if let productInfoDictionary = productDetails?[APIKeys.ProductDetails.Response.productInfo] as? [String : Any] {

                let stringValue = GSCommonHelper.getStringFrom(anyValue: productInfoDictionary[theKey])
                
                if let doubleValue = Double(stringValue), doubleValue == 0 {
                    return 0
                }

                if stringValue == "" || stringValue == "undefined" {
                    return CGFloat.leastNonzeroMagnitude
                }
            }
            
            return UITableViewAutomaticDimension
        } else {
            return productInfoTableViewCellHeight
        }
    }
    
    // MARK: - UITableView Header view methods
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == productDesc_tableView {
            if selectedBtnIndex == 0 { return 3.0 }
            return 50.0
        }
        return 3.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView != productDesc_tableView {
            return UIView()
        }
        
        if selectedBtnIndex == 0 {
            return UIView()
        } else {
            let reviewHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: GSProductReviewHeaderView.headerIdentifier) as! GSProductReviewHeaderView
            reviewHeaderView.rating_view.isUserInteractionEnabled = false
            
            reviewHeaderView.rating_view.type = .halfRatings
            reviewHeaderView.reviewCount_lbl.text = ""
            if let numberOfReviews = reviewsObject["total"] as? Int {
                reviewHeaderView.reviewCount_lbl.text = "\(numberOfReviews) reviews"
                reviewHeaderView.reviewKey_lbl.text = "Customer Reviews:"
            } else {
                reviewHeaderView.reviewKey_lbl.text = "No reviews"
            }
            
            if let totalReview = reviewsObject["average"] as? Double {
                let roundedReview = totalReview
                reviewHeaderView.rating_view.rating = roundedReview
            } else {
                reviewHeaderView.rating_view.rating = Double(0)
            }
            
            return reviewHeaderView
        }
    }
    
    // MARK: - Product details Tableview Configuration
    private func productDetailCell(_ tableView: UITableView, forRowAt indexPath:IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.ProductDetailsVC_detail_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSProductDetailsTableViewCell else {
            return UITableViewCell()
        }
        cell.minus_btn.tag = indexPath.row
        cell.minus_btn.addTarget(self, action: #selector(cell_minusAction(_:)), for: .touchUpInside)
        cell.plus_btn.tag = indexPath.row
        cell.plus_btn.addTarget(self, action: #selector(cell_plusAction(_:)), for: .touchUpInside)
        cell.extra_btn.addTarget(self, action: #selector(cell_moreAction(_:)), for: .touchUpInside)
        cell.configureTheCell(productDetails: productDetails, sorted_stores: stores, indexPath: indexPath)
        return cell
    }
    
    // MARK: - Product Description Tableview Configuration
    private func productDescriptionCell(_ tableView: UITableView, forRowAt indexPath:IndexPath) -> UITableViewCell {
        
        if selectedBtnIndex == 0 {
            
            let identifier = GSString.CellIdentifier.ProductDetailsVC_description_tableCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSProductDescriptionTableCell else {
                return UITableViewCell()
            }
            
            let theKey = templateArray![indexPath.row].key_name
            cell.key_lbl.text = templateArray![indexPath.row].display_name
            var productInfo : [String: Any]? = nil
            cell.value_lbl.text = ""
            
            if productDetails != nil {
                
                productInfo = productDetails![APIKeys.ProductDetails.Response.productInfo] as? [String : Any]
                if let prodInfo = productInfo {
                    
                    if let val = prodInfo[theKey ?? ""] {
                        cell.key_lbl.isHidden = false
                        
                        if theKey == "category", var strValue = val as? String {
                            
                            if strValue.first == "/" {
                                strValue.removeFirst()
                            }
                            cell.value_lbl.text = strValue.replacingOccurrences(of: "/", with: " > ")
                            
                        } else {
                            cell.value_lbl.text = "\(val)"
                        }
                        
                        prodDesTableHeight = prodDesTableHeight + 40
                    } else {
                        cell.key_lbl.isHidden = true
                    }
                }
            }
            cell.lblBG_view.backgroundColor = UIColor.clear
            cell.lblBG_view.layer.borderWidth = 0.0
            cell.lblBG_view.layer.borderColor = UIColor(hexString: defaultTheme.productDescVC_otherInfoLbl_border).cgColor
            return cell
        }  else {
            
            let identifier = GSString.CellIdentifier.ProductDetailsVC_review_tableCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSProductDescriptionReviewTableCell else {
                return UITableViewCell()
            }
            
            cell.rating_view.isUserInteractionEnabled = false
            
            cell.lblBG_view.isHidden = true
            
            if let review_array = reviewsObject["customer"] as? [[String:Any]], review_array.count > indexPath.row {
                let review = review_array[indexPath.row]
                cell.configureTheCell(reviewItem:review)
            }
            
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    //MARK: - Cell Action methods
    @objc func cell_plusAction (_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        guard let cell = info_tableView.cellForRow(at: indexPath) as? GSProductDetailsTableViewCell else {
            return
        }
        
        let indexPathForPriceCell = IndexPath(row: sender.tag - 1, section: 0)
        
        guard let priceCell = info_tableView.cellForRow(at: indexPathForPriceCell) as? GSProductDetailsTableViewCell else {
            return
        }
        
        if var quantity = Int(cell.quantity_lbl.text!) {
            
            if quantity == GSConstant.addToCartMax {
                CustomAlert.showAlert(title: GSString.AppName, message: "You cannot add more than \(GSConstant.addToCartMax) products to cart.", viewController: self)
                return
            }
            
            if quantity < totalStock {
                quantity += 1
                cell.quantity_lbl.text = "\(quantity)"
                
                addToCart_btn.backgroundColor = UIColor.init(hexString: color.whiteTheme.productDescVC_addCartBtn_BG)
                addToCart_btn.isEnabled = true
                if quantity == 1 {
                    return
                }
                addProduct()
                updateTheCell(priceCell, quantityCell: cell)
            }
        }
    }
    
    private func addProduct() {
        
        let addedProductsTill = selectedProducts_array.count
        
        var available_stock = 0
        
        for store in self.stores {
            
            guard let theStore = store as? [String:Any] else { continue }
            guard let product_details = theStore[APIKeys.ProductDetails.Response.product_details] as? [String:Any] else { continue }
            
            let stock = product_details[APIKeys.ProductDetails.Response.stock] as? Int ?? 0
            
            let store_id = theStore[APIKeys.ProductDetails.Response.store_id] as? String ?? ""
            
            available_stock += stock
            
            if addedProductsTill > available_stock - 1 {
                continue
            } else {
                selectedProducts_array.append(theStore)
                selectedProducts_dictionary[store_id] = (selectedProducts_dictionary[store_id] ?? 0) + 1
                break
            }
        }
    }
    
    private func removeProduct() {
        
        if selectedProducts_array.count > 0 {
            
            var storeObject = selectedProducts_array.removeLast()
            let storeId = storeObject["store_id"] as? String ?? ""
            
            if selectedProducts_dictionary[storeId] != nil {
                
                if selectedProducts_dictionary[storeId]! == 1 {
                    selectedProducts_dictionary.removeValue(forKey: storeId)
                } else {
                    selectedProducts_dictionary[storeId] = (selectedProducts_dictionary[storeId] ?? 0) - 1
                }
            }
        }
        
        #if false // Need to remove
        for store in stores.reversed() {
            guard let theStore = store as? [String:Any] else { continue }
            let store_id = theStore[APIKeys.ProductDetails.Response.store_id] as? String ?? ""
            
            if selectedProducts_dictionary[store_id] != nil {
                
                if selectedProducts_dictionary[store_id]! == 1 {
                    selectedProducts_dictionary.removeValue(forKey: store_id)
                    
                    print("Cart store_id 3", store_id)
                    
                    break
                } else {
                    selectedProducts_dictionary[store_id] = (selectedProducts_dictionary[store_id] ?? 0) - 1
                }
            } else {
                continue
            }
        }
        #endif
    }
    
    private func updateTheCell(_ pricecell:GSProductDetailsTableViewCell, quantityCell:GSProductDetailsTableViewCell) {
        
        var savedMoney:Double = 0
        
        quantityCell.extra_btn.isHidden = true
        
        var finalSelling_price:Double = 0
        var finalDiscount_price:Double = 0
        
        for store in stores {
            
            guard let theStore = store as? [String:Any] else { continue }
            
            let store_id = theStore[APIKeys.ProductDetails.Response.store_id] as? String ?? ""
            
            if let product_detials = theStore[APIKeys.ProductDetails.Response.product_details] as? [String:Any] {
                
                let selling_price = product_detials[APIKeys.ProductDetails.Response.selling_price] as? Double ?? Double(0)
                
                let offer = product_detials[APIKeys.ProductDetails.Response.offer] as? Double ?? Double(0)
                
                var final_price = selling_price
                let selectedStock = selectedProducts_dictionary[store_id] ?? 0
                
                if offer > 0 {
                    final_price = caluculatePriceWithOffer(selling_price, offer: offer)
                }
                
                finalSelling_price += selling_price * Double(selectedStock)
                finalDiscount_price += final_price * Double(selectedStock)
            }
        }
        
        if selectedProducts_dictionary.count > 1 {          // Multiple stores involved
            quantityCell.extra_btn.isHidden = false
        }
        
        savedMoney = finalSelling_price - finalDiscount_price
        
        if savedMoney == 0 {            // Means there is no offer
            pricecell.detailValue_lbl.text = GSCommonHelper.formattedPrice(price: finalSelling_price) //GSConstant.currency_symbol + " \(finalSelling_price)"
            pricecell.orignalPriceWithStrikedLineBg_view.isHidden = true
            pricecell.extra_btn.isHidden = true
        } else {
            pricecell.detailValue_lbl.text = GSCommonHelper.formattedPrice(price: finalDiscount_price) //GSConstant.currency_symbol + " \(finalDiscount_price)"
            pricecell.orignalPriceWithStrikedLineBg_view.isHidden = false
            pricecell.originalPriveWithStrikedLine_lbl.text = GSCommonHelper.formattedPrice(price: finalSelling_price) //GSConstant.currency_symbol + " \(finalSelling_price)"
            pricecell.extra_btn.isHidden = false
            let roundedSaved_price = round(savedMoney)
            let int_savedValue = Int(roundedSaved_price)
            pricecell.extra_btn.setTitle("Save \(int_savedValue)", for: .normal)
        }
    }
    
    @objc func cell_minusAction (_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        guard let cell = info_tableView.cellForRow(at: indexPath) as? GSProductDetailsTableViewCell else {
            return
        }
        let indexPathForPriceCell = IndexPath(row: sender.tag - 1, section: 0)
        
        guard let priceCell = info_tableView.cellForRow(at: indexPathForPriceCell) as? GSProductDetailsTableViewCell else {
            return
        }
        
        if var quantity = Int(cell.quantity_lbl.text ?? "") {
            
            if quantity > 1 {
                quantity -= 1
            } else {
                return
            }
            cell.quantity_lbl.text = "\(quantity)"
            removeProduct()
            updateTheCell(priceCell, quantityCell: cell)
        }
    }
    
    @objc func cell_moreAction (_ sender: UIButton) {
        
        view.endEditing(true)
        
        if detailsWithOfferPopup != nil {
            if detailsWithOfferPopup.isDescendant(of: self.view) {
                return
            }
            detailsWithOfferPopup = nil
        }
        
        detailsWithOfferPopup = GSProductDetailsWithOfferPopUpView()
        if let theStores = stores as? [[String:Any]] {
            detailsWithOfferPopup.initializeDataAndLoadUI(products_array: theStores, products_dic: selectedProducts_dictionary)
            detailsWithOfferPopup.showTheViewOn(self.view)
        }
    }
}

extension GSProductDetailsViewController:NavigationBarCartDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        GSCustomPushPop.doCustomPop(from: self)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        if let pushVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSCartViewController) as? GSCartViewController {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.selectedStoreCategory_id, value: catId ?? "")
            if let navigator = navigationController {
                navigator.pushViewController(pushVC, animated: true)
            }
        }
    }
}

extension GSProductDetailsViewController:UIScrollViewDelegate  {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if scrollView == productDesc_tableView {
            main_scrollView.setContentOffset(CGPoint(x: 0, y: main_scrollView.contentSize.height - main_scrollView.frame.size.height), animated: true)
        }
    }
    private func changeTheOffsetFor(_ scrollView:UIScrollView, isPositive:Bool) {
    }
}










