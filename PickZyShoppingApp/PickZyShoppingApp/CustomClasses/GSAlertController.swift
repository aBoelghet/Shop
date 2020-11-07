//
//  GSAlertController.Swift
//  GSAlertController
//
//  Created by Arpit Jain on 13/12/17.
//  Copyright © 2017 Arpit Jain. All rights reserved.
//

import UIKit
import Foundation

class GSAlertController: UIViewController {
    
    // MARK:- Private Properties
    // MARK:-
    
    private var alertTitle_str = GSString.AppName
    private var alertMessage_str = String()
    private var cancelButtonTitle_str:String?
    private var otherButtonTitle_str:String?
    private var extraDetails_str:String?

    private var btnOtherColor  = UIColor.init(hexString: "FFFFFF")
//    private let btnCancelColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    
    // MARK:- Public Properties
    // MARK:-
    
    @IBOutlet var viewAlert: UIView!
    @IBOutlet var viewAlertBtns: UIView!

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblAlertText: UILabel?
    @IBOutlet var lblDetailText: UILabel?
    
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnOther: UIButton!
    @IBOutlet var btnOK: UIButton!
    
    @IBOutlet var alertWidthConstraint: NSLayoutConstraint!
    
    /// AlertController Completion handler
    typealias alertCompletionBlock = ((Int, String) -> Void)?
    private var block : alertCompletionBlock?
    
    // MARK:- GSAlertController Initialization
    // MARK:-
    
    /**
     Creates a instance for using GSAlertController
     - returns: GSAlertController
     */
    static func initialization() -> GSAlertController
    {
        let alertController = GSAlertController(nibName: "GSAlertController", bundle: nil)
        return alertController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGSAlertController()
    }
    
    // MARK:- GSAlertController Private Functions
    // MARK:-
    
    /// Inital View Setup
    private func setupGSAlertController(){
        
        preferredAlertWidth()
        
        viewAlert.layer.cornerRadius  = 6.0
        viewAlert.layer.shadowOffset  = CGSize(width: 0.0, height: 0.0)
        viewAlert.layer.shadowColor   = UIColor(white: 0.0, alpha: 1.0).cgColor
        viewAlert.layer.shadowOpacity = 0.3
        viewAlert.layer.shadowRadius  = 3.0
        
        lblTitle.text   = alertTitle_str
        lblAlertText?.text   = alertMessage_str
        lblDetailText?.text  = extraDetails_str
        
        lblTitle.backgroundColor = UIColor(hexString: defaultTheme.alertTitle_BG)
        
        if let aCancelTitle = cancelButtonTitle_str {
            btnCancel.setTitle(aCancelTitle, for: .normal)
            btnOK.setTitle(nil, for: .normal)
            btnCancel.setTitleColor(btnOtherColor, for: .normal)
        } else {
            btnCancel.isHidden  = true
        }
        
        if let aOtherTitle = otherButtonTitle_str {
            btnOther.setTitle(aOtherTitle, for: .normal)
            btnOK.setTitle(nil, for: .normal)
            btnOther.setTitleColor(btnOtherColor, for: .normal)
        } else {
            btnOther.isHidden  = true
        }
        
        if btnOK.title(for: .normal) != nil {
            btnOK.setTitleColor(btnOtherColor, for: .normal)
        } else {
            btnOK.isHidden  = true
        }
    }
    
