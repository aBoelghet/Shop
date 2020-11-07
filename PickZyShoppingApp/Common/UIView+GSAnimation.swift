//
//  UIView+PresentAnimation.swift
//  PickZyShoppingApp
//
//  Created by Bala on 5/10/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

public typealias ViewFromBottomTopCompletion = () -> Void


extension UIView {
    
    
    func showTheViewFromBottom(on view:UIView, for reqFrame:CGRect,completionHandler:@escaping ViewFromBottomTopCompletion) {
        view.addSubview(self)
           frame = CGRect(x: reqFrame.origin.x, y: view.frame.size.height, width: reqFrame.size.width, height: reqFrame.size.height)
        
//        addConstraintsForTheView(reqFrame)
//        let topConstraint = self.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.size.height)
//        topConstraint.isActive = true
        //view.layoutIfNeeded()
        
//        topConstraint.constant = reqFrame.origin.y
        UIView.animate(withDuration: 0.45, animations: {
            self.frame = reqFrame
            //view.layoutIfNeeded()
            
            //topConstraint.constant = reqFrame.origin.y
            
        }) {  _ in
//            self?.frame = CGRect.zero

            self.addConstraintsForTheView(reqFrame)
            completionHandler()
        }
    }
    
    func showTheViewFromBottom(on view:UIView, bgColor:UIColor, for reqFrame:CGRect,completionHandler:@escaping ViewFromBottomTopCompletion) {
        view.addSubview(self)
        frame = CGRect(x: reqFrame.origin.x, y: view.frame.size.height, width: reqFrame.size.width, height: reqFrame.size.height)

        UIView.animate(withDuration: 0.45, animations: {
            self.frame = reqFrame
            self.backgroundColor = bgColor
            
        }) {  _ in
            
            self.addConstraintsForTheView(reqFrame)
            completionHandler()
        }
    }
    
    func removeTheViewFrom(view:UIView) {
        UIView.animate(withDuration: 0.45, animations: { [weak self] in
            self?.frame = CGRect(x: (self?.frame.origin.x)!, y: view.frame.size.height, width: (self?.frame.size.width)!, height: (self?.frame.size.height)!)
        }) { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private func addConstraintsForTheView(_ frame:CGRect) {
        if let theSuperView = superview {
            
            translatesAutoresizingMaskIntoConstraints = false
            self.leftAnchor.constraint(equalTo: theSuperView.leftAnchor, constant: frame.origin.x).isActive = true
            self.topAnchor.constraint(equalTo: theSuperView.topAnchor, constant: frame.origin.y).isActive = true
            self.rightAnchor.constraint(equalTo: theSuperView.rightAnchor, constant: -(theSuperView.frame.size.width - frame.size.width - frame.origin.x)).isActive = true
            self.bottomAnchor.constraint(equalTo: theSuperView.bottomAnchor, constant: -(theSuperView.frame.size.height - frame.size.height - frame.origin.y)).isActive = true
        }
        
    }
    
    private func removeConstraintdBeforeDismiss(_ mainView:UIView ,childView:UIView) {

//        for constraint in mainView.constraints {
//            if constraint.firstItem is self {
//
//            }
//        }

    }
    
    func showWithFadeAnimation() {
        isHidden = false
        alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.alpha = 1.0
            }, completion: nil)
    }
    func hideWithFadeAnimation() {
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.alpha = 0.0
        }) { [weak self] _ in
            self?.alpha = 1.0
            self?.isHidden = true
        }
    }
    
    func removeWithFadeAnimation() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.alpha = 0.0
        }) { [weak self] _ in
            self?.alpha = 1.0
            self?.removeFromSuperview()
        }
    }
}
