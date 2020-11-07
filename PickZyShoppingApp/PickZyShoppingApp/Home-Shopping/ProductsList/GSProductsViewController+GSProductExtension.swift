//
//  GSProductsViewController+UIViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh Mac Mini on 05/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation
import SDWebImage

// MARK: - Collection View Methods

extension GSProductsViewController {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return productListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = GSString.CellIdentifier.ProductVC_Item_CollectionCell
        guard let cell = items_CollectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? GSItemsCollectionCell else {
            return UICollectionViewCell()
        }
        let item = productListArray[indexPath.row]

        // Category Display Name - Ratheesh
        if categoryDisplayBar.text == nil {
            var categoryStr = item.productInfo?.category
            categoryStr = String(categoryStr?.dropFirst() ?? "")
            let categoryDispName = categoryStr?.replacingOccurrences(of: "/", with: " ❯ ")
            categoryDisplayBar.text = categoryDispName
        }

        cell.configureTheCell(items: item, selectedSizeClass:selectedSizeClass)
        if indexPath.row == productListArray.count - 1 {

            if productListArray.count < totalProuctsAvailableInStores {
                getCategoryProductsAPI(selectedCategory: selected_category, categoryChanged: false)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let productDetailVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSProductDetailsViewController) as? GSProductDetailsViewController {
            productDetailVC.catId = categoryId
            productDetailVC.storesArray = storesArray
            productDetailVC.selectedProductItem = productListArray[indexPath.row]
            productDetailVC.productId = productListArray[indexPath.row]._id
            productDetailVC.templateArray = templateArray
            productDetailVC.productListArray = productListArray
            productDetailVC.selectedProductIndex = indexPath.row
            GSCustomPushPop.doCustomPush(from: self, to: productDetailVC)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if selectedSizeClass == 0 {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height - 20)
        }
        let cellHeight = cellHeightForCollectionView ()
        let item       = productListArray[indexPath.row]
        
        if let image_array = item.productInfo?.images {
            
            if image_array.count > 0 {
                let imageWidth = image_array[0].width ?? 0
                let imageHeight = image_array[0].height ?? 0
                let calculatedWidth = widthForTheImage(width : CGFloat(imageWidth), height: CGFloat(imageHeight), basedOn: cellHeight)
                
                return CGSize(width: calculatedWidth, height: cellHeight + 15 )
            }
        }
        return CGSize(width: cellHeight, height: cellHeight + 15 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
    }
    
    // MARK: - CollectionView user defined
    func cellHeightForCollectionView () -> CGFloat {
        
        var productHeight:CGFloat = productHeightForiPad * selectedSizeClass
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            productHeight = productHeightForiPhone * selectedSizeClass
        }
        
        let numOfRows = Int(self.items_CollectionView.frame.height / (productHeight + 10 ))
        
        let remainingSpace = self.items_CollectionView.frame.height - (CGFloat(numOfRows) * (productHeight + 10 ))
        
        let labelHeight:CGFloat = 15
        
//        if remainingSpace > (CGFloat(numOfRows) * 10) {
        
            let devidedForEach = (remainingSpace / CGFloat(numOfRows)) - labelHeight
        
        if devidedForEach > 0 {
        
            productHeight += devidedForEach
        }
//        }
        return productHeight
    }
    
    func widthForTheImage(width : CGFloat, height: CGFloat, basedOn cellheight:CGFloat) -> CGFloat {
        
        let aspectRatioOfImage = width / height
        let calculatedWidth = aspectRatioOfImage * cellheight
        
        return calculatedWidth
    }
    
    // MARK: - Gesture Delegate Methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if !((touch.view?.isDescendant(of: navigationBar_view.navigSearchBar))!) {
            view.endEditing(true)
        }
        
//        if self.isEditing && gestureRecognizer == self.panGesture {
//            return false
//        }
        
        return true
    }
    
