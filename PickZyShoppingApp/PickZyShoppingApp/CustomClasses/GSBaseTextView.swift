//
//  GSBaseTextView.swift
//  PickZyShoppingApp
//
//  Created by PickZy on 5/30/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSBaseTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setUpTextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpTextView()
    }
    
    override func prepareForInterfaceBuilder() {
        setUpTextView()
    }
    
    //MARK: Methods to change some properties
    
    func setUpTextView() {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        self.setValue(PlaceHolderTextColor, forKeyPath: "_placeholderLabel.textColor")
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }

    //MARK: Some Inspectables
    
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
    @IBInspectable var cornerRadius:CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var PlaceHolderTextColor:UIColor = UIColor.gray {
        didSet {
            self.setValue(PlaceHolderTextColor, forKeyPath: "_placeholderLabel.textColor")
        }
    }
}
