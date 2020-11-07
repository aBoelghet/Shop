//
//  GSHomeRootClass.swift
//  PickZyShoppingApp
//
//  Created by Purushoth on 11/09/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct GSSuccessClass : Codable {
    let success : Bool?
    let message : String?
    
    enum CodingKeys: String, CodingKey {
        
        case success = "success"
        case message = "message"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        message = values.decodeSafely(.message)
    }
}

struct GSHomeRootClass : Codable {
    let success : Bool?
    let data : GSHomeDataClass?
    
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

struct GSHomeDataClass : Codable {
    let count : Int?
    let category : [GSHomeDocsClass]?
    enum CodingKeys: String, CodingKey {
        
        case count = "count"
        case category = "category"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        count = values.decodeSafely(.count)
        category = values.decodeSafely(.category)
    }
}

struct GSHomeDocsClass : Codable {
    let _id : String?
    let display_name : String?
    let is_open: Bool?
    let image : String?
    let stores : [String]?
    let storeRating: StoreRating?
    let deliveryLocalType: [Int]?
    let deliveryLocalFrom, deliveryLocalTo: String?
    let deliveryLocalDuration: Int?
    let deliveryLocalDurationUnit: String?
    let deliveryOtherDuration: Int?
    let deliveryOtherDurationUnit: String?
    let deliveryOtherEnabled: Bool?
    let features: Features?
    let cartType, frameType: Int?
    let templateKeys : [GSProductDetailsKeyTemplate]?
    let distance : Double?
    let isCod: Bool?
    let codLimit: Double?
    let isCodLimitType: String?
    
    enum CodingKeys: String, CodingKey {
        
        case _id = "_id"
        case display_name = "display_name"
        case is_open = "is_open"
        case image = "image"
        case stores = "stores"
        case deliveryLocalType = "delivery_local_type"
        case deliveryLocalFrom = "delivery_local_from"
        case deliveryLocalTo = "delivery_local_to"
        case deliveryLocalDuration = "delivery_local_duration"
        case deliveryLocalDurationUnit = "delivery_local_duration_unit"
        case deliveryOtherDuration = "delivery_other_duration"
        case deliveryOtherDurationUnit = "delivery_other_duration_unit"
        case deliveryOtherEnabled = "delivery_other_enabled"
        case templateKeys = "template"
        case distance = "distance"
        case cartType = "cart_type"
        case frameType = "frame_type"
        case isCod = "is_cod"
        case codLimit = "is_cod_limit"
        case isCodLimitType = "is_cod_limit_type"
        case features
        case storeRating = "store_rating"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = values.decodeSafely(._id)
        display_name = values.decodeSafely(.display_name)
        is_open = values.decodeSafely(.is_open)
        image = values.decodeSafely(.image)
        stores = values.decodeSafely(.stores)
        deliveryLocalType = values.decodeSafely(.deliveryLocalType)
        deliveryLocalFrom = values.decodeSafely(.deliveryLocalFrom)
        deliveryLocalTo = values.decodeSafely(.deliveryLocalTo)
        deliveryLocalDuration = values.decodeSafely(.deliveryLocalDuration)
        deliveryLocalDurationUnit = values.decodeSafely(.deliveryLocalDurationUnit)
        deliveryOtherDuration = values.decodeSafely(.deliveryOtherDuration)
        deliveryOtherDurationUnit = values.decodeSafely(.deliveryOtherDurationUnit)
        deliveryOtherEnabled = values.decodeSafely(.deliveryOtherEnabled)
        features = values.decodeSafely(.features)
        templateKeys = values.decodeSafely(.templateKeys)
        distance = values.decodeSafely(.distance)
        cartType = values.decodeSafely(.cartType)
        frameType = values.decodeSafely(.frameType)
        isCod = values.decodeSafely(.isCod)
        codLimit = values.decodeSafely(.codLimit)
        isCodLimitType = values.decodeSafely(.isCodLimitType)
        storeRating = values.decodeSafely(.storeRating)
    }
}

// MARK: - StoreRating
struct StoreRating: Codable {
    let avgRating: Double?
    let totalRatings, usersCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case avgRating = "avg_rating"
        case totalRatings = "total_ratings"
        case usersCount = "users_count"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        avgRating = values.decodeSafely(.avgRating)
        totalRatings = values.decodeSafely(.totalRatings)
        usersCount = values.decodeSafely(.usersCount)
    }
}

struct Features: Codable {
    let notes, upload: Bool?
    let enableSubscription: Bool?

    enum CodingKeys: String, CodingKey {
        
        case enableSubscription = "enable_subscription"
        case notes 
        case upload
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        enableSubscription = values.decodeSafely(.enableSubscription)
        notes = values.decodeSafely(.notes)
        upload = values.decodeSafely(.upload)
    }
}

struct GSProductDetailsKeyTemplate : Codable {
    let key_name : String?
    let display_name : String?
    let format : Int?
    let tooltipID: Int?
    
    enum CodingKeys: String, CodingKey {
        
        case key_name = "key_name"
        case display_name = "display_name"
        case format = "format"
        case tooltipID = "tooltip_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key_name = values.decodeSafely(.key_name)
        display_name = values.decodeSafely(.display_name)
        format = values.decodeSafely(.format)
        tooltipID = values.decodeSafely(.tooltipID)
    }
}



