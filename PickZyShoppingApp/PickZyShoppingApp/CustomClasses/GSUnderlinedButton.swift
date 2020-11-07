//
//  GSBaseButtonWithUnderline.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/25/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

@IBDesignable class GSUnderlinedButton: GSBaseButton {
    
    override func draw(_ rect: CGRect) {
        guard let textRect = self.titleLabel?.frame else {return}
        guard let descender = self.titleLabel?.font.descender else {return}
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor((titleLabel?.textColor.cgColor)!)
        
        let theBottomHeightDiff = 0.5 * (frame.size.height - textRect.size.height)
        let theYPos = textRect.origin.y + textRect.size.height + descender + min(theBottomHeightDiff, 3)
        context?.move(to:  CGPoint(x: textRect.origin.x, y: theYPos))
        context?.addLine(to: CGPoint(x: textRect.origin.x + textRect.size.width, y: theYPos))
        context?.closePath()
        context?.drawPath(using: .stroke)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpCustomButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpCustomButton()
    }
    
    override func prepareForInterfaceBuilder() {
        setUpCustomButton()
    }
    
    //MARK: Methods to change some properties
    
    func setUpCustomButton() {
        
    }
    
    //MARK: Some Inspectables
    
    
}
