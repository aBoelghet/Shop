//
//  GSPhoneField.swift
//  PickZyShoppingApp
//
//  Created by Bala on 5/9/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

@IBDesignable class GSPhoneField: GSBaseTextField {
    
    public var restrictionLength = 10
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpPhoneField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpPhoneField()
    }
    
    override func prepareForInterfaceBuilder() {
        setUpPhoneField()
    }
    
    //MARK: Methods to change some properties
    
    func setUpPhoneField() {
        keyboardType = .phonePad
        delegate = self
    }
    
    //MARK: Delegate methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let resultText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        return resultText.count <= restrictionLength
    }
}