// MARK: - Search Bar delegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Request the server to load the category data
        addSearchedProductsView();
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchedCategories == nil {
            return
        }
        
        if searchText.count > 0 {
            
            if (searchedCategories?.count)! > 0 {
                searchedCategories?.removeAll()
            }
            
            let filteredStrings = categories?.filter({(item: String) -> Bool in
                let stringMatch = item.lowercased().range(of: searchText.lowercased())
                return stringMatch != nil ? true : false
            })
            
            searchedCategories = filteredStrings
            categorySearchView.categories = searchedCategories
            categorySearchView.categoryTable.reloadData()
            
            #if DEBUG
                print(categorySearchView.categories ?? [0] as Any)
            #endif
            
            getSearchedProductsAPI()
        } else {
            searchedProductArray?.removeAll()
            categorySearchView.searchedProductsArr?.removeAll()
            reloadCategoryTable()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        categorySearchView.removeFromSuperview()
        items_CollectionView.reloadData()
    }
    
    //MARK: - All The Gesture Methods
    func doSomeThingsAfterPanCompletion() {
        
        if customView.isDescendant(of: view) {
            customView.removeFromSuperview()
        }
        isReachedDest = false
        isPanRunning  = false
        isPanAllowed  = false
        isNeedToRestrictPinch = false
    }
    
    @objc func doSomethingWhenTheAppGoesBackground() {
        
        doSomeThingsAfterPanCompletion()    // Almost all are same
        isNeedToRestrictPinch = false
        isPinchGesture = false
        removeBlurredView()
        removePopUpView(animated: false)
    }
    
    // MARK: Gesture Action methods
    @objc func tapGestureAction (_ gestureRecognizer : UIPanGestureRecognizer) {
        if gestureRecognizer.view != productDescription_View {
            bgProductDescription_view.isHidden = true
            
            UIView.animate(withDuration: 0.2, animations: { [weak weakSelf = self] in
                weakSelf?.customView.frame = weakSelf?.constructFrameForIndex(indexPath: weakSelf?.indexPathForItem) ?? CGRect.zero
                }, completion:{  [weak weakSelf = self] _ in
                    (weakSelf?.customView.isDescendant(of: (weakSelf?.view)!))! ? weakSelf?.customView.removeFromSuperview() : print("")
                    weakSelf?.isPinchGesture = false
                    weakSelf?.isReachedDest = false
                    weakSelf?.isPanRunning = false
                    weakSelf?.isPanAllowed = false})
            items_CollectionView.isScrollEnabled = true
            
        }
    }
    
    @objc func panGestureAction (_ gestureRecognizer : UIPanGestureRecognizer) {
        
        if !isPanAllowed || !customView.isDescendant(of: self.view) {
            items_CollectionView.isScrollEnabled = true
            return
        }
        
        let translation = gestureRecognizer.translation(in: self.view)
        items_CollectionView.isScrollEnabled = false
        
        if gestureRecognizer.state == .began  {
            
            //removePopUpView()
            startFrame = customView.frame
        } else if gestureRecognizer.state == .changed {
            
            checkWhetherProductMovedToCartFrame()
            
            customView.center = CGPoint(x: customView.center.x + translation.x, y: customView.center.y + translation.y)
            
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            
            guard menuView != nil else {return}
            menuView.center = CGPoint(x: menuView.center.x + translation.x, y: menuView.center.y + translation.y)
            menuView.refreshTheViews(CGPoint(x: customView.center.x, y: customView.center.y))
            
        } else if gestureRecognizer.state == .ended {
            caseMethodForPanCompletionWith(gestureRecognizer)
        }
    }
    
    private func caseMethodForPanCompletionWith(_ gestureRecognizer:UIPanGestureRecognizer) {
        
        if isPinchGesture {
            return              // We should not add it to cart or reverse animation
        }
        if indexPathForItem == nil || !customView.isDescendant(of: self.view) {
            errorExceptionMethodForGestures()
            return
        }
        
        let velocity = gestureRecognizer.velocity(in: self.view)
        
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let slideMultiplier = magnitude / 200
        
        #if DEBUG
            print("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
        #endif
        
        let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
        
        var finalPoint = CGPoint(x:customView.center.x + (velocity.x * slideFactor),
                                 y:customView.center.y + (velocity.y * slideFactor))
        finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
        finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: { [weak self] in
                        self?.removeBlurredView()
                        self?.removePopUpView(animated: false)
                        self?.customView.center = finalPoint
                        self?.checkWhetherProductMovedToCartFrame()
            },
                       completion: { [weak self] _ in
                        
                        self?.panCompletionMethod()
        })
        items_CollectionView.isScrollEnabled = true
    }
    
    func panCompletionMethod() {
        
        if self.isReachedDest {
            UIView.animate(withDuration: 0.2, animations: { [weak weakSelf = self] in
                let yDestPoint = (weakSelf?.navigationBar_view.rightBarBtn.center.y)! + (weakSelf?.navigationBar_view.frame.origin.y)!
                weakSelf?.customView.frame = CGRect(x: (weakSelf?.navigationBar_view.rightBarBtn.center.x)! - 5, y: yDestPoint - 5, width: 10.0, height: 10.0)
                
                #if DEBUG
                    print(self.indexPathForItem ?? "")
                #endif
                
                if let unwrappedIndexPathForItem = weakSelf?.indexPathForItem {
                    self._checkAvailabilityOfStockAndAddItToCart(index: unwrappedIndexPathForItem.row)
                }

                weakSelf?.removePopUpView(animated: false)
                weakSelf?.removeBlurredView()
                }, completion:{  [weak weakSelf = self] _ in
                    if weakSelf?.isFromCategoryScreen == true {
                        GSCustomPushPop.doCustomPop(from: self)
                        return
                    }
                    weakSelf?.doSomeThingsAfterPanCompletion()})
        } else {
            UIView.animate(withDuration: 0.2, animations: { [weak weakSelf = self] in
                weakSelf?.customView.frame = weakSelf?.constructFrameForIndex(indexPath: weakSelf?.indexPathForItem) ?? CGRect.zero
                weakSelf?.removePopUpView(animated: false)
                weakSelf?.removeBlurredView()
                }, completion:{  [weak weakSelf = self] _ in
                    weakSelf?.doSomeThingsAfterPanCompletion()
            })
        }
    }

    private func getTheStoreFromCartListFor(store_id: String, from cartItem:GSCartListNewData) -> GSCartListNewStore? {
        
        guard let cartStoreArray = cartItem.stores else { return nil }
        
        for cartStore in cartStoreArray {
            let cartStore_id = cartStore.storeID ?? ""
            if store_id == cartStore_id {
                return cartStore
            }
        }
        return nil
    }
    
    func selectMatchingStore(_storeCartArray : [GSCartListNewStore], productStoreId : String) -> GSCartListNewStore? {
        
        for storeCart in _storeCartArray {
            
            if storeCart.storeID == productStoreId {
                return storeCart
            }
        }
        return nil
    }
    
    func _checkAvailabilityOfStockAndAddItToCart(index : Int)    {
        
        let productAtIndex = productListArray[index]
        let product_id = productAtIndex._id ?? ""
        var totalCart : Int = 0
        var storeQty : Int = 0
        var isQtyReached : Bool = true

        if let productCartItem = cartItemsDictionary[product_id] {
            
            guard let cartStoreItems = productCartItem.stores else { return }

            guard let productStoresArray = productAtIndex.stores else { return }
            
            for productIndex in 0..<productStoresArray.count {
                
                isQtyReached = true
                if productIndex < cartStoreItems.count {
                    
                    let product_store = productStoresArray[productIndex]

                    let storeCartArray = selectMatchingStore(_storeCartArray: cartStoreItems, productStoreId: product_store.store_id ?? "")
                    if storeCartArray == nil {
                        continue
                    }

                    let _cartQty : Int = (storeCartArray?.productDetails?.qty ?? 0) + totalCart

                    let productStock : Int = (product_store.product_details?.stock) ?? 0
                    
                    if productStock >= _cartQty {
                        storeQty = productStock - _cartQty
                    } else {
                        storeQty = 0
                        totalCart = _cartQty - productStock
                    }

                    if storeQty != 0 {
                        isQtyReached = false
                        addProductToCartAPI(index: index, storeIndex: productIndex)
                        break
                    }
                } else {
                    isQtyReached = false
                    addProductToCartAPI(index: index, storeIndex: productIndex)
                    break
                }
            }
        } else {
            isQtyReached = false
            addProductToCartAPI(index: index, storeIndex: 0)
        }
        if isQtyReached == true {
           CustomAlert.showAlert(title: GSString.AppName, message: "You have reached the maximum stocks available currently", viewController: self)
        }
    }
    
    private func checkWhetherProductMovedToCartFrame() {
        isPanRunning = true
        
        let draggingViewX = customView.frame.origin.x + customView.frame.size.width
        let draggingViewY = customView.frame.origin.y
        
        isReachedDest = false
        if (draggingViewY <= navigationBar_view.frame.origin.y + navigationBar_view.rightBarBtn.frame.size.height && draggingViewX >= navigationBar_view.rightBarBtn.frame.origin.x)  {
            isReachedDest = true
        }
    }
    @objc func longPressGestureAction(_ gestureRecognizer : UILongPressGestureRecognizer) {
        
        if isPanRunning || isPinchGesture {
            
            if isPinchGesture {
                errorExceptionMethodForGestures()   // Temporary fix for UI hang
            }
            return
        }
        
        if gestureRecognizer.state == .began {
            
            let point = gestureRecognizer.location(in: items_CollectionView)
            
            guard let indexPathToCheck = items_CollectionView.indexPathForItem(at: point) else {
                return
            }
            if customView.isDescendant(of: self.view) {
                customView.removeFromSuperview()
            }
            isPanAllowed = true
            isNeedToRestrictPinch = true
            
            #if DEBUG
            print("IndexPath : \(indexPathToCheck)")
            #endif
            
            addBlurredViewOnLongPressToShowTipTool()
            addCustomViewAt(point)
            //setUpForTipToolView()
            
            #if DEBUG
            print("productListArray[indexPathToCheck.row] = ", productListArray[indexPathToCheck.row])
            #endif
            
            if selectedSizeClass != GSProductFrameType.Values.fullScreen_iPhone && selectedSizeClass != GSProductFrameType.Values.fullScreen_iPad {
                createMenuItem((customView.image != nil) ? customView.image! : #imageLiteral(resourceName: "Pickzy_logo"), productDetails: productListArray[indexPathToCheck.row])
            }
            
            //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        } else if gestureRecognizer.state == .ended {
            
            isPanAllowed = false
            isNeedToRestrictPinch = false
            removeBlurredView()
            removePopUpView(animated: true)
            
            if customView.isDescendant(of: view) {
                customView.removeFromSuperview()
            }
            items_CollectionView.isScrollEnabled = true
        }
    }
    
   @objc func pinchGestureAction(_ pinchGesture:UIPinchGestureRecognizer) {
        
//        if isNeedToRestrictPinch {
//            return
//        }
    
        if pinchGesture.state == .began || pinchGesture.state == .changed {
            
            if !customView.isDescendant(of: self.view) {
                
                let point = pinchGesture.location(in: items_CollectionView)
                guard let indexPathToCheck = items_CollectionView.indexPathForItem(at: point) else {
                    return
                }
                
                #if DEBUG
                    print("IndexPath : \(indexPathToCheck)")
                #endif
                
                addCustomViewAt(point)
                customView.backgroundColor = UIColor.white
            }
            
            isPanAllowed = true
            isPinchGesture = true
            items_CollectionView.isScrollEnabled = false
            
            if Float(pinchGesture.scale) < 1.0 {
                
                self.bgProductDescription_view.isHidden = true
                self.customView.backgroundColor = UIColor.white
                
                // Issue here....
                
                if indexPathForItem?.row == nil || ((indexPathForItem?.row ?? 0) >= productListArray.count) {
                    errorExceptionMethodForGestures()
                    return
                }
                
                let itemAtIndexPath = self.productListArray[(self.indexPathForItem?.row)!]
                
                guard let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String else {
                    
                    #if DEBUG
                        print("Unique Id is nil...")
                    #endif
                    return
                }
                SDWebImageDownloader.shared().setValue(accessToken, forHTTPHeaderField: "Authorization")
                let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
                customView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewProductImage + (itemAtIndexPath.productInfo?.images![0].name)!+imgHeight) , placeholderImage: nil, completed: nil)
            }
            
            let currentScale: CGFloat = customView.layer.value(forKeyPath: "transform.scale.x") as! CGFloat
            
            let minScale: CGFloat = 1.0
            //            let maxScale: CGFloat = 3.0//scaleFactor
            let maxScale: CGFloat = scaleFactor
            let zoomSpeed: CGFloat = 1.0
            
            var deltaScale = pinchGesture.scale
            
            deltaScale = ((deltaScale - 1) * zoomSpeed) + 1
            deltaScale = min(deltaScale, maxScale / currentScale)
            deltaScale = max(deltaScale, minScale / currentScale)
            let zoomTransform = (customView.transform).scaledBy(x: deltaScale, y: deltaScale)
            customView.transform = zoomTransform
            
            if Float(pinchGesture.scale) != 1.0 {
                pinchValue = Float(pinchGesture.scale)
            }
            
            if pinchValue.isNaN {
                pinchValue = Float(0)
            }
            
            pinchGesture.scale = 1
        } else /*if pinchGesture.state == .ended*/ {
            
            isPanAllowed = false
            
            if indexPathForItem == nil || !customView.isDescendant(of: self.view) {
                errorExceptionMethodForGestures()
                return
            }
            
            checkWhetherProductMovedToCartFrame()
            var collectionViewCellHeight = cellHeightForCollectionView()
            let excusableValue:CGFloat = 60
            collectionViewCellHeight += excusableValue
            
            if isReachedDest, customView.frame.size.height <= collectionViewCellHeight {
                panCompletionMethod()
                isPinchGesture = false
                isReachedDest = false
                isPanRunning = false
                isPanAllowed = false
                items_CollectionView.isScrollEnabled = true
                return
            }
            
            if pinchValue > 1.0 {
                
                UIView.animate(withDuration: 0.2, animations: { [weak weakSelf = self] in
                    weakSelf?.customView.layer.setValue(weakSelf?.scaleFactor, forKeyPath: "transform.scale.x")
                    weakSelf?.customView.layer.setValue(weakSelf?.scaleFactor, forKeyPath: "transform.scale.y")
                    weakSelf?.customView.frame = (weakSelf?.productDescription_View.frame) ?? CGRect.zero
                    
                    }, completion:{ [weak weakSelf = self] _ in
                        
                        UIView.transition(with: (weakSelf?.customView)!, duration: 0.01, options: .transitionCrossDissolve, animations: {
                            weakSelf?.customView.image = nil
                            weakSelf?.customView.backgroundColor = UIColor.clear
                            weakSelf?.bgProductDescription_view.isHidden = false
                            
                            // Issue here...
                            
                            if weakSelf?.indexPathForItem?.row == nil || ((weakSelf?.indexPathForItem?.row ?? 0) >= (weakSelf?.productListArray.count ?? 0)) {
                                weakSelf?.errorExceptionMethodForGestures()
                                return
                            }
                            
                            let itemAtIndexPath = weakSelf?.productListArray[(weakSelf?.indexPathForItem?.row)!]
                            
                            var price = ""
                            if let unwrappedPrice = itemAtIndexPath?.stores?[0].product_details?.selling_price {
                                price = "\(unwrappedPrice)"
                            }
                            guard let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String else {
                                #if DEBUG
                                    print("Unique Id is nil...")
                                #endif
                                return
                            }
                            SDWebImageDownloader.shared().setValue(accessToken, forHTTPHeaderField: "Authorization")
                            weakSelf?.product_ImgView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewProductImage + (itemAtIndexPath?.productInfo?.images?.first?.name ?? "")) , placeholderImage: #imageLiteral(resourceName: "Pickzy_logo"), completed: nil)
                            weakSelf?.productDescription_lbl.text = "\(itemAtIndexPath?.productInfo?.product_name ?? "")\nPrice:\(price)"
                        }, completion: nil)
                })
            } else {

                let finalFrame = constructFrameForIndex(indexPath: indexPathForItem)
                
                UIView.animate(withDuration: 0.2, animations: { [weak weakSelf = self] in
                        weakSelf?.customView.frame = finalFrame
                    }, completion:{  [weak weakSelf = self] _ in
                        
                        guard weakSelf != nil else { return }
                        weakSelf?.customView.layer.setValue(1, forKeyPath: "transform.scale.x")
                        weakSelf?.customView.layer.setValue(1, forKeyPath: "transform.scale.y")
                        if weakSelf!.customView.isDescendant(of: weakSelf!.view) {
                            weakSelf?.customView.removeFromSuperview()
                        }
                        weakSelf?.isPinchGesture = false
                        weakSelf?.isReachedDest = false
                        weakSelf?.isPanRunning = false
                        weakSelf?.isPanAllowed = false})
                items_CollectionView.isScrollEnabled = true
            }
        }
    }
    
    private func errorExceptionMethodForGestures() {
        if customView.isDescendant(of: view) {
            customView.removeFromSuperview()
        }
        if blurredView.isDescendant(of: view) {
            blurredView.removeFromSuperview()
        }
        
        if menuView != nil, menuView.isDescendant(of: view) {
            menuView.removeFromSuperview()
        }
        isPinchGesture = false
        isReachedDest = false
        isPanRunning = false
        isPanAllowed = false
        isNeedToRestrictPinch = false
        items_CollectionView.isScrollEnabled = true
    }
    
    func addCustomViewAt(_ point:CGPoint) {
        
        navigationBar_view.navigSearchBar.resignFirstResponder()
        
        let indexPath = items_CollectionView.indexPathForItem(at: point)
        
        if customView.isDescendant(of: self.view) || indexPath == nil {
            #if DEBUG
                print("Nil Indexpath or already view available>>>>>>> Returned")
            #endif
            return
        }
        
        indexPathForItem = indexPath! as IndexPath
        customView = UIImageView.init(frame:constructFrameForIndex(indexPath: indexPath))
        customView.contentMode = .scaleAspectFit
        
        guard let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String else {
            #if DEBUG
                print("Unique Id is nil...")
            #endif
            return
        }
        SDWebImageDownloader.shared().setValue(accessToken, forHTTPHeaderField: "Authorization")
        let itemAtIndexPath = productListArray[(indexPath?.row)!]
        let imgHeight : String = "&height=" + GSConstant.tumbnailImgHeight
        
        var imageName = ""
        if let image_array = itemAtIndexPath.productInfo?.images {
            if image_array.count > 0 {
                imageName = image_array[0].name ?? ""
            }
        }
        
        customView.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewProductImage + imageName + imgHeight) , placeholderImage: #imageLiteral(resourceName: "Pickzy_logo"), completed: nil)
        customView.backgroundColor = UIColor.clear
        
        let customLayerScaleFactor = (customView.frame.size.width)
        let descLayerScaleFactor = (productDescription_View.frame.size.width)
        
        scaleFactor = descLayerScaleFactor/customLayerScaleFactor
        
        startFrame = customView.frame
        startFrameBeforePinch = customView.frame
        self.view.addSubview(customView)
    }
    
    func addBlurredViewOnLongPressToShowTipTool() {
        
        if blurredView.isDescendant(of: self.view) {
            return
        }
        navigationBar_view.navigSearchBar.resignFirstResponder()
        blurredView = UIView()
        blurredView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(blurredView)
        
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint.init(item: blurredView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: blurredView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint.init(item: blurredView, attribute: .top, relatedBy: .equal, toItem: navigationBar_view, attribute: .bottom, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint.init(item: blurredView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([leading,trailing,top,bottom])
    }
    
    // MARK: - NavigationBar Methods
    func leftBarBtnPressed(sender: UIButton) {
        
        view.endEditing(true)
        
        if isFromCategoryScreen {
            
            //dismiss(animated: true, completion: nil)
            GSCustomPushPop.doCustomPop(from: self)
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    func categoryMenuAction() {
        
//        if categoryDictionary.count != 0 {
//            categoryMenuView.intializeTheData(categoryDict: categoryDictionary)
//        } else {
//            categoryListAPI()
//        }
//
//        view.endEditing(true)
//
//        categoryMenuView.delegate = self
//        view.addSubview(categoryMenuView)
//        categoryMenuView.showTheViewOn(view)
        
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        guard let theWindow = appDelegate.window else { return }
//        theWindow.addSubview(categoryMenuView)
//        categoryMenuView.showTheViewOn(theWindow)
        
//        view.addSubview(categoryMenuView)
//        categoryMenuView.showTheViewWithAnimation()
    }
    
    func sizeClassBtnPressed(sender: UIButton) {
        
        if frameTypes_array.count == 0 {
            getAvailableFramesAssignedForProducts(isToOpenAfterCompletion: true)
            return
        }
        
        let alertController = UIAlertController.init(title: "Select the size", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        var size_array = [String]()
        var iPhoneSize_array = [CGFloat]()
        var iPadSize_array = [CGFloat]()
        
        for sizeItem in frameTypes_array {
            
            let typeName = sizeItem.name ?? ""
            size_array.append(typeName)
            
            switch typeName {
            case GSProductFrameType.Names.oneX:
                iPhoneSize_array.append(GSProductFrameType.Values.oneX_iPhone)
                iPadSize_array.append(GSProductFrameType.Values.oneX_iPad)
                break
            case GSProductFrameType.Names.twoX:
                iPhoneSize_array.append(GSProductFrameType.Values.twoX_iPhone)
                iPadSize_array.append(GSProductFrameType.Values.twoX_iPad)
                break
            case GSProductFrameType.Names.threeX:
                iPhoneSize_array.append(GSProductFrameType.Values.threeX_iPhone)
                iPadSize_array.append(GSProductFrameType.Values.threeX_iPad)
                break
            case GSProductFrameType.Names.fullScreen:
                iPhoneSize_array.append(GSProductFrameType.Values.fullScreen_iPhone)
                iPadSize_array.append(GSProductFrameType.Values.fullScreen_iPad)
                break
            default:
                break
            }
        }
        
        for size in size_array {
            
            let alertAction = UIAlertAction.init(title: size, style: .default) { _ in
                
                if size == GSProductFrameType.Names.fullScreen {
                    self.navigationBar_view.sizeClass_imgView.image = #imageLiteral(resourceName: "fullscreen_icon")
                    self.navigationBar_view.sizeClass_btn.setTitle("", for: .normal)
                } else {
                    self.navigationBar_view.sizeClass_imgView.image = nil
                    self.navigationBar_view.sizeClass_btn.setTitle(size, for: .normal)
                }
                let index = size_array.index(of: size)
                self.selectedSizeClass = UIDevice.current.userInterfaceIdiom == .pad ? iPadSize_array[index!] : iPhoneSize_array[index!]
                self.assignLayoutProperties()
                self.items_CollectionView.reloadData()
                self.items_CollectionView.layoutIfNeeded()
                self.configurePageControlForProducts()
            }
            alertController.addAction(alertAction)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if let currentPopoverpresentioncontroller = alertController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = navigationBar_view.sizeClass_btn
                let btnFrame = navigationBar_view.sizeClass_btn.frame
                currentPopoverpresentioncontroller.sourceRect = CGRect(x: 0, y: 0, width: btnFrame.size.width, height: btnFrame.size.height)
                currentPopoverpresentioncontroller.permittedArrowDirections = .up
                self.present(alertController, animated: true, completion: nil)
            }
        }else{
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSCartViewController) as? GSCartViewController {
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.selectedStoreCategory_id, value: categoryId ?? "")
                if let navigator = navigationController {
                navigator.pushViewController(tempVC, animated: true)
            }
        }
    }
    
// MARK: - ScrollView Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == items_CollectionView {

            var visibleRect = CGRect()
            visibleRect.origin = items_CollectionView.contentOffset
            visibleRect.size = items_CollectionView.bounds.size
            
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            
            guard let indexPath = items_CollectionView.indexPathForItem(at: visiblePoint) else {
                
                for cell in items_CollectionView.visibleCells {
        
                    guard let indexPath = items_CollectionView.indexPath(for: cell) else { return }
                                            
                        let item = productListArray[indexPath.row]
                        
                        // Category Display Name - Ratheesh
                        var categoryStr = item.productInfo?.category
                        
                        categoryStr = String(categoryStr?.dropFirst() ?? "")
                        let categoryDispName = categoryStr?.replacingOccurrences(of: "/", with: " ❯ ")
                        categoryDisplayBar.text = categoryDispName
                        break
                }
                
                categoryDisplayBar.frame = CGRect(x: scrollView.contentOffset.x, y: 0, width: items_CollectionView.bounds.width, height: 18)
                
                let pageNumber = round(scrollView.contentOffset.x / (scrollView.frame.size.width))
                
                if pageNumber >= 0 {
                    pageControl.currentPage = UInt(Int(pageNumber))
                    updatePageControl(scrollView.contentOffset.x)
                }
                return
            }
            
            let item = productListArray[indexPath.row]
            
            // Category Display Name - Ratheesh
            var categoryStr = item.productInfo?.category
            
            categoryStr = String(categoryStr?.dropFirst() ?? "")
            let categoryDispName = categoryStr?.replacingOccurrences(of: "/", with: " ❯ ")
            categoryDisplayBar.text = categoryDispName
            
            categoryDisplayBar.frame = CGRect(x: scrollView.contentOffset.x, y: 0, width: items_CollectionView.bounds.width, height: 18)

            let pageNumber = round(scrollView.contentOffset.x / (scrollView.frame.size.width))
            
            if pageNumber >= 0 {
                pageControl.currentPage = UInt(Int(pageNumber))
                updatePageControl(scrollView.contentOffset.x)
            }
        }
    }
    
    //MARK: Page Control methods
    func configurePageControlForProducts() {
        let pageNumbers = items_CollectionView.contentSize.width / items_CollectionView.frame.size.width
        //        let remainder = (items_CollectionView.contentSize.width).truncatingRemainder(dividingBy: (items_CollectionView.frame.size.width))
        //        if remainder != 0 {
        //            pageNumbers += 1
        //        }
        
        pageControl.delegate = self
        pageControl.numberOfPages = UInt(pageNumbers.rounded(.toNearestOrAwayFromZero))
        pageControl.currentPage = UInt(items_CollectionView.contentOffset.x / items_CollectionView.frame.size.width)
        pageControl.selectedColor = UIColor(hexString: defaultTheme.pageControl_selection)
        if UInt(pageNumbers.rounded(.toNearestOrAwayFromZero)) > 1 {
//            pageControl.backgroundColor = UIColor(hexString: defaultTheme.pageControl_BG)
            pageControl.isHidden = false
        }
        else{
//            pageControl.backgroundColor = UIColor(hexString: defaultTheme.pageControlSingleView_BG)
            pageControl.isHidden = true
        }
    }
    
    func updatePageControl(_ offsetX:CGFloat) {
        pageControl.update(forScrollContentOffset: offsetX, pageSize: items_CollectionView.frame.size.width)
    }
}


extension GSProductsViewController:UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionLayout.numColumns
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "normalCell")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return tableView.frame.size.height / CGFloat(collectionLayout.numColumns)
        
    }
}

