//
//  CartItemsModel.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 4/6/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

var cartItemsDictionary : [String:GSCartListNewData] = [:]

// MARK: - Cart List Local Model Class
struct GSCartListLocalModel: Codable {
    let id: String?
    let products: [GSCartListLocalProduct]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case products
    }
}

struct GSCartListLocalProduct: Codable {
    let id: String?
    let images: [GSCartListLocalImage]?
    let productName: String?
    let avgOffer: Double?
    let totalQty: Int?
    let avgSellingPrice: Double?
    let totalStock, tax: Int?
    let stores: [GSCartListLocalStore]?
    
    enum CodingKeys: String, CodingKey {
        case id, images
        case productName = "product_name"
        case avgOffer = "avg_offer"
        case totalQty = "total_qty"
        case avgSellingPrice = "avg_selling_price"
        case totalStock = "total_stock"
        case tax, stores
    }
}

struct GSCartListLocalImage: Codable {
    let height, keyid, name, width: String?
}

struct GSCartListLocalStore: Codable {
    let id: String?
    let offer, qty: Int?
    let sellingPrice: Double?
    let stock, tax: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, offer, qty
        case sellingPrice = "selling_price"
        case stock, tax
    }
}

// ---

var cartItems : [CartItemsModel] = []

struct CartItemsModel {
    
    let product_id:String
    let quantity:Int
    let productPrice:Double
}

struct cartItemsModel {

    let productName:String
    let productDesc:String
    let productImg:String
    let productPrice:String

    static let cartItemsArray:NSMutableArray = {

        let item1 = cartItemsModel.init(productName: "Guava", productDesc:"Quantity:1\nSuperior_type", productImg: "img1.png",productPrice : "1215")
        let item2 = cartItemsModel.init(productName: "Green_Apple", productDesc:"Quantity:2\nSimla_product", productImg: "img2.png" ,productPrice : "122")
        let item3 = cartItemsModel.init(productName: "Pear", productDesc:"Quantity:4\nSuperior_type", productImg: "img3.png" ,productPrice : "12")
        let item4 = cartItemsModel.init(productName: "Banana", productDesc:"Quantity:4\nSuperior_type", productImg: "img4.png",productPrice : "126")
        let item5 = cartItemsModel.init(productName: "Strawberry", productDesc:"Quantity:6\nSuperior_type", productImg: "img5.png",productPrice : "121")
        let item6 = cartItemsModel.init(productName: "Product", productDesc:"Black ear phones\nblack color\n3.5mm audio jack\nsupported devices", productImg: "img6.png",productPrice : "121")
        let item7 = cartItemsModel.init(productName: "Product", productDesc:"Black ear phones\nblack color\n3.5mm audio jack", productImg: "img7.png",productPrice : "121")
        return [item1,item2,item3,item4,item5,item6,item7]

    }()
}

