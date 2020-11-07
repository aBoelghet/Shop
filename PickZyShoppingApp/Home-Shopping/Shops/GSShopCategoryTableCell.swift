//
//  GSShopCategoryTableCell.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 5/3/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSShopCategoryTableCell: UITableViewCell,UIScrollViewDelegate {
    
    @IBOutlet weak var shopsCollectionView:UICollectionView!
    @IBOutlet weak var pageControl: DAPageControlView!
    
    let shopDefaultIconArray    = ShopDefaultIcon.shopDefaultIcon
    
    var shops = [GSHomeDocsClass]()
    var isDisplayCount : Bool!
    var isCellFormed : Bool = false
    var sessionIndex : Int = 0
    var section_id : Int = 0
    
    var clearCartSupport:GSClearCartSupport?
    
    var offerNotifications_array = [GSNotificationOffersListData]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shopsCollectionView.collectionViewLayout.invalidateLayout()
        configurePageControl()
    }
    
    func setUpCell() {
        shopsCollectionView.delegate = self
        shopsCollectionView.dataSource = self
        shopsCollectionView.clipsToBounds = false
    }
    
    func configureTheCell(displayCount: Bool, shopsModel : [GSHomeDocsClass]?, tableIndex : Int, sectionId: Int) {
        
        shops           = shopsModel ?? [GSHomeDocsClass]()
        isDisplayCount  = displayCount
//      sessionIndex    = tableIndex

        sessionIndex    = sectionId
        isCellFormed    = true
        section_id = sectionId
        DispatchQueue.main.async { [weak self] in
            self?.shopsCollectionView.reloadData()
            self?.configurePageControl()
        }
    }
    
    func configurePageControl() {
        var pageNumbers = shopsCollectionView.contentSize.width / shopsCollectionView.frame.size.width
        let remainder = (shopsCollectionView.contentSize.width).truncatingRemainder(dividingBy: (shopsCollectionView.frame.size.width))
        if remainder != 0 {
            pageNumbers += 1
        }
        
        pageControl.delegate = self
        pageControl.numberOfPages = UInt(pageNumbers)
        pageControl.currentPage = UInt(shopsCollectionView.contentOffset.x / shopsCollectionView.frame.size.width)
        pageControl.tintColor = UIColor.red
        pageControl.selectedColor = UIColor.green
        
        let contentOffsetX = CGFloat(pageControl.currentPage) * shopsCollectionView.frame.size.width
        shopsCollectionView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let pageNumber = round(scrollView.contentOffset.x / (scrollView.frame.size.width))
        if pageNumber >= 0 {
            pageControl.currentPage = UInt(pageNumber)
        }
    }

    func updatePageControl(_ offsetX:CGFloat) {
        pageControl.update(forScrollContentOffset: offsetX, pageSize: shopsCollectionView.frame.size.width)
    }
}

