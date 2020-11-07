//
//  BaseNavigationViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 03/07/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSBaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - PushViewController
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        var viewControllerToPush = viewController
        var pushAnimation = animated
        
        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
        
        if isGuestLogin {
            
            if !(viewControllerToPush.isKind(of: GSLoginViewController.self) ||
                viewControllerToPush.isKind(of: GSSignUpViewController.self) ||
                viewControllerToPush.isKind(of: GSOtpViewController.self) ||
                viewControllerToPush.isKind(of: GSShopsViewController.self) ||
                viewControllerToPush.isKind(of: GSProductsViewController.self) ||
                viewControllerToPush.isKind(of: GSProductDetailsViewController.self) ||
                viewControllerToPush.isKind(of: GSPlacesAutoCompleteViewController.self) ||
                viewControllerToPush.isKind(of: GSSupportViewController.self) ||
                viewControllerToPush.isKind(of: GSSupportDetailsViewController.self) ||
                viewControllerToPush.isKind(of: GSAboutViewController.self)) {
                
                if let welcomeViewController = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSWelcomeScreenViewController) as? GSWelcomeScreenViewController {
                    welcomeViewController.isShowingForGuestUser = true
                    viewControllerToPush = welcomeViewController
                    
                    // Animation to get the view from bottom to top
                    let transition = CATransition()
                    transition.duration = 0.45
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = kCATransitionMoveIn;
                    transition.subtype = kCATransitionFromTop;
                    view.layer.add(transition, forKey: kCATransition)
                    pushAnimation = false
                }
            }
        }
        super.pushViewController(viewControllerToPush, animated: pushAnimation)
    }
}
