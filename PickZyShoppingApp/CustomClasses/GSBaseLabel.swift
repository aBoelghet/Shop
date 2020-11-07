//
//  GSBaseLabel.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 5/3/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

@IBDesignable class GSBaseLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpLabel()
    }
    
    override func prepareForInterfaceBuilder() {
        setUpLabel()
    }
    
    //MARK: Methods to change some properties
    
    func setUpLabel() {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        
        if text == "Label" {
            text = ""
        }
    }

    //MARK: Some Inspectables
    
    @IBInspectable var cornerRadius:CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor:UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
}
