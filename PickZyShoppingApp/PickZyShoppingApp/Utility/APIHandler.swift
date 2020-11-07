//
//  swift
//  PickZyShoppingApp
//
//  Created by Ratheesh on 07/07/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import MBProgressHUD

//var isTokenRefreshing = false

class APIHandler: NSObject {
    
    // MARK: - Normal Post Method with common header...
    class func NetworkSetupRequestWithoutToken(method:HTTPMethod?,params: [String: AnyObject]?,urlString:String, withLoader:Bool, callback: @escaping (_ response: Data?, _ error: NSError?) -> Void) {
        setupNetworkRequestWith(method: method, params: params, urlString: urlString, headers: ["Content-Type":"application/json"], withLoader: withLoader, callback: callback)
    }
    
    // MARK: - Used for either POST or GET with common custom headers...
    
    class func NetworkSetupRequest(method:HTTPMethod?, params: [String: AnyObject]?,urlString:String, withLoader:Bool, callback: @escaping (_ response: Data?, _ error: NSError?) -> Void) {
        
        guard let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String else {
            print("Unique Id is nil...")
            return
        }
        let headers = ["Authorization":accessToken,
                       "Content-Type":"application/json"]
        
        checkForRefreshTokenAndProceedForAPIWith(method: method, params: params, urlString: urlString, headers: headers, withLoader: withLoader, callback: callback)
    }
    
    // MARK: - Methods having closure in control to make them nil
    
    class func BackGroundNetworkSetupRequest(method:HTTPMethod?, params: [String: AnyObject]?,urlString:String, withLoader:Bool, callback: @escaping (_ response: Data?, _ error: NSError?) -> Void) -> ((_ response: Data?, _ error: NSError?) -> Void) {
        
        guard let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String else {
            print("Unique Id is nil...")
            return callback
        }
        let headers = ["Authorization":accessToken,
                       "Content-Type":"application/json"]
        
        checkForRefreshTokenAndProceedForAPIWith(method: method, params: params, urlString: urlString, headers: headers, withLoader: withLoader, callback: callback)
        
        return callback
    }
    
    // MARK: - Normal Function that takes all parameters
    
    class func NetworkSetupRequest(method:HTTPMethod?, params: [String: AnyObject]?,urlString:String,headers: [String:String]?, withLoader:Bool, callback: @escaping (_ response: Data?, _ error: NSError?) -> Void) {
        checkForRefreshTokenAndProceedForAPIWith(method: method ?? .post, params: params ?? nil, urlString: urlString, headers: headers ?? nil, withLoader: withLoader, callback: callback)
    }
    
    // MARK: - Refresh Token
    
    private class func checkForRefreshTokenAndProceedForAPIWith(method:HTTPMethod?, params: [String: AnyObject]?,urlString:String,headers: [String:String]?, withLoader:Bool, callback: @escaping (_ response: Data?, _ error: NSError?) -> Void) {
        
        
        setupNetworkRequestWith(method: method ?? .post, params: params ?? nil, urlString: urlString, headers: headers ?? nil, withLoader: withLoader, callback: callback)
        
        
        //        if isNeedToRefreshToken() == true {
        //
        //
        //
        //            // Need to refresh token here...
        //            print("Need to refresh the token here")
        //
        //            var topViewController:UIViewController! = GSTopViewController.topViewController()
        //            DispatchQueue.main.async {
        //                topViewController = GSTopViewController.topViewController()
        //            }
        //
        //
        //            if isTokenRefreshing {
        //
        //                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
        //
        //                    if isNeedToRefreshToken() == true {
        //
        //                        refreshTokenAPI(topViewController: topViewController) { error in
        //
        //                            if error == nil {
        //                                let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        //                                let newHeaders = ["Authorization":accessToken,
        //                                                  "Content-Type":"application/json"]
        //
        //                                setupNetworkRequestWith(method: method ?? .post, params: params ?? nil, urlString: urlString, headers: newHeaders, withLoader: withLoader, callback: callback)
        //                            }
        //                        }
        //
        //                    } else {
        //                        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        //                        let newHeaders = ["Authorization":accessToken,
        //                                          "Content-Type":"application/json"]
        //
        //                        setupNetworkRequestWith(method: method ?? .post, params: params ?? nil, urlString: urlString, headers: newHeaders, withLoader: withLoader, callback: callback)
        //                    }
        //                }
        //
        //                return
        //            }
        //
        //            refreshTokenAPI(topViewController: topViewController) { error in
        //
        //                if error == nil {
        //
        //                    let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        //                    let newHeaders = ["Authorization":accessToken,
        //                                   "Content-Type":"application/json"]
        //
        //                    setupNetworkRequestWith(method: method ?? .post, params: params ?? nil, urlString: urlString, headers: newHeaders, withLoader: withLoader, callback: callback)
        //                }
        //            }
        //
        //        } else {
        //            setupNetworkRequestWith(method: method ?? .post, params: params ?? nil, urlString: urlString, headers: headers ?? nil, withLoader: withLoader, callback: callback)
        //        }
    }
    
