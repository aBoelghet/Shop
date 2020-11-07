//
//  NotificationModel.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/27/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

struct NotificationModel {
    
    let notifText:String
    
    static let notifyArray:NSMutableArray = {
       
        let item1 = NotificationModel(notifText: "Your order has been placed successfully")
        let item2 = NotificationModel(notifText: "Your order has been dispatched")
        let item3 = NotificationModel(notifText: "You cancelled your order")
        let item4 = NotificationModel(notifText: "Your refund intiated")
        
        return [item1,item2,item3,item3]
    }()
}