extension GSProductsViewController:DAPageControlViewDelegate {
    func pageControlViewDidChangeCurrentPage(_ pageControlView: DAPageControlView!) {
        
        let contentOffsetX = CGFloat(pageControlView.currentPage) * items_CollectionView.frame.size.width
        
        let maxContentSizeX = items_CollectionView.contentSize.width
        let upComingContentSizeX = contentOffsetX + items_CollectionView.frame.size.width
        
        if upComingContentSizeX > maxContentSizeX {
            let theContentOffsetX = maxContentSizeX - items_CollectionView.frame.size.width
            items_CollectionView.setContentOffset(CGPoint(x: theContentOffsetX, y: 0), animated: true)
        } else {
            items_CollectionView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: true)
        }
        
        //[self.pageControlView updateForScrollViewContentOffset:self.collectionView.contentOffset.x];
        //updatePageControl(contentOffsetX)
    }
}

extension GSProductsViewController:GSCategoryMenuViewDelegate {
    
    func categoryOrSubcategorySelectedWith(name: String?, isPathSearch: Bool) {
        selected_category = name
        self.isPathSearch = isPathSearch
        
        if isPathSearch {
            let unwrappedName = name ?? ""
            if let indexOfCategory = categoryApiResponse_array.firstIndex(where: { $0.contains(unwrappedName)}) {
                selected_category = categoryApiResponse_array[indexOfCategory]
            }
        }
        
        getCategoryProductsAPI(selectedCategory: selected_category, categoryChanged: true)
    }
}

