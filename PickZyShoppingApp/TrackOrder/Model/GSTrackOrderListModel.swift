//
//  GSTrackOrderListModel.swift
//  Shopor
//
//  Created by Ratheesh on 17/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation


// MARK: - New Models

struct New_GSTrackOrderListModel: Codable {
    let success: Bool?
    let data: [New_GSTrackOrderListData]?
}

struct New_GSTrackOrderListData: Codable {
    let id, date: String?
    let orders: [New_GSTrackOrderListOrder]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case date, orders
    }
}

struct New_GSTrackOrderListOrder: Codable {
    let id, categoryID, storeID, orderID: String?
    let status: Int?
    let shop: New_GSTrackOrderListOrderShop?
    let products: Int?
    let expectedTime: GSTrackOrderExpectedTime?
    let amount: Double?
    let offer: SATrackOrderOfferObject?
    let date: String?
    let isEscalatedProduct: Bool?
    let cancelSelectedStage: Int?
    let paymentType: Int?
    let isBayfayCash: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case categoryID = "category_id"
        case storeID = "store_id"
        case orderID = "order_id"
        case status, shop, products, amount, date
        case offer
        case expectedTime = "expected_time"
        case isEscalatedProduct = "is_escalated_order"
        case cancelSelectedStage = "cancel_selected_stage"
        case paymentType = "payment_type"
        case isBayfayCash = "is_bayfay_cash"
    }
}

// MARK: - ExpectedTime
struct GSTrackOrderExpectedTime: Codable {
    let at: String?
}

// MARK: - Offer
struct SATrackOrderOfferObject: Codable {
    let isBayfayOffer, isOfferApplied: Bool?
    let offerAmount: Double?
    let offerType: Int?
    let promoID: String?
    let promoCode: String?
    
    enum CodingKeys: String, CodingKey {
        case isBayfayOffer = "is_bayfay_offer"
        case isOfferApplied = "is_offer_applied"
        case offerAmount
        case offerType = "offer_type"
        case promoID = "promo_id"
        case promoCode = "promo_code"
    }
}

struct New_GSTrackOrderListOrderShop: Codable {
    let address: String?
    let mobile: New_GSTrackOrderListOrderShopMobile?
    let location: GSOrderTrackViewOrderLocation?
}

struct New_GSTrackOrderListOrderShopMobile: Codable {
    let primary, secondary: New_GSTrackOrderListOrderShopMobileObject?
}

struct New_GSTrackOrderListOrderShopMobileObject: Codable {
    let dialingCode, otp: Int?
    let number: Int64?
    let isVerified: Bool?
    
    enum CodingKeys: String, CodingKey {
        case dialingCode = "dialing_code"
        case number, otp
        case isVerified = "is_verified"
    }
}

// MARK: - New Model For Track order product list

