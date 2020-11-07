//
//  GSCustomDatePicker.swift
//  PickZyShoppingApp
//
//  Created by Mohanapriya on 06/09/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

public typealias DatePickerCompletion = (_ selectedDate: Date, _ cancel: Bool) -> Void

class GSCustomDatePicker: NibView,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var datePicker:UIDatePicker!
    @IBOutlet weak var bg_view:GSCornerEdgeView!
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    private func setUpThisView() {
        
        bg_view.addShadowEffectWith(color: UIColor.gray, opacity: 0.5, shadowRadius: 1.0, shadowOffset: CGSize.init(width: 0.0, height: -1))
        addGestures()
    }
    
    func addGestures() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGesture_Action))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func initThisViewWithFrame(theView:UIView) {
        
        // Call this method after adding this class as subview
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomCons = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: theView, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingCons = NSLayoutConstraint.init(item: self, attribute: .leading, relatedBy: .equal, toItem: theView, attribute: .leading, multiplier: 1, constant: 0)
        let trailingCons = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: theView, attribute: .trailing, multiplier: 1, constant: 0)
        let heightCons = NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIDevice.current.userInterfaceIdiom == .phone ? 200 : 250)
        NSLayoutConstraint.activate([bottomCons,leadingCons,trailingCons,heightCons])
        
    }
    
    // MARK: Action Methods
    
    @IBAction func cancelAction(_ sender: UIButton) {
        
        self.dateSelected?(Date(), true)
        removeThisView()
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        
        let selectedDate = datePicker.date
        
        self.dateSelected?(selectedDate, false)
        removeThisViewForSelection()
    }
    
    private func removeThisViewForSelection() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.alpha = 1.0
            self.removeFromSuperview()
        }
    }
    
    private var dateSelected: DatePickerCompletion?
    
    @objc open func selectedPicker(completion:DatePickerCompletion?){
        
        self.dateSelected = completion
    }
    
    // MARK: User defined method
    
    private func removeThisView() {
        
        if let theSuperView = self.superview {
            self.backgroundColor = UIColor.clear
            removeTheViewFrom(view: theSuperView)
        }
    }
    
    @objc private func tapGesture_Action(_ sender:UITapGestureRecognizer) {
        removeThisView()
    }
    
    //MARK:- Gesture Delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (touch.view?.isDescendant(of: bg_view))! {
            return false
        }
        return true
    }
    
}