    /// Setup different widths for iPad and iPhone
    private func preferredAlertWidth()
    {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            alertWidthConstraint.constant = UIScreen.main.bounds.width - 40
        case .pad:
            alertWidthConstraint.constant = 340.0
        case .unspecified: break
        case .tv: break
        case .carPlay: break
        }
    }
    
    /// Create and Configure Alert Controller
    private func configure(title: String, message:String, extraDetails:String?, cancelButtonTitle_str:String?, btnOtherTitle:String?)
    {
        self.alertMessage_str          = message
        self.cancelButtonTitle_str     = cancelButtonTitle_str
        self.otherButtonTitle_str    = btnOtherTitle
        self.alertTitle_str = title
        self.extraDetails_str = extraDetails
    }
    
    /// Show Alert Controller
    private func show()
    {
        if let appDelegate = UIApplication.shared.delegate, let window = appDelegate.window, let rootViewController = window?.rootViewController {
            
            var topViewController = rootViewController
            while topViewController.presentedViewController != nil {
                topViewController = topViewController.presentedViewController!
            }
            
            topViewController.addChildViewController(self)
            topViewController.view.addSubview(view)
            viewWillAppear(true)
            didMove(toParentViewController: topViewController)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            view.alpha = 0.0
            view.frame = topViewController.view.bounds
            
            viewAlert.alpha     = 0.0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.view.alpha = 1.0
            }, completion: nil)
            
            viewAlert.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            viewAlert.center    = CGPoint(x: (self.view.bounds.size.width/2.0), y: (self.view.bounds.size.height/2.0)-10)
            UIView.animate(withDuration: 0.2 , delay: 0.1, options: .curveEaseOut, animations: { () -> Void in
                self.viewAlert.alpha = 1.0
                self.viewAlert.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.viewAlert.center    = CGPoint(x: (self.view.bounds.size.width/2.0), y: (self.view.bounds.size.height/2.0))
            }, completion: nil)
        }
    }
    
    /// Hide Alert Controller
    private func hide(btn_tag:Int, title_str:String)
    {
        self.view.endEditing(true)
        self.viewAlert.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.viewAlert.alpha = 0.0
            self.viewAlert.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.viewAlert.center    = CGPoint(x: (self.view.bounds.size.width/2.0), y: (self.view.bounds.size.height/2.0)-5)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 0.05, options: .curveEaseIn, animations: { () -> Void in
            self.view.alpha = 0.0
            
        }) { (completed) -> Void in
            
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            
            self.block!!(btn_tag, title_str)
        }
    }
    
    // MARK:- UIButton Clicks
    // MARK:-
    
    @IBAction func btnCancelTapped(sender: UIButton) {
        hide(btn_tag: 0, title_str: cancelButtonTitle_str!)
//        block!!(0,cancelButtonTitle_str!)
    }
    
    @IBAction func btnOtherTapped(sender: UIButton) {
        hide(btn_tag: 1, title_str: otherButtonTitle_str!)
//        block!!(1,otherButtonTitle_str!)
    }
    
    @IBAction func btnOkTapped(sender: UIButton) 
    {
        block!!(0,"OK")
        hide(btn_tag: 0, title_str: "OK")
    }
    
    /// Hide Alert Controller on background tap
    @objc func backgroundViewTapped(sender:AnyObject)
    {
//        hide(btn_tag: 0, title_str: "")
    }
    
    // MARK:- AJAlert Functions
    // MARK:-
    
    /**
     Display an Alert With "OK" Button
     
     - parameter aStrMessage: Message to display in Alert
     - parameter completion:  Completion block. OK Button Index - 0
     */
    
    public func showAlertWithOkButton( title: String,
                                       aStrMessage:String,
                                       completion : alertCompletionBlock){
        configure(title: title, message: aStrMessage, extraDetails: nil, cancelButtonTitle_str: nil, btnOtherTitle: nil)
        show()
        btnOK.backgroundColor = UIColor(hexString: defaultTheme.singleBtnAlert_OkBtn_BG)
        btnOtherColor  = UIColor.init(hexString: "FFFFFF")
        lblAlertText?.textColor = UIColor(hexString: defaultTheme.singleBtnAlert_msg_text)
        lblAlertText?.font = UIFont(name:"Helvetica Neue", size: 18.0)

        block = completion
    }
    
    /**
     Display an Alert
     
     - parameter aStrMessage:    Message to display in Alert
     - parameter aCancelBtnTitle: Cancel button title
     - parameter aOtherBtnTitle: Other button title
     - parameter otherButtonArr: Array of other button title
     - parameter completion:     Completion block. Other Button Index - 1 and Cancel Button Index - 0
     */
    
    public func showAlert(title: String,
                           aStrMessage:String,
                           aCancelBtnTitle:String?,
                           aOtherBtnTitle:String? ,
                           completion : alertCompletionBlock){
        configure( title: title, message: aStrMessage, extraDetails: nil, cancelButtonTitle_str: aCancelBtnTitle, btnOtherTitle: aOtherBtnTitle)
        show()
        btnCancel.backgroundColor = UIColor(hexString: defaultTheme.cancelOrderAlert_NoBtn_BG)
        btnOther.backgroundColor = UIColor(hexString: defaultTheme.cancelOrderAlert_YesBtn_BG)
        btnOtherColor  = UIColor.init(hexString: "FFFFFF")
        lblAlertText?.textColor = UIColor(hexString: defaultTheme.cancelOrderAlert_msg_text)
        lblAlertText?.font = UIFont(name:"Helvetica Neue", size: 18.0)
        block = completion
    }
    
    public func showAlertWithDetails(title: String,
                          aStrMessage:String,
                          detailText:String?,
                          aCancelBtnTitle:String?,
                          aOtherBtnTitle:String? ,
                          completion : alertCompletionBlock){
        configure( title: title, message: aStrMessage, extraDetails: detailText, cancelButtonTitle_str: aCancelBtnTitle, btnOtherTitle: aOtherBtnTitle)

        show()
        btnCancel.backgroundColor = UIColor(hexString: defaultTheme.paymentMadeAlert_Btn_BG)
        btnOther.backgroundColor = UIColor(hexString: defaultTheme.paymentMadeAlert_Btn_BG)
        btnOtherColor  = UIColor.init(hexString: defaultTheme.paymentMadeAlert_Btn_BG)
        lblAlertText?.textColor = UIColor(hexString: defaultTheme.paymentMadeAlert_msg_text)
        lblAlertText?.font = UIFont(name:"Helvetica Neue Bold", size: 18.0)

        block = completion
    }
}

