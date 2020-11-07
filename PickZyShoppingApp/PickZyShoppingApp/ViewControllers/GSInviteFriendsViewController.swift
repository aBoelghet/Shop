//
//  GSInviteFriendsViewController.swift
//  Shopor
//
//  Created by Ratheesh on 19/02/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class GSInviteFriendsViewController: GSLoggedInBaseViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var topInfo_lbl:GSBaseLabel!
    @IBOutlet weak var referralCode_lbl:GSBaseLabel!
    @IBOutlet weak var referralBG_view:UIView!
    @IBOutlet weak var info_txtView: UITextView!
    @IBOutlet weak var txtViewHeight_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var info_lbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
        applyColors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    // MARK: - Colors For UI
    
    private func applyColors() {
        
        referralBG_view.backgroundColor = UIColor(hexString: defaultTheme.InviteVC_referralLbl_BG)
        topInfo_lbl.textColor = UIColor(hexString: defaultTheme.InviteVC_infoLbl)
        referralCode_lbl.textColor = UIColor(hexString: defaultTheme.InviteVC_referralLbl)
    }
    
    // MARK: User defined Methods
    
    private func addFewIntializers() {
        navigationBar_view.delegate = self
        
        navigationBar_view.titleText = "Refer & Buy Free"
        topInfo_lbl.text = GSConstant.inviteFriendsInfoLable
        
        let referralCode = SharedPersistence.getValue(key: UserDefaultKeys.user.referralCode) as? String ?? ""
        referralCode_lbl.text = referralCode

        let htmlString = """
<!DOCTYPE html>
 <html>
 <head> </head>
 <body>
<p style="font-family:Helvetica;font-size: 15px"><strong>What you have to do to buy free?</strong></p>
 \t\t<p style="font-family:Helvetica;font-size: 14px"><strong>Step 1:</strong> Share this referral code to your friends and known persons.</p>
 \t\t<p style="font-family:Helvetica;font-size: 14px"><strong>Step 2:</strong> Request them to register (you will get Rs 2 of every successful registration) and purchase.</p>
 \t\t<p style="font-family:Helvetica;font-size: 14px"><strong>Step 3:</strong> Every purchase of your referee, you will get 3 to 10% cash back in your BayFay cash account.</p>
 \t\t<p style="font-family:Helvetica;font-size: 14px"><strong>Step 4:</strong> Purchase anything from anywhere through BayFay shops.</p>
 \t\t\t\t<p style="font-family:Helvetica;font-size: 14px"><strong>Note:</strong> T&C apply</p>
 </body>
 </html>
"""
        info_txtView.attributedText = htmlString.html2AttributedString
        info_lbl.attributedText = htmlString.html2AttributedString
        
        self.txtViewHeight_constraint.constant = info_txtView.contentSize.height
    }
    
    // MARK: - View Controller Action Methods
    
    @IBAction private func shareReferralCode(_ sender: UIButton) {
        
        let referralCode = SharedPersistence.getValue(key: UserDefaultKeys.user.referralCode) as? String ?? ""
        let theSharableContent = SharedPersistence.getValue(key: UserDefaultKeys.user.referralLink) as? String ?? "Join me on BayFay, you and me will get 5% cash back on your first purchase. Download BayFay now: http://bayfay.com/refer?referral_code=\(referralCode)"
        
        let activityViewController = UIActivityViewController(activityItems: [theSharableContent], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [.airDrop, .assignToContact, .postToFacebook, .postToTwitter]
        activityViewController.popoverPresentationController?.sourceView = sender
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK:- NavigationBar Methods
extension GSInviteFriendsViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        GSCustomPushPop.doCustomPop(from: self)
    }
    
    func rightBarBtnPressed(sender:UIButton) {
    }
}
