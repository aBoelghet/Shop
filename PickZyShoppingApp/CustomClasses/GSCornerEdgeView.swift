//
//  GSCornerEdgeView.swift
//  PickZyShoppingApp
//
//  Created by Bala on 5/10/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

@IBDesignable class GSCornerEdgeView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpCornerEdgeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpCornerEdgeView()
    }
    
    override func prepareForInterfaceBuilder() {
        setUpCornerEdgeView()
    }
    
    //MARK: Methods to change some properties
    
    func setUpCornerEdgeView() {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
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
    @IBInspectable var cornerRadius:CGFloat = CGFloat() {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
