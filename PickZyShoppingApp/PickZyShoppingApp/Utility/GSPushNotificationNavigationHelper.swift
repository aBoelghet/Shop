//
//  GSPushNotificationNavigationHelper.swift
//  Shopor
//
//  Created by Ratheesh on 25/01/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit
import UserNotifications

class GSPushNotificationNavigationHelper {
    
    var user_info:[AnyHashable : Any]!
    var topViewController:UIViewController?
    var appStatus: UIApplicationState?
    var isLocalNotification = false
    
    var isUserLoggedIn = true
    
    init(with userInfo: [AnyHashable : Any], applicationStatus:UIApplicationState, isLocalNotification:Bool) {
        self.user_info = userInfo
        self.topViewController = GSTopViewController.topViewController()
        self.appStatus = applicationStatus
        self.isLocalNotification = isLocalNotification
        
        if SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) == nil {
            isUserLoggedIn = false
        }
    }
    
    
    func isNeedToShowBanners() -> Bool {
        
        if isUserLoggedIn == false {
            return true
        }
        
        guard let data_object = user_info["datas"] as? [String:Any] else { return false }
        guard let notification_type = data_object["type"] as? Int else { return false }
        guard let notificationBody = data_object["body"] as? [String:Any] else { return false }
        
        switch notification_type {
            
        case PushConfiguration.track_order_list:
            
            if let trackListVC = topViewController as? GSTrackOrderListViewController {
                trackListVC.trackOrderListAPI()
                return false
            }
            
            return true
            
        case PushConfiguration.track_order_view:
            
            guard let orderId = notificationBody["order_id"] as? String else { print("Orderid unavailable");return false }
            guard let shopId = notificationBody["shop_id"] as? String else { print("ShopId unavailable");return false }
            guard let categoryId = notificationBody["category_id"] as? String else { print("CategoryId unavailable");return false }
            
            if let verifyItemsVC = topViewController as? GSVerifyItemsViewController, verifyItemsVC.order_id == orderId {
                
                verifyItemsVC.initializeWith(categoryId: categoryId, storeId: shopId, orderId: orderId)
                verifyItemsVC.productListAPI()
                
                return false
            }
            return true
            
        case PushConfiguration.purchase_history_list:
            
            if let purchaseListVC = topViewController as? GSPurchaseHistoryViewController {
                purchaseListVC.getPurchaseHistoryList()
                return false
            }
            return true
            
        case PushConfiguration.purchase_history_view:
            
            guard let orderId = notificationBody["order_id"] as? String else { print("Orderid unavailable");return false }
            guard let shopId = notificationBody["shop_id"] as? String else { print("ShopId unavailable");return false }
            guard let categoryId = notificationBody["category_id"] as? String else { print("CategoryId unavailable");return false }

            if let verifyItemsVC = topViewController as? GSPurchasedProductsVerifyViewController, verifyItemsVC.order_id == orderId {

                verifyItemsVC.initializeWith(categoryId: categoryId, storeId: shopId, orderId: orderId)
                verifyItemsVC.productListAPI()
                
                return false
            }
            return true
            
        case PushConfiguration.messages_list:
            
            if let messageListVC = topViewController as? GSMessagesRootViewController {
                messageListVC.getMessagesOrderList()
                return false
            }
            
            return true
            
        case PushConfiguration.messages_view:
            
            guard let product_id = notificationBody["product_id"] as? String else { print("ProductId unavailable");return false }
            guard let orderId = notificationBody["order_id"] as? String else { print("Orderid unavailable");return false }
            guard let shopId = notificationBody["shop_id"] as? String else { print("ShopId unavailable");return false }
            guard let categoryId = notificationBody["category_id"] as? String else { print("CategoryId unavailable");return false }
            
            if let messagesVC = topViewController as? GSMessagesViewController, messagesVC.product_id == product_id {

                messagesVC.configureWith(categoryId: categoryId, idOfTheOrder: orderId, storeId: shopId , productId: product_id)
                messagesVC.getChatList()
                
                return false
            }
            return true
            
        default:
            return true
        }
        
    }
    
    // MARK: - Decide The Navigation
    
    func decideTheNavigation() {
        
        if isUserLoggedIn == false {
            return
        }
        
        guard let data_object = user_info["datas"] as? [String:Any] else { return }
        guard let notification_type = data_object["type"] as? Int else { return }
        guard let notificationBody = data_object["body"] as? [String:Any] else { return }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let theWindow = appDelegate.window {
            if let theMenuBar = menuBar, theMenuBar.isDescendant(of: theWindow) {
                
                theMenuBar.menuBG.backgroundColor = UIColor.clear
                let screen: CGRect = UIScreen.main.bounds
                UIView.animate(withDuration: 0.25, animations: { 
                    theMenuBar.frame = CGRect(x: screen.origin.x - screen.size.width, y: screen.origin.y + theMenuBar.topLayoutGuideLength, width: screen.size.width, height: screen.size.height - theMenuBar.topLayoutGuideLength - theMenuBar.bottomLayoutGuideLength)
                },completion: { _ in
                    theMenuBar.removeFromSuperview()
                })
            }
        }
        
        
        switch notification_type {
        case PushConfiguration.track_order_list:
            pushToTrackOrderList(bodyJson: notificationBody)
            break
        case PushConfiguration.track_order_view:
            pushToTrackOrder_productDetails(bodyJson: notificationBody)
            break
        case PushConfiguration.purchase_history_list:
            pushToPurchaseHistoryList(bodyJson: notificationBody)
            break
        case PushConfiguration.purchase_history_view:
            pushToPurchaseHistory_productDetails(bodyJson: notificationBody)
            break
        case PushConfiguration.messages_list:
            pushToMessagesList(bodyJson: notificationBody)
            break
        case PushConfiguration.messages_view:
            pushToChat(bodyJson: notificationBody)
            break
            
        case PushConfiguration.referral:
            pushToPaymentView()
            break
        default:
            break
        }
    }
    
    // MARK: - Unwrap Data and push to appropriate Views
    
    private func pushToTrackOrderList(bodyJson:[String:Any]) {
        
        if let trackListVC = topViewController as? GSTrackOrderListViewController {
            trackListVC.trackOrderListAPI()
            return
        }
        
        if let trackOrderListVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSTrackOrderListViewController) as? GSTrackOrderListViewController {
            
            topViewController?.navigationController?.pushViewController(trackOrderListVC, animated: true)
        }
    }

    
    private func pushToTrackOrder_productDetails(bodyJson:[String:Any]) {
        
        let shopId = bodyJson["shop_id"] as? String ?? ""
        let categoryId = bodyJson["category_id"] as? String ?? ""
        let orderId = bodyJson["order_id"] as? String ?? ""
        
        if let trackOrderVerifyVC_onTop = topViewController as? GSVerifyItemsViewController {
            
                trackOrderVerifyVC_onTop.initializeWith(categoryId: categoryId, storeId: shopId, orderId: orderId)
                trackOrderVerifyVC_onTop.productListAPI()
            
        } else {
            // Top Vc is not the same VC

                if let trackOrderVerifyItemsVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSVerifyItemsViewController) as? GSVerifyItemsViewController {
                    
                    trackOrderVerifyItemsVC.initializeWith(categoryId: categoryId, storeId: shopId, orderId: orderId)
                    topViewController?.navigationController?.pushViewController(trackOrderVerifyItemsVC, animated: true)
                }
        }
        
    }
    
    private func pushToPurchaseHistoryList(bodyJson:[String:Any]) {
        
        if let purchaseListVC = topViewController as? GSPurchaseHistoryViewController {
            purchaseListVC.getPurchaseHistoryList()
            return
        }
        
        if let purchaseHistoryListVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPurchaseHistoryViewController) as? GSPurchaseHistoryViewController {
            
            topViewController?.navigationController?.pushViewController(purchaseHistoryListVC, animated: true)
        }
    }
    
    
    private func pushToPurchaseHistory_productDetails(bodyJson:[String:Any]) {
        
        let shopId = bodyJson["shop_id"] as? String ?? ""
        let categoryId = bodyJson["category_id"] as? String ?? ""
        let orderId = bodyJson["order_id"] as? String ?? ""
        
        if let purhcasedVerifyItemsVC_onTop = topViewController as? GSPurchasedProductsVerifyViewController {
            
                purhcasedVerifyItemsVC_onTop.initializeWith(categoryId: categoryId, storeId: shopId, orderId: orderId)
                purhcasedVerifyItemsVC_onTop.productListAPI()
            
        } else {
            // Top Vc is not the same VC
            
                if let purhcasedVerifyItemsVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPurchasedProductsVerifyViewController) as? GSPurchasedProductsVerifyViewController {
                    
                    purhcasedVerifyItemsVC.initializeWith(categoryId: categoryId, storeId: shopId, orderId: orderId)
                    topViewController?.navigationController?.pushViewController(purhcasedVerifyItemsVC, animated: true)
                }
        }
    }
    
    private func pushToMessagesList(bodyJson:[String:Any]) {
        
        if let messageListVC = topViewController as? GSMessagesRootViewController {
            messageListVC.getMessagesOrderList()
            return
        }
        
        if let messagesRootListVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSMessagesRootViewController) as? GSMessagesRootViewController {
            
            topViewController?.navigationController?.pushViewController(messagesRootListVC, animated: true)
        }
    }
    
    private func pushToChat(bodyJson:[String:Any]) {
        
        let shopId = bodyJson["shop_id"] as? String ?? ""
        let categoryId = bodyJson["category_id"] as? String ?? ""
        let orderId = bodyJson["order_id"] as? String ?? ""
        let product_id = bodyJson["product_id"] as? String ?? ""
        
        if let messageVC_onTop = topViewController as? GSMessagesViewController {
            
                messageVC_onTop.configureWith(categoryId: categoryId, idOfTheOrder: orderId, storeId: shopId , productId: product_id)
                messageVC_onTop.getChatList()
            
        } else {
            // Top Vc is not the same VC
            
            if let messagesVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSMessagesViewController) as? GSMessagesViewController {
                messagesVC.configureWith(categoryId: categoryId, idOfTheOrder: orderId, storeId: shopId , productId: product_id)
                topViewController?.navigationController?.pushViewController(messagesVC, animated: true)
            }
        }
    }
    
    private func pushToPaymentView() {
        
        if let paymentTypeVC = topViewController as? GSPaymentTypeViewController {
            
            paymentTypeVC.bayFayCashAPI()
            
            if paymentTypeVC.isGoingToOrder {
                paymentTypeVC.paymentParams = nil
                paymentTypeVC.paymentParamsWithBayFayCash = nil
                paymentTypeVC.paymentParamsWithOutBayFayCash = nil
                paymentTypeVC.viewWillAppear(false)
            }
            
        } else {
            
            if let paymentTypeVC = UIStoryboard(name: GSString.storyboard.PaymentSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSPaymentTypeViewController) as? GSPaymentTypeViewController {
                
                topViewController?.navigationController?.pushViewController(paymentTypeVC, animated: true)
            }
        }
    }
    
    
    private func createLocalNotifications(with payload:[AnyHashable : Any]) {
        
        return
        
//        let notificationContent = UNNotificationContent()
//        let notificationRequest = UNNotificationRequest(identifier: GSConstant.localPushNotificationIdentifier, content: notificationContent, trigger: nil)
//
//        UNUserNotificationCenter.current().add(notificationRequest) { _ in }
    }
}
