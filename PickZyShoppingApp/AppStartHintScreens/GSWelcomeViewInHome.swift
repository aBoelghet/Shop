//
//  GSWelcomeViewInHome.swift
//  Shopor
//
//  Created by Ratheesh on 13/08/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa

class GSWelcomeViewInHome: NibView, WKNavigationDelegate {
    
    //    @IBOutlet weak var welcomeNote_webView: UIWebView!
    @IBOutlet weak var welcomeNoteHeight_constraint: NSLayoutConstraint!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var welcomeNote_wkWebView: WKWebView!
    
    var messageText = ""
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupThisView()
    }
    
    private func setupThisView() {
        
        welcomeNote_wkWebView.navigationDelegate = self
        
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()
    }
    
    func updateData() {
        welcomeNote_wkWebView.loadHTMLString("<meta name=\"viewport\" content=\"initial-scale=1.0\" />" + messageText, baseURL: nil)
    }
    
    func updateContentSize() {
        
        if welcomeNote_wkWebView.isLoading == false {
            
            DispatchQueue.main.async {
                self.welcomeNoteHeight_constraint.constant = self.welcomeNote_wkWebView.scrollView.contentSize.height
            }
        }
    }
    
    @IBAction func close_action(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { _ in
            
            if let shopVC = GSTopViewController.topViewController() as? GSShopsViewController {
                shopVC.referralAmountAPI()
            }
            
            self.removeFromSuperview()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.indicatorView.stopAnimating()
        
        webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
            self.welcomeNoteHeight_constraint.constant = height as! CGFloat
        })
    }
    
}