extension GSProductsViewController:GNAMenuItemDelegate {
    func createMenuItem(_ touchImage:UIImage, productDetails : GSProductsList) {

        if let thePopUp = menuView {
            if (thePopUp.isDescendant(of: self.view)) {
                thePopUp.dismissMenuView()
            }
        }
        
        var menuItem_array = [GNAMenuItem]()
        guard let jsonData = try? JSONEncoder().encode(productDetails.productInfo) else { return }
        guard let jsonParsed = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) else { return }
        guard let jsonDict = jsonParsed as? [String:Any] else { return }
        
        let bg_colour_array = [UIColor(hexString: defaultTheme.popUp1_BG),UIColor(hexString:  defaultTheme.popUp2_BG), UIColor(hexString:  defaultTheme.popUp3_BG), UIColor(hexString:  defaultTheme.popUp4_BG), UIColor(hexString:  defaultTheme.popUp5_BG)]
        let textColor_array = [UIColor(hexString: defaultTheme.popUp1_text), UIColor(hexString: defaultTheme.popUp2_text), UIColor(hexString: defaultTheme.popUp3_text), UIColor(hexString: defaultTheme.popUp4_text), UIColor(hexString: defaultTheme.popUp5_text)]
        
        for index in 0..<toolTip_array.count {
            let toolTip = toolTip_array[index]
            let keyName = toolTip.key_name ?? ""
            var bg_color = UIColor.white
            var text_color = UIColor.black
            
            if index < bg_colour_array.count {
                bg_color = bg_colour_array[index]
            }
            if index < textColor_array.count {
                text_color = textColor_array[index]
            }
            
            var value = ""
            
            // We are mentioning with these keys particularly instead of looping is because for these keys we are comparing and caluculating with the cart
            if keyName == "stock" || keyName == "offer" || keyName == "selling_price" || keyName == "tax" {
                
                let currentStockPrice = stockByComparingWithCartItems(productDetails: productDetails)
                
                if keyName == "stock" {
                    value = "Stock: " + GSCommonHelper.getStringFrom(anyValue: currentStockPrice.stock)
                } else if keyName == "offer" {
                    value = "Offer: " + GSCommonHelper.getStringFrom(anyValue: currentStockPrice.offer) + "%"
                } else if keyName == "selling_price" {
                    value = "Price: " + GSCommonHelper.getStringFrom(anyValue: currentStockPrice.sellingPrice)
                } else if keyName == "tax" {
                    value = "tax: " + GSCommonHelper.getStringFrom(anyValue: currentStockPrice.tax) + "%"
                }
                
            } else {
                
                value = GSCommonHelper.getStringFrom(anyValue: jsonDict[keyName])
                
                if keyName == "category" {
                    let category_array = value.components(separatedBy: "/")
                    for category in category_array.reversed() {
                        let clear_category = category.removeEnclosedWhieteSpace()
                        if clear_category != "" {
                            value = clear_category
                            break
                        }
                    }
                } // Category
            }
            
            // Filtering the empty values to not to show
            if value.removeEnclosedWhieteSpace() != "" {
                let menuItem = GNAMenuItem(text: value, bgColor: bg_color, textColor: text_color)
                menuItem_array.append(menuItem)
            }
        }
        
