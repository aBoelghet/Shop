//
//  GSPaymentConstants.swift
//  Shopor-dev
//
//  Created by Ratheesh on 03/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct GSPaymentConstants {

    static let DefaultVerifyAmount = "1.0"
    static let GATEWAY_KEY  = "gtKFFx"
    static let GATEWAY_surl = "https://guarded-atoll-92892.herokuapp.com/"
    static let GATEWAY_furl = "https://guarded-atoll-92892.herokuapp.com/"
    
    static let SAVED_CARD_METHOD = "SAVED_CARD_METHOD"
}

enum PaymentMethod : Int {
    case Cash = 1
    case SavedCard
    case AddPaymentMethod
    case Netbanking
    case Upi
    case wallet
    case ShoporPoints
}

struct GSSavePaymentMethod: Codable {
    var payMethod: Int? = -1
    var cardNumber: String?
    var cardType: String?
    var cardExpMonth: String?
    var cardExpYear: String?
    var cardToken: String?
    var cardBin: String?
    var cardName: String?
    var cardBrand: String?
    var bankCode: String?

    enum CodingKeys: String, CodingKey {
        case payMethod
        case cardNumber = "cardNumber"
        case cardType = "cardType"
        case cardExpMonth = "cardExpMonth"
        case cardExpYear = "cardExpYear"
        case cardToken = "cardToken"
        case cardBin = "cardBin"
        case cardBrand = "cardBrand"
        case bankCode
    }
}
