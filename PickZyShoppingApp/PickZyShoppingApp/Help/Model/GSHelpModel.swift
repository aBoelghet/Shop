//
//  GSHelpModel.swift
//  Shopor
//
//  Created by Ratheesh on 10/04/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct GSHelpListModel: Codable {
    let success: Bool?
    let data: GSHelpListData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSHelpListData: Codable {
    let titles: [GSHelpListDataTitle]?
    let order: GSHelpListDataOrder?
    let shop, help: GSHelpListDataHelp?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        titles = values.decodeSafely(.titles)
        order = values.decodeSafely(.order)
        shop = values.decodeSafely(.shop)
        help = values.decodeSafely(.help)
    }
}

struct GSHelpListDataHelp: Codable {
    let dialingCode: Int?
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

struct GSHelpListDataOrder: Codable {
    let lastBuzz: String?
    
    enum CodingKeys: String, CodingKey {
        case lastBuzz = "last_buzz"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        lastBuzz = values.decodeSafely(.lastBuzz)
    }
}

struct GSHelpListDataTitle: Codable {
    let id, displayName: String?
    let buzzUp: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case displayName = "display_name"
        case buzzUp = "buzz_up"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        displayName = values.decodeSafely(.displayName)
        buzzUp = values.decodeSafely(.buzzUp)
    }
}


// MARK: - Content Model

struct GSHelpContentModel: Codable {
    let success: Bool?
    let data: GSHelpContentData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSHelpContentData: Codable {
    let content: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        content = values.decodeSafely(.content)
    }
}
