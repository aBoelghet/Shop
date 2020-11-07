//
//  GSNotificationIconView.swift
//  Shopor
//
//  Created by Ratheesh on 08/01/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

var notificationCount = Variable(0)

@IBDesignable class GSNotificationIconView: NibView {
    
    @IBOutlet weak var notificationCountLabel: GSBaseLabel!
    @IBOutlet weak var notificationCountWidth: NSLayoutConstraint!
    @IBOutlet weak var notificationIconImage: UIImageView!
    
    var someString:String?
    let disposeBag = DisposeBag()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    override func prepareForInterfaceBuilder() {
        setUpThisView()
    }
    
    // MARK: User defined methods
    func setUpThisView() {
        notificationCountLabel.backgroundColor = UIColor(hexString: defaultTheme.cartIconBG)
        notificationCountLabel.textColor = UIColor(hexString: defaultTheme.cartIconText)
        
        notificationCount.asObservable()
            .subscribe(onNext:{[weak self] some in
                self?.checkCountConditions()
            })
            .disposed(by: disposeBag)
        
    }
    
    func checkCountConditions() {
        
        notificationCountLabel.text = "\(notificationCount.value)"
        
        if notificationCount.value > 0 {
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                notificationCountWidth.constant = 15.0
                if notificationCount.value > 99 {
                    notificationCountWidth.constant = 18.0
                }
            } else {
                notificationCountWidth.constant = 20.0
                if notificationCount.value > 99 {
                    notificationCountWidth.constant = 24.0
                }
            }
            notificationCountLabel.isHidden = false
        } else {
            notificationCountLabel.isHidden = true
            
            if cartItemsDictionary.count > 0 {
                cartItemsDictionary.removeAll()
            }
        }
        notificationCountLabel.clipsToBounds = true
        notificationCountLabel.layer.cornerRadius = 0.5 * notificationCountLabel.frame.size.height
    }
}
