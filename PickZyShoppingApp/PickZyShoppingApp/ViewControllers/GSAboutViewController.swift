//
//  GSSupportViewController.swift
//  Shopor
//
//  Created by Ratheesh on 04/03/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSAboutViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var main_stackView:UIStackView!
    @IBOutlet weak var main_scrollView:UIScrollView!
    @IBOutlet weak var version_lbl:GSBaseLabel!
    @IBOutlet weak var poweredBy_lbl:GSBaseLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Colors For UI
    
    private func applyColors() {
        poweredBy_lbl.textColor = UIColor.lightGray
    }
    
    // MARK: User defined Methods
    
    private func addFewIntializers() {
        navigationBar_view.delegate = self
        navigationBar_view.titleText = "About"
        poweredBy_lbl.text = "Powered by PickZy Software Pvt Ltd"
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        version_lbl.text = "\(GSString.AppName) \(GSConstant.appVersionPrefix) " + appVersion
    }
    
    // MARK: - View Controller Action Methods
    
    @IBAction private func termsAndConditionAction(_ sender: UIButton) {
        
        guard let url = URL(string: GSConstant.termsAndConditions_url) else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction private func privacyPolicyAction(_ sender: UIButton) {
        
        guard let url = URL(string: GSConstant.privacyPolicy_url) else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction private func appWebSiteAction(_ sender: UIButton) {
        
        guard let url = URL(string: GSConstant.appWebsite_url) else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
}

// MARK:- NavigationBar Methods
extension GSAboutViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        
        addSideMenu()
    }
    
    func rightBarBtnPressed(sender:UIButton) {
    }
}
