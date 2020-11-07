//
//  GSCustomPickerView.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/28/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit

public typealias PickerCompletion = (_ pickerValue: String?, _ cancel: Bool) -> Void

class GSCustomPickerView: NibView,UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var bg_view:UIView!
    @IBOutlet weak var pickerBottom_constraint:NSLayoutConstraint!
    
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
        
        bg_view.addShadowEffectWith(color: UIColor.gray, opacity: 0.5, shadowRadius: 1.0, shadowOffset: CGSize.init(width: 0.0, height: -1))
        addGestures()
    }
    
    func addGestures() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGesture_Action))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func showTheView(on view:UIView, for reqFrame:CGRect) {
        
        view.addSubview(self)
        view.endEditing(true)
//        addConstraintsForTheView(reqFrame)
        
        
//        frame = CGRect(x: reqFrame.origin.x, y: view.frame.size.height, width: reqFrame.size.width, height: reqFrame.size.height)
//
//        UIView.animate(withDuration: 0.45, animations: {
//            self.frame = reqFrame
//
//        }) {  _ in
//
//            self.addConstraintsForTheView(reqFrame)
//
//            UIView.animate(withDuration: 0.1, animations: {
//                self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//            })
//        }
        
        
        frame = CGRect(x: reqFrame.origin.x, y: view.frame.size.height, width: reqFrame.size.width, height: reqFrame.size.height)

        UIView.animate(withDuration: 0.45, animations: {
            self.frame = reqFrame

        }) {  _ in

            self.addConstraintsForTheView(reqFrame)

            UIView.animate(withDuration: 0.1, animations: {
                self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            })
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
    
    // MARK: Action Methods
    
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
        self.pickerSelected?(pickerData[selRow], false)

        
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