        if menuItem_array.count > 0 {
            menuView = GNAMenuView(touchPointSize: CGSize(width: customView.frame.size.width, height: customView.frame.size.height), touchImage: touchImage, menuItems: menuItem_array)
            menuView.delegate = self
            menuView.showMenuView(inView: self.view, atPoint: CGPoint(x: customView.center.x, y: customView.center.y))
        }
    }
    
    struct CurrentStockAndPrice {
        let sellingPrice:Double
        let stock:Int
        let offer:Double
        let tax: Double
    }
    
    private func stockByComparingWithCartItems(productDetails : GSProductsList) -> CurrentStockAndPrice {
        
        let product_id = productDetails._id ?? ""
        
        var current_price_toShow:Double = productDetails.stores?[0].product_details?.selling_price ?? 0
        var tax:Double = productDetails.stores?[0].product_details?.tax ?? 0
        var stocksToRemove = 0
        
        // Calculating the total stock moved to cart
        if let productExistInCart = cartItemsDictionary[product_id] {
            if let cartStoreArray = productExistInCart.stores {
                for cartStore in cartStoreArray {
                    stocksToRemove += (cartStore.productDetails?.qty ?? 0)
                }
            }
        }
        
        var stocks = 0
        var isCurrentPriceToShowIntialized = false
        var offer:Double = 0
        
        // Caluculating the total stock from product list response...
        if let productListStoreArray = productDetails.stores {
            for product in productListStoreArray {
                stocks += (product.product_details?.stock ?? 0)
                
                if stocks > stocksToRemove && !isCurrentPriceToShowIntialized {
                    current_price_toShow = product.product_details?.selling_price ?? 0
                    offer = product.product_details?.offer ?? 0
                    tax = product.product_details?.tax ?? 0
                    isCurrentPriceToShowIntialized = true
                }
            }
        }

        if stocksToRemove > stocks {
            stocks = 0
        } else {
            stocks -= stocksToRemove
        }
        
        let currentStockPrice = CurrentStockAndPrice(sellingPrice: current_price_toShow, stock: stocks, offer: offer, tax: tax)
        return currentStockPrice
    }
}

