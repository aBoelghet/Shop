//
//  GSPaymentParametersHelper.swift
//  Shopor
//
//  Created by Ratheesh on 29/11/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation
import PayU_coreSDK_Swift

// MARK: - Payment Hashes Generation Model
struct GSPaymentHashesModel: Codable {
    let success: Bool?
    let data: GSPaymentHashesData?
}

struct GSPaymentHashesData: Codable {
    let transactionID, firstname, email: String?
    let amount: String?
    let key, productinfo, phash, gcdhash, scdhash, dcdhash, vmshash: String?
    let pmshash: String?
    let razorpayKey: String?
    let gatepaymentType: Int?

    enum CodingKeys: String, CodingKey {
        case transactionID = "transaction_id"
        case razorpayKey = "rzy_pay_key"
        case gatepaymentType = "gateway_id"
        case firstname, email, amount, key, productinfo, phash, vmshash, pmshash, gcdhash, scdhash, dcdhash
    }
}

class GSPaymentParametersHelper {
    
    func setPaymentParams(isGoingToOrder:Bool, isBayFayCash: Bool, transactionAmount:String, completion:@escaping (_ params:PayUModelPaymentParams?, _ error:NSError?) -> Void) {

        let paymentParams = PayUModelPaymentParams()
        var _isSaveCard : Bool = false

        if let decodedLoginUserData = SharedPersistence.getValue(key: UserDefaultKeys.user.user_details) as? Data {
            
            if let loginUser_jsonObject = try? JSONDecoder().decode(GSLoginData.self, from: decodedLoginUserData) {
                
                paymentParams.firstName = loginUser_jsonObject.userProfile?.firstName
                paymentParams.email = loginUser_jsonObject.userProfile?.email?.id
                
                paymentParams.phoneNumber = "\(loginUser_jsonObject.userProfile?.mobile?.number ?? 0)"
                paymentParams.userCredentials = "key:" + (loginUser_jsonObject.userProfile?.id ?? "")
            }
        }
        
        if isGoingToOrder == false {
            
            paymentParams.amount = GSPaymentConstants.DefaultVerifyAmount
            paymentParams.productInfo = "Card Verification"
            _isSaveCard = true
        } else {
            paymentParams.amount = transactionAmount
            paymentParams.productInfo = "\(GSString.AppName)"
        }
        
        paymentParams.key = GSPaymentConstants.GATEWAY_KEY
        paymentParams.txnId = generateTxnID()
        
        #if DEVELOPEMENT
        paymentParams.environment = ENVIRONMENT_TEST
        #elseif QA
        paymentParams.environment = ENVIRONMENT_TEST
        #else
        paymentParams.environment = ENVIRONMENT_PRODUCTION
        #endif
                
        paymentParams.surl = GSPaymentConstants.GATEWAY_surl
        paymentParams.furl = GSPaymentConstants.GATEWAY_furl
        
        //offer key if some offer is enabled
        paymentParams.offerKey = ""
        #if true
        generateHashesFromAPI(paymentParamsIns: paymentParams, isSaveCard: _isSaveCard, isBayFayCash: isBayFayCash) { (hashes, error) in
        
            if error == nil {
                
                paymentParams.txnId = hashes?.transactionID
                paymentParams.firstName = hashes?.firstname
                paymentParams.email = hashes?.email

                paymentParams.amount = hashes?.amount
                paymentParams.key = hashes?.key

                paymentParams.productInfo = hashes?.productinfo
                paymentParams.hashes.paymentHash = hashes?.phash
                paymentParams.hashes.VASForMobileSDKHash = hashes?.vmshash
                paymentParams.hashes.paymentRelatedDetailsHash = hashes?.pmshash
                
                paymentParams.hashes.getUserCardHash  = hashes?.gcdhash
                paymentParams.hashes.saveUserCardHash = hashes?.scdhash
                paymentParams.hashes.deleteUserCardHash = hashes?.dcdhash
                
                //let shackyClassObject = shackyClass()
                //shackyClassObject.generateHashesFromShackyClass(paymentParams: paymentParams, withSalt: "pjVQAWpA")

                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.transactionId, value: paymentParams.txnId ?? "")
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.razorPaykey, value: hashes?.razorpayKey ?? "")
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.paymentAmount, value:  paymentParams.amount ?? "")
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.paymentHash, value:  hashes?.dcdhash ?? "")
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.paymentGatewayType, value:  hashes?.gatepaymentType ?? "")

                completion(paymentParams,nil)
            } else {
                #if DEBUG
                    print(error ?? "Error")
                #endif
                completion(nil, error)
            }
        }
        #endif
        
        #if false
        
        let genHashes = PUSAGenerateHashes()
        genHashes.generateHashesFromServer(withPaymentParams: paymentParams) { (hashes, error) in
            
            if (hashes.isEqual("") == false)
            {
                paymentParams.hashes.paymentRelatedDetailsHash = hashes.paymentRelatedDetailsHash
                paymentParams.hashes.deleteUserCardHash = hashes.deleteUserCardHash
                paymentParams.hashes.offerHash  = hashes.offerHash
                paymentParams.hashes.VASForMobileSDKHash = hashes.VASForMobileSDKHash
                paymentParams.hashes.saveUserCardHash = hashes.saveUserCardHash
                paymentParams.hashes.paymentHash = hashes.paymentHash

                completion(paymentParams,nil)
            } else {
                #if DEBUG
                    print(error)
                #endif
                //completion(nil, error as NSError)
            }
        }
        #endif
    }
    
    func sha512Hex(string: String) -> String {
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        if let data = string.data(using: String.Encoding.utf8) {
            CC_SHA512(data.bytes, CC_LONG(data.count), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_SHA512_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }

    func generateTxnID() -> String {
        
        let currentDate = DateFormatter()
        currentDate.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        let dateString = currentDate.string(from : date as Date)
        return dateString
        
    }
    
    // MARK: - Card Icons Differentiation
    class func imageForTheCardtypeWithObject(cardBrand: String) -> UIImage {
        
        switch cardBrand {
        case CardTypes.MASTERCARD:
            return #imageLiteral(resourceName: "masterCard_icon")
        case CardTypes.MAESTRO:
            return #imageLiteral(resourceName: "maestroCard_icon")
        case CardTypes.VISA:
            return #imageLiteral(resourceName: "visa_icon")
        case CardTypes.AMEX:
            return #imageLiteral(resourceName: "amexCard_icon")
        case CardTypes.DINER:
            return #imageLiteral(resourceName: "dinerCard_icon")
        case CardTypes.RUPAY:
            return #imageLiteral(resourceName: "rupayCard_icon")
        default:
            return #imageLiteral(resourceName: "Card")
        }
    }
    
    // MARK: - Generate Hashes From API
    func generateHashesFromAPI(paymentParamsIns:PayUModelPaymentParams, isSaveCard:Bool, isBayFayCash: Bool, completion:@escaping (_ paymentParam:GSPaymentHashesData?, _ error: NSError?) -> Void) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.generateHashesFromServer
        
        var params = ["is_save_card" : isSaveCard] as [String : AnyObject]
        
        if isSaveCard == false {
            let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
            params["_id"] = storeCategory_id as AnyObject
            params["is_bayfaycash"] = isBayFayCash as AnyObject
            
            if let promoCode = SharedPersistence.getValue(key: UserDefaultKeys.Payment.promoCode) as? String, promoCode != "" {
                params["promo_id"] = promoCode as AnyObject
            }
        }
        
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:true) { [weak self]  (response, error) in
            
            // Making sure the next code will not execute if the view controller not exists in memory
            guard self != nil else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSPaymentHashesModel.self, from: responseData)
                    
                    if let hashes = responseModel.data {
                        completion(hashes,nil)
                    } else {
                        completion(nil, NSError(domain: "Unknown error", code: 404, userInfo: nil))
                    }
                    
                } catch {
                    print(error)
                    completion(nil,error as NSError)
                }
            } else {
                print(error?.localizedDescription ?? "")
                completion(nil,error)
            }
        }
    }
}

