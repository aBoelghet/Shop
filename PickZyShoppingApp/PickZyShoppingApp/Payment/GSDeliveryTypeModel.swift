//
//  GSDeliveryTypeModel.swift
//  Shopor-dev
//
//  Created by Ratheesh on 13/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct GSDeliveryTypeModel: Codable {
    let success: Bool?
    let data: GSDeliveryTypeData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSDeliveryTypeData: Codable {
    let type: [GSDeliveryType]?
    
    let deliveryType: Int?
    
    enum CodingKeys: String, CodingKey {
        case type
        case deliveryType = "delivery_type"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        type = values.decodeSafely(.type)
        deliveryType = values.decodeSafely(.deliveryType)
    }
}

struct GSDeliveryType: Codable {
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