extension GSProductsViewController : GSCategorySelectDelegate {

    func categorySelectAction(index: Int) {
        
        if categorySearchView != nil {
            categorySearchView.removeFromSuperview()
        }
        selected_category = nil
        navigationBar_view.navigSearchBar.resignFirstResponder()
        
        if (searchedCategories == nil || (searchedCategories?.count ?? 0) < index) {
            return
        }
        // Crash noted
        if index == 0 && (searchedCategories?[index] == categoryAllStr)  {
            navigationBar_view.navigSearchBar.text = "";
        } else {
            if (searchedCategories?.count ?? 0) > 0 {
                navigationBar_view.navigSearchBar.text = searchedCategories?[index]
                selected_category = searchedCategories?[index]
            }
        }
        SDImageCache.shared().clearMemory()
        
        isPathSearch = false
        getCategoryProductsAPI(selectedCategory : selected_category, categoryChanged: true)
    }
    
    func productSelectAction(index: Int, productsArr: [GSProductsList]) {
        
        navigationBar_view.navigSearchBar.resignFirstResponder()
        navigationBar_view.navigSearchBar.text = ""
        if let productDetailVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSProductDetailsViewController) as? GSProductDetailsViewController {
            productDetailVC.catId = categoryId
            productDetailVC.storesArray = storesArray
            productDetailVC.productId = productsArr[index]._id
            productDetailVC.templateArray = templateArray
            productDetailVC.productListArray = productsArr
            productDetailVC.selectedProductIndex = index
            GSCustomPushPop.doCustomPush(from: self, to: productDetailVC)
        }
    }
}

