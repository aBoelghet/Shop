//
//  OrderDetailsWithShopsModel.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 5/25/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct OrderDetailsWithShops {
    
    let shopAddress:String
    let products:[OrderedProducts]
    
    static let orderDetailsArray:[OrderDetailsWithShops] = {
        let shop1 = OrderDetailsWithShops(shopAddress: "Pickzy super market, 7a first road, Teynampet, Chennai 600008, Mobile number : 1234567895", products: OrderedProducts.orderedProd)
        let shop2 = OrderDetailsWithShops(shopAddress: "ABC Shop, 7a first road, Teynampet, Chennai 600008, Mobile number : 1234567895", products: OrderedProducts.orderedProd)

        let shop3 = OrderDetailsWithShops(shopAddress: "XYZ store, 7a first road, Teynampet, Chennai 600008, Mobile number : 1234567895", products: OrderedProducts.orderedProd)

        let shop4 = OrderDetailsWithShops(shopAddress: "123 Store, 7a first road, Teynampet, Chennai 600008, Mobile number : 1234567895", products: OrderedProducts.orderedProd)
        
        return [shop1,shop2,shop3,shop4]
    }()
    
}

struct OrderedProducts {
    
    let title:String
    let approxCost:String
    let quantity:String
    let imageName:String
    
    static let orderedProd : [OrderedProducts] = {
       let product1 = OrderedProducts(title: "Product1", approxCost: "20", quantity: "2", imageName: "img1.png")
        let product2 = OrderedProducts(title: "Product2", approxCost: "50", quantity: "5", imageName: "img2.png")

        let product3 = OrderedProducts(title: "Product3", approxCost: "15", quantity: "2", imageName: "img3.png")
        return [product1,product2,product3]
    }()
}
