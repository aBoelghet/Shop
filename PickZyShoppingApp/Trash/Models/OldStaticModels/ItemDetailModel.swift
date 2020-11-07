//
//  ItemDetailModel.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/3/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct ItemDetailModel {
    
    let productName:String
    let productDesc:String
    let productImg:String
    
    static let itemDetailsArray:NSMutableArray = {
        
        let item1 = ItemDetailModel.init(productName: "Product", productDesc: "Black foldable ear phones\nblack color\n3.5mm audio jack\nsupported for all devices", productImg: "img1.png")
        let item2 = ItemDetailModel.init(productName: "Product", productDesc: "Black foldable ear phones\nblack color\n3.5mm audio jack\nsupported for all devices", productImg: "img2.png")
        let item3 = ItemDetailModel.init(productName: "Product", productDesc: "Black foldable ear phones\nblack color\n3.5mm audio jack\nsupported for all devices", productImg: "img3.png")
        let item4 = ItemDetailModel.init(productName: "Product", productDesc: "Black foldable ear phones", productImg: "img4.png")
        let item5 = ItemDetailModel.init(productName: "Product", productDesc: "Black foldable ear phones\nblack color\n3.5mm audio jack\nsupported for all devices", productImg: "img5.png")
        let item6 = ItemDetailModel.init(productName: "Product", productDesc: "Black foldable ear phones\nblack color\n3.5mm audio jack\nsupported for all devices", productImg: "img6.png")
        let item7 = ItemDetailModel.init(productName: "Product", productDesc: "Black foldable ear phones", productImg: "img7.png")
        let item8 = ItemDetailModel.init(productName: "Product", productDesc: "Black foldable ear phones\nblack color\n3.5mm audio jack", productImg: "img8.png")
        let item9 = ItemDetailModel.init(productName: "Product", productDesc: "Black foldable ear phones\nblack color\n3.5mm audio jack\nsupported for all devices", productImg: "img9.png")
        return [item1,item2,item3,item4,item5,item6,item7,item8,item9]
        
    }()
}
