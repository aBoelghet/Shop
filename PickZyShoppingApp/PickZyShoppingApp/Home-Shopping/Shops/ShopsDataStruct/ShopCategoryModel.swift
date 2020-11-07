//
//  ShopCategoryModel.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/22/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import Foundation

struct ShopsModel {
    
    let catImage : String
    let catName : String
    
    static let someShops:[ShopsModel] = {
        
        let cat1 = ShopsModel(catImage: "Trolley", catName: "Super market")
        let cat2 = ShopsModel(catImage: GSString.Icons.Store_Kids_icon, catName: "Fruit Shop")
        let cat3 = ShopsModel(catImage: GSString.Icons.Store_Mobile_icon, catName: "Toy Store")
        let cat4 = ShopsModel(catImage: GSString.Icons.Store_SuperMarket_icon, catName: "Medical Store")
        let cat5 = ShopsModel(catImage: "Mobileshop", catName: GSString.ShopCategories.mobileStore)
        let cat6 = ShopsModel(catImage: "Kids Shop", catName: "Kids Shop")
        
        return [cat1,cat2,cat3,cat4,cat5,cat6,cat1,cat2,cat3,cat4,cat5,cat6,cat1,cat2,cat3,cat4,cat5,cat6]
    }()
}

struct ShopCategoryModel {
    
    let catName:String
    let catItems:[ShopsModel]
    
    static let someCats:[ShopCategoryModel] = {
       
        let cat1 = ShopCategoryModel(catName: "Public Shops", catItems: ShopsModel.someShops)
        let cat2 = ShopCategoryModel(catName: "Private Shops ", catItems: ShopsModel.someShops)
        let cat3 = ShopCategoryModel(catName: "Branded shops", catItems: ShopsModel.someShops)
        
        return [cat1, cat2, cat3]
    }()
}

// Temp model for shop type, should replace with API.
struct ShopTypeModel {
    
    let shopTypeId:Int
    let shopTypeDisplayName:String
    
    static let shopTypeArray:[ShopTypeModel] = {
        
        let shopType_session_1 = ShopTypeModel(shopTypeId: 1, shopTypeDisplayName: "Public Shops")
        let shopType_session_2 = ShopTypeModel(shopTypeId: 0, shopTypeDisplayName: "Private Shops")
        let shopType_session_3 = ShopTypeModel(shopTypeId: 2, shopTypeDisplayName: "Branded Shops")

        return [shopType_session_1, shopType_session_2, shopType_session_3]
    }()
}

// Shops default icons model.
struct ShopDefaultIcon {
    
    let shopPublicIcon:String
    let shopPublicName:String
    let shopPrivateIcon:String
    let shopPrivateName:String
    let shopBrandedIcon:String
    let shopBrandedName:String
    
    static let shopDefaultIcon:[ShopDefaultIcon] = {
        
        let shopIcon_1 = ShopDefaultIcon(shopPublicIcon: "Img0", shopPublicName: "Super Market", shopPrivateIcon: "icon_privateStore_1", shopPrivateName: "Mobile Store", shopBrandedIcon: "icon_brandedStore_1", shopBrandedName: "Pharmacy")
        let shopIcon_2 = ShopDefaultIcon(shopPublicIcon: "Img1", shopPublicName: "Jewellery world", shopPrivateIcon: "icon_privateStore_2", shopPrivateName: "Chocolate Store", shopBrandedIcon: "icon_brandedStore_2", shopBrandedName: "Clothing store")
        let shopIcon_3 = ShopDefaultIcon(shopPublicIcon: "Img2", shopPublicName: "Medical Store", shopPrivateIcon: "icon_privateStore_3", shopPrivateName: "Kids Store", shopBrandedIcon: "icon_brandedStore_3", shopBrandedName: "Babies & Kids")
        let shopIcon_4 = ShopDefaultIcon(shopPublicIcon: "Img3", shopPublicName: "Phone Shop", shopPrivateIcon: "icon_privateStore_4", shopPrivateName: "Chocolate Corner", shopBrandedIcon: "icon_brandedStore_4", shopBrandedName: "Medical Shop")
        let shopIcon_5 = ShopDefaultIcon(shopPublicIcon: "Img4", shopPublicName: "Phone Shop", shopPrivateIcon: "icon_privateStore_5", shopPrivateName: "Medical Store", shopBrandedIcon: "icon_brandedStore_5", shopBrandedName: "Toy shop")
        let shopIcon_6 = ShopDefaultIcon(shopPublicIcon: "Img5", shopPublicName: "Toy Store", shopPrivateIcon: "icon_privateStore_6", shopPrivateName: "Grocery Store", shopBrandedIcon: "icon_brandedStore_6", shopBrandedName: "Beauty shop")
        
        return [shopIcon_1, shopIcon_2, shopIcon_3, shopIcon_4, shopIcon_5, shopIcon_6]
    }()
}


// MARK: - Shops Categories API Model Class

struct GSHomeShopCategoriesModel: Codable {
    let success: Bool?
    let data: GSHomeShopCategoriesData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSHomeShopCategoriesData: Codable {
    let type: [GSHomeShopCategoriesType]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        type = values.decodeSafely(.type)
    }
}

struct GSHomeShopCategoriesType: Codable {
    let id: Int?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        name = values.decodeSafely(.name)
    }
}


// MARK: - Last Order Feedback Model

struct GSLastOrderFeedbackModel: Codable {
    let success: Bool?
    let data: [GSLastOrderFeedbackData]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSLastOrderFeedbackData: Codable {
    let id, categoryID, storeID, orderID: String?
    let shopName, deliveredAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case categoryID = "category_id"
        case storeID = "store_id"
        case orderID = "order_id"
        case shopName = "shop_name"
        case deliveredAt = "delivered_at"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = values.decodeSafely(.id)
        categoryID = values.decodeSafely(.categoryID)
        storeID = values.decodeSafely(.storeID)
        orderID = values.decodeSafely(.orderID)
        shopName = values.decodeSafely(.shopName)
        deliveredAt = values.decodeSafely(.deliveredAt)
    }
}
