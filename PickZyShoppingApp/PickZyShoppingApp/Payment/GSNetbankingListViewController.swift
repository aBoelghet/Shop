//
//  GSNetbankingListViewController.swift
//  Shopor
//
//  Created by Ratheesh on 11/02/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import PayU_coreSDK_Swift

class GSNetbankingListViewController: GSPaymentViewController {
    
    @IBOutlet weak var navigationBar_view: NavigationBarNormal!
    @IBOutlet weak var cards_tableView: UITableView!
    
    let headerHeight :CGFloat = 35.0
    
    var availableNetbanking_array = [AnyObject]()
    var paymentParams: PayUModelPaymentParams?
    let paymentWebService   = PayUWebService()

    override func viewDidLoad() {
        super.viewDidLoad()

        addFewIntializers()
        applyColors()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if availableNetbanking_array.count <= 0 {
            fetchPaymentOptions()
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
    
    func fetchPaymentOptions() {
        // temporary bool for UI updation
        paymentParams?.isOneTap = false
        
        paymentWebService.callVAS(paymentParamsforVas: paymentParams!)
        
        GSConstant.linearBar.startAnimation()
        // call PayU's fetchPaymentOptions method to get payment options available for your account
        self.paymentWebService.fetchPayUPaymentOptions(paymentParamsToFetchPaymentOptions: paymentParams!) { (array, errorHere) in
            
            DispatchQueue.main.async {
                // Update UI
                if (errorHere == "") {
                    
                    self.availableNetbanking_array = array.availableNetBanking
                    self.cards_tableView.reloadData()
                    GSConstant.linearBar.stopAnimation()

                } else {
                    CustomAlert.showAlert(title: "oops !", message: errorHere as String, viewController: self)
                    GSConstant.linearBar.stopAnimation()
                }
            }
        }
    }
}

// MARK: - UITableView Methods
extension GSNetbankingListViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return availableNetbanking_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.DeliveryOptionVC_delivery_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSPaymentTypeTableCell else {
            return UITableViewCell()
        }
        
        cell.selectionImage.image = nil

        if let netBankItem = availableNetbanking_array[indexPath.row] as? PUExtended {
            cell.topLabel.text = netBankItem.title
        }
        
        cell.bg_view.addShadowEffectWith(color: UIColor(hexString: defaultTheme.paymentOpt_BorderC), opacity: 1.0, shadowRadius: 0, shadowOffset: CGSize(width: 0.0, height: 1.0))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let netBankItem = availableNetbanking_array[indexPath.row] as? PUExtended {
            let webService = PayUWebService()
            GSConstant.linearBar.startAnimation()
            webService.getVASStatus(bankCodeOrCardBin: netBankItem.bankCode) { (status, error) in
                
                DispatchQueue.main.async {
                     GSConstant.linearBar.stopAnimation()
                }
                
                if (status as! String != "") {
                    
                    CustomAlert.showAlert(title: GSString.AppName, message: status as? String ?? "", viewController: self)
                    
                } else {
                    CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.redirectToBank, alertButtonsArray: ["Cancel","Proceed"], viewController: self, completion: { btnIndex in
                        
                        self.paymentParams?.bankCode = netBankItem.bankCode
                        if btnIndex == 1 {
                            self.proceedForThePaymentThroughNetBanking()
                        }
                    })
                }
            }
        }
    }
    
    private func proceedForThePaymentThroughNetBanking() {
        let createRequest = PayUCreateRequest()
        GSConstant.linearBar.startAnimation()
        createRequest.createRequest(withPaymentParam: self.paymentParams!, forPaymentType: PAYMENT_PG_NET_BANKING) { (request, error) in
            
            DispatchQueue.main.async {
                GSConstant.linearBar.stopAnimation()
            }
            
            if (error == "") {
                
                DispatchQueue.main.async {
                    if let paymentWebVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPaymentWebViewController) as? GSPaymentWebViewController {
                        paymentWebVC.paymentRequest = request as URLRequest
                        if let navigator = self.navigationController {
                            navigator.pushViewController(paymentWebVC, animated: true)
                        }
                    }
                }
                
            } else {
                CustomAlert.showAlert(title: GSString.AppName, message: error as String, viewController: self)
            }
        }
    }
    
    // MARK: - Table View Header Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerHeight))
        let headerLabel = UILabel.init(frame: CGRect(x: 10, y: 0, width: headerView.frame.size.width - 10, height: headerHeight))
        headerLabel.textColor = UIColor(hexString: defaultTheme.CCDCDetailVC_header_text)
        if UIDevice.current.userInterfaceIdiom == .phone {
            headerLabel.font = UIFont.systemFont(ofSize: 14)
        } else {
            headerLabel.font = UIFont.systemFont(ofSize: 16)
        }
        headerLabel.text = "Net banking"
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

extension GSNetbankingListViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
    }
}
