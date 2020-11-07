//
//  ViewController.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/9/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit
import SDWebImage

//import RxSwift
//import RxCocoa
//import EasyTipView

class GSProductsViewController: GSLoggedInBaseViewController ,UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UISearchBarDelegate, NavigationForProductsDelegate {
    
    //    let itemCollections = Observable.just(ShopItemsModel.someItems)
    
    lazy var itemCollections = NSMutableArray()
    lazy var searchCollections = NSMutableArray()
    //    let disposeBag = DisposeBag()
    
    lazy var customView = UIImageView()
    lazy var blurredView = UIView()
    lazy var startFrame = CGRect()
    lazy var startFrameBeforePinch = CGRect()
    
    lazy var isFromCategoryScreen = Bool()
    
    lazy var isReachedDest = Bool()
    lazy var isPanRunning = Bool()
    lazy var isPanAllowed = Bool()
    lazy var isNeedToRestrictPinch = Bool()
    lazy var isPinchGesture = Bool()
    
    let panGesture = UIPanGestureRecognizer()
    lazy var customLayer = UIView()
    lazy var pinchValue = Float()
    var indexPathForItem:IndexPath?
    lazy var scaleFactor = CGFloat()
    
    lazy var productListArray = [GSProductsList]()
    var searchedProductArray : [GSProductsList]?
    var templateArray : [GSProductDetailsKeyTemplate]?
    var toolTip_array = [GSProductDetailsKeyTemplate]()
    var storesArray : [String]?
    
    var categories : [String]?
    var searchedCategories : [String]?
    var categoryId : String?
    
    var isCollectionViewLoading = false
    
    var categorySearchView : GSCategorySearchView!
    var offerPopup_view: GSOfferPopupView!
    
    @IBOutlet var items_CollectionView: UICollectionView!
    @IBOutlet var productDescription_View: UIView!
    @IBOutlet var product_ImgView: UIImageView!
    @IBOutlet var productDescription_lbl: GSBaseLabel!
    @IBOutlet var bgProductDescription_view: UIView!
    @IBOutlet var navigationBar_view: NavigationForProducts!
    @IBOutlet weak var pageControl:DAPageControlView!
    
    @IBOutlet weak var menu_btn: GSBaseButton!
    @IBOutlet weak var lines_tableView: UITableView!
    
    var screenSize: CGRect = UIScreen.main.bounds
    let categoryDisplayBar = UILabel()

    var menuView: GNAMenuView!
    lazy var categoryMenuView = GSCategoryMenuView()

    var categoryDictionary = NSMutableDictionary()
    var categoryApiResponse_array = [String]()
    var categoryAllStr  = "All"
    var navigationTitle = ""
    var selectedSizeClass:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1.0 : 1.0
    
    var collectionLayout = JJStaggeredGridCollectionViewLayout()
    
    let showableProductsAPI_limit = 100
    var totalProuctsAvailableInStores = 0
    var selected_category:String?
    
    var frameTypes_array = [GSFrameTypeElement]()
    var selectedFrameType_id = 1
    var storeDeliveryTypesArray:[Int]!
    
    var savedDeviceOrientation: UIDeviceOrientation?
    
    var productHeightForiPhone:CGFloat = 75
    var productHeightForiPad:CGFloat = 100
    var isPathSearch = false
    
    var productGifView : GSProductListGifView!
    
