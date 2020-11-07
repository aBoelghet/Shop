//
//  GSHelpDetailViewController.swift
//  Shopor
//
//  Created by Ratheesh on 07/03/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import WebKit

class GSHelpDetailViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
//    @IBOutlet weak var webView: UIWebView!
    
    var helpDetails_webView: WKWebView!
    
    var orderRootId = ""
    var titleId = ""
    var isBuzzEnabled = false
    var lastBuzz = ""
    
    var contentLoaded = ""
    var titleString = ""
    var isContentLoaded = false
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyColors()
        addFewIntializers()
        helpDetailsAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Configuring With Data
    
    func configureHelpDetailsWith(order_root_id:String, title_id:String, is_buzz_enabled:Bool, title_str:String) {
        self.orderRootId = order_root_id
        self.titleId = title_id
        self.isBuzzEnabled = is_buzz_enabled
        self.titleString = title_str
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        
//        webView.backgroundColor = UIColor.white
    }
    
    // MARK: User defined Methods
    
    private func addFewIntializers() {
        navigationBar_view.delegate = self
        navigationBar_view.titleText = titleString
        
//        webView.isHidden = true

        let webConfiguration = WKWebViewConfiguration()
        helpDetails_webView = WKWebView(frame: .zero, configuration: webConfiguration)

        view.addSubview(helpDetails_webView)
        helpDetails_webView.translatesAutoresizingMaskIntoConstraints = false

        helpDetails_webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        helpDetails_webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        helpDetails_webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        helpDetails_webView.topAnchor.constraint(equalTo: navigationBar_view.bottomAnchor).isActive = true

        navigationBar_view.rightBarBtn.isHidden = true
        if isBuzzEnabled {
            navigationBar_view.rightBarBtn.isHidden = false
        }
    }
}

// MARK: - API Methods

extension GSHelpDetailViewController {
    
    fileprivate func helpDetailsAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.orderHelp_content + titleId
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSHelpContentModel.self, from: responseData)
                    
//                    weakSelf.webView.loadHTMLString(responseModel.data?.content ?? "", baseURL: nil)
                    weakSelf.helpDetails_webView.loadHTMLString("<meta name=\"viewport\" content=\"initial-scale=1.0\" />" + (responseModel.data?.content ?? ""), baseURL: nil)
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? GSString.API.unknownError, viewController: weakSelf)
            }
        }
    }
    
    fileprivate func buzzAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.deliveryDelayBuzz
        
        let parameters = ["order_id": orderRootId] as [String:AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: parameters,urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)

                    CustomAlert.showAlert(title: GSString.AppName, message: responseModel.message ?? "", viewController: weakSelf)
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? GSString.API.unknownError, viewController: weakSelf)
            }
        }
    }
    
}


// MARK:- NavigationBar Methods

extension GSHelpDetailViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender:UIButton) {
        
        buzzAPI()
    }
}
