//
//  GSTipsLabel.swift
//  PickZyShoppingApp
//
//  Created by Bala on 5/9/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSTipsLabel: GSBaseLabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpTipsLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpTipsLabel()
    }
    
    override func prepareForInterfaceBuilder() {
        setUpTipsLabel()
    }
    
    //MARK: Methods to change some properties
    
    func setUpTipsLabel() {
        
    }
}
