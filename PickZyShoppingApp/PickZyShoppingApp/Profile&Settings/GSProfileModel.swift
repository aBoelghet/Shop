//
//  GSProfileModel.swift
//  Shopor
//
//  Created by Ratheesh on 28/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

// MARK: - View Profile Model

struct GSViewProfileModel: Codable {
    let success: Bool?
    let data: GSViewProfileData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSViewProfileData: Codable {
    let firstName, lastName: String?
    let mobile: GSViewProfileMobile?
    let email: GSViewProfileEmail?
    let address: [GSViewProfileAddressObject]?
    let image: String?
    let id: String?
    let setting: GSViewProfileSetting?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case mobile
        case email
        case address, image
        case id = "_id"
        case setting
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        firstName = values.decodeSafely(.firstName)
        lastName = values.decodeSafely(.lastName)
        mobile = values.decodeSafely(.mobile)
        email = values.decodeSafely(.email)
        address = values.decodeSafely(.address)
        image = values.decodeSafely(.image)
        id = values.decodeSafely(.id)
        setting = values.decodeSafely(.setting)
    }
}

struct GSViewProfileEmail: Codable {
    let id: String?
    let isVerified: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case isVerified = "is_verified"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        isVerified = values.decodeSafely(.isVerified)
    }
}

struct GSViewProfileSetting: Codable {
    let preferences: GSViewProfileSettingPreferences?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        preferences = values.decodeSafely(.preferences)
    }
}

struct GSViewProfileSettingPreferences: Codable {
    let email, pns, sms: Bool?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        email = values.decodeSafely(.email)
        pns = values.decodeSafely(.pns)
        sms = values.decodeSafely(.sms)
    }
}

struct GSViewProfileAddressObject: Codable {
    let location: GSViewProfileLocation?
    let address: GSViewProfileAddress?
    let isDefault: Bool?
    let type: String?
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case location, address
        case isDefault = "is_default"
        case type, id
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        location = values.decodeSafely(.location)
        address = values.decodeSafely(.address)
        isDefault = values.decodeSafely(.isDefault)
        type = values.decodeSafely(.type)
        id = values.decodeSafely(.id)
    }
    
    init(location: GSViewProfileLocation?, address: GSViewProfileAddress?, isDefault: Bool?, type: String?, id: String?) {
        self.location = location
        self.address = address
        self.isDefault = isDefault
        self.type = type
        self.id = id
    }
}

struct GSViewProfileAddress: Codable {
    let street, area: String?
    let landmark: String?
    let zipcode: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        street = values.decodeSafely(.street)
        area = values.decodeSafely(.area)
        landmark = values.decodeSafely(.landmark)
        zipcode = values.decodeSafely(.zipcode)
    }
    
    init(street:String?, area:String?, landmark:String?, zipcode:Int?) {
        self.street = street
        self.area = area
        self.landmark = landmark
        self.zipcode = zipcode
    }
}

struct GSViewProfileLocation: Codable {
    let type: String?
    let coordinates: [Double]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        type = values.decodeSafely(.type)
        coordinates = values.decodeSafely(.coordinates)
    }
    
    init(type:String?, coordinates: [Double]?) {
        self.type = type
        self.coordinates = coordinates
    }
}

struct GSViewProfileMobile: Codable {
    let dialingCode : Int?
    let number: Int64?
    
    enum CodingKeys: String, CodingKey {
        case dialingCode = "dialing_code"
        case number
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        dialingCode = values.decodeSafely(.dialingCode)
        number = values.decodeSafely(.number)
    }
}


// MARK: - Saving Address Model

struct GSAddAddressModel: Codable {
    let success: Bool?
    let message, id: String?
    
    enum CodingKeys: String, CodingKey {
        case success, message
        case id = "_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        message = values.decodeSafely(.message)
        id = values.decodeSafely(.id)
    }
}
