//
//  GSCountyListDataClass.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 18/07/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

typealias GSCountryListDataClass = [GSCountryListDataClassElement]

struct GSCountryListDataClassElement: Codable {
    let flag, name, alpha2Code: String
    let callingCodes: [String]
}
