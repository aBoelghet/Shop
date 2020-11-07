//
//  GSTextField.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 5/2/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

@IBDesignable class GSBaseTextField: UITextField,UITextFieldDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpTextField()
    }
    
    override func prepareForInterfaceBuilder() {
        setUpTextField()
    }
    
    //MARK: Methods to change some properties
    
    func setUpTextField() {
        delegate = self
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        self.setValue(PlaceHolderTextColor, forKeyPath: "_placeholderLabel.textColor")
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
    
    //MARK: UITextField Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let currentMainView = GSTopViewController.topViewController().view
        if let nextField = currentMainView?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    
    //MARK: UITextField Methods
    
    var padding:UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
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

extension UITextField {
    func setRoundedCorners() {
        layer.cornerRadius = 0.5 * frame.size.height
    }
}
