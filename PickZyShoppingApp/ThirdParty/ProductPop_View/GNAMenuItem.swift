//
//  Created by Kateryna Gridina.
//  Copyright (c) gridNA. All rights reserved.
//  Latest version can be found at https://github.com/gridNA/GNAContextMenu
//

import UIKit

public class GNAMenuItem: UIView {
    
    public var itemId: String?
    public var angle: CGFloat = 0
    public var defaultLabelMargin: CGFloat = 6
    
    private var titleView: UIView?
    private var titleLabel: UILabel?
    private var menuIcon: UIImageView!
    
    private var infoLabel:UILabel!
    
    private var titleText: String?
    private var activeMenuIcon: UIImageView?
    
    public convenience init(text:String?,bgColor:UIColor,textColor:UIColor) {
        
        var widthOfLabel:CGFloat = 150
        var locLabelHeight:CGFloat = 0
        let topVC = GSTopViewController.topViewController()
        
        let horizontalClass = topVC.view.traitCollection.horizontalSizeClass
        let verticalClass = topVC.view.traitCollection.verticalSizeClass
        
        if horizontalClass == UIUserInterfaceSizeClass.regular && verticalClass == UIUserInterfaceSizeClass.regular {
            locLabelHeight = 25
            widthOfLabel = 180
        } else {
            locLabelHeight = 20
        }
        
        let frame = CGRect(x: 0, y: 0, width: widthOfLabel, height: locLabelHeight)
        //self.init(icon: icon, activeIcon: activeIcon, title: title, frame: frame)
        self.init(text: text, frame: frame, bgColor:bgColor,textColor:textColor)

    }
    
    // Added by Venu
    
    var labelFontSize:CGFloat = 0
    
    public init(text:String?,frame:CGRect, bgColor:UIColor,textColor:UIColor) {
        super.init(frame: frame)
        
        infoLabel = addLabel(text: text)
        infoLabel.backgroundColor = bgColor
        infoLabel.textColor = textColor
        //activate(shouldActivate: false)
    }
    
    private func addLabel(text:String?) -> UILabel {
        let info_Label = UILabel.init(frame: self.bounds)
        info_Label.text = text
        self.addSubview(info_Label)
        info_Label.textAlignment = .center
        
        checkTheSizeClasses ()
        info_Label.font = UIFont.boldSystemFont(ofSize: labelFontSize)

        
//        info_Label.backgroundColor = UIColor.green
        info_Label.layer.masksToBounds = true
        info_Label.layer.cornerRadius = 0.5 * info_Label.frame.size.height
        return info_Label
    }
    
    func checkTheSizeClasses () {
        let topVC = GSTopViewController.topViewController()
        
        let horizontalClass = topVC.view.traitCollection.horizontalSizeClass
        let verticalClass = topVC.view.traitCollection.verticalSizeClass
        
        if horizontalClass == UIUserInterfaceSizeClass.regular && verticalClass == UIUserInterfaceSizeClass.regular {
            labelFontSize = 13
        } else {
            labelFontSize = 11
        }
        
    }
    
//    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
//        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
//        label.numberOfLines = 0
//        label.lineBreakMode = NSLineBreakMode.byWordWrapping
//        label.font = font
//        label.text = text
//        label.sizeToFit()
//
//        return label.frame.height
//    }
    
    // Closed
    

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
