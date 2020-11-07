//
//  BottomTableViewController.swift
//  Shopor
//
//  Created by Ratheesh on 21/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
protocol BottomTableViewDelegate:class {
    func selectSubscribeType(subscription:SubscriptionTypeData)
}
class BottomTableViewController: UIViewController {

    @IBOutlet weak var bottom_TableView: UITableView!
    
    @IBOutlet weak var bottomTableviewHeight: NSLayoutConstraint!
    
    weak var delegate: BottomTableViewDelegate?
    
    var arraySubscriptionList = [SubscriptionTypeData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInitialized()
        
    }
    
    func viewInitialized()  {
        
        bottom_TableView.delegate = self
        bottom_TableView.dataSource = self
        bottom_TableView.isScrollEnabled = false
       
    }
    
}
// MARK:- TableView Delegates
extension BottomTableViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        
        let title_lable = UILabel()
        title_lable.text = "Subscription Type"
        title_lable.font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont(name: "HelveticaNeue-Medium", size: 16) : UIFont(name: "HelveticaNeue-Medium", size: 14)
        title_lable.textAlignment = .center
        title_lable.textColor = UIColor.darkGray
        headerView.backgroundColor = UIColor.white
        headerView.addSubview(title_lable)
        
        title_lable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: title_lable, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: title_lable, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        
        let closeButton = UIButton()
        headerView.addSubview(closeButton)
        closeButton .setImage(UIImage(named: "CloseIcon"), for: .normal)
        closeButton.frame = CGRect(x: headerView.frame.maxX - 25, y: 10, width: 20, height: 20)
        
        closeButton.addTarget(self, action: #selector(cellHeader_closeButtonSelection(_:)), for: .touchUpInside)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let rowHeight = 40
        
        return CGFloat(rowHeight)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arraySubscriptionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier:"DeliverySlotTimeTableViewCell" ) as? DeliverySlotTimeTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.title_Label.text = arraySubscriptionList[indexPath.row].displayName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.selectSubscribeType(subscription: self.arraySubscriptionList[indexPath.row])
        dismiss(animated: false, completion: {
        })
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let height = tableView.contentSize.height
        bottomTableviewHeight.constant =  height
        
    }
    @objc private func cellHeader_closeButtonSelection(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
