//
//  GSPlaceOrderHelper.swift
//  Shopor
//
//  Created by Ratheesh on 03/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation

protocol GSPlaceOrderHelperDelegate:NSObjectProtocol {
    func orderPlacedWith(status:Bool,data:GSPlaceOrderResponseData? , message:String)
}

class GSPlaceOrderHelper {
    
    var delegate:GSPlaceOrderHelperDelegate?
    var isOnlyBayFayCashOrder = false
    var txn_id = ""
    var paidAmount = ""
    
    func placeOrderAPI(paymentObject:[String:AnyObject]?) {
        
        var urlString = ""
        
        let storeCategory_id = SharedPersistence.getValue(key: UserDefaultKeys.Products.selectedStoreCategory_id) as? String ?? ""
        let selectedDelivery_type = SharedPersistence.getValue(key: UserDefaultKeys.Payment.selectedDeliveryType) as? Int ?? 1

        var params = [String : AnyObject]()
        
        var isShopDelivery = true
        
        if selectedDelivery_type == GSConstant.defaultDeliveryMethod_id {        // Delivery by Shop
            params = createParametersToPlaceOrderWithShopDelivery(storeCategory_id: storeCategory_id)
            urlString = APIurl.baseURL + APIurl.subURL.placeOrderByShop_COD
        } else {                                                                // Take Away
            let deliveryPreference = createDeliveryTimePreferenceJson()
            params = ["_id" : storeCategory_id,
                      "deliveryPreferences" : deliveryPreference] as [String : AnyObject]
            urlString = APIurl.baseURL + APIurl.subURL.placeOrderTakeAway_COD
            isShopDelivery = false
        }

        if let unwrapped_paymentObject = paymentObject {
            
            if selectedDelivery_type == GSConstant.defaultDeliveryMethod_id {
                urlString = APIurl.baseURL + APIurl.subURL.placeOrderByShop_payment
            } else {
                urlString = APIurl.baseURL + APIurl.subURL.placeOrderTakeAway_payment
            }
            params["payment"] = unwrapped_paymentObject as AnyObject
            params["is_bayfaycash"] = (SharedPersistence.getValue(key: UserDefaultKeys.Payment.isBayFayCashSelected) as? Bool ?? false) as AnyObject
        }
        
        if isOnlyBayFayCashOrder {
            params = createParametersToPlaceOrderWithShopDelivery(storeCategory_id: storeCategory_id)
            params["payment"] = ["txnid": txn_id] as AnyObject
            params["is_bayfaycash"] = true  as AnyObject
            params["is_shop_delivery"] = isShopDelivery as AnyObject
            urlString = APIurl.baseURL + APIurl.subURL.OrderWithOnlyBayfayCash
        }
        
        if let promoCode = SharedPersistence.getValue(key: UserDefaultKeys.Payment.promoCode) as? String, promoCode != "" {
            params["promo_id"] = promoCode as AnyObject
        }
        
        if let deliveryNotes = SharedPersistence.getValue(key: UserDefaultKeys.DeliveryFeatureDetails.deliveryNotes) as? String {
            params["notes"] = deliveryNotes as AnyObject
        }
        
        var imageArray = [Data]()
        var imageKeyArray = [String]()
        var multipartParameters = [String:Data]()
        
        if let deliveryInstructionImageData = SharedPersistence.getValue(key: UserDefaultKeys.DeliveryFeatureDetails.deliveryInstructionImage) as? Data {
            
            imageArray = [deliveryInstructionImageData]
            imageKeyArray = ["image"]
        }
        
        guard let jsonObject_data: Data = try? JSONSerialization.data(withJSONObject:params,options: JSONSerialization.WritingOptions.prettyPrinted) else { return }
        
        multipartParameters = ["inputs": jsonObject_data]
        
        let accessToken = SharedPersistence.getValue(key: UserDefaultKeys.user.accessToken) as? String ?? ""
        let headers = ["Authorization": accessToken,
                       "Content-Type":"multipart/form-data"]
        // API doc.txt
        APIHandler.multiPartNetworkRequestWith(method: .post, multiPartItems: imageArray, keyNames: imageKeyArray, fileName: "attachment.jpeg", params: multipartParameters, urlString: urlString, headers: headers, needToResignKeyboard: true) { [weak self]  (response, error) in
            
            // Making sure the next code will not execute if the view controller not exists in memory
            guard self != nil else { return }
            
            var transaction_id = ""
            var paymentHash = ""
            var isPaid = false
            
            if let unwrapped_paymentObject = paymentObject {
                
                isPaid = true
                transaction_id = unwrapped_paymentObject["txnid"] as? String ?? ""
                paymentHash = unwrapped_paymentObject["hash"] as? String ?? ""
                
                SharedPersistence.storeUserDefaults(key: UserDefaultKeys.Payment.transactionId, value: transaction_id)
            }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSPlaceOrderResponseModel.self, from: responseData)
                    
                    let status = responseModel.success ?? false
                    
                    if status {
                        if let data = responseModel.data {
                            self?.delegate?.orderPlacedWith(status: status, data: data, message: "")
                        }
                    } else {
                        
                        if isPaid {
                            self?.caseForPaidOrderNotPlaced(txnId: transaction_id, paymentHash: paymentHash)
                            return
                        }
                        
                        self?.delegate?.orderPlacedWith(status: status, data: nil, message: responseModel.error ?? "Unknown error")
                    }
                    
                } catch {
                    self?.delegate?.orderPlacedWith(status: false, data: nil, message: error.localizedDescription)
                }
            } else {
                
                if isPaid {
                    let transId = SharedPersistence.getValue(key: UserDefaultKeys.Payment.transactionId) as? String ?? transaction_id
                    self?.caseForPaidOrderNotPlaced(txnId: transId, paymentHash: paymentHash)
                    return
                }
                self?.delegate?.orderPlacedWith(status: false, data: nil, message: error?.localizedDescription ?? "Unknown error")
            }
        }
        
        
        /*
        
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:true) { [weak self]  (response, error) in
            
            // Making sure the next code will not execute if the view controller not exists in memory
            guard self != nil else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSPlaceOrderResponseModel.self, from: responseData)
                    
                    let status = responseModel.success ?? false
                    
                    if status {
                        if let data = responseModel.data {
                            self?.delegate?.orderPlacedWith(status: status, data: data, message: "")
                        }
                    } else {
                        self?.delegate?.orderPlacedWith(status: status, data: nil, message: responseModel.error ?? "Unknown error")
                    }
                    
                } catch {
                    self?.delegate?.orderPlacedWith(status: false, data: nil, message: error.localizedDescription)
                }
            } else {
                self?.delegate?.orderPlacedWith(status: false, data: nil, message: error?.localizedDescription ?? "Unknown error")
            }
        }
        
        */
    }
    
    // MARK: - Case Where Paid but order not placed
    func caseForPaidOrderNotPlaced(txnId: String, paymentHash: String) {
        
        let urlString = APIurl.baseURL + APIurl.subURL.refundForOrderIssue
        
        let params = ["amount_paid": paidAmount,
                      "payment": ["txnid": txnId,
                                  "hash": paymentHash]] as [String: AnyObject]
        
        APIHandler.NetworkSetupRequest(method: .post, params: params, urlString: urlString, withLoader:true) { [weak self]  (response, error) in
            
            // Making sure the next code will not execute if the view controller not exists in memory
            guard self != nil else { return }
            
            if error == nil {
                do {
                    guard let responseData = response else {return}
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(GSCommonSuccesWithMessageModel.self, from: responseData)
                    
                    self?.delegate?.orderPlacedWith(status: false, data: nil, message: responseModel.message ?? "")

                } catch {
                    self?.delegate?.orderPlacedWith(status: false, data: nil, message: error.localizedDescription)
                }
            } else {
                self?.delegate?.orderPlacedWith(status: false, data: nil, message: error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    // MARK: - Creating Parameters for delivery by shop order place
    
    private func createParametersToPlaceOrderWithShopDelivery(storeCategory_id:String) -> [String : AnyObject] {
        
        let deliveryLongitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLong) as? Double ?? 0
        let deliveryLattitude = SharedPersistence.getValue(key: UserDefaultKeys.locations.deliveryLat) as? Double ?? 0
        let zipCode = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_zipCode) as? String ?? ""
        
        var street = ""
        let changeableAddress = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_changeable) as? String ?? ""
        let landMark = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_landMark) as? String ?? ""
        if changeableAddress != "" {
            street += changeableAddress
        }

        if street == "" {
            street = "NA"
        }
        
        let area = SharedPersistence.getValue(key: UserDefaultKeys.locations.delivery_unchangeable_address) as? String ?? ""
        
        let deliveryPreference = createDeliveryTimePreferenceJson()
        
        var deliveryAddress = [ "street": street,
                                "area": area,
                                "zipcode": Int64(zipCode) ?? 0] as [String:AnyObject]
        
        if landMark != "" {
            deliveryAddress["landmark"] = landMark as AnyObject
        }
        
        let params = ["_id" : storeCategory_id ,
                      "deliveryLocation" : ["type": "Point",
                                            "coordinates": [deliveryLongitude, deliveryLattitude]],
                      "deliveryAddress": deliveryAddress,
                      "deliveryPreferences": deliveryPreference] as [String : AnyObject]
        
        return params
    }
    
    private func createDeliveryTimePreferenceJson() -> [String:AnyObject] {
        
        let isPreferenceSelected = SharedPersistence.getValue(key: UserDefaultKeys.DeliveryPreferences.isPrefferDateTimeSelected) as? Bool ?? false
        
        var deliveryPreference = [String : AnyObject]()
        
        if isPreferenceSelected {
            let preferredDate = SharedPersistence.getValue(key: UserDefaultKeys.DeliveryPreferences.prefferedDate) as? String ?? ""
            let preferedTime = SharedPersistence.getValue(key: UserDefaultKeys.DeliveryPreferences.prefferedTime) as? String ?? ""
            
            let times_array = preferedTime.components(separatedBy: "-")
            var from_time = ""
            var to_time = ""
            if times_array.count > 1 {
                from_time = times_array[0].removeEnclosedWhieteSpace().components(separatedBy: " ").first ?? ""
                let from_timeAMPM = times_array[0].removeEnclosedWhieteSpace().components(separatedBy: " ").last ?? ""
                if from_timeAMPM.lowercased().contains("pm") {
                    let intFromTime = Int(from_time) ?? 0
                    from_time = "\(intFromTime + 12)"
                }
                
                to_time = times_array[1].removeEnclosedWhieteSpace().components(separatedBy: " ").first ?? ""
                let to_timeAMPM = times_array[1].removeEnclosedWhieteSpace().components(separatedBy: " ").last ?? ""
                if to_timeAMPM.lowercased().contains("pm") {
                    let intToTime = Int(to_time) ?? 0
                    to_time = "\(intToTime + 12)"
                }
            }
            let seconds = TimeZone.current.secondsFromGMT()
            let milliSeconds = seconds * 1000
            let strMilliSec = "\(milliSeconds)"
            
            deliveryPreference = ["isAnytime": false,
                                  "customTime": ["from": "\(preferredDate) \(from_time):00:00:000",
                                    "to": "\(preferredDate) \(to_time):00:00:000",
                                    "offset" : strMilliSec]] as [String : AnyObject]
        } else {
            deliveryPreference = ["isAnytime": true] as [String : AnyObject]
        }
        
        return deliveryPreference
    }
    
}
