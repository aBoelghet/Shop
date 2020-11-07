//
//  GSPlaceOrderResponseModel.swift
//  Shopor-dev
//
//  Created by Ratheesh on 05/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct GSPlaceOrderResponseModel: Codable {
    let success: Bool?
    let data: GSPlaceOrderResponseData?
    let error: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = values.decodeSafelyIfPresent(.success)
        data = values.decodeSafelyIfPresent(.data)
        error = values.decodeSafelyIfPresent(.error)
    }
}

struct GSPlaceOrderResponseData: Codable {
    let shops: [GSPlaceOrderResponseShop]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        shops = values.decodeSafelyIfPresent(.shops)
    }
}

struct GSPlaceOrderResponseShop: Codable {
    let id, displayName: String?
    let address: GSPlaceOrderResponseAddress?
    let mobile: GSPlaceOrderResponseMobile?
    let delivery: GSPlaceOrderResponseDelivery?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case displayName = "display_name"
        case address, mobile, delivery
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafelyIfPresent(.id)
        displayName = values.decodeSafelyIfPresent(.displayName)
        address = values.decodeSafelyIfPresent(.address)
        mobile = values.decodeSafelyIfPresent(.mobile)
        delivery = values.decodeSafelyIfPresent(.delivery)
    }
}

struct GSPlaceOrderResponseAddress: Codable {
    let location: GSPlaceOrderResponseLocation?
    let street, city, state, country, zipcode: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        location = values.decodeSafelyIfPresent(.location)
        street = values.decodeSafelyIfPresent(.street)
        city = values.decodeSafelyIfPresent(.city)
        state = values.decodeSafelyIfPresent(.state)
        country = values.decodeSafelyIfPresent(.country)
        zipcode = values.decodeSafelyIfPresent(.zipcode)
    }
}

struct GSPlaceOrderResponseLocation: Codable {
    let type: String?
    let coordinates: [Double]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        type = values.decodeSafelyIfPresent(.type)
        coordinates = values.decodeSafelyIfPresent(.coordinates)
    }
}

struct GSPlaceOrderResponseDelivery: Codable {
    let local: GSPlaceOrderResponseLocal?
    let other: GSPlaceOrderResponseOther?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        local = values.decodeSafelyIfPresent(.local)
        other = values.decodeSafelyIfPresent(.other)
    }
}

struct GSPlaceOrderResponseLocal: Codable {
    let radius, type: Int?
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
     
        radius = values.decodeSafelyIfPresent(.radius)
        type = values.decodeSafelyIfPresent(.type)
        isCod = values.decodeSafelyIfPresent(.isCod)
        fee = values.decodeSafelyIfPresent(.fee)
        from = values.decodeSafelyIfPresent(.from)
        to = values.decodeSafelyIfPresent(.to)
    }
}

struct GSPlaceOrderResponseOther: Codable {
    let isEnabled, isLocked: Bool?
    let type: Int?
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
     
        isEnabled = values.decodeSafelyIfPresent(.isEnabled)
        isLocked = values.decodeSafelyIfPresent(.isLocked)
        type = values.decodeSafelyIfPresent(.type)
        isCod = values.decodeSafelyIfPresent(.isCod)
        fee = values.decodeSafelyIfPresent(.fee)
        from = values.decodeSafelyIfPresent(.from)
        to = values.decodeSafelyIfPresent(.to)
    }
}

struct GSPlaceOrderResponseMobile: Codable {
    
    let primary, secondary: GSPlaceOrderResponseMobileObject?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        primary = values.decodeSafely(.primary)
        secondary = values.decodeSafely(.secondary)
    }
    
//    let dialingCode: Int?
//    let number: GSPlaceOrderResponseNumber?
//    let isPrimary: Bool?
//    let code: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case dialingCode = "dialing_code"
//        case number
//        case isPrimary = "is_primary"
//        case code
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        dialingCode = values.decodeSafelyIfPresent(.dialingCode)
//        number = values.decodeSafelyIfPresent(.number)
//        isPrimary = values.decodeSafelyIfPresent(.isPrimary)
//        code = values.decodeSafelyIfPresent(.code)
//    }
}

struct GSPlaceOrderResponseMobileObject: Codable {
    let dialingCode, otp: Int?
    let number: Int64?
    let isVerified: Bool?
    
    enum CodingKeys: String, CodingKey {
        case dialingCode = "dialing_code"
        case number, otp
        case isVerified = "is_verified"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        dialingCode = values.decodeSafely(.dialingCode)
        number = values.decodeSafely(.number)
        otp = values.decodeSafely(.otp)
        isVerified = values.decodeSafely(.isVerified)
    }
}


enum GSPlaceOrderResponseNumber: Codable {
    case integer(Int64)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int64.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(GSPlaceOrderResponseNumber.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Number"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
