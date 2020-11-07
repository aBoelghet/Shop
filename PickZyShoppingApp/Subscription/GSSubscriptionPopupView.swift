//
//  GSSubscriptionPopupView.swift
//  PickZyShoppingApp
//
//  Created by Purushoth on 03/09/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation


protocol GSSubscriptionPopupDelegate:class{
    
    func okAction(sender: UIButton)
    func durationAction(sender: UIButton)
    func dateAction(sender: UIButton)
}

class GSSubscriptionPopupView: NibView{
    
    @IBOutlet weak var duration_lbl: GSBaseLabel!
    
    @IBOutlet weak var duration_btn: UIButton!
    
    @IBOutlet weak var date_lbl: GSBaseLabel!
    
    @IBOutlet weak var date_btn: UIButton!
    
    @IBOutlet weak var cancel_btn: GSBaseButton!
    
    @IBOutlet weak var ok_btn: GSBaseButton!
    
    @IBOutlet weak var duration_img: UIImageView!
    
    @IBOutlet weak var date_img: UIImageView!
    
    
    weak var delegate : GSSubscriptionPopupDelegate?
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setUpThisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setUpThisView()
    }
    
    private func setUpThisView() {
        
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        
        removeFromSuperview()
    }
    
    @IBAction func okAction(_ sender: Any) {
        
        delegate?.okAction(sender: sender as! UIButton)
    }
    
    @IBAction func durationAction(_ sender: Any) {
        
        delegate?.durationAction(sender: sender as! UIButton)
    }
    
    @IBAction func dateAction(_ sender: Any) {
        
        delegate?.dateAction(sender: sender as! UIButton)
    }
   
    
}