    var offerProductsCount: Int?
        
// MARK: - ViewContrller Lifecycle
    func initVariables() {
        categories         = nil;
        searchedCategories = nil;
        categorySearchView = nil;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables();
        items_CollectionView.alwaysBounceVertical = false
        initialLoadSetUp()
        
        self.categoryDisplayBar.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: screenSize.width, height: 18))
        self.categoryDisplayBar.font = UIFont(name: "Roboto-Regular", size: 15)
        self.categoryDisplayBar.textAlignment = .left
        self.categoryDisplayBar.backgroundColor =  UIColor(red:0.94, green:0.94, blue:0.94, alpha:0.8) // GSConstant.categoryBarBGColor
        self.categoryDisplayBar.textColor = UIColor.black
        
        addProductGifViewIfThisIsFirstOpen()
        self.updateStoreViewAPI()
        self.getTotalCountOfProductsFromAPI(selectedCategory: nil, categoryChanged: true, isFirstTimeCheck: true)
        self.getAvailableFramesAssignedForProducts(isToOpenAfterCompletion: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        intializeRequiredNotifications()
        navigationBar_view.navigationBarReload()
        
        if let unwrappedSavedDeviceOrientation = savedDeviceOrientation {
            let currentDeviceOrientation = UIDevice.current.orientation
            
            if unwrappedSavedDeviceOrientation != currentDeviceOrientation || unwrappedSavedDeviceOrientation == .faceUp || unwrappedSavedDeviceOrientation == .faceDown {
                // If device oriention changes in any other view controller and come back to this view... need to refresh the layout
                DispatchQueue.main.async {
                    self.assignLayoutProperties()
                    self.reloadTheCollectionViewLayout()
                }
            }
        }
        // Added Category Display Label
        self.items_CollectionView.addSubview(categoryDisplayBar)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        methodForSomeIntializers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(true)
        doSomethingWhenTheAppGoesBackground()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self)
        
        savedDeviceOrientation = UIDevice.current.orientation
        SDImageCache.shared.clearMemory()
    }
    
    
    private func addProductGifViewIfThisIsFirstOpen() {
        
        let isProductAnimationShown = SharedPersistence.getValue(key: UserDefaultKeys.isProductAnimationShown) as? Bool ?? false
        
        if isProductAnimationShown == true { return }
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.isProductAnimationShown, value: true)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let topLength = appDelegate?.topSafeAreaInset ?? 0
        let bottomLength = appDelegate?.bottomSafeAreaInset ?? 0
        
        guard let theWindow = appDelegate?.window else { return }
        
        if productGifView != nil, productGifView.isDescendant(of: theWindow) { return }
        productGifView = GSProductListGifView()
        
        theWindow.addSubview(productGifView)
        
        productGifView.translatesAutoresizingMaskIntoConstraints = false
        productGifView.leftAnchor.constraint(equalTo: theWindow.leftAnchor).isActive = true
        productGifView.rightAnchor.constraint(equalTo: theWindow.rightAnchor).isActive = true
        productGifView.topAnchor.constraint(equalTo: theWindow.topAnchor, constant: topLength).isActive = true
        productGifView.bottomAnchor.constraint(equalTo: theWindow.bottomAnchor, constant: -bottomLength).isActive = true
        productGifView.updateGIF()
    }
    
    
    @IBAction func menu_action(_ sender: UIButton) {
        
        if categoryDictionary.count != 0 {
            categoryMenuView.intializeTheData(categoryDict: categoryDictionary)
        } else {
            categoryListAPI()
        }
        
        view.endEditing(true)
        
        categoryMenuView.delegate = self
        categoryMenuView.offerCount = offerProductsCount ?? 0
        categoryMenuView.updateOfferProductView()
        view.addSubview(categoryMenuView)
        categoryMenuView.showTheViewOn(view)
    }
    
    
    // MARK: - Search product / category
    func categoryListAPI()  {
        
        let urlString = APIurl.baseURL + APIurl.subURL.categoryList
        
        let params = ["_id" : (categoryId ?? "") as Any,
                      "stores" : storesArray as Any] as [String : Any]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSProductsCategoryRootModel.self, from: responseData)
                    weakSelf.categories = responseModel.data?.category
                    
                    if let indexOfCategory = weakSelf.categories?.firstIndex(where: { $0 == "Offer Products"}) {
                        weakSelf.categories?.remove(at: indexOfCategory)
                    }
                    
                    weakSelf.offerProductsCount = responseModel.data?.offerProductCount ?? 0
                    if let unwrappedCategories = weakSelf.categories {

                        weakSelf.categories = weakSelf.splitStringToArray(strArray:weakSelf.categories)
                        weakSelf.categoryApiResponse_array = unwrappedCategories
                        weakSelf.searchedCategories = weakSelf.categories
                        weakSelf.parseSubcategories(categoryStringArray: unwrappedCategories)
                    }
                    print("self.categories : ", weakSelf.categories ?? "")
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
    
    fileprivate func updateStoreViewAPI()  {
        
        let isPrivateShop = SharedPersistence.getValue(key: UserDefaultKeys.Products.isPrivateShop) as? Bool ?? false
//        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
        
//        if isPrivateShop == false || isGuestLogin == true { return }
//        if isGuestLogin == true { return }

        let urlString = APIurl.baseURL + APIurl.subURL.updateStoreView
        
        guard let store_array = storesArray, store_array.count > 0 else { return }
        
        let params = ["_id" : (categoryId ?? "") as Any,
                      "stores" : store_array,
                      "is_private" : isPrivateShop] as [String : Any]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: urlString, withLoader:true) { (response, error) in
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    print(responseModel.message ?? "")
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }
    
    func reloadCategoryTable() {
        
        if categories == nil {
            return
        }
        categorySearchView.categories = categories //splitStringToArray(strArray: categories!)
        categorySearchView.categories?.insert(categoryAllStr, at: 0)
        self.searchedCategories       = categorySearchView.categories
        categorySearchView.categoryTable.reloadData()
    }
    
    func splitStringToArray(strArray: [String]?) -> [String] {
        
        var tempStringArray = [String]()
        for categoryString in strArray! {
            
            if categoryString.count == 0 {
                continue
            }
            var tempCategoryString: String = categoryString
            if tempCategoryString.prefix(1) == "/" {
                tempCategoryString = tempCategoryString.components(separatedBy: "/").dropFirst().first!
            }
            tempStringArray.append(tempCategoryString.components(separatedBy: "/").first!)
            tempStringArray.removeDuplicates()
        }
        return tempStringArray
    }
    
    func addSearchedProductsView() {
        
        if categorySearchView == nil {
            
            categorySearchView = GSCategorySearchView()
            categorySearchView.delegate = self
            categorySearchView.layer.cornerRadius = 10
            categorySearchView.layer.masksToBounds = false
            categorySearchView.clipsToBounds = true
        }
        navigationBar_view.navigSearchBar.text = ""
        categorySearchView.searchedProductsArr?.removeAll()
        categoryViewResize(keyboardHeight:0)
        reloadCategoryTable()
    }
    
    func categoryViewResize(keyboardHeight: CGFloat) {
        
        if categorySearchView != nil {
            categorySearchView.showTheViewFromBottom(on: view, for: CGRect(x: 30, y: navigationBar_view.frame.origin.y + navigationBar_view.frame.height - 5, width: view.frame.size.width - 60, height: view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - navigationBar_view.frame.height - keyboardHeight), completionHandler: {})
        }
    }
    // MARK: - Category and Subcategories
    func parseSubcategories(categoryStringArray: [String]) {
        categoryDictionary.removeAllObjects()
        for categoryString in categoryStringArray {
            
            if categoryString.count == 0 {
                continue
            }
            var stringArray = categoryString.components(separatedBy: "/")
            if stringArray[0] == "" {
                stringArray.removeFirst()
            }
            categoryDictionary = categoryRecursion(parentCategoryDic: categoryDictionary, categoryDic: categoryDictionary, stringArray: stringArray)
        }
        categoryMenuView.intializeTheData(categoryDict: categoryDictionary)
        
        return
    }

    func categoryRecursion(parentCategoryDic: NSMutableDictionary, categoryDic: NSMutableDictionary, stringArray: [String]) -> NSMutableDictionary  {
        
        if stringArray.count == 0 {
            return parentCategoryDic
        }
        var categoryDictionary = parentCategoryDic
        var tempStringArray = stringArray
        if categoryDic.value(forKey: tempStringArray[0]) != nil {
            let subCategoryDic = categoryDic.value(forKey: tempStringArray[0]) as! NSMutableDictionary
            tempStringArray.removeFirst()
            categoryDictionary = categoryRecursion(parentCategoryDic: parentCategoryDic, categoryDic: subCategoryDic, stringArray: tempStringArray)
        } else {
            let subCategoryDic = NSMutableDictionary()
            categoryDic.setValue(subCategoryDic, forKey: tempStringArray[0])
            tempStringArray.removeFirst()
            categoryDictionary = categoryRecursion(parentCategoryDic: parentCategoryDic,categoryDic: subCategoryDic, stringArray: tempStringArray)
        }
        return categoryDictionary
    }
    
    // MARK: - Keyboard delegate methods
    @objc func keyBoardWillShow(notification:NSNotification) -> Void {
        
        let info = notification.userInfo
        let keyboardSize = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        // Resize the category view based upon the keyboard height
        categoryViewResize(keyboardHeight:keyboardSize.height)
    }
    
    @objc func keyBoardWillHide(notification:NSNotification) -> Void {
        
        categoryViewResize(keyboardHeight:0)
        navigationBar_view.navigSearchBar.text = ""
        if categorySearchView != nil {
            if categorySearchView.isDescendant(of: view) {
                categorySearchView.removeFromSuperview()
            }
        }
    }

