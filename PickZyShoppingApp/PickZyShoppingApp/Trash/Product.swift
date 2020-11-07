//
//  Product.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh Mac Mini on 04/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class Product: NSObject {

  public  var imageName:String = ""
  public  var itemName:String = ""
  public  var cost:Double = 0.0
    
    public func initWithProducts (_ allObj : [Any]) -> NSMutableArray {
        
        let allProducts = NSMutableArray()
        for i in 0 ..< allObj.count {
            autoreleasepool {
                
                let p = Product()
                let dic = allObj[i] as! NSDictionary
                p.imageName = dic.value(forKey: "image") as! String
                p.itemName = dic.value(forKey: "itemName") as! String
                p.cost = dic.value(forKey: "cost") as! Double
                allProducts.add(p)
            }
        }
        return allProducts
    }
}
