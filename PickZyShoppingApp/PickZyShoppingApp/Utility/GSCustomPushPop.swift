//
//  GSCustomPush.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/17/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSCustomPushPop: NSObject {
    
    class func doCustomPush(from sourceVC:UIViewController, to destinationVC:UIViewController) {
        
        let transition = CATransition()
        transition.duration = 0.45
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        sourceVC.navigationController?.view.layer.add(transition, forKey: kCATransition)
        sourceVC.navigationController?.pushViewController(destinationVC, animated: false)
    }
    
    class func doCustomPop(from sourceVC:UIViewController) {
        
        let transition = CATransition()
        transition.duration = 0.45
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromBottom
        sourceVC.navigationController?.view.layer.add(transition, forKey:kCATransition)
        sourceVC.navigationController?.popViewController(animated: false)
    }
}

