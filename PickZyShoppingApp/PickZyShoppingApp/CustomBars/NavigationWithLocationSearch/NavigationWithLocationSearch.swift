//
//  NavigationWithLocationSearch.swift
//  PickZyShoppingApp
//
//  Created by Purushoth on 29/09/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

import UIKit

@objc protocol NavigationWithLocationSearchBarDelegate:class {
    
    func leftBarBtnPressed(sender:UIButton)
    
}

@IBDesignable class NavigationWithLocationSearchBar: NibView {
    
    weak var delegate:NavigationWithLocationSearchBarDelegate?
    
    @IBOutlet weak var leftBarBtn: UIButton!
    @IBOutlet weak var titleLable: GSBaseLabel!
    @IBOutlet weak var leftBarImage: UIImageView!
    @IBOutlet weak var navigSearchBar:GSSearchBar!
    @IBOutlet weak var bottomLine_view:UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        someSetUps()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        someSetUps()
    }
    
    override func prepareForInterfaceBuilder() {
        someSetUps()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        navigationBarReload()
    }
    
    func navigationBarReload() {
        GSConstant.progressYaxis = self.frame.size.height + GSConstant.deviceTopStatusBarHeight
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        
        titleLable.textColor = UIColor(hexString: defaultTheme.NAVIGATION_TITLE_COLOR)
        leftBarBtn.setTitleColor(UIColor(hexString: defaultTheme.NavBarBtnTitle), for: .normal)
        self.view.backgroundColor = UIColor(hexString: defaultTheme.NAVIGATION_BG_COLOR)
        bottomLine_view.backgroundColor = UIColor(hexString: defaultTheme.NavBarBottomLine)
    }
    
    // MARK: User defined methods
    private func someSetUps() {
        applyColors()
    }
    
    @IBAction func leftBarBtnAction(_ sender: UIButton) {
        delegate?.leftBarBtnPressed(sender: sender)
    }
    
    //MARK: Inspectables
    @IBInspectable var leftBtnimage:UIImage = UIImage() {
        didSet {
            leftBarImage.image = leftBtnimage
        }
    }
    
    @IBInspectable var titleText:String = "" {
        didSet {
            titleLable.text = titleText
        }
    }
    
    @IBInspectable var leftBtnTitle:String = "" {
        didSet {
            leftBarBtn.setTitle(leftBtnTitle, for: .normal)
        }
    }
    
    @IBInspectable var leftBtnTitleColor:UIColor = UIColor() {
        didSet {
            leftBarBtn.setTitleColor(leftBtnTitleColor, for: .normal)
        }
    }
    
    @IBInspectable var searchPlaceHolder:String = "" {
        didSet{
            navigSearchBar.placeholder = searchPlaceHolder
        }
    }
}