    // MARK: - Base Networking Method
    private class func setupNetworkRequestWith(method:HTTPMethod?, params: [String: AnyObject]?,urlString:String,headers: [String:String]?, withLoader:Bool, callback: @escaping (_ response: Data?, _ error: NSError?) -> Void) {
        
        #if DEBUG
        print(urlString)
        print(params ?? "")
        #endif
        
        var topViewController:UIViewController!
        DispatchQueue.main.async {
            topViewController = GSTopViewController.topViewController()
        }
        
        if !Reachability.isConnectedToNetwork() {
            let userInfo: [String : Any] = [ NSLocalizedDescriptionKey :  NSLocalizedString(GSString.API.NoInternetConnection, comment: "")]
            callback(nil, NSError(domain: GSString.API.NoInternetConnection, code: 404, userInfo: userInfo))
            return
        }
        
        
        var httpMethod:HTTPMethod = .post
        if let methodUnWrapper = method {
            httpMethod = methodUnWrapper
        }
        let parameterEncoding:ParameterEncoding = httpMethod == .get ? URLEncoding.default : JSONEncoding.default
        
        DispatchQueue.main.async {
            GSConstant.linearBar.startAnimation()
        }
        if withLoader {
            //MBProgressHUD.showAdded(to: topViewController.view, animated: true)
            DispatchQueue.main.async {
                topViewController.view.endEditing(true)
            }
        }
        
        Alamofire.request(urlString,
                          method: httpMethod,
                          parameters: params,
                          encoding: parameterEncoding,
                          headers: headers)
            //            .validate(statusCode: 200..<500)
            //            .validate(contentType: ["application/json"])
            .responseJSON { responseData in
                
                DispatchQueue.main.async {
                    GSConstant.linearBar.stopAnimation()
                }
                if withLoader {
                    //MBProgressHUD.hide(for: topViewController.view, animated: true)
                }
                switch responseData.result {
                case .success(let result):
                    if let statusCode = responseData.response?.statusCode {
                        if statusCode == 200 {
                            debugPrint(responseData)
                            callback(responseData.data, nil)
                        } else {
                            
                            if let parsedError = failureResonseFormat(responseData: responseData, result: result, statusCode: statusCode) {
                                callback(nil, parsedError)
                            }
                        }
                    } else {
                        let userInfo: [String : Any] = [ NSLocalizedDescriptionKey :  NSLocalizedString("Error", comment: "")]
                        callback(nil, NSError(domain: "", code: 400, userInfo: userInfo))
                    }
                    
                case .failure(let error):
                    print(error)
                    callback(nil, error as NSError)
                }
        }
    }
    
    class private func failureResonseFormat(responseData: (DataResponse<Any>), result: (Any), statusCode: Int) -> NSError? {
        
        guard let resultValue = result as? [String:AnyObject] else {
            if let responseData = responseData.data {
                
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String:Any] {
                    
                    let message = json?["message"] as? String ?? GSString.API.unknownError
                    
                    let userInfo: [String : Any] = [ NSLocalizedDescriptionKey :  NSLocalizedString(message, comment: "")]
                    return NSError(domain: message, code: statusCode, userInfo: userInfo)
                }
                
            }
            
            let userInfo: [String : Any] = [ NSLocalizedDescriptionKey :  NSLocalizedString(responseData.error?.localizedDescription ?? "Error", comment: "")]
            return NSError(domain: responseData.error?.localizedDescription ?? "", code: statusCode, userInfo: userInfo)
        }
        
        if resultValue[APIKeys.token_expire_key] != nil {
            
            SharedPersistence.removeUserDefaults()
            tokenExpiryAction(message: resultValue[APIKeys.BadResponse.message] as? String ?? "Token expired... Please login again")
            
            return nil
        }
        