extension GSProductsViewController  {
    
    func getTotalCountOfProductsFromAPI(selectedCategory : String?, categoryChanged:Bool, isFirstTimeCheck:Bool) {
        
        let baseUrlCombined = (selectedCategory == nil) ? APIurl.baseURL + APIurl.subURL.productsCount : APIurl.baseURL + APIurl.subURL.productCountInCategory
        
        var params = ["_id" : categoryId ?? "",
                      "stores" : storesArray ?? [""]] as [String : AnyObject]
        
        
        if selectedCategory != nil {
            params["category"] = selectedCategory as AnyObject
            params["is_reg_exp"] = !isPathSearch as AnyObject
        }
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject], urlString: baseUrlCombined, withLoader:false) { [weak self] (responseData, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = responseData else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSTotalProductsCountModel.self, from: responseData)
                    
                    let total_count = responseModel.data?.total ?? 0
                    weakSelf.totalProuctsAvailableInStores = total_count
                    if total_count == 0, isFirstTimeCheck {
                        CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.noProducts, alertButtonsArray: ["Ok"], viewController: weakSelf, completion: { _ in
                            weakSelf.navigationController?.popViewController(animated: true)
                        })
                        return
                    } else if isFirstTimeCheck {
                        weakSelf.isPathSearch = false
                        weakSelf.getCategoryProductsAPI(selectedCategory: selectedCategory, categoryChanged: categoryChanged)
                        
                        if weakSelf.storeDeliveryTypesArray.count == 1, weakSelf.storeDeliveryTypesArray[0] == GSConstant.selfPickUP_id {
                            
                            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.onlySelfPickupAvailable, alertButtonsArray: ["Cancel", "Continue"], viewController: weakSelf, completion: { btnIndex in
                                
                                if btnIndex == 0 {
                                    weakSelf.navigationController?.popViewController(animated: true)
                                }
                            })
                        }
                    }

                    if isFirstTimeCheck {
                        
                        if weakSelf.productGifView != nil, weakSelf.productGifView.isDescendant(of: weakSelf.view) == false {
                            return
                        }
                        
                        weakSelf.offerPopupAPI()
                    }
                    
                    weakSelf.categoryListAPI()
                    
                } catch(let decode_error) {
                    CustomAlert.showAlert(title: GSString.AppName, message: decode_error.localizedDescription, viewController: weakSelf)
                }
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func getAvailableFramesAssignedForProducts(isToOpenAfterCompletion:Bool) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.frameTypesForProducts
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil, urlString: urlString, withLoader:true) { [weak self] (responseData, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = responseData else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSFrameTypesModel.self, from: responseData)
                    
                    if let unwrappedFrameTypes_array = responseModel.data?.type {
                        weakSelf.frameTypes_array = unwrappedFrameTypes_array
                        if isToOpenAfterCompletion {
                            weakSelf.navigationBar_view.sizeClass_btn.sendActions(for: .touchUpInside)
                        } else {

                            var selectedIpadSize:CGFloat = 1
                            var selectedIphoneSize:CGFloat = 1
                            for sizeItem in weakSelf.frameTypes_array {
                                
                                let typeName = sizeItem.name ?? ""
                                if weakSelf.selectedFrameType_id != sizeItem.id {
                                    continue
                                }
                                weakSelf.navigationBar_view.sizeClass_btn.setTitle(typeName, for: .normal)
                                weakSelf.navigationBar_view.sizeClass_imgView.image = nil
                                switch typeName {
                                case GSProductFrameType.Names.oneX:
                                    selectedIphoneSize = GSProductFrameType.Values.oneX_iPhone
                                    selectedIpadSize = GSProductFrameType.Values.oneX_iPad
                                    break
                                case GSProductFrameType.Names.twoX:
                                    selectedIphoneSize = GSProductFrameType.Values.twoX_iPhone
                                    selectedIpadSize = GSProductFrameType.Values.twoX_iPad
                                    break
                                case GSProductFrameType.Names.threeX:
                                    selectedIphoneSize = GSProductFrameType.Values.threeX_iPhone
                                    selectedIpadSize = GSProductFrameType.Values.threeX_iPad
                                    break
                                case GSProductFrameType.Names.fullScreen:
                                    selectedIphoneSize = GSProductFrameType.Values.fullScreen_iPhone
                                    selectedIpadSize = GSProductFrameType.Values.fullScreen_iPad
                                    weakSelf.navigationBar_view.sizeClass_btn.setTitle(GSProductFrameType.emptyTitleForFullScreen, for: .normal)
                                    weakSelf.navigationBar_view.sizeClass_imgView.image = #imageLiteral(resourceName: "fullscreen_icon")
                                    break
                                default:
                                    break
                                }
                            }
                            weakSelf.selectedSizeClass = UIDevice.current.userInterfaceIdiom == .pad ? selectedIpadSize : selectedIphoneSize
                            weakSelf.assignLayoutProperties()
                            weakSelf.items_CollectionView.reloadData()
                            weakSelf.items_CollectionView.layoutIfNeeded()
                            weakSelf.configurePageControlForProducts()
                        }
                    }
                    
                } catch(let decode_error) {
                    CustomAlert.showAlert(title: GSString.AppName, message: decode_error.localizedDescription, viewController: weakSelf)
                }
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func getCategoryProductsAPI(selectedCategory : String?, categoryChanged:Bool){
        
        let baseUrlCombined = (selectedCategory == nil) ? APIurl.baseURL + APIurl.subURL.productsList : APIurl.baseURL + APIurl.subURL.productListByCategory
        
        var urlString = ""
        
        if categoryChanged {
           urlString = baseUrlCombined + "?skip=0&limit=\(showableProductsAPI_limit)"
        } else {
            urlString = baseUrlCombined + "?skip=\(productListArray.count + 1)&limit=\(showableProductsAPI_limit)"
        }
        
        var params:[String:AnyObject] = ["_id" : categoryId ?? "" ,
                                         "stores" : storesArray ?? [""]] as [String : AnyObject]
        
        if selectedCategory != nil {
            // If any category other than all selected... need to send the selected category
            params["category"] = selectedCategory as AnyObject
            params["is_reg_exp"] = !isPathSearch as AnyObject
        } else {
            
            if let productOffer_count = offerProductsCount {
                params["offerProdCount"] = productOffer_count as AnyObject
            }
        }
        
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:false) { (responseData, error) in
            
            if error == nil {
                
                if categoryChanged {
                    self.getTotalCountOfProductsFromAPI(selectedCategory: selectedCategory, categoryChanged: categoryChanged, isFirstTimeCheck: false)
                }
                self.handleProductResponse(response: responseData, categoryChanged: categoryChanged)
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: self)
            }
        }
    }
    
    func getSearchedProductsAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.productListBySearch
        
        let params = ["_id" : categoryId ?? "" ,
                      "stores" : storesArray ?? [""],
                      "search" : navigationBar_view.navigSearchBar.text ?? ""] as [String : AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params , urlString: urlString, withLoader:false) { [weak self] (responseData, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                weakSelf.handleProductSearchResponse(response: responseData)
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func offerPopupAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.offerPopupAPI

        let params = ["category_id" : categoryId ?? "" ,
                      "store_id" : storesArray ?? [""]] as [String : AnyObject]

        APIHandler.NetworkSetupRequest(method: .post, params: params , urlString: urlString, withLoader:false) { [weak self] (responseData, error) in

            guard let weakSelf = self else { return }

            if error == nil {

                do {
                    guard let response = responseData else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSOfferPopupModel.self, from: response)

                    if responseModel.success == true {
                        let message = responseModel.message ?? ""

                        weakSelf.addOfferPopupView(with: message)
                    }

                } catch {
                    #if DEBUG
                    print(error)
                    #endif
                }
            } else {
                #if DEBUG
                print(error?.localizedDescription ?? "")
                #endif
            }
        }
    }
    
    func addOfferPopupView(with message: String) {
        
        if offerPopup_view != nil {
            if offerPopup_view.isDescendant(of: view) {
                return
            }
            offerPopup_view = nil
        }
        
        offerPopup_view = GSOfferPopupView()
        offerPopup_view.htmlString = message

//        view.addSubview(offerPopup_view)
//        offerPopup_view.translatesAutoresizingMaskIntoConstraints = false

//        var topAnchor:NSLayoutConstraint!
//        if #available(iOS 11.0, *) {
//            topAnchor = offerPopup_view.topAnchor.constraint(equalTo: view.topAnchor)
//        } else {
//            // Fallback on earlier versions
//        }
//        topAnchor.isActive = true
//        offerPopup_view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        offerPopup_view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        offerPopup_view.topConstraintRef = topAnchor
        
//        offerPopup_view.showTheViewFromBottom(on: self.view, for: CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)) {
//
//        }
        
        offerPopup_view.showTheView(on: self.view, for: CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom))
        