struct GSTrackOrderProductListModel: Codable {
    let success: Bool?
    let data: GSTrackOrderProductListData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSTrackOrderProductListData: Codable {
    let shop: GSTrackOrderProductListShop?
    let order: GSTrackOrderProductListOrder?
    let products: [GSTrackOrderProductListProduct]?
    let discountAmount: Double?
    
    enum CodingKeys: String, CodingKey {

        case shop, order, products
        case discountAmount = "discount_amount"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        shop = values.decodeSafely(.shop)
        order = values.decodeSafely(.order)
        products = values.decodeSafely(.products)
        discountAmount = values.decodeSafely(.discountAmount)
    }
}

struct GSTrackOrderProductListOrder: Codable {
    let id: String?
    let offer: SATrackOrderOfferObject?
    let status: Int?
    let prices: GSTrackOrderProductListOrderPrices?
    let ordered, accepted, readyToShip, shipping: String?
    let delivered, verified: String?
    let cancelled, rejected, denied: String?
    let isEscalatedProduct: Bool?
    let orderId: String?
    let address: GSTrackOrderAddress?
    let cancelSelectedStage: Int?
    let paymentType: Int?
    let isBayfayCash: Int?
    let paymentModeName: String?
    let distance: Double?
    let location: GSOrderTrackViewOrderLocation?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case offer
        case status, prices, ordered, accepted
        case readyToShip = "ready_to_ship"
        case shipping, delivered, verified, cancelled, rejected, denied
        case isEscalatedProduct = "is_escalated_order"
        case orderId = "order_id"
        case address
        case cancelSelectedStage = "cancel_selected_stage"
        case paymentType = "payment_type"
        case isBayfayCash = "is_bayfay_cash"
        case paymentModeName = "mode_name"
        case distance
        case location
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = values.decodeSafely(.id)
        offer = values.decodeSafely(.offer)
        status = values.decodeSafely(.status)
        prices = values.decodeSafely(.prices)
        ordered = values.decodeSafely(.ordered)
        accepted = values.decodeSafely(.accepted)
        readyToShip = values.decodeSafely(.readyToShip)
        shipping = values.decodeSafely(.shipping)
        delivered = values.decodeSafely(.delivered)
        verified = values.decodeSafely(.verified)
        cancelled = values.decodeSafely(.cancelled)
        rejected = values.decodeSafely(.rejected)
        denied = values.decodeSafely(.denied)
        isEscalatedProduct = values.decodeSafely(.isEscalatedProduct)
        orderId = values.decodeSafely(.orderId)
        address = values.decodeSafely(.address)
        cancelSelectedStage = values.decodeSafely(.cancelSelectedStage)
        paymentType = values.decodeSafely(.paymentType)
        isBayfayCash = values.decodeSafely(.isBayfayCash)
        paymentModeName = values.decodeSafely(.paymentModeName)
        distance = values.decodeSafely(.distance)
        location = values.decodeSafely(.location)
    }
}

// MARK: - Address
struct GSTrackOrderAddress: Codable {
    let area, street, zipcode: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        area = values.decodeSafely(.area)
        street = values.decodeSafely(.street)
        zipcode = values.decodeSafely(.zipcode)
    }
}

struct GSTrackOrderProductListOrderPrices: Codable {
    let grossPrice, taxes, netPrice, serviceFee, delivery, paymentFee: Double?
    
    enum CodingKeys: String, CodingKey {
        case grossPrice = "gross_price"
        case taxes
        case netPrice = "net_price"
        case serviceFee = "service_fee"
        case delivery
        case paymentFee = "payment_fee"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        grossPrice = values.decodeSafely(.grossPrice)
        taxes = values.decodeSafely(.taxes)
        netPrice = values.decodeSafely(.netPrice)
        serviceFee = values.decodeSafely(.serviceFee)
        delivery = values.decodeSafely(.delivery)
        paymentFee = values.decodeSafely(.paymentFee)
    }
}

struct GSTrackOrderProductListShop: Codable {
    let name: String?
    let address: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        name = values.decodeSafely(.name)
        address = values.decodeSafely(.address)
    }
}

struct GSTrackOrderProductListProduct: Codable {
    let id: String?
    let qty: Int?
    let escalatedQty:Int?
    let netPrice: Double?
    let sellingPrice: Double?
    let offerPrice: Double?
    let productName, unit: String?
    let image: GSTrackOrderProductListProductImage?
    let mfdExp: GSTrackOrderProductListProductDates?
    let verifyStatus:Int?
    let notifications:Bool?
    let replacement:String?
    let escalationStatus:Int?
    
