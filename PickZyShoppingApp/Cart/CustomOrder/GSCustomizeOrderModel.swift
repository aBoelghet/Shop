//
//  GSCustomizeOrderModel.swift
//  Shopor-dev
//
//  Created by Ratheesh on 15/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct GSCustomizeOrderModel: Codable {
    let success: Bool?
    let data: [GSCustomizeOrderData]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSCustomizeOrderData: Codable {
    let id: String?
    let products: [GSCustomizeOrderProduct]?
    let shop: GSCustomizeOrderStore?
    let prices: GSCustomizeOrderPrices?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case products, shop, prices
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        products = values.decodeSafely(.products)
        shop = values.decodeSafely(.shop)
        prices = values.decodeSafely(.prices)
    }
}

struct GSCustomizeOrderPrices: Codable {
    
    let grossPrice, taxes: Double?
    let delivery: Int?
    let netPrice: Double?
    
    enum CodingKeys: String, CodingKey {
        case grossPrice = "gross_price"
        case taxes, delivery
        case netPrice = "net_price"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        grossPrice = values.decodeSafely(.grossPrice)
        taxes = values.decodeSafely(.taxes)
        delivery = values.decodeSafely(.delivery)
        netPrice = values.decodeSafely(.netPrice)
    }
    
    init(grossPrice: Double?, taxes: Double?, delivery: Int?, netPrice: Double?) {
        self.grossPrice = grossPrice
        self.taxes = taxes
        self.delivery = delivery
        self.netPrice = netPrice
    }
}

struct GSCustomizeOrderProduct: Codable {
    let id: String?
    let qty: Int?
    let sellingPrice, grossPrice, taxPrice, netPrice: Double?
    let productName: String?
    let images: [GSCustomizeOrderImage]?
    
    enum CodingKeys: String, CodingKey {
        case id, qty
        case sellingPrice = "selling_price"
        case grossPrice = "gross_price"
        case taxPrice = "tax_price"
        case netPrice = "net_price"
        case productName = "product_name"
        case images
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = values.decodeSafely(.id)
        qty = values.decodeSafely(.qty)
        sellingPrice = values.decodeSafely(.sellingPrice)
        grossPrice = values.decodeSafely(.grossPrice)
        taxPrice = values.decodeSafely(.taxPrice)
        netPrice = values.decodeSafely(.netPrice)
        productName = values.decodeSafely(.productName)
        images = values.decodeSafely(.images)
    }
    
    init(id:String?, qty: Int?, sellingPrice: Double?, grossPrice: Double?, taxPrice: Double?, netPrice: Double?, productName: String?, images: [GSCustomizeOrderImage]?) {
        self.id = id
        self.qty = qty
        self.sellingPrice = sellingPrice
        self.grossPrice = grossPrice
        self.taxPrice = taxPrice
        self.netPrice = netPrice
        self.productName = productName
        self.images = images
    }
}

struct GSCustomizeOrderImage: Codable {
    let keyid, name: String?
    let width, height: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        keyid = values.decodeSafely(.keyid)
        name = values.decodeSafely(.name)
        width = values.decodeSafely(.width)
        height = values.decodeSafely(.height)
    }
}

struct GSCustomizeOrderStore: Codable {
    
    let displayName: String?
    let delivery: GSCustomizeOrderDelivery?
    let rating: Double?
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case delivery
        case rating
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        displayName = values.decodeSafely(.displayName)
        delivery = values.decodeSafely(.delivery)
        rating = values.decodeSafely(.rating)
    }
}

struct GSCustomizeOrderDelivery: Codable {
    let local: GSCustomizeOrderLocalLocations?
    let other: GSCustomizeOrderOtherLocations?
}

struct GSCustomizeOrderLocalLocations: Codable {
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
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        radius = values.decodeSafely(.radius)
        type = values.decodeSafely(.type)
        isCod = values.decodeSafely(.isCod)
        fee = values.decodeSafely(.fee)
        from = values.decodeSafely(.from)
        to = values.decodeSafely(.to)
    }
}

struct GSCustomizeOrderOtherLocations: Codable {
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
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        isEnabled = values.decodeSafely(.isEnabled)
        isLocked = values.decodeSafely(.isLocked)
        type = values.decodeSafely(.type)
        isCod = values.decodeSafely(.isCod)
        fee = values.decodeSafely(.fee)
        from = values.decodeSafely(.from)
        to = values.decodeSafely(.to)
    }
}


// MARK: - Write Custom Cart Model

struct GSCustomizeOrderWriteCartModel: Codable {
    let success: Bool?
    let message: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        message = values.decodeSafely(.message)
    }
}
