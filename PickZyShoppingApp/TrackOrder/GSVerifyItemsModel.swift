//
//  GSVerifyItemsModel.swift
//  Shopor
//
//  Created by Ratheesh on 18/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

// MARK: - Replacement Configuration Model

struct GSVerifyItemsReplacementConfigurationModel: Codable {
    let success: Bool?
    let data: GSVerifyItemsReplacementConfigurationData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSVerifyItemsReplacementConfigurationData: Codable {

    let titles: [String]?
    
    enum CodingKeys: String, CodingKey {
        case titles
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        titles = values.decodeSafely(.titles)
    }
}