        if let messageValue = resultValue[APIKeys.BadResponse.message] as? String {
            
            let userInfo: [String : Any] = [ NSLocalizedDescriptionKey :  NSLocalizedString(messageValue, comment: "")]
            let error = NSError(domain: messageValue, code: statusCode, userInfo: userInfo)
            return error as NSError
            
        } else if let error_value = resultValue[APIKeys.BadResponse.error] as? [String: Any] {
            
            if let message_value = error_value[APIKeys.BadResponse.message] as? String {
                let userInfo: [String : Any] = [ NSLocalizedDescriptionKey :  NSLocalizedString(message_value, comment: "")]

                return NSError(domain: message_value, code: statusCode, userInfo: userInfo)
            }
        } else if let error_value = resultValue[APIKeys.BadResponse.error] as? String {
            let userInfo: [String : Any] = [ NSLocalizedDescriptionKey :  NSLocalizedString(error_value, comment: "")]

            return NSError(domain: error_value, code: statusCode, userInfo: userInfo)
        }
        
        let userInfo: [String : Any] = [ NSLocalizedDescriptionKey :  NSLocalizedString(responseData.error?.localizedDescription ?? "Error", comment: "")]

        return NSError(domain: responseData.error?.localizedDescription ?? "", code: statusCode, userInfo: userInfo)
    }
    
    class func tokenExpiryAction(message:String) {
        
        var topViewController:UIViewController!
        
        DispatchQueue.main.async {
            topViewController = GSTopViewController.topViewController()
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                if let theWindow = appDelegate.window {
                    
                    if let unwrappedMenuBar = menuBar, unwrappedMenuBar.isDescendant(of: theWindow) {
                        unwrappedMenuBar.removeFromSuperview()
                    }
                    
                    if let productListVC = topViewController as? GSProductsViewController, productListVC.categoryMenuView.isDescendant(of: theWindow) {
                        productListVC.categoryMenuView.removeFromSuperview()
                    }
                }
            }
            
            let storyboard = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil)
            let intialVC = storyboard.instantiateViewController(withIdentifier: GSString.Push.GSWelcomeScreenViewController)
            topViewController.navigationController?.viewControllers = [intialVC]
            CustomAlert.showAlert(title: GSString.AppName, message: message, viewController: intialVC)
            
            
