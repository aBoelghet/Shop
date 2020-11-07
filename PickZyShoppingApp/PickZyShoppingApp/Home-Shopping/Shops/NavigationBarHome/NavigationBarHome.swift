//
//  NavigationBarHome.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/22/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

protocol NavigationBarHomeDelegate:class {
    func leftBarBtnPressed(sender:UIButton)
    func rightBarBtnPressed(sender:UIButton)
    func secondRightBarBtnPressed(sender:UIButton)
    func thirdRightBarBtnPressed(sender:UIButton)
    func rewardBtnPressed(sender:UIButton)
}

@IBDesignable class NavigationBarHome: NibView {
    
    weak var delegate:NavigationBarHomeDelegate?
    
    @IBOutlet weak var leftBarBtn: UIButton!
    @IBOutlet weak var rightBarBtn: UIButton!
    @IBOutlet weak var secondRightBarBtn: UIButton!
    @IBOutlet weak var thirdRightBarBtn: UIButton!
    @IBOutlet weak var titleLable: GSBaseLabel!
    @IBOutlet weak var bottomLine_view:UIView!
    @IBOutlet weak var cartIconView:GSCartIconView!
    @IBOutlet weak var rewardImageButton: MIBadgeButton!
    @IBOutlet weak var rewardButton: UIButton!
    
    @IBOutlet weak var notificationCountButton: MIBadgeButton!
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
        
        notificationCountButton.badgeEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 5)
        notificationCountButton.badgeTextColor = UIColor.white
        notificationCountButton.badgeBackgroundColor = UIColor.red
        
        titleLable.textColor = UIColor(hexString: defaultTheme.NAVIGATION_TITLE_COLOR)
        leftBarBtn.setTitleColor(UIColor(hexString: defaultTheme.NavBarBtnTitle), for: .normal)
        self.view.backgroundColor = UIColor(hexString: defaultTheme.NAVIGATION_BG_COLOR)
        bottomLine_view.backgroundColor = UIColor(hexString: defaultTheme.NavBarBottomLine)

        thirdRightBarBtn.isHidden = true
        rewardImageButton.isHidden = true
        rewardButton.isHidden = true
        rewardImageButton .setImage(UIImage.gifImageWithName("reward_Icon"), for: .normal)
        rewardImageButton.badgeEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0)
        rewardImageButton.badgeTextColor = UIColor.white
        rewardImageButton.badgeBackgroundColor = UIColor.red
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
    @IBAction func secondRightBarBtnAction(_ sender: UIButton) {
        delegate?.secondRightBarBtnPressed(sender: sender)
    }
    @IBAction func thirdRightBarBtnAction(_ sender: UIButton) {
        delegate?.thirdRightBarBtnPressed(sender: sender)
    }
    @IBAction func rewardButtonAction(_ sender: UIButton) {
        delegate?.rewardBtnPressed(sender: sender)
        
    }
    //MARK: Inspectables
    @IBInspectable var titleText:String = "" {
        didSet {
            titleLable.text = titleText
        }
    }

}
