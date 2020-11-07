//
//  GSPaymentViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh Mac Mini on 08/05/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import PayU_coreSDK_Swift

class GSPaymentViewController: GSLoggedInBaseViewController {
    
    var paymentParameterHelper:GSPaymentParametersHelper?

    //MARK: - UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
