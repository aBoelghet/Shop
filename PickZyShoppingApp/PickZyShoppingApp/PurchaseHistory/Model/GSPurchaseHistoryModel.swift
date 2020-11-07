//
//  GSPurchaseHistoryModel.swift
//  Shopor
//
//  Created by Ratheesh on 08/01/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

// MARK: - New Models for Purchase History

struct New_GSPurchasedListModel: Codable {
    let success: Bool?
    let data: [New_GSPurchasedListData]?
}

struct New_GSPurchasedListData: Codable {
    let id, date: String?
    let orders: [New_GSPurchasedListDataOrder]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case date, orders
    }
}

struct New_GSPurchasedListDataOrder: Codable {
    let id, categoryID, storeID, orderID: String?
    let status: Int?
    let shop: New_GSPurchasedListDataOrderedShop?
    let products: Int?
    let offer: SATrackOrderOfferObject?
    let amount: Double?
    let date: String?
    let isEscalatedProduct: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case categoryID = "category_id"
        case storeID = "store_id"
        case orderID = "order_id"
        case status, shop, products, amount, date
        case offer
        case isEscalatedProduct = "is_escalated_order"
    }
}

struct New_GSPurchasedListDataOrderedShop: Codable {
    let address: String?
    let mobile: New_GSPurchasedListDataOrderedShopMobile?
    let replacement: String?
}

struct New_GSPurchasedListDataOrderedShopMobile: Codable {
    let primary, secondary: New_GSPurchasedListShopMobileObject?
}

struct New_GSPurchasedListShopMobileObject: Codable {
    let dialingCode, otp: Int?
    let number: Int64?
    let isVerified: Bool?
    
    enum CodingKeys: String, CodingKey {
        case dialingCode = "dialing_code"
        case number, otp
        case isVerified = "is_verified"
    }
}


// MARK: - New Model For Purchase History product list

struct GSPurchaseHistoryProductListModel: Codable {
    let success: Bool?
//    let data: GSPurchaseHistoryProductListData?
    let data: GSTrackOrderProductListData?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

//struct GSPurchaseHistoryProductListData: Codable {
//    let shop: GSPurchaseHistoryProductListDataShop?
//    let order: GSPurchaseHistoryProductListDataOrder?
//    let products: [GSPurchaseHistoryProductListDataProduct]?
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        shop = values.decodeSafely(.shop)
//        order = values.decodeSafely(.order)
//        products = values.decodeSafely(.products)
//    }
//}
//
//struct GSPurchaseHistoryProductListDataOrder: Codable {
//    let id: String?
//    let status: Int?
//    let prices: GSPurchaseHistoryProductListDataOrderPrices?
//    let ordered, accepted, readyToShip, shipping: String?
//    let delivered, verified: String?
//    let cancelled, rejected, denied: String?
//    let isEscalatedProduct: Bool?
//    let orderId: String?
//    let offer: SATrackOrderOfferObject?
//
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case status, prices, ordered, accepted
//        case readyToShip = "ready_to_ship"
//        case shipping, delivered, verified, cancelled, rejected, denied
//        case isEscalatedProduct = "is_escalated_order"
//        case orderId = "order_id"
//        case offer
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        id = values.decodeSafely(.id)
//        status = values.decodeSafely(.status)
//        prices = values.decodeSafely(.prices)
//        ordered = values.decodeSafely(.ordered)
//        accepted = values.decodeSafely(.accepted)
//        readyToShip = values.decodeSafely(.readyToShip)
//        shipping = values.decodeSafely(.shipping)
//        delivered = values.decodeSafely(.delivered)
//        verified = values.decodeSafely(.verified)
//        cancelled = values.decodeSafely(.cancelled)
//        rejected = values.decodeSafely(.rejected)
//        denied = values.decodeSafely(.denied)
//        isEscalatedProduct = values.decodeSafely(.isEscalatedProduct)
//        orderId = values.decodeSafely(.orderId)
//        offer = values.decodeSafely(.offer)
//    }
//}
//
//struct GSPurchaseHistoryProductListDataOrderPrices: Codable {
//    let grossPrice, taxes, netPrice, serviceFee, delivery, paymentFee: Double?
//
//    enum CodingKeys: String, CodingKey {
//        case grossPrice = "gross_price"
//        case taxes
//        case netPrice = "net_price"
//        case serviceFee = "service_fee"
//        case delivery
//        case paymentFee = "payment_fee"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        grossPrice = values.decodeSafely(.grossPrice)
//        taxes = values.decodeSafely(.taxes)
//        netPrice = values.decodeSafely(.netPrice)
//        serviceFee = values.decodeSafely(.serviceFee)
//        delivery = values.decodeSafely(.delivery)
//        paymentFee = values.decodeSafely(.paymentFee)
//    }
//}
//
//struct GSPurchaseHistoryProductListDataProduct: Codable {
//
//    let id: String?
//    let qty: Int?
//    let escalatedQty:Int?
//    let netPrice: Double?
//    let productName, unit: String?
//    let image: GSPurchaseHistoryProductListDataProductImage?
//    let mfdExp: GSPurchaseHistoryProductListProductDates?
//    let verifyStatus:Int?
//    let notifications:Bool?
//    let replacement:String?
//    let escalationStatus:Int?
//
//    enum CodingKeys: String, CodingKey {
//        case id, qty
//        case netPrice = "net_price"
//        case productName = "product_name"
//        case unit, image
//        case mfdExp = "mfd_exp"
//        case verifyStatus = "verify_status"
//        case notifications
//        case escalatedQty = "escalated_qty"
//        case replacement
//        case escalationStatus = "escalation_status"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        id = values.decodeSafely(.id)
//        qty = values.decodeSafely(.qty)
//        escalatedQty = values.decodeSafely(.escalatedQty)
//        netPrice = values.decodeSafely(.netPrice)
//        productName = values.decodeSafely(.productName)
//        unit = values.decodeSafely(.unit)
//        image = values.decodeSafely(.image)
//        mfdExp = values.decodeSafely(.mfdExp)
//        verifyStatus = values.decodeSafely(.verifyStatus)
//        notifications = values.decodeSafely(.notifications)
//        replacement = values.decodeSafely(.replacement)
//        escalationStatus = values.decodeSafely(.escalationStatus)
//    }
//}
//
//struct GSPurchaseHistoryProductListProductDates: Codable {
//    let type: Int?
//    let dates: [GSPurchaseHistoryProductListProductDateObject]?
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        type = values.decodeSafely(.type)
//        dates = values.decodeSafely(.dates)
//    }
//}
//
//struct GSPurchaseHistoryProductListProductDateObject: Codable {
//    let mfgDate, expDate: String?
//
//    enum CodingKeys: String, CodingKey {
//        case mfgDate = "mfg_date"
//        case expDate = "exp_date"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        mfgDate = values.decodeSafely(.mfgDate)
//        expDate = values.decodeSafely(.expDate)
//    }
//}
//
//struct GSPurchaseHistoryProductListDataProductImage: Codable {
//    let keyid, name: String?
//    let width, height: Int?
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        keyid = values.decodeSafely(.keyid)
//        name = values.decodeSafely(.name)
//        width = values.decodeSafely(.width)
//        height = values.decodeSafely(.height)
//    }
//}
//
//struct GSPurchaseHistoryProductListDataShop: Codable {
//    let name: String?
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        name = values.decodeSafely(.name)
//    }
//}


