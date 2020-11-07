//
//  SAShadowView.swift
//  ShoporAdmin
//
//  Created by Ratheesh on 17/08/18.
//  Copyright © 2018 Ratheesh. All rights reserved.
//

import UIKit

@IBDesignable class GSShadowView: UIView {
    
    var shadowLayer: CAShapeLayer!
    
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
        clipsToBounds = false
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        //        addShadowEffect()
    }
    
    func addShadowEffect() {
        
        //        if shadowLayer == nil {
        //            shadowLayer = CAShapeLayer()
        //            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        //            shadowLayer.fillColor = UIColor.white.cgColor
        //
        //            shadowLayer.shadowColor = UIColor.darkGray.cgColor
        //            shadowLayer.shadowPath = shadowLayer.path
        //            shadowLayer.shadowOffset = CGSize(width: -2.0, height: 2.0)
        //            shadowLayer.shadowOpacity = 0.8
        //            shadowLayer.shadowRadius = 2
        //
        ////            if layer.superlayer != nil {
        ////                return
        ////            }
        //
        //            layer.insertSublayer(shadowLayer, at: 0)
        ////            layer.insertSublayer(shadowLayer, below: nil) // also works
        //        }
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = shadowColor.cgColor
            shadowLayer.shadowColor = shadowColor.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = shadowOffset
            shadowLayer.shadowOpacity = shadowOpacity
            shadowLayer.shadowRadius = shadowRadius
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
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
            //            layer.masksToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var shadowColor:UIColor = UIColor.clear {
        
        didSet{
            layer.shadowColor = shadowColor.cgColor
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
}