// MARK: - User defined methods (Data)
//    private func getProductData () -> Void {
//
//        if self.searchCollections.count > 0 {
//
//            self.searchCollections.removeAllObjects()
//        }
//
//        let dataDictionary = self.dataFromPlist("Products")
//        let tempArr =  dataDictionary.value(forKey: "result") as! [Any]
//        let p = Product ()
//        self.searchCollections = p.initWithProducts(tempArr)
//        DispatchQueue.main.sync {
//            self.reloadTheCollectionViewLayout()
//        }
//        self.itemCollections = self.searchCollections
//        addGesturesForCollectionView()
//    }
    
// MARK: - Initial setup
    private func initialLoadSetUp() -> Void {
        
        initializeCollectionViewFlowLayout()
        
        navigationBar_view.delegate = self
        navigationBar_view.titleLable.text = navigationTitle
        navigationBar_view.navigSearchBar.delegate = self
        
        isReachedDest = false
        bgProductDescription_view.isHidden = true
        items_CollectionView.delegate = self
        items_CollectionView.dataSource = self
        
        addGesturesForCollectionView()
    }
    
    private func initializeCollectionViewFlowLayout() {
        
        collectionLayout = items_CollectionView.collectionViewLayout as! JJStaggeredGridCollectionViewLayout
        lines_tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)

        collectionLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)

        assignLayoutProperties()
    }
    
    func assignLayoutProperties() {
        
        if selectedSizeClass == 0 {
            collectionLayout.numColumns = 1
            lines_tableView.reloadData()
            return
        }
        
        let reqHeightForFrame = cellHeightForCollectionView()
        
        let numOfRows = Int(self.items_CollectionView.frame.height / (reqHeightForFrame + 10 ))                // -1 is to prevent the layout issues...
        
        collectionLayout.numColumns = max(numOfRows, 1)
        
        lines_tableView.reloadData()
    }
    
    private func intializeRequiredNotifications() -> Void {
        
        NotificationCenter.default.addObserver(self, selector: #selector(doSomethingWhenTheAppGoesBackground), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(doSomethingWhenTheAppGoesBackground), name: .UIApplicationDidBecomeActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
// MARK: - User defined methods (View)
    func methodForSomeIntializers() {
        
        productDescription_View.addShadowEffectWith(color: UIColor.black, opacity: 0.5, shadowRadius: 3, shadowOffset: CGSize(width: -1, height: -1))
//        productDescription_lbl.addShadowEffectWith(color: UIColor.black, opacity: 0.5, shadowRadius: 3, shadowOffset: CGSize(width: 0, height: 1))
        productDescription_lbl.backgroundColor = UIColor.white
        productDescription_lbl.textColor = UIColor.darkGray
    }
    
    func addGesturesForCollectionView() {
        
        let longPressGest = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressGestureAction))
        longPressGest.delegate = self
        longPressGest.minimumPressDuration = 0.2
        
        items_CollectionView.addGestureRecognizer(longPressGest)
        
        panGesture.addTarget(self, action: #selector(panGestureAction))
        panGesture.delaysTouchesBegan = true
        panGesture.delegate = self
        items_CollectionView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(pinchGestureAction))
        pinchGesture.delegate = self
        items_CollectionView.addGestureRecognizer(pinchGesture)
        
        addGestureToProductView()
    }
    
    private func addGestureToProductView () -> Void {
        
        let pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(pinchGestureAction))
        pinchGesture.delegate = self
        productDescription_View.addGestureRecognizer(pinchGesture)
        
        let somePanGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureAction))
        somePanGesture.delaysTouchesBegan = true
        somePanGesture.delegate = self
        productDescription_View.addGestureRecognizer(somePanGesture)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureAction(_:)))
        tapGesture.delegate = self
        bgProductDescription_view.addGestureRecognizer(tapGesture)
    }
    
    func removeBlurredView() {
        if (blurredView.isDescendant(of: self.view)) {
            blurredView.removeFromSuperview()
        }
    }
    
    func removePopUpView(animated:Bool) {
        
        guard let thePopUp = menuView else {return}
        guard thePopUp.isDescendant(of: self.view) else { return }
        
        switch animated {
        case true:
            UIView.animate(withDuration: 0.25, animations: {
                thePopUp.alpha = 0
            }) { _ in
                thePopUp.dismissMenuView()
                thePopUp.alpha = 1.0
            }
            break
        case false:
            thePopUp.dismissMenuView()
            break
        }
    }
    
    func constructCustomViewForPinchOff() {
        
        customView.backgroundColor = UIColor.clear
        customView.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint.init(item: customView, attribute: .leading, relatedBy: .equal, toItem: productDescription_View, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: customView, attribute: .trailing, relatedBy: .equal, toItem: productDescription_View, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint.init(item: customView, attribute: .top, relatedBy: .equal, toItem: productDescription_View, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint.init(item: customView, attribute: .bottom, relatedBy: .equal, toItem: productDescription_View, attribute: .bottom, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([leading,trailing,top,bottom])
    }
    
    func constructFrameForIndex(indexPath:IndexPath?)->CGRect {
        
        guard let unwrappedIndexPath = indexPath else { return CGRect.zero }
        
        // Issue here...
        
        let numberOfItemsInSection = items_CollectionView.numberOfItems(inSection: unwrappedIndexPath.section)
        if unwrappedIndexPath.row >= numberOfItemsInSection {
            return CGRect.zero
        }
        
        let attributes = items_CollectionView.layoutAttributesForItem(at: unwrappedIndexPath as IndexPath)
        guard let sizeRect = attributes?.frame else { return CGRect.zero }
        
        let tempView = UIView.init(frame: CGRect(x: 0, y: 0, width: sizeRect.size.width + 20.0, height: sizeRect.size.height + 20.0))
        
        tempView.center = CGPoint(x: (attributes?.center.x)! + items_CollectionView.frame.origin.x - items_CollectionView.contentOffset.x , y: (attributes?.center.y)! + items_CollectionView.frame.origin.y - items_CollectionView.contentOffset.y)
        
        return tempView.frame
    }
    
     func reloadTheCollectionViewLayout() {
        
        if isCollectionViewLoading {
            return
        }
        
        isCollectionViewLoading = true
//        assignLayoutProperties()
        items_CollectionView.reloadData()
        self.items_CollectionView.performBatchUpdates({
        }, completion: { [weak self] _ in
            self?.configurePageControlForProducts()
            self?.isCollectionViewLoading = false
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if self.isVisible == false { return }
        
        if customView.isDescendant(of: self.view) {
            
            if !isNeedToRestrictPinch {
                if isPinchGesture {     // Pinch is running
                    
                    customView.removeFromSuperview()
                    bgProductDescription_view.isHidden = true
                    isPinchGesture = false
                    isReachedDest = false
                    isPanRunning = false
                    isPanAllowed = false
                    isNeedToRestrictPinch = false
                    
                } else {
                    self.customView.frame = self.productDescription_View.frame
                    customView.layoutIfNeeded()
                    self.customView.layer.setValue(scaleFactor, forKeyPath: "transform.scale.x")
                }
            } else {
                customView.removeFromSuperview()
                removeBlurredView()
                removePopUpView(animated: true)
                self.isReachedDest = false
                self.isPanRunning = false
                self.isPanAllowed = false
                self.isNeedToRestrictPinch = false
            }
        }
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
        }) { (UIViewControllerTransitionCoordinatorContext) -> Void in
            DispatchQueue.main.async {
                self.assignLayoutProperties()
                self.reloadTheCollectionViewLayout()
            }
        }
    }
}

extension Array where Element: Hashable {
    
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

//    weak var tipView : EasyTipView?
//    func setUpForTipToolView() {
//        navigationBar_view.navigSearchBar.resignFirstResponder()
//
//        if tipView != nil {
//            return
//        }
//
//        var preferences = EasyTipView.Preferences()
//        preferences.drawing.backgroundColor = UIColor.init(red: 12/255.0, green: 117/255.0, blue: 18/255.0, alpha: 1.0)
//
//        preferences.animating.dismissTransform = CGAffineTransform(translationX: 0, y: -15)
//        preferences.animating.showInitialTransform = CGAffineTransform(translationX: 0, y: -15)
//        preferences.animating.showInitialAlpha = 0
//        preferences.animating.showDuration = 1.0
//        preferences.animating.dismissDuration = 1.0
//        preferences.drawing.arrowPosition = .bottom
//
//        let tempTipView = EasyTipView(text: "Apple\n50 rupees/1kg\n5 pieces approximately", preferences: preferences)
//        tempTipView.show(forView: customView, withinSuperview: self.view)
//        tipView = tempTipView
//    }
