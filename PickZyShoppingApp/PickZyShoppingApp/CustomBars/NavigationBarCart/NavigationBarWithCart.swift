//
//  NavigationBarWithCart.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/23/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

protocol NavigationBarCartDelegate:class {
    func leftBarBtnPressed(sender:UIButton)
    func rightBarBtnPressed(sender:UIButton)
}

@IBDesignable class NavigationBarWithCart: NibView {
    
    weak var delegate:NavigationBarCartDelegate?
    
    @IBOutlet weak var leftBarBtn: UIButton!
    @IBOutlet weak var rightBarBtn: UIButton!
    @IBOutlet weak var titleLable: GSBaseLabel!
    @IBOutlet weak var cartIconView:GSCartIconView!
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
        GSConstant.linearBar.progressBarPositionChange()
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        
        titleLable.textColor = UIColor(hexString: defaultTheme.NAVIGATION_TITLE_COLOR)
        rightBarBtn.setTitleColor(UIColor(hexString: defaultTheme.NavBarBtnTitle), for: .normal)
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
    
    @IBAction func rightBarBtnAction(_ sender: UIButton) {
        delegate?.rightBarBtnPressed(sender: sender)
    }
    
    //MARK: Inspectables
    @IBInspectable var titleText:String = "" {
        didSet {
            titleLable.text = titleText
        }
    }
}