//            CustomAlert.showAlert(title: GSString.AppName, message: message, alertButtonsArray: ["Ok"], viewController: topViewController, completion: { _ in
//                let storyboard = UIStoryboard(name: GSString.storyboard.LoginSB, bundle: nil)
//                let intialVC = storyboard.instantiateViewController(withIdentifier: GSString.Push.GSWelcomeScreenViewController)
//                topViewController.navigationController?.viewControllers = [intialVC]
//            })
        }
    }
    
    
    // MARK: - Form Data Network Request
    
    private class func multiPartRequestWith(method: HTTPMethod,multiPartItems:[Data],keyNames:[String],fileName:String,params: [String: Data]?,urlString:String,headers: [String:String]?, needToResignKeyboard:Bool, callback: @escaping (_ response: Data?, _ error: NSError?) -> Void) {
        
        print(urlString)
        
        var topViewController:UIViewController! = GSTopViewController.topViewController()
        DispatchQueue.main.async {
            topViewController = GSTopViewController.topViewController()
            if needToResignKeyboard {
                topViewController.view.endEditing(true)
            }
        }
        
        if !Reachability.isConnectedToNetwork() {
            
            //            SACustomAlert.showAlert(title: "\(SAString.AppName) - Info", message: SAString.API.NoInternetConnection, viewController: topViewController)
            let userInfo: [String : Any] = [ NSLocalizedDescriptionKey :  NSLocalizedString(GSString.API.NoInternetConnection, comment: "")]
            callback(nil, NSError(domain: GSString.API.NoInternetConnection, code: 404, userInfo: userInfo))
            return
        }
        
        DispatchQueue.main.async {
//            MBProgressHUD.showAdded(to: topViewController.view, animated: true)
            
            let hudInstance = MBProgressHUD.showAdded(to: topViewController.view, animated: true)
//            hudInstance.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            hudInstance.bezelView.color = UIColor.lightGray
            hudInstance.bezelView.style = .solidColor
        }
        
        
        Alamofire.upload(multipartFormData: { MultipartFormData in
            
            if let parameters = params {
                
                for (key,value) in parameters {
                    MultipartFormData.append(value, withName:key)
                }
            }
            for count in 0..<keyNames.count {
                MultipartFormData.append(multiPartItems[count], withName: keyNames[count], fileName: "myImage.png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: urlString, method: method, headers: headers) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: topViewController.view, animated: true)
                    }
                    
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 200 {
                            debugPrint(response)
                            callback(response.data, nil)
                        } else {
                            
                            if let parsedError = failureResonseFormat(responseData: response, result: result, statusCode: statusCode) {
                                callback(nil, parsedError)
                            }
                        }
                    } else {
                        let userInfo: [String : Any] = [ NSLocalizedDescriptionKey :  NSLocalizedString("Error", comment: "")]
                        callback(nil, NSError(domain: "", code: 400, userInfo: userInfo))
                    }
                }
                break
                
            case .failure(let error):
                callback(nil, error as NSError)
            }
            
        }   // Alamofire braces ends here...
        
    }
    
    
    class func multiPartNetworkRequestWith(method: HTTPMethod,multiPartItems:[Data],keyNames:[String],fileName:String,params: [String: Data]?,urlString:String,headers: [String:String]?, needToResignKeyboard:Bool, callback: @escaping (_ response: Data?, _ error: NSError?) -> Void) {
        
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        let headers_updated = ["Authorization": accessToken,
                       "Content-Type":"multipart/form-data"]
        
        multiPartRequestWith(method: method, multiPartItems: multiPartItems, keyNames: keyNames, fileName: fileName, params: params, urlString: urlString, headers: headers_updated, needToResignKeyboard: needToResignKeyboard, callback: callback)
        

    }
    
    // MARK: - Method to check the need of refresh token
    
    class private func isNeedToRefreshToken() -> Bool {
        
//        let tokenExpiryEpochTime = SharedPersistence.getValue(key: UserDefaultKeys.user.tokenExpiryTime) as? Int64 ?? 0
        let tokenExpiryEpochTime:Int64 = 0

        let currentEpochTime = Date().timeIntervalSince1970
        let currentEpochTimeDouble = Double(currentEpochTime)
        let currentTimeInSec = Int64(currentEpochTimeDouble)
        
        if tokenExpiryEpochTime - currentTimeInSec < GSConstant.refreshTokenDifferentiationSeconds {
            return true
        }
        
        return false
    }
    
    
    // MARK: - Refresh Token
    
    class func refreshTokenAPI(topViewController:UIViewController, callback: @escaping ( _ error: NSError?) -> Void) {
        
        let refreshTokenUrl = APIurl.baseURL + APIurl.subURL.refreshToken
        
        #if DEBUG
        print("\n\n\n\n\n")
        print("Refresh Token API Called")
        print("\n\n\n\n\n")
        #endif
        
        guard let refreshToken = SharedPersistence.getValue(key: UserDefaultKeys.user.refreshToken) as? String else {
            print("Unique Id is nil...")
            callback(nil)
            return
        }
        let headers = ["Authorization":refreshToken,
                       "Content-Type":"application/json"]
        
//        isTokenRefreshing = true
        
        Alamofire.request(refreshTokenUrl,
                          method: .post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
            //            .validate(statusCode: 200..<500)
            //            .validate(contentType: ["application/json"])
            .responseJSON { responseData in
                
//                isTokenRefreshing = false
                
                switch responseData.result {
                case .success( _):
                    if let statusCode = responseData.response?.statusCode {
                        if statusCode == 200 {
                            
                            manageRefreshToken(responseData: responseData)
                            callback(nil)
                            
                        } else {
                            callback(nil)
                        }
                    } else {
                        callback(nil)
                    }
                    
                case .failure(let error):
                    print(error)
                    callback(error as NSError)
                    
                    #if DEBUG
                    print("\n\n\n\n\n")
                    print("Refresh Token Expired....")
                    print("\n\n\n\n\n")
                    #endif
                    
//                    tokenExpiryAction(message: GSConstant.AlertMessages.tokenExpired)
                }
        }
        
    }
    
    class private func manageRefreshToken(responseData: (DataResponse<Any>)?) {
        
        do {
            guard let unwrappedResponseData = responseData?.data else { return }
            let jsonDecoder = JSONDecoder()
            let responseModel = try jsonDecoder.decode(GSLoginRootClass.self, from: unwrappedResponseData)
            
            let accessToken = responseModel.data?.authToken?.access?.token ?? ""
            let accessTokenPrefix = responseModel.data?.authToken?.access?.schema ?? ""
            
            let refreshToken = responseModel.data?.authToken?.refresh?.token ?? ""
            let refreshTokenPrefix = responseModel.data?.authToken?.refresh?.schema ?? ""
            
            SharedPersistence.storeAccessToken(accessToken: accessToken, prefix: accessTokenPrefix)
            SharedPersistence.storeRefreshToken(refreshToken: refreshToken, prefix: refreshTokenPrefix)
//            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.user.tokenExpiryTime, value: responseModel.data?.authToken?.access?.exp ?? 0)
        } catch {
            print(error)
        }
    }
}
