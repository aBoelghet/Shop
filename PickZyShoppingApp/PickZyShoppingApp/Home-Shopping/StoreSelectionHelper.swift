//
//  StoreSelectionHelper.swift
//  Shopor
//
//  Created by Ratheesh on 13/09/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import MBProgressHUD

class StoreSelectionHelper {
    
    func checkForTheStoreSelection(selectedStoreId: String, tempSessionIndex: Int) {
        
        let storeIdDifferentationToClearCart = SharedPersistence.getValue(key: UserDefaultKeys.Products.storeIdToDifferentiateCartClear) as? String ?? selectedStoreId
        let selectedShopType = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedShopType) as? Int ?? tempSessionIndex
        //        let lastSelectedStoreCategory = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? idOfShop
        
        if tempSessionIndex == selectedShopType, storeIdDifferentationToClearCart == selectedStoreId {
            
            
            
        } else {
            
            if cartCount.value > 0 {
                let clearCartSupport =  GSClearCartSupport()
                clearCartSupport.clearCartAPI()
                clearCartSupport.clearSaveForLaterAPI()
            }
        }
    }
    
    func pushToProductListPage(shopAtIndex: GSHomeDocsClass, tempSessionIndex: Int) {
        
        
        checkForTheStoreSelection(selectedStoreId: shopAtIndex.stores?.first ?? "", tempSessionIndex: tempSessionIndex)
        
        guard let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSProductsViewController) as? GSProductsViewController else { return }
        
        let idOfShop = shopAtIndex._id
        tempVC.storesArray = shopAtIndex.stores
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.selecedStoreArray, value: shopAtIndex.stores ?? [""])
        tempVC.categoryId = idOfShop
        
        assignCommonStoreSettings(shopAtIndex: shopAtIndex, tempSessionIndex: tempSessionIndex)
        
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
    
    func assignCommonStoreSettings(shopAtIndex: GSHomeDocsClass, tempSessionIndex: Int) {
        
        let idOfShop = shopAtIndex._id
        
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
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Products.selectedShopType, value: tempSessionIndex)
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
    }
    
    
    func fetchShopDetailsAPI(categoryId: String, storeId: String, completion: @escaping (GSHomeDocsClass?, String?) -> Void) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.fetchShopDetails
        
        let params = ["category_id": categoryId,
                      "store_id": storeId] as [String : AnyObject]
        
        let topVC = GSTopViewController.topViewController()
        
        MBProgressHUD.showAdded(to: topVC.view, animated: true)
        
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:true) { (response, error) in
            
//            guard let weakSelf = self else { return }
            MBProgressHUD.hide(for: topVC.view, animated: true)
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSFetchStoreModel.self, from: responseData)
                    
                    if let storeObject = responseModel.data?.storeConfig?.first {
                        completion(storeObject, nil)
                    } else {
                        completion(nil, GSString.API.unknownError)
                    }
                    
                } catch {
                    print(error)
                    completion(nil, error.localizedDescription)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                completion(nil, error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }
    
}


// MARK: - GSFetchStoreModel
struct GSFetchStoreModel: Codable {
    let success: Bool?
    let data: GSFetchStoreData?
}

// MARK: - DataClass
struct GSFetchStoreData: Codable {
    let storeConfig: [GSHomeDocsClass]?
    
    enum CodingKeys: String, CodingKey {
        case storeConfig = "store_config"
    }
}
