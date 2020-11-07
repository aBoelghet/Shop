//
//  GSAddressConfirmationDeliveryPreferenceView.swift
//  Shopor
//
//  Created by Ratheesh on 24/01/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

public typealias DeliveryPreferencesCompletion = (_ selectedDate: Date, _ cancel: Bool) -> Void

class GSAddressConfirmationDeliveryPreferenceView: NibView,UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var datePicker:UIDatePicker!
    @IBOutlet weak var bg_view:UIView!
    
    var pickerData  = ["10", "20"]

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
        
        datePicker.datePickerMode = .date
        
        bg_view.addShadowEffectWith(color: UIColor.gray, opacity: 0.5, shadowRadius: 1.0, shadowOffset: CGSize.init(width: 0.0, height: -1))
        addGestures()
    }
    
    func addGestures() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGesture_Action))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    // MARK: Action Methods
    
    @IBAction func cancelAction(_ sender: UIButton) {
        
//        self.pickerSelected?("", true)
        removeThisView()
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        
//        let selRow = pickerView.selectedRow(inComponent: 0)
//        self.pickerSelected?(pickerData[selRow], false)
        
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.alpha = 1.0
            self.removeFromSuperview()
        }
        
        //removeThisView()
    }
    
    private var pickerSelected: DeliveryPreferencesCompletion?
    
    @objc open func selectedPicker(completion:DeliveryPreferencesCompletion?){
        
        self.pickerSelected = completion
    }
    
    // MARK: User defined method
    
    private func removeThisView() {
        
        if let theSuperView = self.superview {
            self.backgroundColor = UIColor.clear
            removeTheViewFrom(view: theSuperView)
        }
        
        //        UIView.animate(withDuration: 0.45, animations: { _ in
        //            self.alpha = 0.0
        //        }) { _ in
        //            self.alpha = 1.0
        //            self.removeFromSuperview()
        //        }
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
