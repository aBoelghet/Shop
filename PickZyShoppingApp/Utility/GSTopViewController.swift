//
//  GSTopViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/3/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSTopViewController: NSObject {
    
    class func topViewController() -> UIViewController {
        
        let tempInstance = GSTopViewController()
        return tempInstance.giveTopViewController((UIApplication.shared.keyWindow?.rootViewController)!)
    }
    
    func giveTopViewController(_ topVC:UIViewController) -> UIViewController {
        
        if topVC.isKind(of: UINavigationController.self){
            let navigationController = topVC as! UINavigationController
            return giveTopViewController(navigationController.viewControllers.last!)
        }
        return topVC
    }

}
