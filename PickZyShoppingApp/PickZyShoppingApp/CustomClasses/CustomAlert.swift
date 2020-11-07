//
//  CustomAlert.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/21/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import UIKit

class CustomAlert: NSObject {
    
    class func showAlert(title: String ,message: String , viewController:UIViewController){
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okaction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            //viewController.present(viewController,animated: true,completion: nil)
        })
        alert.addAction(okaction)
        viewController.present(alert,animated: true,completion: nil)
    }
    
    //MARK: - Alert Controller with multiple buttons
    
    class func showAlert(title: String ,message: String , alertButtonsArray:[String] , viewController:UIViewController,completion: @escaping (Int) -> ()){
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        for actionTitle in alertButtonsArray {
            let alertAction = UIAlertAction.init(title: actionTitle, style: .default) { action in
                completion(alertButtonsArray.index(of: actionTitle)!)
            }
            alert.addAction(alertAction)
        }
        
        viewController.present(alert,animated: true,completion: nil)
    }
    
    
    class func showAlert(title: String ,message: String , alertButtonsArray:[String], isLastButtonDestructive:Bool , viewController:UIViewController,completion: @escaping (Int) -> ()){
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        for index in 0..<alertButtonsArray.count {
            let actionTitle = alertButtonsArray[index]
            
            var actionStyle:UIAlertActionStyle = .default
            
            if isLastButtonDestructive {
                if index == alertButtonsArray.count - 1 {
                    actionStyle = .destructive
                }
            }
            
            let alertAction = UIAlertAction.init(title: actionTitle, style: actionStyle) { action in
                completion(alertButtonsArray.index(of: actionTitle)!)
            }
            alert.addAction(alertAction)
        }
        
        viewController.present(alert,animated: true,completion: nil)
    }
    
    //MARK: - Action Sheet with multiple buttons
    
    class func showActionSheet(title:String?,message:String?,cancelTitle:String,optionArray:[String],sourceView:UIView?,in VC:UIViewController,completion: @escaping (Int) -> ()) {
        
        let alertController = UIAlertController.init(title: title ?? nil, message: message ?? nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction.init(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        for option in optionArray {
            let alertAction = UIAlertAction.init(title: option, style: .default) { action in
                completion(optionArray.index(of: option)!)
            }
            alertController.addAction(alertAction)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            guard let theView = sourceView else {return}
            if let currentPopoverpresentioncontroller = alertController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = theView
                let viewFrame = theView.frame
                currentPopoverpresentioncontroller.sourceRect = CGRect(x: 0, y: 0, width: viewFrame.size.width, height: viewFrame.size.height)
                currentPopoverpresentioncontroller.permittedArrowDirections = .any
                VC.present(alertController, animated: true, completion: nil)
            }
        }else{
            VC.present(alertController, animated: true, completion: nil)
        }
        
    }
}
