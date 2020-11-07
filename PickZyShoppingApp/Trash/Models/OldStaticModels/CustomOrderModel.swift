//
//  CustomOrderModel.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 5/31/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct OrderItems {
    
    let productName:String
    let quantity:String
    let productImg:String
    let productPrice:String
    
    static let orderItemsArray:[OrderItems] = {
        
        let item1 = OrderItems(productName: "Guava", quantity:"2", productImg: "img1.png",productPrice : "1215")
        let item2 = OrderItems(productName: "Green_Apple", quantity:"4", productImg: "img2.png" ,productPrice : "122")
        let item3 = OrderItems(productName: "Pear", quantity:"5", productImg: "img3.png" ,productPrice : "12")

        return [item1,item2,item3]
        
    }()
}

struct Markets {
    
    let marketName:String
    let itemsQuantity:String
    let rating:String
    let orderedItems:[OrderItems]
    let isAutoSelectedShop:Bool
    
    static let autoSelectedMarkets:[Markets] = {
        let market1 = Markets(marketName: "Pickzy Super Market", itemsQuantity: "5", rating: "4.5", orderedItems: OrderItems.orderItemsArray, isAutoSelectedShop: true)
        let market2 = Markets(marketName: "XYZ Super Market", itemsQuantity: "5", rating: "4.5", orderedItems: OrderItems.orderItemsArray, isAutoSelectedShop: true)
        let market3 = Markets(marketName: "Planet Super Market", itemsQuantity: "5", rating: "4.5", orderedItems: OrderItems.orderItemsArray, isAutoSelectedShop: true)
        
        return [market1,market2,market3]
    }()
    
    static let someMarkets:[Markets] = {
        let market1 = Markets(marketName: "Pickzy Super Market", itemsQuantity: "5", rating: "4.5", orderedItems: OrderItems.orderItemsArray, isAutoSelectedShop: false)
        let market2 = Markets(marketName: "XYZ Super Market", itemsQuantity: "5", rating: "4.5", orderedItems: OrderItems.orderItemsArray, isAutoSelectedShop: false)
        let market3 = Markets(marketName: "Planet Super Market", itemsQuantity: "5", rating: "4.5", orderedItems: OrderItems.orderItemsArray, isAutoSelectedShop: false)
        
        return [market1,market2,market3]
    }()
}

struct CustomOrderCat {
    let shopCat:String
    let theMarkets:[Markets]
    
    static let someShopCats:[CustomOrderCat] = {
       let cat1 = CustomOrderCat(shopCat: "Auto Selected Shops", theMarkets: Markets.autoSelectedMarkets)
        let cat2 = CustomOrderCat(shopCat: "Super Markets", theMarkets: Markets.someMarkets)
        let cat3 = CustomOrderCat(shopCat: "Kids Store", theMarkets: Markets.someMarkets)
        let cat4 = CustomOrderCat(shopCat: "Mobile Store", theMarkets: Markets.someMarkets)
        
        return [cat1,cat2,cat3,cat4]
    }()
}
