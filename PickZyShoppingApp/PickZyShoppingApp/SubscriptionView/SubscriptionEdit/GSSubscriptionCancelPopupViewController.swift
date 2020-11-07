//
//  GSSubscriptionCancelPopupViewController.swift
//  Shopor
//
//  Created by Ratheesh on 27/02/20.
//  Copyright © 2020 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
protocol SubscriptionCancelPopViewDelegate:class {
    func subscriptionCancelResponseSuccess()
}
class GSSubscriptionCancelPopupViewController: UIViewController {

    
    @IBOutlet weak var subscription_Tableview: UITableView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var background_PopupView: UIView!
    
    @IBOutlet weak var text_backgroundView: UIView!
    
    @IBOutlet weak var description_Textview: UITextView!
    
    @IBOutlet weak var no_Button: UIButton!
    
    @IBOutlet weak var cancel_Button: UIButton!
        
    var arrayCancelList = [String]()
    
    weak var delegate: SubscriptionCancelPopViewDelegate?

    var selectType = ""
    var subscriptionId = ""
    var subscriptionName = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInitialized()
        
    }
    
    func viewInitialized()  {
        
        self.SendRequestSubscriptionProductcancelListApi()
        self .setViewPrperties(view: background_PopupView)
        self .setViewPrperties(view: text_backgroundView)

        self .setButtonPrperties(button: no_Button)
        self .setButtonPrperties(button: cancel_Button)

        subscription_Tableview.delegate = self
        subscription_Tableview.dataSource = self
        subscription_Tableview.isScrollEnabled = false
        subscription_Tableview.layer.cornerRadius = 3
        subscription_Tableview.clipsToBounds = true
    }
    
    func setViewPrperties(view:UIView)  {
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
    }
    func setButtonPrperties(button:UIButton)  {
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
    }
    @IBAction func noButtonAction(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.view .endEditing(true)
        guard validateTextFileds() == true else {return}
        self .SendRequestSubscriptionProductUnSubscribedApi(subscriptionId: subscriptionId)
    }
    
    // MARK: - Validations for Textfields
    func validateTextFileds() -> Bool {
        
        if (selectType.isEmpty){
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.selectAnyOne, viewController: self)
            return false
        } else if (description_Textview.text?.isEmpty)!{
            CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.fillAllDetails, viewController: self)
            return false
        }
        
        return true
    }
    
    // Common method to fetch the recharge wallet from server
    fileprivate func SendRequestSubscriptionProductUnSubscribedApi(subscriptionId:String) {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionProductUnSubscribe
        
        let  params = ["subs_mongo_id" : subscriptionId,
                       "is_unsubscribed": subscriptionName,
                       "feedback_text": selectType,
                       "note": description_Textview.text ?? ""] as [String : Any]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionProductEditModel.self, from: responseData)
                    weakSelf.methodPush()
                    NotificationCenter.default.post(name: Notification.Name(UserDefaultKeys.subscriptionUpdate), object: nil)

                    weakSelf.showAlertMessage(message: responseModel.message ?? "")
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
            
        }
    }
    
    func methodPush()  {
        delegate?.subscriptionCancelResponseSuccess()
    }
    func showAlertMessage(message:String)
    {
        let alert = UIAlertController.init(title: GSString.AppName, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okaction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            self.dismiss(animated: true, completion:{
                
            })
            
        })
        alert.addAction(okaction)
        self.present(alert,animated: true,completion: nil)
    }
    // Common method to fetch the recharge wallet from server
    fileprivate func SendRequestSubscriptionProductcancelListApi() {
        
        let hostString  = APIurl.baseURL + APIurl.subURL.subscriptionProductFeedbacktext
        
        let  params = ["":""] as [String : Any]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject] ,urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(SubscriptionCancelFeedBackModel.self, from: responseData)
                    if let typesArray = responseModel.data {
                        print(typesArray)
                        
                        if typesArray.count > 0 {
                            weakSelf.arrayCancelList = typesArray
                        }
                    }
                    weakSelf.subscription_Tableview .reloadData()
                    
                } catch {
                    print(error)
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
            
        }
    }
    
    
}
// MARK:- TableView Delegates
extension GSSubscriptionCancelPopupViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let rowHeight = 40
        
        return CGFloat(rowHeight) // UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayCancelList.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        
        let title_lable = UILabel()
        title_lable.text = "Are you sure you want to cancel this Subscription?"
        title_lable.font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont(name: "HelveticaNeue-Medium", size: 16) : UIFont(name: "HelveticaNeue-Medium", size: 14)
        title_lable.textAlignment = .left
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier:"SubscriptionCancelTableViewCell" ) as? SubscriptionCancelTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.title_Label.text = arrayCancelList[indexPath.row]
        cell.radio_Imageview.image = UIImage(named: "radioButton_InActive")

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.reloadData()

        let cell: SubscriptionCancelTableViewCell = tableView.cellForRow(at: indexPath) as! SubscriptionCancelTableViewCell
        cell.radio_Imageview.image = UIImage(named: "radioButton_Active")

        selectType = arrayCancelList[indexPath.row]
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let height = tableView.contentSize.height
        tableViewHeight.constant =  height
        backgroundViewHeight.constant = height + 140
        
    }
    
    @objc private func cellHeader_closeButtonSelection(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
// MARK: - SubscriptionCancelFeedBackModel
struct SubscriptionCancelFeedBackModel: Codable {
    let success: Bool?
    let data: [String]?
}