extension GSShopCategoryTableCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            if shops.count < 6 {
                return shops.count + (6 - shops.count)
            } else {
                if shops.count % 6 != 0 {
                    return shops.count + (6 - shops.count % 6)
                } else {
                    return shops.count
                }
            }
        } else {
            if shops.count < 14 {
                return shops.count + (14 - shops.count)
            } else {
                if shops.count % 14 != 0 {
                    return shops.count + (14 - shops.count % 14)
                } else {
                    return shops.count
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = GSString.CellIdentifier.ShopVC_shop_collectionCell
       
        guard let cell = shopsCollectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? GSShopCategoryCollectionCell else {
            return UICollectionViewCell()
        }
        cell.categoryNotCount.isHidden = true
        
        cell.categoryImage.image = nil
        cell.categoryImage.sd_cancelCurrentImageLoad()
        
        cell.rating_imgView.image = nil
        cell.ratingBg_view.isHidden = true
        
        cell.offerBg_view.isHidden = true
        
        if indexPath.row < shops.count {
            
            if isDisplayCount {
                cell.categoryNotCount.isHidden = false
            }
            cell.categoryName.isHidden = false
            cell.categoryImage.isHidden = false
            cell.configureTheCell(shopModel: shops[indexPath.row])
            
            cell.rating_imgView.image = nil
            cell.ratingBg_view.isHidden = true
            
            if let rating = shops[indexPath.row].storeRating?.avgRating {
                
                if (rating <= 0) {
                    cell.ratingBg_view.isHidden = true
                } else {
                    cell.ratingBg_view.isHidden = false
                    cell.rating_lbl.text = String(format: "%.1f", rating)
                }
            }
            
            let offerText = returnOfferText(store_array: shops[indexPath.row].stores ?? [String]())
            
            if offerText != "" {
                cell.offerBg_view.isHidden = false
                cell.offerText_lbl.text = "Save\n" + offerText
            }
            
        } else {
            if indexPath.row < shopDefaultIconArray.count {

                var shopName: String? = nil
                var shopIconImg: UIImage? = nil
                switch sessionIndex {
                case 1,3:
                    shopName = shopDefaultIconArray[indexPath.row].shopPublicName
                    shopIconImg = UIImage(named:shopDefaultIconArray[indexPath.row].shopPublicIcon)!
                    break
                case 0:
                    shopName = shopDefaultIconArray[indexPath.row].shopPrivateName
                    shopIconImg = UIImage(named:shopDefaultIconArray[indexPath.row].shopPrivateIcon)!
                    break
                case 2:
                    shopName = shopDefaultIconArray[indexPath.row].shopBrandedName
                    shopIconImg = UIImage(named:shopDefaultIconArray[indexPath.row].shopBrandedIcon)!
                    break
                default:
                    break
                }
                cell.categoryImage.image = nil
                cell.categoryName.text = ""
                if shopName != nil {
                    cell.categoryName.text = shopName
                }
                if shopIconImg != nil {
                    cell.categoryImage.isHidden = false
                    cell.categoryImage.image = shopIconImg
                }

            } else {
                cell.categoryImage.isHidden = true
                cell.categoryName.text = ""
            }
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSProductsViewController) as? GSProductsViewController else { return }
        
        if indexPath.row >= shops.count { return }
        
        var idOfShop = shops[indexPath.row]._id ?? ""
        
        if sessionIndex == 0 {
            
            guard let stores = shops[indexPath.row].stores, stores.count > 0 else { return }
            idOfShop = stores[0]
        }
        
        let storeIdDifferentationToClearCart = SharedPersistence.getValue(key: UserDefaultKeys.Products.storeIdToDifferentiateCartClear) as? String ?? idOfShop
        let selectedShopType = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedShopType) as? Int ?? sessionIndex
        
//        let lastSelectedStoreCategory = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? idOfShop
        
        if shops[indexPath.row].is_open != false {
        
            if sessionIndex == selectedShopType, storeIdDifferentationToClearCart == idOfShop {
                
                pushToProductListPage(shopAtIndex: shops[indexPath.row], tempVC: tempVC, tempSessionIndex: sessionIndex)
            } else {
                if cartCount.value > 0 {
                    
                    clearCartAndProceed(to: tempVC, indexPath: indexPath, alertMessage: GSConstant.AlertMessages.otherStoreCartClear)
                } else {
                    pushToProductListPage(shopAtIndex: shops[indexPath.row], tempVC: tempVC, tempSessionIndex: sessionIndex)
                }
            }
        }
    }
    
    private func returnOfferText(store_array: [String]) -> String {
        
        var offerText = ""
        
        var tempOfferValue = 0
        
        for storeItem in store_array {
            
            for offer in offerNotifications_array {
                
                if let offeredStore = offer.storeID,
                    offeredStore == storeItem,
                    let offerType = offer.codeProObj?.valueType,
                    let offerValue = offer.codeProObj?.codeValue {
                    
                    if tempOfferValue < offerValue {
                        tempOfferValue = offerValue
                        
                        
                        if offerType == 1 {
                            offerText = "\(GSConstant.currency_symbol)\(tempOfferValue)"
                        } else {
                            offerText = "\(tempOfferValue)%"
                        }
                    }
                    
                    // Offer Or Value   =   1   ---> Price
                    //                      2   ---> Percentage
                }
            }
        }
        
        if tempOfferValue != 0 {
            return offerText
        }
        
        return ""
    }
    
    private func clearCartAndProceed(to productVC:GSProductsViewController, indexPath: IndexPath, alertMessage:String) {
        
        CustomAlert.showAlert(title: GSString.AppName, message: alertMessage, alertButtonsArray: ["Cancel","Continue"], isLastButtonDestructive: true, viewController: GSTopViewController.topViewController()) { (btnIndex) in
            
            if btnIndex == 1 {  // Conitnue
                self.clearCartSupport = GSClearCartSupport()
                self.clearCartSupport?.clearCartAPI()
                self.clearCartSupport?.clearSaveForLaterAPI()
                self.pushToProductListPage(shopAtIndex: self.shops[indexPath.row], tempVC: productVC, tempSessionIndex: self.sessionIndex)
            }
        }
    }
    
    private func pushToProductListPage(shopAtIndex: GSHomeDocsClass, tempVC:GSProductsViewController, tempSessionIndex: Int) {
        
        let idOfShop = shopAtIndex._id
        tempVC.storesArray = shopAtIndex.stores
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.selecedStoreArray, value: shopAtIndex.stores ?? [""])
        tempVC.categoryId = idOfShop
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.selectedStoreCategory_id, value: idOfShop ?? "")
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.storeIdToDifferentiateCartClear, value: idOfShop ?? "")
        
        if tempSessionIndex == 0 {
            // Private store
            
            guard let stores = shopAtIndex.stores, stores.count > 0 else { return }
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.storeIdToDifferentiateCartClear, value: stores[0])
        }
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.isPrivateShop, value: (tempSessionIndex == 0))
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isNoteFeatureEnabled, value: shopAtIndex.features?.notes ?? false)
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isUploadFeatureEnabled, value: shopAtIndex.features?.upload ?? false)
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.selectedShopType, value: section_id)
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isSubscriptionEnabled, value: shopAtIndex.features?.enableSubscription ?? false)

        
        SharedPersistence.removeValues(for: [UserDefaultKeys.Shops.localDeliveryDuration, UserDefaultKeys.Shops.localDeliveryDurationUnit, UserDefaultKeys.Shops.otherDeliveryDuration, UserDefaultKeys.Shops.otherDeliveryDurationUnit])
        
        if let deliveryLocalDuration = shopAtIndex.deliveryLocalDuration, let deliveryLocalDurationUnit = shopAtIndex.deliveryLocalDurationUnit {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.localDeliveryDuration, value: deliveryLocalDuration)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.localDeliveryDurationUnit, value: deliveryLocalDurationUnit)
        }
        
        if let otherDeliveryDuration = shopAtIndex.deliveryOtherDuration, let otherDeliveryDurationUnit = shopAtIndex.deliveryOtherDurationUnit {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.otherDeliveryDuration, value: otherDeliveryDuration)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.otherDeliveryDurationUnit, value: otherDeliveryDurationUnit)
        }
        
        SharedPersistence.removeValue(key: UserDefaultKeys.Shops.localDeliveryFromTime)
        SharedPersistence.removeValue(key: UserDefaultKeys.Shops.localDeliveryToTime)
        
        if let localDeliveryFromTime = shopAtIndex.deliveryLocalFrom, let localDeliveryToTime = shopAtIndex.deliveryLocalTo {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.localDeliveryFromTime, value: localDeliveryFromTime)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.localDeliveryToTime, value: localDeliveryToTime)
        }
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isGlobalShopsLoaded, value: false)
        
        if tempSessionIndex == 3 {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isGlobalShopsLoaded, value: true)
        }
        
        if let isCodEnabled = shopAtIndex.isCod {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isCodEnabled, value: isCodEnabled)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isNeedToShowCOD, value: isCodEnabled)
            if let codLimit = shopAtIndex.codLimit {
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.codLimit, value: codLimit)
            }
            
            if let codLimitType = shopAtIndex.isCodLimitType, codLimitType == APIKeys.Shops.shopCodLimitType_any {
                SharedPersistence.removeValue(key: UserDefaultKeys.Shops.codLimit)
            }
            
        } else {            // In case of any server issues making default to show COD...
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isCodEnabled, value: true)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isNeedToShowCOD, value: true)
        }
        
        if let isGlobalShopsLoaded = SharedPersistence.getValue(key: UserDefaultKeys.Shops.isGlobalShopsLoaded) as? Bool, isGlobalShopsLoaded == true {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isCodEnabled, value: false)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Shops.isNeedToShowCOD, value: false)
        }
        
        tempVC.templateArray = shopAtIndex.templateKeys
        tempVC.navigationTitle = shopAtIndex.display_name ?? ""
        tempVC.selectedFrameType_id = shopAtIndex.frameType ?? 1
        
        guard let deliveryTypesArray = shopAtIndex.deliveryLocalType else { return }
        tempVC.storeDeliveryTypesArray = deliveryTypesArray
        
        var toolTip_array = [GSProductDetailsKeyTemplate]()
        if let template_array = shopAtIndex.templateKeys {
            
            for template in template_array {
                if template.tooltipID != nil {
                    toolTip_array.append(template)
                }
            }
        }
        toolTip_array.sort { (firstTemplate, secondTemplate) -> Bool in
            return (firstTemplate.tooltipID ?? 0) < (secondTemplate.tooltipID ?? 0)
        }
        tempVC.toolTip_array = toolTip_array
        GSTopViewController.topViewController().navigationController?.pushViewController(tempVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension GSShopCategoryTableCell:DAPageControlViewDelegate {
    func pageControlViewDidChangeCurrentPage(_ pageControlView: DAPageControlView!) {
        
        let contentOffsetX = CGFloat(pageControlView.currentPage) * shopsCollectionView.frame.size.width
        shopsCollectionView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: true)
        updatePageControl(contentOffsetX)
    }
}




