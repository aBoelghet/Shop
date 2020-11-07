//
//  NavigationBarNormal.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/23/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

@objc protocol NavigationBarNormalDelegate:class {
    
    func leftBarBtnPressed(sender:UIButton)
    func rightBarBtnPressed(sender:UIButton)
}

@IBDesignable class NavigationBarNormal: NibView {
    
    weak var delegate:NavigationBarNormalDelegate?
    
    @IBOutlet weak var leftBarBtn: UIButton!
    @IBOutlet weak var rightBarBtn: UIButton!
    @IBOutlet weak var titleLable: GSBaseLabel!
    @IBOutlet weak var leftBarImage: UIImageView!
    @IBOutlet weak var rightBarImage: UIImageView!
    @IBOutlet weak var bottomLine_view:UIView!
    
    @IBOutlet weak var leftBarBtnLeading_constraint:NSLayoutConstraint!
    @IBOutlet weak var rightBarBtnTrailing_constraint:NSLayoutConstraint!
    
    let leftBarBtnLeading:CGFloat = 5.0
    let rightBarBtnTrailing:CGFloat = 5.0
    
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
        rightBtnTitleColor = UIColor(hexString: defaultTheme.NavBarBtnTitle)
        leftBtnTitleColor = UIColor(hexString: defaultTheme.NavBarBtnTitle)
        self.view.backgroundColor = UIColor(hexString: defaultTheme.NAVIGATION_BG_COLOR)
        bottomLine_view.backgroundColor = UIColor(hexString: defaultTheme.NavBarBottomLine)
    }

    // MARK: User defined methods
    private func someSetUps() {
        applyColors()
        
        setUpLeftBarButtonLeading()
        setUpRightBarButtonTrailing()
    }
    
    private func setUpLeftBarButtonLeading() {
        if (leftBarBtn.titleLabel?.text ?? "") == "" {
            leftBarBtnLeading_constraint.constant = 0
        } else {
            leftBarBtnLeading_constraint.constant = leftBarBtnLeading
        }
    }
    
    private func setUpRightBarButtonTrailing() {
        if (rightBarBtn.titleLabel?.text ?? "") == "" {
            rightBarBtnTrailing_constraint.constant = 0
        } else {
            rightBarBtnTrailing_constraint.constant = rightBarBtnTrailing
        }
    }
    
    @IBAction func leftBarBtnAction(_ sender: UIButton) {
        delegate?.leftBarBtnPressed(sender: sender)
    }
    
    @IBAction func rightBarBtnAction(_ sender: UIButton) {
        delegate?.rightBarBtnPressed(sender: sender)
    }
    
    //MARK: Inspectables
    @IBInspectable var leftBtnimage:UIImage = UIImage() {
        didSet {
            leftBarImage.image = leftBtnimage
        }
    }
    
    @IBInspectable var rightBtnImage:UIImage = UIImage() {
        didSet {
            rightBarImage.image = rightBtnImage
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
            setUpLeftBarButtonLeading()
        }
    }
    
    @IBInspectable var rightBtnTitle:String = "" {
        didSet {
            rightBarBtn.setTitle(rightBtnTitle, for: .normal)
            setUpRightBarButtonTrailing()
        }
    }
    
    @IBInspectable var rightBtnTitleColor:UIColor = UIColor() {
        didSet {
            rightBarBtn.setTitleColor(rightBtnTitleColor, for: .normal)
        }
    }
    
    @IBInspectable var leftBtnTitleColor:UIColor = UIColor() {
        didSet {
            leftBarBtn.setTitleColor(leftBtnTitleColor, for: .normal)
        }
    }
}







