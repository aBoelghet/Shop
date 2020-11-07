 //
//  GSSharedPersistence.swift
//  SampleDesigns
//
//  Created by Ratheesh TR on 2/26/18.
//  Copyright © 2018 Ratheesh TR. All rights reserved.
//

import Foundation
import UserNotifications

class SharedPersistence {
    
    class func storeUserDefaults(key:String, value:Any) {
        let tempDefaults = UserDefaults()
        tempDefaults.set(value, forKey: key)
        tempDefaults.synchronize()
    }
    
    class func storeAccessToken(accessToken:String, prefix:String) {
        let tempDefaults = UserDefaults()
        tempDefaults.set(prefix + " " + accessToken, forKey: UserDefaultKeys.user.accessToken)
        tempDefaults.synchronize()
    }
    
    class func storeRefreshToken(refreshToken:String, prefix:String) {
        let tempDefaults = UserDefaults()
        tempDefaults.set(prefix + " " + refreshToken, forKey: UserDefaultKeys.user.refreshToken)
        tempDefaults.synchronize()
    }
    
    class func getValue(key:String) -> Any? {
        let tempDefaults = UserDefaults()
        if let theValue = tempDefaults.value(forKey: key) {
            return theValue
        }
        return nil
    }
    
    class func removeValue(key:String){
        let tempDefaults = UserDefaults()
        if tempDefaults.value(forKey: key) != nil{
            tempDefaults.removeObject(forKey: key)
            tempDefaults.synchronize()
        }
    }
    
    class func removeValues(for keys:[String]) {
        for key in keys {
            removeValue(key: key)
        }
    }
    
    class func removeUserDefaults() {
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        cartCount.value = 0
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key != UserDefaultKeys.deviceToken, key != UserDefaultKeys.isShopWelcomeShown, key != UserDefaultKeys.isProductAnimationShown {
                defaults.removeObject(forKey: key)
            }
        }  // Ends here
    }

}
