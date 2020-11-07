//
//  NotificationNavigationBar.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh Mac Mini on 04/06/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

@objc protocol NavigationWithSegmentDelegate :class {
    
    func leftBarBtnPressed(sender: UIButton)
    func segmentPressed(index: Int)

    func rightBarBtnPressed(sender: UIButton)
}

class NotificationNavigationBar: NibView {

    @IBOutlet weak var leftBarBtn: UIButton!
    @IBOutlet weak var rightBarBtn: UIButton!
    @IBOutlet weak var titleLable: GSBaseLabel!
    @IBOutlet weak var leftBarImage: UIImageView!
    @IBOutlet weak var rightBarImage: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var bottomLine_view:UIView!
    @IBOutlet weak var notificationIconButton: MIBadgeButton!

    weak var delegate: NavigationWithSegmentDelegate?


    override init(frame: CGRect) {
        
        super.init(frame: frame)
        initialSetUp()
    }
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        initialSetUp()
    }
    override func prepareForInterfaceBuilder() {
        
        initialSetUp()
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
        
        segmentControl.apportionsSegmentWidthsByContent = false
        notificationIconButton.badgeEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0)
        notificationIconButton.badgeTextColor = UIColor.white
        notificationIconButton.badgeBackgroundColor = UIColor.red
        
        titleLable.textColor = UIColor(hexString: defaultTheme.NAVIGATION_TITLE_COLOR)
        rightBarBtn.setTitleColor(UIColor(hexString: defaultTheme.NavBarBtnTitle), for: .normal)
        leftBarBtn.setTitleColor(UIColor(hexString: defaultTheme.NavBarBtnTitle), for: .normal)
        self.view.backgroundColor = UIColor(hexString: defaultTheme.NAVIGATION_BG_COLOR)
        bottomLine_view.backgroundColor = UIColor(hexString: defaultTheme.NavBarBottomLine)
    }
    
    // MARK: User defined methods
    private func initialSetUp() {
        applyColors()
    }
    
    // MARK: IBAction methods
    @IBAction func leftBarBtnAction(_ sender: UIButton) {
        
        delegate?.leftBarBtnPressed(sender: sender)
    }
    
    @IBAction func rightBarBtnAction(_ sender: UIButton) {
        
        delegate?.rightBarBtnPressed(sender: sender)
    }
    
    @IBAction func segmentPressed(_ sender: UISegmentedControl) {
        
        delegate?.segmentPressed(index: sender.selectedSegmentIndex)
    }
    
    //MARK: Inspectables
    @IBInspectable var leftBtnimage:UIImage = UIImage() {
        didSet {
            leftBarImage.image = leftBtnimage
        }
    }
    @IBInspectable var rightBtnimage:UIImage = UIImage() {
        didSet {
            rightBarImage.image = rightBtnimage
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
    
    @IBInspectable var rightBtnTitle:String = "" {
        didSet {
            rightBarBtn.setTitle(rightBtnTitle, for: .normal)
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
