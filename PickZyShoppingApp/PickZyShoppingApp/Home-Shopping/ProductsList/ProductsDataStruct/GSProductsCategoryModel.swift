//
//  GSProductsCategoryModel.swift
//  PickZyShoppingApp
//
//  Created by Purushoth on 12/10/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct GSProductsCategoryRootModel : Codable {
    let success : Bool?
    let data : GSProductsCategoryDataModel?
    
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

struct GSProductsCategoryDataModel : Codable {
    let category : [String]?
    let offerProductCount: Int?
    
    enum CodingKeys: String, CodingKey {
        
        case category = "category"
        case offerProductCount = "offer_prod_count"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        category = values.decodeSafely(.category)
        offerProductCount = values.decodeSafely(.offerProductCount)
    }
}

