//
//  GSClearCartSupport.swift
//  Shopor-dev
//
//  Created by Ratheesh on 10/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

protocol GSClearCartDelegate:NSObjectProtocol {
    func cartClearedSuccessfully()
}

class GSClearCartSupport {
    
    weak var delegate:GSClearCartDelegate?
    
    func clearCartAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.clearCart
        
        APIHandler.NetworkSetupRequest(method: .delete, params: [String:AnyObject]() ,urlString: urlString, withLoader:true) { (response, error) in
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if let success = responseModel.success {
                        debugPrint("Clear Cart Status : \(success)")
                        cartCount.value = 0
                        self.delegate?.cartClearedSuccessfully()
                        
                        if cartItemsDictionary.count > 0 {
                            cartItemsDictionary.removeAll()
                        }
                    }
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
            
        }
        
    }
    
    func clearSaveForLaterAPI() {
        
        let urlString = APIurl.baseURL + APIurl.subURL.clearSaveForLater
        
        APIHandler.NetworkSetupRequest(method: .delete, params: [String:AnyObject]() ,urlString: urlString, withLoader:true) { (response, error) in
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    if let success = responseModel.success {
                        debugPrint("Clear Save For Later Status : \(success)")
                    }
                    
                } catch {
                    print(error)
                }
            } else {
                print(error?.localizedDescription ?? GSString.API.unknownError)
            }
            
        }
        
    }
}
