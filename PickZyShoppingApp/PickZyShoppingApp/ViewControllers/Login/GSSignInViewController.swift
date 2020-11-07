//
//  GSSignInViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 5/2/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSSignUpViewController: GSBaseViewController {
    
    @IBOutlet weak var firstNameField: GSBaseTextField!
    @IBOutlet weak var lastNameField: GSBaseTextField!
    @IBOutlet weak var mobileNumberField: GSBaseTextField!
    @IBOutlet weak var passwordField: GSBaseTextField!
    @IBOutlet weak var emailField: GSBaseTextField!
    @IBOutlet weak var loginWithOTPbtn:GSButtonWithUnderline!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadFewIntializers()
    }

    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(true)
        addNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        removeNotifications()
    }
    
    //MARK: UIViewController Methods
    
    @IBAction func loginUsingOTPAction(_ sender: UIButton) {
        pushToOTPView()
    }
    
    // MARK: User defined methods
    
    func loadFewIntializers() {
        
        navigationBarView.delegate = self
     }
    
    func pushToOTPView() {
        
        if let tempVC = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil)
            .instantiateViewController(withIdentifier: GSString.Push.GSOtpViewController) as? GSOtpViewController {
            tempVC.mobileNumber = mobileNumberField.text
            if let navigator = navigationController {
                navigator.pushViewController(tempVC, animated: true)
            }
        }
    }
}

// MARK: NavigationBar Methods

extension GSSignUpViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        pushToOTPView()
    }
}

// MARK: UITextField Delegate methods

extension GSSignUpViewController:UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextField = textField as? GSBaseTextField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
     }
    
}

// MARK: TextField Handlings

var activeTextField:GSBaseTextField?

extension GSSignUpViewController {
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardShownOrHidden(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardShownOrHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyBoardShownOrHidden(_ notification:Notification?) {
        
        var keyBoardFrame = CGRect.zero
        
        if let info = (notification as NSNotification?)?.userInfo {
            
            if let kbFrame = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                keyBoardFrame = kbFrame
            }
        }
        
        if notification?.name == Notification.Name.UIKeyboardDidShow {
            
            mainScrollView.contentSize = CGSize(width: mainScrollView.frame.size.width, height: (loginWithOTPbtn.superview?.frame.origin.y)! + (loginWithOTPbtn.superview?.frame.size.height)! + keyBoardFrame.size.height + 10)
            
            let boardY = view.frame.size.height - keyBoardFrame.size.height
            
            var currentTfBottom = (activeTextField?.frame.origin.x)! + (activeTextField?.frame.size.height)!
            
            if let tfSuper = activeTextField?.superview {
                currentTfBottom += tfSuper.frame.origin.y
                if let someView = tfSuper.superview {
                    currentTfBottom += someView.frame.origin.y
                    if let scroll = someView.superview {
                        currentTfBottom += scroll.frame.origin.y
                    }
                }
            }
            currentTfBottom = currentTfBottom - mainScrollView.contentOffset.y
            let currentOffset = mainScrollView.contentOffset
            
            if currentTfBottom > boardY {
                let theDiff = currentTfBottom - boardY + 10
                mainScrollView.setContentOffset(CGPoint(x: currentOffset.x, y: currentOffset.y + theDiff), animated: true)
            } else {
                if currentOffset.y > 0 {
                    let theDiff = boardY - currentTfBottom
                    
                    if theDiff > currentOffset.y {
                        mainScrollView.setContentOffset(CGPoint(x: currentOffset.x, y: 0), animated: true)
                    } else {
                        mainScrollView.setContentOffset(CGPoint(x: currentOffset.x, y: currentOffset.y - theDiff), animated: true)
                    }
                }
            }
        } else {
            mainScrollView.contentSize = CGSize(width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
            mainScrollView.setContentOffset(CGPoint(x: mainScrollView.contentOffset.x, y: 0), animated: true)
        }
        
    }
}

