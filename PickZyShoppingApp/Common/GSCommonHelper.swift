//
//  GSCommonHelper.swift
//  Shopor
//
//  Created by Ratheesh on 08/01/19.
//  Copyright © 2019 PickZy Software Pvt Ltd. All rights reserved.
//

import Foundation
import MKToolTip
import Photos
import AVFoundation

class GSCommonHelper {

    // MARK: -  Converting the date time format to required format
    
    class func getDateTimeInTheSimpleFormat(dateStr:String?, inputFormat:String, reqFormat:String) -> String {
        
        guard let unwrappedString = dateStr else { return "NA" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        let date = dateFormatter.date(from: unwrappedString) ?? Date()
        
        let anotherDateFormatter = DateFormatter()
        anotherDateFormatter.dateFormat = reqFormat
        
        return anotherDateFormatter.string(from: date)
    }
    
    // MARK: - Date Differences
    
    class func getTheDifferentiatedString(from:Date, toDate:Date) -> String {
        
        let calenderComponents = Calendar.current.dateComponents([.year, .month, .hour, .minute], from: from, to: toDate)
        
        let years = calenderComponents.year ?? 0
        let months = calenderComponents.month ?? 0
        let days = calenderComponents.day ?? 0
        let hours = calenderComponents.hour ?? 0
        let minutes = calenderComponents.minute ?? 0
        
        var remainingTimeString = ""
        
        if years > 0 {
            if years == 1 {
                remainingTimeString += "\(years) year "
            } else {
                remainingTimeString += "\(years) years "
            }
        }
        if months > 0 {
            if months == 1 {
                remainingTimeString += "\(months) month "
            } else {
                remainingTimeString += "\(months) months "
            }
        }
        if days > 0 {
            if days == 1 {
                remainingTimeString += "\(days) day "
            } else {
                remainingTimeString += "\(days) days "
            }
        }
        if hours > 0 {
                remainingTimeString += "\(hours)h "
        }
        if minutes > 0 {
                remainingTimeString += "\(minutes)m "
        }
        return remainingTimeString.removeEnclosedWhieteSpace()
    }
    
    // MARK: - Convert to string
    
    class func getStringFrom(anyValue:Any?) -> String {
        
        if let theValue = anyValue as? String {
            return theValue
        } else if let theValue = anyValue as? Int {
            return "\(theValue)"
        }else if let intValue = anyValue as? Int64 {
            return "\(intValue)"
        } else if let theValue = anyValue as? Double {
            return "\(theValue)"
        } else if let theValue = anyValue as? Float {
            return "\(theValue)"
        } else if let theValue = anyValue as? NSInteger {
            return "\(theValue)"
        }
        return ""
    }
    
    // MARK: - Cropping image in required size
    
