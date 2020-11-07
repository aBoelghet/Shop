//
//  GSOfferPopupView.swift
//  Shopor
//
//  Created by Ratheesh on 09/07/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import WebKit

class GSOfferPopupView: NibView, WKNavigationDelegate {
    
    @IBOutlet weak var bg_view: GSCornerEdgeView!
    
//    @IBOutlet weak var welcomeNote_webView: UIWebView!
    @IBOutlet weak var welcomeNote_wkWebView: WKWebView!
    @IBOutlet weak var welcomeNoteHeight_constraint: NSLayoutConstraint!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var topConstraintRef: NSLayoutConstraint!
    
    var timer_instance: Timer?
    
    var htmlString: String = ""

    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    // MARK: - Setting up the View
    
    private func setUpThisView() {
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapGestureAction(_:)))
        
        self.addGestureRecognizer(tapGesture)
        
        welcomeNote_wkWebView.navigationDelegate = self
        indicatorView.hidesWhenStopped = true
        
    }
    
    

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        

        self.indicatorView.stopAnimating()

        webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
            self.welcomeNoteHeight_constraint.constant = height as! CGFloat
        })
    }
    
    func showTheView(on view:UIView, for reqFrame:CGRect) {
        
        view.addSubview(self)
        view.endEditing(true)

        
        frame = CGRect(x: reqFrame.origin.x, y: view.frame.size.height, width: reqFrame.size.width, height: reqFrame.size.height)
        
        UIView.animate(withDuration: 0.45, animations: {
            self.frame = reqFrame
            
        }) {  _ in
            
            self.addConstraintsForTheView(reqFrame)
            
            DispatchQueue.main.async {
                self.indicatorView.startAnimating()
                self.welcomeNote_wkWebView.loadHTMLString(self.htmlString, baseURL: nil)
            }
            
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
    
    func initiateAutoClose() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.removeThisViewFromSuperView()
        }
    }
    
    @objc private func swipeGestureAction(_ gesture: UISwipeGestureRecognizer) {
        removeThisViewFromSuperView()
    }
    
    @objc private func tapGestureAction(_ gesture: UISwipeGestureRecognizer) {
        removeThisViewFromSuperView()
    }
    
    @IBAction private func closeAction(_ sender: UIButton) {
        
        removeThisViewFromSuperView()
    }
    
    private func removeThisViewFromSuperView() {
        
        self.removeTheViewFrom(view: self.superview!)
    }
}
