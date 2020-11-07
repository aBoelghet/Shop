//
//  GSApiTokenData.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 10/07/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation
//import JWT

// We used this in starting of this project... after few days we have discussed that we dont need this.. Not removing so that we can use in the future...

/*

class GSApiTokenData {
    
    class func unWrapTheDataFrom(_ token:String) -> Bool {
        
        guard let secretKey = SharedPersistence.getValue(key: UserDefaultKeys.apiDynamicSecretKey) as? String else {return false}
        guard let utf8DataFromSecretKet = secretKey.data(using: .utf8) else {return false}
        
        do {
            //        let decodedData = try JWT.decode(token, algorithm: .hs256(utf8DataFromSecretKet))
            let decodedData = try JWT.decode(token, algorithm: .hs256(utf8DataFromSecretKet), leeway: 10)
            print(decodedData)
        
            let claims = decodedData.claims
            let secretKey = claims["secret_key"]
            let uniqueId = claims["unique_id"]
            
            guard secretKey != nil, uniqueId != nil else {return false}
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.apiDynamicSecretKey, value: secretKey as Any)
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.user.accessToken, value: uniqueId as Any)
            return true
            
        } catch {
            print(error)
            return false
        }
    }
    
    class func createToken(_ payload:[String:AnyObject]) -> String {
        guard let secretKey = SharedPersistence.getValue(key: UserDefaultKeys.apiDynamicSecretKey) as? String else {return ""}
        guard let utf8DataFromSecretKet = secretKey.data(using: .utf8) else {return ""}
        
        let claims = ClaimSet.init(claims: payload)
        let encodedData = JWT.encode(claims: claims, algorithm: .hs256(utf8DataFromSecretKet))
        
        print(encodedData)
        return "Bearer" + " " + encodedData
    }

}

 
 */
