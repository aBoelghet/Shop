//
//  GSSearchBar.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 5/9/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

@IBDesignable class GSSearchBar: UISearchBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSearchBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSearchBar()
    }
    
    override func prepareForInterfaceBuilder() {
        setUpSearchBar()
    }
    
    //MARK: Methods to change some properties
    
    func setUpSearchBar() {
        
        let textFieldInsideSearchBar = value(forKey:"searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.darkGray
        
        // Placeholder Customization
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor.darkGray
        
        // We need this Properties
        
        backgroundColor = UIColor.white
        barTintColor = UIColor.white
        backgroundImage = UIImage()

        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
     }
    
    //MARK: Few Inspectables
    
    @IBInspectable var cornerRadius:CGFloat = 10.0 {
        
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var shadowColor:CGColor = UIColor.clear.cgColor {
        
        didSet{
            layer.shadowColor = shadowColor
        }
    }
    
    @IBInspectable var shadowOffset:CGSize = CGSize(width: 0, height: 0) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var shadowOpacity:Float = 0.0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowRadius : CGFloat = 0.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 0.5 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor:UIColor = UIColor.lightGray {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }


}
