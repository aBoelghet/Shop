//
//  GSScratchCardsViewController.swift
//  Shopor
//
//  Created by Ratheesh on 30/12/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import GLScratchCard
import CoreLocation

protocol ScratchCardViewDelegate:class {
    func selectedBannerStoreId(storeID:String)
    func callBackMethodSCCount()
}

class GSScratchCardsViewController: UIViewController{
   
    @IBOutlet weak var scratchCardImageView:GLScratchCardImageView?
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var tableOfferList: UITableView!
    
    @IBOutlet weak var scratchViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scratchBackgroundView: UIView!
    
    @IBOutlet weak var reward_image: UIImageView!
    
    @IBOutlet weak var reward_TitleLabel: UILabel!
    
    @IBOutlet weak var reward_AmountLabel: UILabel!
    
    @IBOutlet weak var reward_currenySymbol: UILabel!
    
    @IBOutlet weak var winAmountLabel: UILabel!
    
    @IBOutlet weak var promoPercentageLabel: UILabel!
    
    @IBOutlet weak var promobackgroundView: UIView!
    
    @IBOutlet weak var rewardBackgroundView: UIView!
    
    var scratchModel : ScratchcardModel?
    
    var locationManger:CLLocationManager?

    var sessionIndex : Int = 0
    
    var isActivated :  Bool = false
    
