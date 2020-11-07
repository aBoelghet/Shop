//
//  GSProductsRootClass.swift
//  PickZyShoppingApp
//
//  Created by Purushoth on 12/10/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct GSProductsRootClass : Codable {
    let success : Bool?
    let data : [GSProductsData]?
    
    enum CodingKeys: String, CodingKey {
        
        case success = "success"
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSProductsData : Codable {
    let category : [GSProductsList]?
    
    enum CodingKeys: String, CodingKey {
        
        case category = "category"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        category = values.decodeSafely(.category)
    }
}

struct GSProductsList : Codable {
    let _id : String?
    let stores : [GSProductStores]?
    let productInfo : GSProductInfo?
    
    enum CodingKeys: String, CodingKey {
        
        case _id = "_id"
        case stores = "stores"
        case productInfo = "productInfo"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = values.decodeSafely(._id)
        stores = values.decodeSafely(.stores)
        productInfo = values.decodeSafely(.productInfo)
    }
}

struct GSProductInfo : Codable {
    let manufacturer : String?
    let category : String?
    let unit : String?
    let colour: String?
    let images : [GSProductImage]?
    let product_name : String?
    let upc:String?
    enum CodingKeys: String, CodingKey {
        
        case manufacturer = "manufacturer"
        case category = "category"
        case unit = "unit"
        case images = "images"
        case product_name = "product_name"
        case colour
        case upc
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        manufacturer = values.decodeSafely(.manufacturer)
        category = values.decodeSafely(.category)
        unit = values.decodeSafely(.unit)
        images = values.decodeSafely(.images)
        product_name = values.decodeSafely(.product_name)
        colour = values.decodeSafely(.colour)
        upc = values.decodeSafely(.upc)
    }
}

struct GSProductImage : Codable {
    let keyid : String?
    let name : String?
    let width : Int?
    let height : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case keyid = "keyid"
        case name = "name"
        case width = "width"
        case height = "height"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        keyid = values.decodeSafely(.keyid)
        name = values.decodeSafely(.name)
        width = values.decodeSafely(.width)
        height = values.decodeSafely(.height)
    }
}

struct GSProductStores : Codable {
    let store_id : String?
    let product_details : GSProductDetails?
    
    enum CodingKeys: String, CodingKey {
        
        case store_id = "store_id"
        case product_details = "product_details"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        store_id = values.decodeSafely(.store_id)
        product_details = values.decodeSafely(.product_details)
    }
}

struct GSProductDetails : Codable {
    let id : String?
    let stock : Int?
    let selling_price : Double?
    let offer : Double?
    let tax : Double?
    let offer_selling_price : String?

    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case stock = "stock"
        case selling_price = "selling_price"
        case offer_selling_price = "offer_selling_price"
        case offer = "offer"
        case tax = "tax"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(.id)
        stock = values.decodeSafely(.stock)
        selling_price = values.decodeSafely(.selling_price)
        offer = values.decodeSafely(.offer)
        tax = values.decodeSafely(.tax)
        offer_selling_price = values.decodeSafely(.offer_selling_price)

    }
}

struct GSTotalProductsCountModel: Codable {
    let success: Bool?
    let data: GSTotalProductsCountData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
   
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSTotalProductsCountData: Codable {
    let total: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        total = values.decodeSafely(.total)
    }
}

// MARK: - Frame Types Model

struct GSFrameTypesModel: Codable {
    let success: Bool?
    let data: GSFrameTypesData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
    
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSFrameTypesData: Codable {
    let type: [GSFrameTypeElement]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        type = values.decodeSafely(.type)
    }
}

struct GSFrameTypeElement: Codable {
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
