//
//  GSPasswordField.swift
//  PickZyShoppingApp
//
//  Created by Bala on 5/10/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

@IBDesignable class GSPasswordField: GSBaseTextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpPasswordField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpPasswordField()
    }
    
    override func prepareForInterfaceBuilder() {
        setUpPasswordField()
    }
    
    //MARK: Methods to change some properties
    
    func setUpPasswordField() {
        isSecureTextEntry = true
        delegate = self
    }

    //MARK: Delegate methods

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isValidPassword())! {
            textField.layer.borderWidth = 0.5
            textField.layer.borderColor = UIColor.red.cgColor
        } else {
            textField.layer.borderWidth = 0.0
            textField.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
