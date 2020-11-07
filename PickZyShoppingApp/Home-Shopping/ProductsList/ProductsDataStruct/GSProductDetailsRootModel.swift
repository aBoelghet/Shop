//
//  GSProductDetailsRootModel.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 17/10/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct GSProductDetailsRootModel : Codable {
    let success : Bool?
    let data : GSProductDetailsDataModel?

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

struct GSProductDetailsDataModel : Codable {
    let _id : String?
    let stores : [GSProductDetailsStoreModel]?
//    let productInfo : []?

    enum CodingKeys: String, CodingKey {

        case _id = "_id"
        case stores = "stores"
//        case productInfo
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = values.decodeSafely(._id)
        stores = values.decodeSafely(.stores)
    }
}

struct GSProductDetailsStoreModel : Codable {
    let store_id : String?
    let product_details : GSProductStoreDetailsModel?

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

struct GSProductStoreDetailsModel : Codable {
    let id : String?
    let stock : Int?
    let selling_price : Int?
    let offer : Int?
    let tax : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case stock = "stock"
        case selling_price = "selling_price"
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
    }
}
