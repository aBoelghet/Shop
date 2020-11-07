//
//  GSCartIconView.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 5/3/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

var cartCount = Variable(0)

@IBDesignable class GSCartIconView: NibView {
    
    @IBOutlet weak var cartCountLabel: GSBaseLabel!
    @IBOutlet weak var cartCountWidth: NSLayoutConstraint!
    
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
        cartCountLabel.backgroundColor = UIColor(hexString: defaultTheme.cartIconBG)
        cartCountLabel.textColor = UIColor(hexString: defaultTheme.cartIconText)

        cartCount.asObservable()
            .subscribe(onNext:{[weak self] some in
                self?.checkCountConditions()
            })
            .disposed(by: disposeBag)
        
    }

    func checkCountConditions() {
        
        cartCountLabel.text = "\(cartCount.value)"
        
        if cartCount.value > 0 {
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                cartCountWidth.constant = 15.0
                if cartCount.value > 99 {
                    cartCountWidth.constant = 18.0
                }
            } else {
                cartCountWidth.constant = 20.0
                if cartCount.value > 99 {
                    cartCountWidth.constant = 24.0
                }
            }
            cartCountLabel.isHidden = false
        } else {
            cartCountLabel.isHidden = true
            
            if cartItemsDictionary.count > 0 {
                cartItemsDictionary.removeAll()
            }
        }
        cartCountLabel.clipsToBounds = true
        cartCountLabel.layer.cornerRadius = 0.5 * cartCountLabel.frame.size.height
    }
}
