//
//  GSPaymentCCDCDetailViewController.swift
//  Shopor
//
//  Created by Ratheesh on 06/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import PayU_coreSDK_Swift

class GSPaymentCCDCDetailViewController: GSPaymentViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var cards_tableView: UITableView!
    
    var savedCard: PUExtended?
    
    var paymentParams = PayUModelPaymentParams()
    let webService = PayUWebService()
    var paymentOption : PaymentMethod?

    let headerHeight :CGFloat = 35.0

    override func viewDidLoad() {
        super.viewDidLoad()

        //delegate = self
        addFewIntializers()
        applyColors()
        if paymentOption?.hashValue == PaymentMethod.Cash.hashValue {
            navigationBar_view.rightBarBtn.isHidden = true
            navigationBar_view.rightBarImage.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Colors For UI
    private func applyColors() {
        cards_tableView.backgroundColor = UIColor(hexString: defaultTheme.CCDCDetailVC_tableView_BG)
    }
    
    // MARK: User defined Methods
    private func addFewIntializers() {
        
        navigationBar_view.delegate = self
        cards_tableView.dataSource = self
        cards_tableView.delegate = self
    }
    
    // MARK: - Delete Card API
    fileprivate func deleteTheCard() {
        // Implement bank api to delete the card
        paymentParams.cardToken = savedCard?.cardToken
        paymentParams.cardBin = savedCard?.cardBin
        GSConstant.linearBar.startAnimation()
        
        webService.deleteSavedCard(paymentParamsForDeletingSavedCard: paymentParams, completionBlockForDeletingSavedCard: { (status, error) in
            
            DispatchQueue.main.async {
                GSConstant.linearBar.stopAnimation()
            }
            if (error == "") {
                
                CustomAlert.showAlert(title: "Info !", message: GSConstant.AlertMessages.deletedCard, alertButtonsArray: ["Ok"], viewController: self) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                CustomAlert.showAlert(title: "oops !", message: error as String, viewController: self)
            }
        })
    }
}

// MARK: - UITableView Methods
extension GSPaymentCCDCDetailViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var sectionCount : Int = 0
        if paymentOption?.hashValue == PaymentMethod.SavedCard.hashValue {
            sectionCount = (savedCard != nil) ? 1 : 0
        } else if paymentOption?.hashValue == PaymentMethod.Cash.hashValue {
            sectionCount = 1
        }
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var sectionCount : Int = 0
        if paymentOption?.hashValue == PaymentMethod.SavedCard.hashValue {
            sectionCount = (savedCard != nil) ? 1 : 0
        } else if paymentOption?.hashValue == PaymentMethod.Cash.hashValue {
            sectionCount = 1
        }
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.ccdcDetailsTableCell) as? GSPaymentCCDCDetailTableCell else {
            return UITableViewCell()
        }
        if paymentOption?.hashValue == PaymentMethod.SavedCard.hashValue {
    
            let cardNo = savedCard?.cardNo ?? "   "
//            let lastThreeCharactersFromCard = cardNo.substring(from:cardNo.index(cardNo.endIndex, offsetBy: -3))
            let lastThreeCharactersFromCard = cardNo[cardNo.index(cardNo.endIndex, offsetBy: -3)...]
            cell.cardNo_lbl?.text = "Credit / Debit Card ***" + lastThreeCharactersFromCard
            cell.expiry_lbl?.text = "**/**"
            cell.card_imgView.image = GSPaymentParametersHelper.imageForTheCardtypeWithObject(cardBrand: savedCard!.cardBrand)
        } else {
            cell.card_imgView.image = #imageLiteral(resourceName: "CashIcon")
            cell.cardNo_lbl?.text = "Make the cash payment directly to the delivery boy."
        }
        
        return cell
    }
    
    // MARK: - Table View Header Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerHeight))
        let headerLabel = UILabel.init(frame: CGRect(x: 10, y: 0, width: headerView.frame.size.width - 10, height: headerHeight))
        headerLabel.textColor = UIColor(hexString: defaultTheme.CCDCDetailVC_header_text)

        var normalStr = "Credit/Debit card"
        if paymentOption?.hashValue == PaymentMethod.Cash.hashValue {
            normalStr = "Cash"
        }
        headerLabel.text = normalStr
        headerView.addSubview(headerLabel)
        headerView.backgroundColor = UIColor(hexString: defaultTheme.CCDCDetailVC_header_BG)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

// MARK: - Navigation Bar View Delegate Methods

extension GSPaymentCCDCDetailViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        
//        let transition = CATransition()
//        transition.duration = 2
//        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.type = kCATransitionReveal
//        transition.subtype = kCATransitionFromLeft
//        
//        navigationController?.view.layer.add(transition, forKey: kCATransition)
//        
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
        CustomAlert.showActionSheet(title: nil, message: nil, cancelTitle: "Cancel", optionArray: ["Delete Card"], sourceView: navigationBar_view.rightBarBtn, in: self) { btnIndex in
            if btnIndex == 0 {
                self.deleteTheCard()
            }
        }
    }
}
