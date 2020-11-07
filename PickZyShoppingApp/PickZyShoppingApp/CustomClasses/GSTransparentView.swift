//
//  GSTransparentView.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 5/9/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

@IBDesignable class GSTransparentView: GSCornerEdgeView {
    
    var alphaForBGColor:CGFloat = 0.4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpTransparentView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpTransparentView()
    }
    
    override func prepareForInterfaceBuilder() {
        setUpTransparentView()
    }
    
    //MARK: Methods to change some properties
    
    func setUpTransparentView() {
        backgroundColor = color.withAlphaComponent(alphaForBGColor)
    }
    
    
    //MARK: Some Inspectables
    
    @IBInspectable var transparency:CGFloat = 0.4 {
        didSet {
            alphaForBGColor = max(0, min(transparency, 1.0))
            setUpTransparentView()
        }
    }
    @IBInspectable var color:UIColor = UIColor.clear {
        didSet {
            setUpTransparentView()
        }
    }
}
