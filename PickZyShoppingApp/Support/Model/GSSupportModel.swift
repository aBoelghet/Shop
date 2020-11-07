//
//  GSSupportModel.swift
//  Shopor
//
//  Created by Ratheesh on 10/04/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct GSSupportListModel: Codable {
    let success: Bool?
    let data: GSSupportListData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSSupportListData: Codable {
    let titles: [GSSupportListDataTitle]?
    let emailID: String?
    let supportAvailableTime: String?
    let help: GSSupportListDataHelp?
    
    enum CodingKeys: String, CodingKey {
        case titles
        case emailID = "email_id"
        case supportAvailableTime = "support_available_time"
        case help
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        titles = values.decodeSafely(.titles)
        emailID = values.decodeSafely(.emailID)
        supportAvailableTime = values.decodeSafely(.supportAvailableTime)
        help = values.decodeSafely(.help)
    }
}

struct GSSupportListDataHelp: Codable {
    let dialingCode: Int?
    let number: String?
    
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

struct GSSupportListDataTitle: Codable {
    let id, displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case displayName = "display_name"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        displayName = values.decodeSafely(.displayName)
    }
}


// MARK: - Content Model

struct GSSupportContentModel: Codable {
    let success: Bool?
    let data: GSSupportContentData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSSupportContentData: Codable {
    let content: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        content = values.decodeSafely(.content)
    }
}