    class func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef = contextImage.cgImage!.cropping(to: rect)
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    class func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    class func checkForUsagePermission(resourceType:UIImagePickerControllerSourceType, viewController:UIViewController) -> Bool {
        
        if resourceType == .camera {
            
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.denied || AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.restricted {
                CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.noPermissionToLoadCamera, viewController: viewController)
                return false
            }
            
        } else {
            if PHPhotoLibrary.authorizationStatus() == .denied || PHPhotoLibrary.authorizationStatus() == .restricted {
                CustomAlert.showAlert(title: GSString.AppName, message: GSConstant.noPermissionToLoadPhotos, viewController: viewController)
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Track Order and Purchase History
    
    class func checkForEscalationStatus(escalatedQty: Int, escalationStatus: Int,verifyStatus:Int) -> String {
        
        switch escalationStatus {
            
        case TrackOrderConstants.EscalationStatus.EscalatedByCustomer:
            
            if verifyStatus == TrackOrderConstants.VerifyStatus.replacement {
                return "Replacement requested for \(escalatedQty) product(s)"
            } else {
                return "Undelivered requested for \(escalatedQty) product(s)"
            }
            
        case TrackOrderConstants.EscalationStatus.EscalatedByShop:
            
            if verifyStatus == TrackOrderConstants.VerifyStatus.replacement {
                return "Replacement request escalated by store for \(escalatedQty) product(s)"
            } else {
                return "Undelivered request escalated by store for \(escalatedQty) product(s)"
            }
            
        case TrackOrderConstants.EscalationStatus.AcceptedByCustomer:
            
            if verifyStatus == TrackOrderConstants.VerifyStatus.replacement {
                return "Replacement request resolved for \(escalatedQty) product(s)"
            } else {
                return "Undelivered request resolved for \(escalatedQty) product(s)"
            }
            
        case TrackOrderConstants.EscalationStatus.AcceptedByShop:
            
            if verifyStatus == TrackOrderConstants.VerifyStatus.replacement {
                return "Replacement request accepted for \(escalatedQty) product(s)"
            } else {
                return "Undelivered request accepted for \(escalatedQty) product(s)"
            }
            
        case TrackOrderConstants.EscalationStatus.RefundedRequested:
            
            if verifyStatus == TrackOrderConstants.VerifyStatus.replacement {
                return "Refund requested for \(escalatedQty) product(s)"
            } else {
                return "Refund requested for \(escalatedQty) product(s)"
            }
            
        case TrackOrderConstants.EscalationStatus.RefundedInitiated:
            
            if verifyStatus == TrackOrderConstants.VerifyStatus.replacement {
                return "Refund initiated for \(escalatedQty) product(s)"
            } else {
                return "Refund initiated for \(escalatedQty) product(s)"
            }
            
        case TrackOrderConstants.EscalationStatus.EscalationClosed:
            
            if verifyStatus == TrackOrderConstants.VerifyStatus.replacement {
                return "Escalation closed for \(escalatedQty) product(s)"
            } else {
                return "Escalation closed for \(escalatedQty) product(s)"
            }
            
        default:
            
            if verifyStatus == TrackOrderConstants.VerifyStatus.replacement {
                return "Replacement request for \(escalatedQty) product(s)"
            } else {
                return "Undelivered request for \(escalatedQty) product(s)"
            }
        }
    }
    
    // MARK: - Store User Details After Login
    
    class func storeUserDetailsAfterLoginAndPush(responseModel: GSLoginRootClass, isFromSignup: Bool, from viewController: UIViewController) {
        
        let accessToken = responseModel.data?.authToken?.access?.token ?? ""
        let accessTokenPrefix = responseModel.data?.authToken?.access?.schema ?? ""
        
        let refreshToken = responseModel.data?.authToken?.refresh?.token ?? ""
        let refreshTokenPrefix = responseModel.data?.authToken?.refresh?.schema ?? ""
        
        SharedPersistence.storeAccessToken(accessToken: accessToken, prefix: accessTokenPrefix)
        SharedPersistence.storeRefreshToken(refreshToken: refreshToken, prefix: refreshTokenPrefix)
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.user.profile_image, value: responseModel.data?.userProfile?.image ?? "")
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.user.referralCode, value: responseModel.data?.userProfile?.referralCode ?? "")
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.user.referralLink, value: responseModel.data?.userProfile?.referralLink ?? "")
        
        if let encodedLoginUserData = try? JSONEncoder().encode(responseModel.data) {
            SharedPersistence.storeUserDefaults(key: UserDefaultKeys.user.user_details, value: encodedLoginUserData)
        }
        
        // Storing false for not to create problems when a user sign up or login from guest login
        SharedPersistence.storeUserDefaults(key: UserDefaultKeys.isGuestUserLogin, value: false)
        
        if let shopsVC = UIStoryboard(name: GSString.storyboard.CommonSB, bundle: nil).instantiateViewController(withIdentifier: GSString.Push.GSShopsViewController) as? GSShopsViewController {
            
            shopsVC.isFromLoginResponse = true
            shopsVC.isFromSignUpResponse = isFromSignup
            viewController.navigationController?.setViewControllers([shopsVC], animated: true)
        }
    }
    
    class func ratingExperienceDictionary() -> [Int:String] {
        
        return [1: "What disappointed you?",
                2: "What disappointed you?",
                3: "What disappointed you?",
                4: "Where improvement required?",
                5: "What satisfied you the most?"]
    }
    
    class func formattedPrice(price:Double) -> String {
        
        return (GSConstant.currency_symbol + " " + String(format: "%.2f", price))
    }
    
    class func formattedDouble(double:Double) -> String {
        
        return (String(format: "%.2f", double))
    }
}

extension KeyedDecodingContainer {
    
    public func decodeSafely<T: Decodable>(_ key: KeyedDecodingContainer.Key) -> T? {
        return self.decodeSafely(T.self, forKey: key)
    }
    
    public func decodeSafely<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) -> T? {
        let decoded = try? decode(T.self, forKey: key)
        return decoded
    }
    
    public func decodeSafelyIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) -> T? {
        
        return self.decodeSafelyIfPresent(T.self, forKey: key)
    }
    
    public func decodeSafelyIfPresent<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) -> T? {
        let decoded = try? decodeIfPresent(T.self, forKey: key)
        return decoded ?? nil
    }
}
