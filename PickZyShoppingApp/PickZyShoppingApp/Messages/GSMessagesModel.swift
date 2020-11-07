//
//  GSMessagesModel.swift
//  Shopor
//
//  Created by Ratheesh on 14/01/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation


// MARK: - Messages List New Model

struct New_GSMessagesOrderListModel: Codable {
    let success: Bool?
    let data: [New_GSMessagesOrderListData]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct New_GSMessagesOrderListData: Codable {
    let id, categoryID, storeID, orderID: String?
    let date: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case categoryID = "category_id"
        case storeID = "store_id"
        case orderID = "order_id"
        case date
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        categoryID = values.decodeSafely(.categoryID)
        storeID = values.decodeSafely(.storeID)
        orderID = values.decodeSafely(.orderID)
        date = values.decodeSafely(.date)
    }
}

// MARK: - Product List Model

struct GSMessagesProductListModel: Codable {
    let success: Bool?
    let data: GSMessagesProductListData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct GSMessagesProductListData: Codable {
    let id: String?
    let shop: GSMessagesProductListDataShop?
    let products: [GSMessagesProductListDataProduct]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case shop, products
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        shop = values.decodeSafely(.shop)
        products = values.decodeSafely(.products)
    }
}

struct GSMessagesProductListDataProduct: Codable {
    let id: String?
    let qty: Int?
    let netPrice: Double?
    let verifyStatus, escalatedQty: Int?
    let productName, unit: String?
    let image: GSMessagesProductListDataProductImage?
    
    enum CodingKeys: String, CodingKey {
        case id, qty
        case netPrice = "net_price"
        case verifyStatus = "verify_status"
        case escalatedQty = "escalated_qty"
        case productName = "product_name"
        case unit, image
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        qty = values.decodeSafely(.qty)
        netPrice = values.decodeSafely(.netPrice)
        verifyStatus = values.decodeSafely(.verifyStatus)
        escalatedQty = values.decodeSafely(.escalatedQty)
        productName = values.decodeSafely(.productName)
        unit = values.decodeSafely(.unit)
        image = values.decodeSafely(.image)
    }
}

struct GSMessagesProductListDataProductImage: Codable {
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

struct GSMessagesProductListDataShop: Codable {
    let name: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        name = values.decodeSafely(.name)
    }
}

// MARK: - Chat List Model

struct New_GSMessageChatListModel: Codable {
    let success: Bool?
    let data: New_GSMessageChatListData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

struct New_GSMessageChatListData: Codable {
    
    let order: String?
    let product: New_GSMessageChatListDataProduct?
    let chat: New_GSMessageChatListDataChatObject?
    let shop: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        order = values.decodeSafely(.order)
        product = values.decodeSafely(.product)
        chat = values.decodeSafely(.chat)
        shop = values.decodeSafely(.shop)
    }
}

struct New_GSMessageChatListDataChatObject: Codable {
    let id: String?
    let chat: [New_GSMessageChatListDataChat]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case chat
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        chat = values.decodeSafely(.chat)
    }
}

struct New_GSMessageChatListDataChat: Codable {
    let id, message, at, by: String?
    let image: New_GSMessageChatListDataImage?
    let isTemplate: Bool?
    let templateResponse: Int?
    let isDeleted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, message, at, by, image
        case isTemplate = "is_template"
        case templateResponse = "template_response"
        case isDeleted = "is_deleted"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        message = values.decodeSafely(.message)
        at = values.decodeSafely(.at)
        by = values.decodeSafely(.by)
        image = values.decodeSafely(.image)
        isTemplate = values.decodeSafely(.isTemplate)
        templateResponse = values.decodeSafely(.templateResponse)
        isDeleted = values.decodeSafely(.isDeleted)
    }
    
    init(id: String?, message: String?, at: String?, by: String?, image: New_GSMessageChatListDataImage?, isTemplate: Bool?, templateResponse: Int?, isDeleted: Bool?) {
        self.id = id
        self.message = message
        self.at = at
        self.by = by
        self.image = image
        self.isTemplate = isTemplate
        self.templateResponse = templateResponse
        self.isDeleted = isDeleted
    }
}

struct New_GSMessageChatListDataProduct: Codable {
    let id, productName: String?
    let image: New_GSMessageChatListDataImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case productName = "product_name"
        case image
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
        productName = values.decodeSafely(.productName)
        image = values.decodeSafely(.image)
    }
}

struct New_GSMessageChatListDataImage: Codable {
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


// MARK: - Single Message Model Response

struct GSMessageSuccessSendingMessageModel:Codable {
    let success: Bool?
    let data: New_GSMessageChatListDataChat?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = values.decodeSafely(.success)
        data = values.decodeSafely(.data)
    }
}

