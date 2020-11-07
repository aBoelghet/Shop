//
//  GSBaseViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/26/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSBaseViewController: UIViewController {
    
    let loader = AJProgressView()
    
    var viewInfoLable:UILabel!
    var isVisible = false
    
    var locationPermissionStackView: UIStackView!
    
    //MARK: - UIViewController Methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let navigationBarAppearace = self.navigationController?.navigationBar
        navigationBarAppearace?.barTintColor = UIColor.darkGray
        navigationBarAppearace?.tintColor = UIColor.white
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isVisible = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isVisible = false
//        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
    }

    func addInfoLableWith(_ message:String) {
        
        if viewInfoLable != nil, viewInfoLable.isDescendant(of: view) {
            viewInfoLable.text = message
            return
        }
        
        viewInfoLable = UILabel()
        view.addSubview(viewInfoLable)
        
        viewInfoLable.translatesAutoresizingMaskIntoConstraints = false
        
        viewInfoLable.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        viewInfoLable.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewInfoLable.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.7, constant: 0).isActive = true
        
        viewInfoLable.textAlignment = .center
        
        viewInfoLable.numberOfLines = 0
        viewInfoLable.text = message
        viewInfoLable.textColor = UIColor.darkGray
    }
    
    func removeInfoLable() {
        
        if viewInfoLable != nil, viewInfoLable.isDescendant(of: view) {
            viewInfoLable.removeFromSuperview()
        }
    }
    
    func addSideMenu() {
        
        if let theMenuBar = menuBar {
            if (theMenuBar.isDescendant(of: view)) {
                return
            }
        }
        view.endEditing(true)
        if menuBar == nil {
            menuBar = GSMenuBarView.init()
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let theWindow = appDelegate.window else { return }
        theWindow.addSubview(menuBar!)
        menuBar?.showTheViewOn(theWindow)
    }
    
//    func addLocationPermissionLinkView() {
//
//        locationPermissionStackView = UIStackView()
//        locationPermissionStackView.axis = .vertical
//
//        view.addSubview(locationPermissionStackView)
//
//        locationPermissionStackView.translatesAutoresizingMaskIntoConstraints = false
//
//        locationPermissionStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        locationPermissionStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        locationPermissionStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
//        locationPermissionStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20).isActive = true
//
//        let infoLable = UILabel()
//        infoLable.textAlignment = .center
//        infoLable.font = UIFont.systemFont(ofSize: 14)
//
//        infoLable.text = "Location permission denied"
//        infoLable.numberOfLines = 0
//        infoLable.lineBreakMode = .byWordWrapping
//
//        locationPermissionStackView.addSubview(infoLable)
//
//        let linkButton = UIButton()
//        linkButton.setTitle("Click here", for: .normal)
//        linkButton.addTarget(self, action: #selector(locationLinkButtonAction(_:)), for: .touchUpInside)
//
//        locationPermissionStackView.addSubview(linkButton)
//    }
//
//    func removeLocationPermissionLinkView() {
//
//        if locationPermissionStackView != nil, locationPermissionStackView.isDescendant(of: self.view) {
//            locationPermissionStackView.removeFromSuperview()
//        }
//    }
//
//    @objc private func locationLinkButtonAction(_ sender: UIButton) {
//
//    }
}




