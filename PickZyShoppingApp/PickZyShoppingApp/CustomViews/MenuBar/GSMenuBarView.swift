//
//  GSMenuBarView.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/5/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class GSMenuBarView: NibView,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var menuTable:UITableView!
    @IBOutlet weak var menuBG:UIView!
    @IBOutlet weak var version_lbl:GSBaseLabel!
    @IBOutlet weak var tableLeading_constraint:NSLayoutConstraint!
    
    var menuItem_array = [GSMenuModel]()
    var selectedMenuItem: GSMenuBarItem = .shop
    
    let topLayoutGuideLength = GSTopViewController.topViewController().view.safeAreaInsets.top
    let bottomLayoutGuideLength = GSTopViewController.topViewController().view.safeAreaInsets.bottom
    
    var trackOrderCount = 0
    var messagesCount = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        someSetUps()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        someSetUps()
    }
    
    // MARK:- User defined methods
    private func someSetUps() {
        intializeTableViewDependents()
    }
    
    func menuTableReload() {
        menuTable.reloadData()
    }
    
    func intializeTableViewDependents() {
        
        menuTable.delegate   = self
        menuTable.dataSource = self
        
        let nib = UINib.init(nibName: GSString.NibNames.GSMenuBarTableCell, bundle: nil)
        menuTable.register(nib, forCellReuseIdentifier: GSString.CellIdentifier.Menu_menu_tableCell)
        
        let headerNib = UINib.init(nibName: GSString.NibNames.GSMenuTableHeaderView, bundle: nil)
        menuTable.register(headerNib, forHeaderFooterViewReuseIdentifier: GSMenuTableHeaderView.identifier)
//        self.addShadowEffectWith(color: UIColor.gray, opacity: 1.0, shadowRadius: 1.0, shadowOffset: CGSize(width: 1, height: 0))
        dataSet()
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        version_lbl.text = "\(GSConstant.appVersionPrefix) " + appVersion
        menuTable.contentInset = UIEdgeInsetsMake(0, 0, 40, 0)
    }

    func addGestures() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureAction))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapGestureAction(_ sender:UITapGestureRecognizer) {
        
//        self.menuBG.backgroundColor = UIColor.clear
//        let screen: CGRect = UIScreen.main.bounds
//        UIView.animate(withDuration: 0.45, animations: {
//            self.frame = CGRect(x: screen.origin.x - screen.size.width, y: screen.origin.y + self.topLayoutGuideLength, width: screen.size.width, height: screen.size.height - self.topLayoutGuideLength - self.bottomLayoutGuideLength)
//        },completion: {  _ in
//            self.removeFromSuperview()
//        })
        
        removeThisViewFromParent {
            // Nothing to do
        }
    }
    
    func showTheViewOn (_ window:UIWindow) {
        
        let previousSelectedMenuItem = selectedMenuItem
        self.updateSelectedMenuItem()
        
        if selectedMenuItem == .trackOrder || selectedMenuItem == .messages || selectedMenuItem == .shop || previousSelectedMenuItem != selectedMenuItem {
            // We will call the menu bar count api only first time on a view.
            trackOrderCountAPI()
            messagesCountAPI()
        }
        endEditing(true)
        
        initThisViewWithWindow(window)
        
        let widthOfTable = menuTable.frame.width
        tableLeading_constraint.constant = -widthOfTable
        layoutIfNeeded()
        self.tableLeading_constraint.constant = 0
        UIView.animate(withDuration: 0.25, animations: {  
            self.menuBG.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.layoutIfNeeded()
            
        },completion: { _ in
            
        })
    }
    
    func initThisViewWithWindow(_ theWindow:UIWindow) {
        
        // Call this method after adding this class as subview
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint.init(item: self, attribute: .leading, relatedBy: .equal, toItem: theWindow, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: theWindow, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: theWindow, attribute: .top, multiplier: 1, constant: topLayoutGuideLength)
        let bottom = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: theWindow, attribute: .bottom, multiplier: 1, constant: -bottomLayoutGuideLength)
        NSLayoutConstraint.activate([leading,trailing,top,bottom])
    }
    
    private func removeThisViewFromParent(completion:@escaping () -> Void) {
        
        let widthOfTable = menuTable.frame.width
        self.tableLeading_constraint.constant = -widthOfTable
        UIView.animate(withDuration: 0.25, animations: {
            self.menuBG.backgroundColor = UIColor.clear
            self.layoutIfNeeded()
            
        },completion: { _ in
            completion()
            self.removeFromSuperview()
        })
    }
    
    // MARK:- TableView Delegates

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return menuItem_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = GSString.CellIdentifier.Menu_menu_tableCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? GSMenuBarTableCell else {
            return UITableViewCell()
        }
        
        let menu_item = menuItem_array[indexPath.row]
        cell.menuName.text = menu_item.menuName
        cell.menuIconView.image = menu_item.menuIcon
        cell.countLabel.text = ""
        
        cell.bg_view.backgroundColor = UIColor.clear
        
        if menu_item.type == selectedMenuItem {
            cell.bg_view.backgroundColor = UIColor(hexString: defaultTheme.sideMenuHeader)
        }
        
        if menu_item.type == .trackOrder {
            
            if trackOrderCount != 0 {
                cell.countLabel.text = "\(trackOrderCount)"
            }
            
        } else if menu_item.type == .messages {
            
            if messagesCount != 0 {
                cell.countLabel.text = "\(messagesCount)"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        self.menuBG.backgroundColor = UIColor.clear
//        let screen: CGRect = UIScreen.main.bounds
//        UIView.animate(withDuration: 0.45, animations: {
//            self.frame = CGRect(x: screen.origin.x - screen.size.width, y: screen.origin.y + self.topLayoutGuideLength, width: screen.size.width, height: screen.size.height - self.topLayoutGuideLength - self.bottomLayoutGuideLength)
//        },completion: { _ in
//
//            self.decideTheNavigationsBasedOnSelectionOf(indexPath.row)
//            self.removeFromSuperview()
//        })
        
        removeThisViewFromParent {
            self.decideTheNavigationsBasedOnSelectionOf(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 50.0
        }
        return 60.0
    }
    
    // MARK: - Table Header Footer View Methods
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 120.0
        }
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: GSMenuTableHeaderView.identifier) as? GSMenuTableHeaderView else {
            return UIView()
        }
        
        headerView.profileName.text = ""
        headerView.signupLogin_btn.addTarget(self, action: #selector(loginSignupAction(_:)), for: .touchUpInside)
        
        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
        if isGuestLogin {
//            headerView.profileName.isHidden = true
//            headerView.guestUser_stackView.isHidden = false
            
            headerView.profileImage.image = #imageLiteral(resourceName: "placeHolderProfile_icon")
            headerView.profileName.text = "Login / Signup"
            return headerView
        }
        
//        headerView.profileName.isHidden = false
//        headerView.guestUser_stackView.isHidden = true
        
        if let decodedLoginUserData = SharedPersistence.getValue(key: UserDefaultKeys.user.user_details) as? Data {
            if let loginUser_jsonObject = try? JSONDecoder().decode(GSLoginData.self, from: decodedLoginUserData) {
                headerView.profileName.text = ((loginUser_jsonObject.userProfile?.firstName ?? "") + " " + (loginUser_jsonObject.userProfile?.lastName ?? ""))
            }
        }
        
        let imageLinkFromAPI = SharedPersistence.getValue(key: UserDefaultKeys.user.profile_image) as? String ?? ""
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        SDWebImageDownloader.shared().setValue(accessToken, forHTTPHeaderField: "Authorization")
        
        if imageLinkFromAPI != "" {
            let imageUrl = APIurl.baseURL + "/profile/image/view?img=\(imageLinkFromAPI)&format=jpeg&width=\(GSConstant.tumbnailImgHeight)"
            headerView.profileImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: #imageLiteral(resourceName: "placeHolderProfile_icon"), options: .progressiveDownload) { (image, error, cache_type, url) in
                headerView.profileImage.image =  GSCommonHelper.cropToBounds(image: headerView.profileImage.image!, width: Double(headerView.profileImage.frame.width), height: Double(headerView.profileImage.frame.height))
            }
        } else {
            headerView.profileImage.image = #imageLiteral(resourceName: "placeHolderProfile_icon")
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    // MARK: - Header View Action Methods
    
    @objc private func loginSignupAction(_ sender:UIButton) {
        
        self.menuBG.backgroundColor = UIColor.clear
        let screen: CGRect = UIScreen.main.bounds
        UIView.animate(withDuration: 0.45, animations: { 
            self.frame = CGRect(x: screen.origin.x - screen.size.width, y: screen.origin.y + self.topLayoutGuideLength, width: screen.size.width, height: screen.size.height - self.topLayoutGuideLength - self.bottomLayoutGuideLength)
        },completion: { _ in
            
            self.removeFromSuperview()
            
            let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
            if isGuestLogin {
            
            if let welcomeViewController = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSWelcomeScreenViewController) as? GSWelcomeScreenViewController {
                GSTopViewController.topViewController().navigationController?.pushViewController(welcomeViewController, animated: true)
            }
            } else {
                if let profileIndex = self.menuItem_array.index(where: { $0.type == .profile }) {
                    self.decideTheNavigationsBasedOnSelectionOf(profileIndex)
                }
            }
        })
    }
    
    //MARK:- Gesture Delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (touch.view?.isDescendant(of: menuTable))! {
            return false
        }
        return true
    }
    
    // MARK:- User defined methods (Data)
    
    private func dataSet () -> Void {

        addGestures()
        menuItem_array = [GSMenuModel(menuName: "Shopping", menuIcon: #imageLiteral(resourceName: "Menu_Shop_icon"), count: "", type: .shop),
                              GSMenuModel(menuName: "Track Order", menuIcon: #imageLiteral(resourceName: "Menu_TrackOrder_icon"), count: "3", type: .trackOrder),
                              GSMenuModel(menuName: "Subscription", menuIcon: #imageLiteral(resourceName: "subscribe_Icon"), count: "", type: .subscription),
                              GSMenuModel(menuName: "Messages", menuIcon: #imageLiteral(resourceName: "Menu_Messages_icon"), count: "5", type: .messages),
                              GSMenuModel(menuName: "Purchase History", menuIcon: #imageLiteral(resourceName: "Menu_PurchaseHistory_icon"), count: "", type: .purchaseHistory),
                              GSMenuModel(menuName: "Payment", menuIcon: #imageLiteral(resourceName: "Menu_Payment_icon"), count: "", type: .payment),
                              GSMenuModel(menuName: "Refer & Buy Free", menuIcon: #imageLiteral(resourceName: "Menu_Invite_icon"), count: "", type: .invite),
                              GSMenuModel(menuName: "Profile and Settings", menuIcon: #imageLiteral(resourceName: "Menu_Profile_icon"), count: "", type: .profile),
                              GSMenuModel(menuName: "Notifications", menuIcon: #imageLiteral(resourceName: "Menu_Notification_icon"), count: "5", type: .notification),
                              GSMenuModel(menuName: "Support", menuIcon: #imageLiteral(resourceName: "Menu_Support_icon"), count: "", type: .support),
                              GSMenuModel(menuName: "About", menuIcon: #imageLiteral(resourceName: "Menu_About_icon"), count: "", type: .about)]
    }
    
    struct GSMenuModel {
        let menuName: String
        let menuIcon:UIImage
        let count: String
        let type:GSMenuBarItem
    }
    
    func decideTheNavigationsBasedOnSelectionOf(_ index:Int) {
        
        let menu_item = menuItem_array[index]
        
        if menu_item.type == selectedMenuItem {
            return
        }
        
        if let navigator = GSTopViewController.topViewController().navigationController {
            navigator.popToRootViewController(animated: false)
        }
        

        switch menu_item.type {

            case .shop:          // Shopping
//                if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
//                    .instantiateViewController(withIdentifier: GSString.Push.GSShopsViewController) as? GSShopsViewController {
//                    if let navigator = GSTopViewController.topViewController().navigationController {
//                        navigator.pushViewController(tempVC, animated: false)
//                    }
//                }
                break
            case .trackOrder:         //Track Order
                if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
                    .instantiateViewController(withIdentifier: GSString.Push.GSTrackOrderListViewController) as? GSTrackOrderListViewController {
                    if let navigator = GSTopViewController.topViewController().navigationController {
                        navigator.pushViewController(tempVC, animated: false)
                    }
                }
                
                break
            case .messages:         // Messages
                if let messagesVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
                    .instantiateViewController(withIdentifier: GSString.Push.GSMessagesRootViewController) as? GSMessagesRootViewController {
                    if let navigator = GSTopViewController.topViewController().navigationController {
                        navigator.pushViewController(messagesVC, animated: false)
                    }
                }
                break
            case .purchaseHistory:        // Purchase History
                if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
                    .instantiateViewController(withIdentifier: GSString.Push.GSPurchaseHistoryViewController) as? GSPurchaseHistoryViewController {
                    if let navigator = GSTopViewController.topViewController().navigationController {
                        navigator.pushViewController(tempVC, animated: false)
                    }
                }
                break
            case .payment:         // Payment
                if let tempVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil)
                    .instantiateViewController(withIdentifier: GSString.Push.GSPaymentTypeViewController) as? GSPaymentTypeViewController {
                    if let navigator = GSTopViewController.topViewController().navigationController {
                        navigator.pushViewController(tempVC, animated: false)
                    }
                }
                break
        case .invite:              // Invite
            if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
                .instantiateViewController(withIdentifier: GSString.Push.GSInviteFriendsViewController) as? GSInviteFriendsViewController {
                
                GSCustomPushPop.doCustomPush(from: GSTopViewController.topViewController(), to: tempVC)
            }
            break
            
            case .profile:        // Profile and Settings
                if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
                    .instantiateViewController(withIdentifier: GSString.Push.GSProfileViewController) as? GSProfileAndSettingsViewController {
                    if let navigator = GSTopViewController.topViewController().navigationController {
                        navigator.pushViewController(tempVC, animated: false)
                    }
                }
                break
            case .notification: // Notifications
                
                if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
                    .instantiateViewController(withIdentifier: GSString.Push.GSNotificationsViewController) as? GSNotificationsViewController {
                    tempVC.isFromMenu = true
                    if let navigator = GSTopViewController.topViewController().navigationController {
                        navigator.pushViewController(tempVC, animated: false)
                    }
                }
                break
            case .support:         // Support
                if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
                    .instantiateViewController(withIdentifier: GSString.Push.GSSupportViewController) as? GSSupportViewController {
                    if let navigator = GSTopViewController.topViewController().navigationController {
                        navigator.pushViewController(tempVC, animated: false)
                    }
                }
                break
            case .about:         // About
                
                if let tempVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil)
                    .instantiateViewController(withIdentifier: GSString.Push.GSAboutViewController) as? GSAboutViewController {
                    if let navigator = GSTopViewController.topViewController().navigationController {
                        navigator.pushViewController(tempVC, animated: false)
                    }
                }
                
                break
            case .subscription:         // Subscription
                
                if let tempVC = UIStoryboard(name: GSString.storyboard.SubscriptionSB, bundle: nil)
                    .instantiateViewController(withIdentifier: GSString.Push.GSSubacriptionWalletViewController) as? GSSubacriptionWalletViewController {
                    if let navigator = GSTopViewController.topViewController().navigationController {
                        navigator.pushViewController(tempVC, animated: false)
                    }
                }
                break
            
        }
    }
    

    func updateSelectedMenuItem(){
        
        let topVC = GSTopViewController.topViewController()
        
        if topVC.isKind(of: GSShopsViewController.self) {
            selectedMenuItem = .shop
            
        } else if topVC.isKind(of: GSTrackOrderListViewController.self) {
            selectedMenuItem = .trackOrder

        } else if topVC.isKind(of: GSSubacriptionWalletViewController.self) {
            selectedMenuItem = .subscription
            
        } else if topVC.isKind(of: GSMessagesRootViewController.self) {
            selectedMenuItem = .messages
            
        } else if topVC.isKind(of: GSPurchaseHistoryViewController.self) {
            selectedMenuItem = .purchaseHistory

        }  else if topVC.isKind(of: GSPaymentTypeViewController.self) {
            selectedMenuItem = .payment
            
        } else if topVC.isKind(of: GSProfileAndSettingsViewController.self) {
            selectedMenuItem = .profile

        } else if topVC.isKind(of: GSNotificationsViewController.self) {
            selectedMenuItem = .notification
            
        } else if topVC.isKind(of: GSAboutViewController.self) {
            selectedMenuItem = .about
            
        } else if topVC.isKind(of: GSSupportViewController.self) {
            selectedMenuItem = .support
        } else {
            selectedMenuItem = .shop
        }
        menuTable.reloadData()
    }
    
    enum GSMenuBarItem {
        case shop
        case trackOrder
        case subscription
        case messages
        case purchaseHistory
        case payment
        case invite
        case profile
        case notification
        case support
        case about
    }
    
    // MARK: - API Methods
    
//    fileprivate func menuBarCountAPI() {
//
//        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
//        if isGuestLogin {
//            return
//        }
//
//        let urlString = APIurl.baseURL + APIurl.subURL.menuBarCount
//
//        APIHandler.NetworkSetupRequest(method: .get, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
//
//            guard let weakSelf = self else { return }
//
//            if error == nil {
//                do {
//                    guard let responseData = response else { return }
//                    let jsonDecoder = JSONDecoder()
//                    let responseModel = try jsonDecoder.decode(GSMenuBarCountModel.self, from: responseData)
//                    weakSelf.trackOrderCount = responseModel.trackOrderCount ?? 0
//                    weakSelf.messagesCount = responseModel.escalationCount ?? 0
//                    weakSelf.menuTable.reloadData()
//
//                } catch {
//                    print(error)
//                }
//            } else {
//                print(error?.localizedDescription ?? GSString.API.unknownError)
//            }
//        }
//    }
    
    fileprivate func trackOrderCountAPI() {
        
        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
        if isGuestLogin {
            return
        }
        
        let urlString = APIurl.baseURL + APIurl.subURL.trackOrderListCount
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSMenuBarCountModel.self, from: responseData)
                    weakSelf.trackOrderCount = responseModel.count ?? 0
                    weakSelf.menuTable.reloadData()
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }
    
    fileprivate func messagesCountAPI() {
        
        let isGuestLogin = SharedPersistence.getValue(key: UserDefaultKeys.isGuestUserLogin) as? Bool ?? false
        if isGuestLogin {
            return
        }
        
        let urlString = APIurl.baseURL + APIurl.subURL.messagesListCount
        
        APIHandler.NetworkSetupRequest(method: .get, params: nil, urlString: urlString, withLoader:true) { [weak self] (response, error) in
            
            guard let weakSelf = self else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else { return }
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSMenuBarCountModel.self, from: responseData)
                    weakSelf.messagesCount = responseModel.count ?? 0
                    weakSelf.menuTable.reloadData()
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
        }
    }
}

// MARK: - Menu Bar Count Model

struct GSMenuBarCountModel: Codable {
    let success: Bool?
    let count: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        count = values.decodeSafely(.count)
    }
}