    weak var delegate:ScratchCardViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scratchCardMethod()
    }
    
    func scratchCardMethod()  {

        guard (UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView) != nil else {
            return
        }
        
        scratchCardImageView?.lineType = .round
        scratchCardImageView?.lineWidth = 30
        scratchCardImageView?.benchMarkScratchPercentage = 0
        scratchCardImageView?.addDelegate(delegate: self)

        let imageArr = ["scratchCardRed","scratchCardYellow","scratchCardGreen","scratchCardBlue"]
        let RandomNumber = Int(arc4random_uniform(UInt32(imageArr.count)))
        scratchCardImageView?.image =  UIImage.init(named: "\(imageArr[RandomNumber])")
        
        scratchCardImageView?.layer.cornerRadius = 3
        scratchCardImageView?.clipsToBounds = true
        scratchBackgroundView.isHidden = true
        
        self.tableOfferList.estimatedRowHeight = 80
        self.tableOfferList.rowHeight = UITableViewAutomaticDimension
        tableOfferList.delegate     = self
        tableOfferList.dataSource   = self
        
        scratchBackgroundView.isHidden = true
        self.tableOfferList.register(UINib(nibName: "GSScratchCardTableviewCell", bundle: nil), forCellReuseIdentifier: "GSScratchCardTableviewCell")

        if scratchModel == nil {
            self.scratchCardApi(radius: GSConstant.defaultRadius)
        } else {
            scratchBackgroundView.isHidden = false
            
            if let reward = scratchModel?.data?.cardInfo?.first?.rewardInfo {
                
                let randomCost = reward.randomCost
                if randomCost == 0 {
                    
                    reward_TitleLabel.text! = "Better Luck Next Time"
                    reward_AmountLabel.text! = ""
                    reward_currenySymbol.text! = ""
                    reward_image.image = UIImage(named: "scratch_rewardBlue")
                    reward_TitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
                } else {
                    
                    reward_TitleLabel.text! = "You've Won"
                    reward_AmountLabel.text! = "\(String(describing: reward.randomCost!))"
                    reward_currenySymbol.text! = "₹"
                    reward_image.image = UIImage(named: "scratch_rewardGold")
                    reward_TitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
                }
                promobackgroundView.isHidden = true
                promobackgroundView.backgroundColor = UIColor.clear
            }
            
            if let promo = scratchModel?.data?.cardInfo?.first?.promoInfo{
                promobackgroundView.layer.cornerRadius = promobackgroundView.frame.height / 2
                promobackgroundView.clipsToBounds = true
                promobackgroundView.isHidden = false
                promobackgroundView.backgroundColor = GSConstant.promoBackgroundColor
                
                if (promo.codeType == 1 && promo.codeModel == 1) {  // 2 - %
                    promoPercentageLabel.text = "\(String(describing: promo.codeValue!))%\nCashback"
                } else if (promo.codeType == 2 && promo.codeModel == 1) {   // 1 - Rupees
                    promoPercentageLabel.text = "₹\(String(describing: promo.codeValue!))\nCashback"
                }
                
                if (promo.codeType == 1 && promo.codeModel == 2) {  // 2 - %
                    promoPercentageLabel.text = "\(String(describing: promo.codeValue!))%\nDiscount"
                } else if (promo.codeType == 2 && promo.codeModel == 2) {   // 1 - Rupees
                    promoPercentageLabel.text = "₹\(String(describing: promo.codeValue!))\nDiscount"
                }
                
                reward_TitleLabel.attributedText = String().getAttributedString(firstString: "Code:\n", firstFont: UIFont.systemFont(ofSize: 15), firstColor: UIColor.black, secondString: "\(String(describing: promo.promoCode!))", secondFont: UIFont.boldSystemFont(ofSize: 18), secondColor: UIColor.black)
                
                // reward_TitleLabel.text! = "Code:\n \(String(describing: promo.promoCode!))"
                reward_AmountLabel.text! = "\(String(describing: promo.note!))"
                reward_currenySymbol.text! = ""
                // reward_TitleLabel.font = UIFont.systemFont(ofSize: 15)
                reward_AmountLabel.font = UIFont.systemFont(ofSize: 18)
                reward_AmountLabel.textColor = GSConstant.promoNoteTxtColor
            }
            winAmountLabel.text = scratchModel?.data?.titlemsg
            tableOfferList.reloadData()
        }
    }
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func closeScratchView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func scratchCardApi(radius:Int) {
        
         let currentLatitude    = SharedPersistence.getValue(key:"current_Latitude")
         let currentLangitude   = SharedPersistence.getValue(key: "current_Langitude")
         let locationRadius     = SharedPersistence.getValue(key: "location_radius") == nil ? radius : SharedPersistence.getValue(key: "location_radius")

         let searchLat = SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLatitude) == nil ? currentLatitude : SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLatitude)
         let searchLong = SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLongitude) == nil ? currentLangitude : SharedPersistence.getValue(key: UserDefaultKeys.locations.searchLongitude)
        
         let deliveryLat = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLat) ?? searchLat
         let deliveryLong = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong) ?? searchLong
        
         let hostString: String!

         let params: [String:Any]
            hostString = APIurl.baseURL + APIurl.subURL.scratchCard
            params = ["searchLocation" : ["type" : "Point",
                                          "coordinates" : [searchLong, searchLat]],
                      "deliveryLocation":["type": "Point",
                                          "coordinates": [deliveryLong, deliveryLat]],
                      "maxDistance" : "\(locationRadius ?? 0)"] as [String : Any]
        
         APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject],urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if (error == nil) {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(ScratchcardModel.self, from: responseData)
                    
                    let cardInfo = responseModel.data?.cardInfo
                    let adInfo = responseModel.data?.adInfo
                    
                    if cardInfo?.count == 0 && adInfo?.count == 0 {
                        self?.scratchViewHeight.constant = 0
                        self?.scratchBackgroundView.isHidden = true
                        self?.tableOfferList.isHidden = true
                        CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.AlertMessages.rewardEmpty, alertButtonsArray: ["OK"], isLastButtonDestructive: true, viewController: self!) { btnIndex in
                            if btnIndex == 0 {
                                self!.dismiss(animated: true, completion: nil)
                                return
                            }
                        }
                    } else {
                        self!.reloadTableView(scratch: responseModel)
                    }
                } catch {
                    
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                // print(error?.localizedDescription ?? GSString.API.unknownError)
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func scratchCardActivateApi() {
        
        let params: [String:Any]
        let hostString = APIurl.baseURL + APIurl.subURL.scratchCardActivate
        let scrdId = scratchModel?.data?.cardInfo?.first?.id
        
        params = ["scard_id" :scrdId!] as [String : Any]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject],urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(ScratchcardActivateModel.self, from: responseData)
                    self?.isActivated = responseModel.success!
                    self?.delegate?.callBackMethodSCCount()
                } catch {
                    
                    CustomAlert.showAlert(title: GSString.AppName, message: error.localizedDescription, viewController: weakSelf)
                }
            } else {
                
                CustomAlert.showAlert(title: GSString.AppName, message: error?.localizedDescription ?? "", viewController: weakSelf)
            }
        }
    }
    
    func scratchCardListClickedApi(ad_id: String) {
        
        var params: [String:AnyObject]
        let hostString = APIurl.baseURL + APIurl.subURL.scratchCardClicked
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        params = ["ad_id" :ad_id,
                  "device_uniqueid":deviceId] as [String : AnyObject]
    
        APIHandler.NetworkSetupRequest(method: .post, params: params as [String : AnyObject],urlString: hostString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(ScratchcardClickedModel.self, from: responseData)
                    print(responseModel)
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
    
    func reloadTableView(scratch:ScratchcardModel)  {
        
        scratchModel = scratch
        
        let rewardInfo = scratch.data?.cardInfo?.first?.rewardInfo
        let promoInfo = scratch.data?.cardInfo?.first?.promoInfo
        
        if rewardInfo != nil || promoInfo != nil {
            
            scratchBackgroundView.isHidden = false
            rewardBackgroundView.layer.cornerRadius = 3
            rewardBackgroundView.clipsToBounds = true
            
            if let reward = scratchModel?.data?.cardInfo?.first?.rewardInfo {
                
                let randomCost = reward.randomCost
                if randomCost == 0 {
                    reward_TitleLabel.text! = "Better Luck Next Time"
                    reward_AmountLabel.text! = ""
                    reward_currenySymbol.text! = ""
                    reward_image.image = UIImage(named: "scratch_rewardBlue")
                    
                } else {
                    reward_TitleLabel.text! = "You've Won"
                    reward_AmountLabel.text! = "\(String(describing: reward.randomCost!))"
                    reward_currenySymbol.text! = "₹"
                    reward_image.image = UIImage(named: "scratch_rewardGold")
                }
            }
            if let promo = scratchModel?.data?.cardInfo?.first?.promoInfo {
                
                promobackgroundView.layer.cornerRadius = promobackgroundView.frame.height / 2
                promobackgroundView.clipsToBounds = true
                promobackgroundView.backgroundColor = UIColor.green
                
                if (promo.codeType == 1 && promo.codeModel == 1) {  // 2 - %
                    promoPercentageLabel.text = "\(String(describing: promo.codeValue!))%\nCashback"
                } else if (promo.codeType == 2 && promo.codeModel == 1) {   // 1 - Rupees
                    promoPercentageLabel.text = "₹\(String(describing: promo.codeValue!))\nCashback"
                }
                
                if (promo.codeType == 1 && promo.codeModel == 2) {  // 2 - %
                    promoPercentageLabel.text = "\(String(describing: promo.codeValue!))%\nDiscount"
                } else if (promo.codeType == 2 && promo.codeModel == 2) {   // 1 - Rupees
                    promoPercentageLabel.text = "₹\(String(describing: promo.codeValue!))\nDiscount"
                }
                
                reward_TitleLabel.attributedText = String().getAttributedString(firstString: "Code:\n", firstFont: UIFont.systemFont(ofSize: 15), firstColor: UIColor.black, secondString: "\(String(describing: promo.promoCode!))", secondFont: UIFont.boldSystemFont(ofSize: 18), secondColor: UIColor.black)
                
                //reward_TitleLabel.text! = "Code: \n\(String(describing: promo.promoCode!))"
                reward_AmountLabel.text! = "\(String(describing: promo.note!))"
                reward_currenySymbol.text! = ""
                //reward_TitleLabel.font = UIFont.systemFont(ofSize: 15)
                reward_AmountLabel.font = UIFont.systemFont(ofSize: 18)
                reward_AmountLabel.textColor = GSConstant.promoNoteTxtColor
            }
            winAmountLabel.text = scratchModel?.data?.titlemsg
        } else {
            let newMultiplier:CGFloat = 0
            scratchViewHeight.constant = 0
            scratchViewHeight = scratchViewHeight.setMultiplier(multiplier: newMultiplier)
            scratchBackgroundView.isHidden = true
        }
        tableOfferList.reloadData()
    }
}

// MARK:- TableView Delegates
extension GSScratchCardsViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        var rowHeight = 100

        let adType = scratchModel?.data?.adInfo?[indexPath.row].adType
        if adType == 2 {
        
            let imageHeight = (scratchModel?.data?.adInfo?[indexPath.row].bannerAdInfo?.height)!
            let imageWidth = (scratchModel?.data?.adInfo?[indexPath.row].bannerAdInfo?.width)!

            let viewWidth = Float(self.view.frame.width)
            let oldWidth: Float = Float(imageWidth)
            let scaleFactor: Float = Float(viewWidth / oldWidth)
            
            let newHeight: Float  = Float(Float(imageHeight) * scaleFactor)
            
            rowHeight = Int(newHeight+10)
        }
        return CGFloat(rowHeight) // UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (scratchModel?.data?.adInfo?.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier:"GSScratchCardTableviewCell" ) as? GSScratchCardTableviewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        let adType = scratchModel?.data?.adInfo?[indexPath.row].adType
        if adType == 1 {
            
            cell.contentbackgroundView.isHidden = false
            cell.storeImage.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewPromoCodeStoreImage + ((scratchModel?.data?.adInfo?[indexPath.row].privateIcon)!)) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
            cell.bannerImage.image = nil
            cell.storeContentLabel.text = scratchModel?.data?.adInfo?[indexPath.row].textAdInfo?.adContent
        } else {
            
            cell.contentbackgroundView.isHidden = true
            let imgWidth : String = "&width=" + String((scratchModel?.data?.adInfo?[indexPath.row].bannerAdInfo?.width)!)
            cell.bannerImage.sd_setImage(with: URL(string: APIurl.baseURL + APIurl.subURL.viewBannerImage + (scratchModel?.data?.adInfo?[indexPath.row].bannerAdInfo?.image)! + imgWidth) , placeholderImage: #imageLiteral(resourceName: "blurImage"), completed: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: false, completion: nil)
        self.scratchCardListClickedApi(ad_id:(scratchModel?.data?.adInfo![indexPath.row].adID)!)
        delegate?.selectedBannerStoreId(storeID:(scratchModel?.data?.adInfo![indexPath.row].storeID)!)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        self.viewWillLayoutSubviews()
    }
}

extension GSScratchCardsViewController:GLScratchCarImageViewDelegate {
    
    func scratchpercentageDidChange(value: Float) {
        
        if (value >= 50 && isActivated == false) {
            
            isActivated = true
            self.scratchCardActivateApi()
        }
    }
    
    func didScratchStarted() {
    }
    
    func didScratchEnded() {
    }
}

extension NSLayoutConstraint {
    
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            
            item: firstItem ?? 0,
            
            attribute: firstAttribute,
            
            relatedBy: relation,
            
            toItem: secondItem,
            
            attribute: secondAttribute,
            
            multiplier: multiplier,
            
            constant: constant)
        
        newConstraint.priority = priority
        
        newConstraint.shouldBeArchived = self.shouldBeArchived
        
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
}
