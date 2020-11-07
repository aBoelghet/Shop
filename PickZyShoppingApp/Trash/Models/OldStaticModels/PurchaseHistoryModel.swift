//
//  PurchaseHistoryModel.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/9/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct PurchaseHistoryModel {
    let datePurchased:String
    let purchasedFrom:[PurchasedMarkets]
    static let purchaseHistory:[PurchaseHistoryModel] = {
        
        let model1 = PurchaseHistoryModel(datePurchased: "10/04/2018", purchasedFrom: PurchasedMarkets.purchasedMarket)
        
        let model2 = PurchaseHistoryModel(datePurchased: "25/05/2018", purchasedFrom: PurchasedMarkets.purchasedMarket)
        let model3 = PurchaseHistoryModel(datePurchased: "30/05/2018", purchasedFrom: PurchasedMarkets.purchasedMarket)
        let model4 = PurchaseHistoryModel(datePurchased: "08/06/2018", purchasedFrom: PurchasedMarkets.purchasedMarket)
        
        return [model1,model2,model3,model4]
    }()
    
}

struct PurchasedMarkets {
    let shopCat:String
    let orderCost:String
    
    static let purchasedMarket:[PurchasedMarkets] = {
        let market1 = PurchasedMarkets(shopCat: "Super Market", orderCost: "200")
        let market2 = PurchasedMarkets(shopCat: "Furniture", orderCost: "289")
        let market3 = PurchasedMarkets(shopCat: "Toy Store", orderCost: "2000")
        return [market1,market2,market3]
    }()
}


