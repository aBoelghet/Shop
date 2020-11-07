//
//  GSLoggedInBaseViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh Mac Mini on 08/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSLoggedInBaseViewController: GSBaseViewController {

    //MARK: - UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - User Defined Methods (Data)

//    func dataFromPlist(_ key: String) -> Array<Any> {
//
//        let path = Bundle.main.path(forResource: "Products", ofType: "plist")
//        let plistCategoryArray = NSDictionary.init(contentsOfFile: path!)
//        let plistDataArray = plistCategoryArray?.value(forKey: key) as! [Any]
//        return plistDataArray
//    }
    
    func dataFromPlist(_ key: String) -> NSDictionary {
        
        let path = Bundle.main.path(forResource: key, ofType: "plist")
        let plistCategoryArray = NSDictionary.init(contentsOfFile: path!)
//        let plistDataArray = plistCategoryArray?.value(forKey: key) as! [Any]
//        return plistDataArray
        
        return plistCategoryArray!
    }

}
