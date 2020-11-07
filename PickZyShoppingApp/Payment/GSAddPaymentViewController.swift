//
//  GSAddPaymentViewController.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 3/30/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import PayU_coreSDK_Swift

class GSAddPaymentViewController: GSPaymentViewController {
    
    @IBOutlet weak var navigationBarView: NavigationBarNormal!
    @IBOutlet weak var payMentListTable: UITableView!
    
    var paymentParams = PayUModelPaymentParams()

    let headerHeight:CGFloat = 50.0
    
    var paymentListArray = NSMutableArray()
    var paymentImageArr  = [UIImage]()
    var isGoingToOrder = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addFewIntializers()
        
        payMentListTable.backgroundColor = UIColor(hexString: defaultTheme.paymentOpt_table_BG)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: User defined Methods
    func addFewIntializers() {
        
        navigationBarView.delegate = self
        navigationBarView.titleText = ""
        
        payMentListTable.delegate = self
        payMentListTable.dataSource = self
        
        paymentListArray = ["Credit or Debit card"]
        paymentImageArr = [#imageLiteral(resourceName: "CreditDebitIcon")]
        payMentListTable.tableFooterView = UIView()
        
            payMentListTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
    }
}

extension GSAddPaymentViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return paymentListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.AddPaymentVC_addPayment_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSAddPaymentTableCell else {
            return UITableViewCell()
        }
        
        let walletDetails = paymentListArray[indexPath.row] as! String
        let cellImage = paymentImageArr[indexPath.row]
        
        cell.configureTheCell(walletDetails, cellImage)
        
        cell.shadowView.addShadowEffectWith(color: UIColor(hexString: defaultTheme.paymentOpt_BorderC), opacity: 1.0, shadowRadius: 0, shadowOffset: CGSize(width: 0.0, height: 1.0))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.payMentListTable.frame.size.width, height: headerHeight))
        headerView.backgroundColor = UIColor.init(hexString: defaultTheme.paymentType_header_bg)
        
        let headerLabel = UILabel.init(frame: CGRect.init(x: 10, y: 0, width: headerView.frame.size.width - 10, height: headerView.frame.size.height))
        headerLabel.text = "Add Payment"
        headerLabel.textColor = UIColor(hexString: defaultTheme.paymentType_header_text)
        headerLabel.textAlignment = .left
        headerLabel.font = headerLabel.font.withSize(14)
        headerLabel.font = UIDevice.current.userInterfaceIdiom == .phone ? UIFont.systemFont(ofSize: 14.0) : UIFont.systemFont(ofSize: 17.0)
        headerLabel.addShadowEffectWith(color: UIColor(hexString: defaultTheme.paymentOpt_BorderC), opacity: 1.0, shadowRadius: 0, shadowOffset: CGSize(width: 0.0, height: 1.0))
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            if let tempVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil)
                .instantiateViewController(withIdentifier: GSString.Push.GSAddCardViewController) as? GSAddCardViewController {
                tempVC.paymentParams  = paymentParams
                tempVC.isGoingToOrder = isGoingToOrder
                if let navigator = navigationController {
                    navigator.pushViewController(tempVC, animated: true)
                }
            }
        }
//        if indexPath.row == 1 {
//            let someView = GSCashOnDeliveryPopUpView.init()
//            someView.delegate = self
//            view.addSubview(someView)
//            someView.initThisViewWithFrame(theView: view)
//        }
        //        else {
        //            if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
        //                .instantiateViewController(withIdentifier: GSString.Push.GSOrderPlacedViewController) as? GSOrderPlacedViewController {
        //                if let navigator = navigationController {
        //                    navigator.pushViewController(tempVC, animated: true)
        //                }
        //            }
        //        }
    }
}

extension GSAddPaymentViewController:NavigationBarNormalDelegate {
    
    func leftBarBtnPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func rightBarBtnPressed(sender: UIButton) {
        
    }
}