//        offerPopup_view.offer_lbl.text = message

        
//        topAnchor.constant = -100
//        view.layoutIfNeeded()
//
//        topAnchor.constant = 0
        
//        UIView.animate(withDuration: 0.45, animations: {
//            self.view.layoutIfNeeded()
//        }) { _ in
//            self.offerPopup_view.initiateAutoClose()
//        }
    }
    
    func addProductToCartAPI(index : Int, storeIndex : Int){
        
        let urlString = APIurl.baseURL + APIurl.subURL.addProductToCart
        
        let prodId = productListArray[index].stores![storeIndex].product_details?.id
        let store_item = productListArray[index].stores![storeIndex]
        let storeId = store_item.store_id
        
        let params = ["_id" : (categoryId ?? "") as Any ,
                      "product_id" : (prodId ?? "") as Any ,
                      "is_private" : SharedPersistence.getValue(key: UserDefaultKeys.Products.isPrivateShop) as? Bool ?? false,
                      "stores"     : [["store_id" : (storeId ?? "") as Any ,
                                      "qty" : 1]] ] as [String : Any]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] , urlString: urlString, withLoader:true) { [weak self] (responseData, error) in
            guard let weakSelf = self else { return }
            if error == nil {
                weakSelf.handleAddCartResponse(response: responseData)
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func handleProductResponse(response: Data?, categoryChanged:Bool){
        
        do {
            guard let responseData = response else {return}
            let jsonDecoder = JSONDecoder()
            let responseModel = try jsonDecoder.decode(GSProductsRootClass.self, from: responseData)
            
            if categoryChanged {                    // If the category changed will remove the previous data
                items_CollectionView.setContentOffset(CGPoint.zero, animated: false)
                if productListArray.count > 0 {
                    productListArray.removeAll()
                }
            }
            
            if let products_array = responseModel.data {

                for category in products_array {
                    if let products = category.category {
                        productListArray.append(contentsOf: products)
                    }
                }
                
                if products_array.count == 0 {
                    totalProuctsAvailableInStores = productListArray.count
                }
                
/*                let sortedArray = products_array.sorted { (firstItem, secondItem) -> Bool in

                    let theFirstItemName = firstItem.productInfo?.product_name ?? ""
                    
                    var firstItemCategoryName = firstItem.productInfo?.category ?? ""
                    if firstItemCategoryName.first == "/" {
                        firstItemCategoryName.removeFirst()
                    }

                    let secondItemName = secondItem.productInfo?.product_name ?? ""

                    var secondItemCategoryName = secondItem.productInfo?.category ?? ""
                    if secondItemCategoryName.first == "/" {
                        secondItemCategoryName.removeFirst()
                    }
                    
                    return (theFirstItemName.localizedCaseInsensitiveCompare(secondItemName) == ComparisonResult.orderedAscending) && (firstItemCategoryName == secondItemCategoryName)
                }
                productListArray.append(contentsOf: sortedArray)
*/
            }
            
            reloadTheCollectionViewLayout()
//          addGesturesForCollectionView()
        } catch {
            print(error)
        }
    }
    
    func handleProductSearchResponse(response: Data?){
        
        do {
            guard let responseData = response else {return}
            let jsonDecoder = JSONDecoder()
            let responseModel = try jsonDecoder.decode(GSProductsRootClass.self, from: responseData)
            
            var tempProductArray = [GSProductsList]()
            if let products_array = responseModel.data {
                for category in products_array {
                    
                    if let products = category.category {
                        tempProductArray.append(contentsOf: products)
                    }
                }
            }
    
            searchedProductArray = tempProductArray
            categorySearchView.searchedProductsArr = searchedProductArray
            categorySearchView.categoryTable.reloadData()
        } catch {
            print(error)
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

// MARK: - GSOfferPopupModel
struct GSOfferPopupModel: Codable {
    let success: Bool?
    let message : String?
    
    enum CodingKeys: String, CodingKey {
        case success, message
    }
}