    enum CodingKeys: String, CodingKey {
        case id, qty
        case netPrice = "net_price"
        case sellingPrice = "selling_price"
        case offerPrice = "offer_price"
        case productName = "product_name"
        case unit, image
        case mfdExp = "mfd_exp"
        case verifyStatus = "verify_status"
        case notifications
        case escalatedQty = "escalated_qty"
        case replacement
        case escalationStatus = "escalation_status"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = values.decodeSafely(.id)
        qty = values.decodeSafely(.qty)
        escalatedQty = values.decodeSafely(.escalatedQty)
        netPrice = values.decodeSafely(.netPrice)
        sellingPrice = values.decodeSafely(.sellingPrice)
        offerPrice = values.decodeSafely(.offerPrice)
        productName = values.decodeSafely(.productName)
        unit = values.decodeSafely(.unit)
        image = values.decodeSafely(.image)
        mfdExp = values.decodeSafely(.mfdExp)
        verifyStatus = values.decodeSafely(.verifyStatus)
        notifications = values.decodeSafely(.notifications)
        replacement = values.decodeSafely(.replacement)
        escalationStatus = values.decodeSafely(.escalationStatus)
    }
}

struct GSTrackOrderProductListProductDates: Codable {
    let type: Int?
    let dates: [GSTrackOrderProductListProductDateObject]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        type = values.decodeSafely(.type)
        dates = values.decodeSafely(.dates)
    }
}

struct GSTrackOrderProductListProductDateObject: Codable {
    let mfgDate, expDate: String?
    
    enum CodingKeys: String, CodingKey {
        case mfgDate = "mfg_date"
        case expDate = "exp_date"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        mfgDate = values.decodeSafely(.mfgDate)
        expDate = values.decodeSafely(.expDate)
    }
}

struct GSTrackOrderProductListProductImage: Codable {
    let keyid, name: String?
    let width, height: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        keyid = values.decodeSafely(.keyid)
        name = values.decodeSafely(.name)
        width = values.decodeSafely(.width)
        height = values.decodeSafely(.height)
    }
}


// MARK: - Track Order View Location Model

struct GSOrderTrackViewLocationModel: Codable {
    let success: Bool?
    let data: GSOrderTrackViewLocationData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSOrderTrackViewLocationData: Codable {
    let order: GSOrderTrackViewLocationOrder?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        order = values.decodeSafely(.order)
    }
}

struct GSOrderTrackViewLocationOrder: Codable {
    let id, orderID: String?
    let status: Int?
    let distance: Double?
    let shop: GSOrderTrackViewLocationOrderShop?
    let delivery: GSOrderTrackViewLocationOrderDelivery?
    let products: Int?
    let date: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case orderID = "order_id"
        case status, distance, shop, delivery, products, date
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        orderID = values.decodeSafely(.orderID)
        status = values.decodeSafely(.status)
        distance = values.decodeSafely(.distance)
        shop = values.decodeSafely(.shop)
        delivery = values.decodeSafely(.delivery)
        products = values.decodeSafely(.products)
        date = values.decodeSafely(.date)
    }
}

struct GSOrderTrackViewLocationOrderDelivery: Codable {
    let location: GSOrderTrackViewOrderLocation?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        location = values.decodeSafely(.location)
    }
}

struct GSOrderTrackViewOrderLocation: Codable {
    let type: String?
    let coordinates: [Double]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        type = values.decodeSafely(.type)
        coordinates = values.decodeSafely(.coordinates)
    }
}

struct GSOrderTrackViewLocationOrderShop: Codable {
    let name: String?
    let location: GSOrderTrackViewOrderLocation?
    let address: String?
    let mobile: GSOrderTrackViewLocationOrderShopMobile?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        name = values.decodeSafely(.name)
        location = values.decodeSafely(.location)
        address = values.decodeSafely(.address)
        mobile = values.decodeSafely(.mobile)
    }
}

struct GSOrderTrackViewLocationOrderShopMobile: Codable {
    let primary, secondary: GSOrderTrackViewLocationMobileObject?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        primary = values.decodeSafely(.primary)
        secondary = values.decodeSafely(.secondary)
    }
}

struct GSOrderTrackViewLocationMobileObject: Codable {
    let dialingCode, number, otp: Int?
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



