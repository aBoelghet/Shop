//
//  SubscriptionPopupViewController.swift
//  Shopor
//
//  Created by Ratheesh on 24/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
protocol SubscriptionPopViewDelegate:class {
    func subscriptionName(subscription:String)
}
class SubscriptionPopupViewController: UIViewController {

    @IBOutlet weak var background_Popupvew: UIView!
    
    @IBOutlet weak var subscriptionTitle_Label: UILabel!
    
    @IBOutlet weak var close_Button: UIButton!
    
    @IBOutlet weak var subscription_Textfield: UITextField!
    
    @IBOutlet weak var cancel_Button: UIButton!
    
    @IBOutlet weak var submit_Button: UIButton!
    
    
    var subscriptionAmount = ""
    
    weak var delegate: SubscriptionPopViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializedMethod()
       
    }

    func initializedMethod()  {
        
        if let subscription = SharedPersistence.getValue(key: UserDefaultKeys.subscriptionName) {
            
            subscription_Textfield.text = subscription as? String

        }
        
        background_Popupvew.layer.cornerRadius = 3
        background_Popupvew.clipsToBounds = true
        
        subscription_Textfield.layer.borderWidth = 1
        subscription_Textfield.layer.borderColor = UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND).cgColor
        subscription_Textfield.layer.cornerRadius = 3
        subscription_Textfield.clipsToBounds = true
        
        cancel_Button.layer.borderWidth = 1
        cancel_Button.layer.borderColor = UIColor(hexString: defaultTheme.VIEW_OR_TABLE_BACKGROUND).cgColor
        cancel_Button.layer.cornerRadius = 3
        cancel_Button.clipsToBounds = true
        
        submit_Button.layer.cornerRadius = 3
        submit_Button.clipsToBounds = true
        
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
        subscription_Textfield.leftView = paddingView
        subscription_Textfield.leftViewMode = .always
    }
    // MARK: - Validations for Textfields
    func validateTextFileds() -> Bool {
        
        if (subscription_Textfield.text?.isEmpty)!{
            CustomAlert.showAlert(title: GSString.AppName, message: "Please enter \(subscription_Textfield?.placeholder ?? "Please enter missing field")", viewController: self)
            return false
        }
        
        return true
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: false, completion: {
        })
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        
        self.view.endEditing(true)
        guard validateTextFileds() == true else {return}
        
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.subscriptionName, value:  subscription_Textfield.text!)

        delegate?.subscriptionName(subscription: subscription_Textfield.text!)
        dismiss(animated: false, completion: {})

    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: false, completion: {})

    }
    
}
