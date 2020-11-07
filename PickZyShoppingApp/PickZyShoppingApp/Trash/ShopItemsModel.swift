//
//  ShopItemsModel.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/9/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import Foundation

struct ShopItemsModel {
    
    let imageName:String
    let itemName:String
    let cost:Double
    
    static let someItems: NSMutableArray = {
        
        let item1 = ShopItemsModel(imageName:"img1.png", itemName: "Kiwi", cost: 20)
        let item2 = ShopItemsModel(imageName:"img2.png", itemName: "Orange", cost: 40)
        let item3 = ShopItemsModel(imageName:"img3.png", itemName: "Banana", cost: 10)
        let item4 = ShopItemsModel(imageName:"img4.png", itemName: "Apple", cost: 50)
        let item5 = ShopItemsModel(imageName:"img5.png", itemName: "Papaya", cost: 70)
        let item6 = ShopItemsModel(imageName:"img6.png", itemName: "Green Apple", cost: 45)
        let item7 = ShopItemsModel(imageName:"img7.png", itemName: "Grapes", cost: 12)
        let item8 = ShopItemsModel(imageName:"img8.png", itemName: "PomeGrenate", cost: 21)
        let item9 = ShopItemsModel(imageName:"img9.png", itemName: "Tomato", cost: 35)
        
        return [item1,item2,item3,item4,item5,item6,item7,item8,item9,
        item1,item2,item3,item4,item5,item6,item7,item8,item9,
        item1,item2,item3,item4,item5,item6,item7,item8,item9,
        item1,item2,item3,item4,item5,item6,item7,item8,item9,
        item1,item2,item3,item4,item5,item6,item7,item8,item9,
        item1,item2,item3,item4,item5,item6,item7,item8,item9,
        item1,item2,item3,item4,item5,item6,item7,item8,item9]
    } ()
    
}
