//
//  GSCartModel.swift
//  Shopor-dev
//
//  Created by Ratheesh on 08/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct GSCartListNewModel: Codable {
    let success: Bool?
    let data: [GSCartListNewData]?
}

struct GSCartListNewData: Codable {
    let id: String?
    var stores: [GSCartListNewStore]?
    let productInfo: GSCartListNewProductInfo?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case stores, productInfo
    }
}

struct GSCartListNewProductInfo: Codable {
    let id, productName: String?
    let images: [GSCartListNewImage]?
    let unit:String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case productName = "product_name"
        case images
        case unit
    }
}

struct GSCartListNewImage: Codable {
    let keyid, name: String?
    let width, height: Int?
}

struct GSCartListNewStore: Codable {
    let storeID: String?
    var productDetails: GSCartListNewProductDetails?
    
    enum CodingKeys: String, CodingKey {
        case storeID = "store_id"
        case productDetails = "product_details"
    }
}

struct GSCartListNewProductDetails: Codable {
    
    let id: String?
    let stock, qty: Int?
    let offerPrice, offerSellingPrice: Double?
    let sellingPrice, offer, tax: Double?
    let taxPrice, netPrice: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, stock, qty
        case sellingPrice = "selling_price"
        case offer
        case offerPrice = "offer_price"
        case offerSellingPrice = "offer_selling_price"
        case tax
        case taxPrice = "tax_price"
        case netPrice = "net_price"
    }
}

// MARK: - Stock Availaibility Model

struct GSStockAvailabilityModel: Codable {
    let success: Bool?
    let data: [GSStockAvailabilityData]?
}

struct GSStockAvailabilityData: Codable {
    let storeID: String?
    let products: [GSStockAvailabilityProduct]?
    
    enum CodingKeys: String, CodingKey {
        case storeID = "store_id"
        case products
    }
}

struct GSStockAvailabilityProduct: Codable {
    let id: String?
    let stock, qty, sellingPrice, offer: Int?
    let offerPrice, offerSellingPrice, tax: Int?
    let taxPrice, netPrice: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, stock, qty
        case sellingPrice = "selling_price"
        case offer
        case offerPrice = "offer_price"
        case offerSellingPrice = "offer_selling_price"
        case tax
        case taxPrice = "tax_price"
        case netPrice = "net_price"
    }
}


// MARK: - Quantity Model

struct GSCartListQuantityModel: Codable {
    let success: Bool?
    let data: GSCartListNewData?
}

// MARK: - Check Or Uncheck Cart Model

struct GSCommonSuccesWithMessageModel: Codable {
    let success: Bool?
    let message: String?
}


// MARK: - View Billing Model


struct GSViewBillingModel: Codable {
    let success: Bool
    let data: GSViewBillingData
}

struct GSViewBillingData: Codable {
    let stores: [GSViewBillingStore]
    let prices: GSViewBillingPrices
}

struct GSViewBillingPrices: Codable {
    let grossPrice, taxes: Double
    let delivery: Int
    let netPrice: Double
    
    enum CodingKeys: String, CodingKey {
        case grossPrice = "gross_price"
        case taxes, delivery
        case netPrice = "net_price"
    }
}

struct GSViewBillingStore: Codable {
    let id: String
    let products: [GSViewBillingProduct]
    let shop: GSViewBillingShop
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case products, shop
    }
}

struct GSViewBillingProduct: Codable {
    let id: String
    let qty: Int
    let sellingPrice, grossPrice, taxPrice, netPrice: Double
    let productName: String
    
    enum CodingKeys: String, CodingKey {
        case id, qty
        case sellingPrice = "selling_price"
        case grossPrice = "gross_price"
        case taxPrice = "tax_price"
        case netPrice = "net_price"
        case productName = "product_name"
    }
}

struct GSViewBillingShop: Codable {
    let delivery: GSViewBillingDelivery?
}

struct GSViewBillingDelivery: Codable {
    let local: GSViewBillingLocal?
    let other: GSViewBillingOther?
}

struct GSViewBillingLocal: Codable {
    let radius: Int?
    let type: [Int]?
    let isCod: Bool?
    let fee: Int?
    let from, to: String?
    
    enum CodingKeys: String, CodingKey {
        case radius, type
        case isCod = "is_cod"
        case fee, from, to
    }
}

struct GSViewBillingOther: Codable {
    let isEnabled, isLocked: Bool?
    let type: [Int]?
    let isCod: Bool?
    let fee: Int?
    let from, to: String?
    
    enum CodingKeys: String, CodingKey {
        case isEnabled = "is_enabled"
        case isLocked = "is_locked"
        case type
        case isCod = "is_cod"
        case fee, from, to
    }
}

//-- Need to delete later
struct GSCartListModel: Codable {
    let success: Bool?
    let data: [GSCartListStoreData]?
}

struct GSCartListStoreData: Codable {
    let id: String?
    let products: [GSCartListProduct]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case products
    }
}

struct GSCartListProduct: Codable {
    let id: String?
    let qty, stock: Int?
    let sellingPrice, offer: Double?
    let tax: Double?
    let productName: String?
    let images: [GSCartListImage]?
    
    enum CodingKeys: String, CodingKey {
        case id, qty, stock
        case sellingPrice = "selling_price"
        case offer, tax
        case productName = "product_name"
        case images
    }
}

struct GSCartListImage: Codable {
    let keyid: GSCartListKeyid?
    let name: String?
    let width, height: Int?
}

enum GSCartListKeyid: String, Codable {
    case image1 = "image1"
    case image2 = "image2"
    case image3 = "image3"
    case image4 = "image4"
    case image5 = "image5"
    case image6 = "image6"
}
