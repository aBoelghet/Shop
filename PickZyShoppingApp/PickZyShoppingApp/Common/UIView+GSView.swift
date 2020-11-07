//
//  UIView+ShadowEffect.swift
//  PickZyShoppingApp
//
//  Created by Bala on 5/9/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

extension UIView {
    
    func addShadowEffectWith (color col:UIColor, opacity op:Float, shadowRadius radius: CGFloat, shadowOffset offset: CGSize) {
        
        layer.masksToBounds = false
        layer.shadowColor = col.cgColor
        layer.shadowOpacity = op
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }
    
    func addShadowEffectWithDirection(_ color:UIColor, opacity op:Float,radius rad:CGFloat,  shadowDiretion dir:ShadowDirection) {
        var shadowOffset:CGSize
        
        switch dir {
        case .Left_And_Top:
            shadowOffset = CGSize(width: -3, height: -3)
            break
        case .Right_And_Top:
            shadowOffset = CGSize(width: 3, height: -3)
            break
        case .Left_And_Bottom:
            shadowOffset = CGSize(width: -3, height: 3)
            break
        case .Right_And_Bottom:
            shadowOffset = CGSize(width: 3, height: 3)
            break
        }
        
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = op
        layer.shadowRadius = rad
        layer.shadowOffset = shadowOffset
    }
    
    enum ShadowDirection {
        
        case Left_And_Bottom
        case Right_And_Bottom
        case Left_And_Top
        case Right_And_Top
    }
}
