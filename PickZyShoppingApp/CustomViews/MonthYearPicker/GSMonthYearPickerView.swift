//
//  GSMonthYearPickerView.swift
//  PickZyShoppingApp
//
//  Created by Mohanapriya on 06/09/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

public typealias MonthDatePickerCompletion = (_ pickerValue: String?, _ cancel: Bool) -> Void

class GSMonthYearPickerView: NibView,UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var bg_view:UIView!
    var months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var day: [String] = ["1","2","3","4", "5", "6", "7", "8", "9", "10", "11","12","13","14", "15", "16", "17", "18", "19", "20", "21","22","23", "24", "25", "26", "27", "28"]
   
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
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.selectRow(0, inComponent: 0, animated: true)
        
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
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return day.count
        case 1:
            return months.count
        default:
            return 0
        }
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return day[row]
        case 1:
            return months[row]
        default:
            return nil
        }
    }
    
    //    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    //        var pickerLabel : GSBaseLabel? = (view as? GSBaseLabel)
    //        if pickerLabel == nil {
    //            pickerLabel = GSBaseLabel()
    //            pickerLabel?.font = pickerLabel?.font.withSize(17)
    //            pickerLabel?.textAlignment = .center
    //        }
    //        pickerLabel?.text = pickerData[row]
    //        return pickerLabel ?? GSBaseLabel()
    //    }
    //
    // MARK: Action Methods
    
    @IBAction func cancelAction(_ sender: UIButton) {
        
        self.pickerSelected?("", true)
        removeThisView()
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        
        
        let selRow = pickerView.selectedRow(inComponent: 0)
        let selCol = pickerView.selectedRow(inComponent: 1)
        self.pickerSelected?(day[selRow] + ", " + months[selCol], false)
        
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.alpha = 1.0
            self.removeFromSuperview()
        }
        
        
        //removeThisView()
    }
    
    private var pickerSelected: PickerCompletion?
    
    @objc open func selectedPicker(completion:PickerCompletion?){
        
        self.pickerSelected = completion
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

