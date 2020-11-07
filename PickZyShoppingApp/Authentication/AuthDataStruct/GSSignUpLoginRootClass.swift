/* 
Copyright (c) 2018 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation

//struct GSLoginRootClass: Codable {
//    let success: Bool?
//    let message: String?
//    let data: GSLoginDataClass?
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        success = values.decodeSafely(.success)
//        message = values.decodeSafely(.message)
//        data = values.decodeSafely(.data)
//    }
//}
//
//struct GSLoginDataClass: Codable {
//    let user: GSLoginUser?
//    let token: String?
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        user = values.decodeSafely(.user)
//        token = values.decodeSafely(.token)
//    }
//
//    init(user: GSLoginUser?, token:String?) {
//        self.user = user
//        self.token = token
//    }
//}
//
//struct GSLoginUser: Codable {
//    let firstName, lastName: String?
//    var image:String?
//    let mobile: GSLoginMobile?
//    let email: GSLoginEmail?
//    let _id: String?
//
//    enum CodingKeys: String, CodingKey {
//        case firstName = "first_name"
//        case lastName = "last_name"
//        case mobile
//        case email
//        case _id = "_id"
//        case image
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        firstName = values.decodeSafely(.firstName)
//        lastName = values.decodeSafely(.lastName)
//        image = values.decodeSafely(.image)
//        mobile = values.decodeSafely(.mobile)
//        email = values.decodeSafely(.email)
//        _id = values.decodeSafely(._id)
//    }
//
//    init(firstName: String?, lastName:String?, image: String?, mobile:GSLoginMobile?, email: GSLoginEmail?, _id: String?) {
//
//        self.firstName = firstName
//        self.lastName = lastName
//        self.image = image
//        self.mobile = mobile
//        self.email = email
//        self._id = _id
//    }
//}
//
//struct GSLoginEmail: Codable {
//    let id: String?
//    let isVerified: Bool?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case isVerified = "is_verified"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        id = values.decodeSafely(.id)
//        isVerified = values.decodeSafely(.isVerified)
//    }
//}
//
//struct GSLoginMobile: Codable {
//    let dialingCode : Int?
//    let number: Int64?
//
//    enum CodingKeys: String, CodingKey {
//        case dialingCode = "dialing_code"
//        case number
//    }
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        dialingCode = values.decodeSafely(.dialingCode)
//        number = values.decodeSafely(.number)
//    }
//}


struct GSLoginRootClass: Codable {
    let success: Bool?
    let message: String?
    let data: GSLoginData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        success = values.decodeSafely(.success)
        message = values.decodeSafely(.message)
        data = values.decodeSafely(.data)
    }
}

struct GSLoginData: Codable {
    let userProfile: GSLoginDataUserProfile?
    let authToken: GSLoginDataAuthToken?
    
    enum CodingKeys: String, CodingKey {
        case userProfile = "user_profile"
        case authToken = "auth_token"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        userProfile = values.decodeSafely(.userProfile)
        authToken = values.decodeSafely(.authToken)
    }
    
    init(userProfile: GSLoginDataUserProfile?, authToken:GSLoginDataAuthToken?) {
        self.userProfile = userProfile
        self.authToken = authToken
    }
}

struct GSLoginDataAuthToken: Codable {
    let access, refresh: GSLoginDataAuthTokenAccess?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        access = values.decodeSafely(.access)
        refresh = values.decodeSafely(.refresh)
    }
}

struct GSLoginDataAuthTokenAccess: Codable {
    let schema, token: String?
    let exp: Int64?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        schema = values.decodeSafely(.schema)
        token = values.decodeSafely(.token)
        exp = values.decodeSafely(.exp)
    }
}

struct GSLoginDataUserProfile: Codable {
    let id, firstName, lastName: String?
    let email: GSLoginDataUserProfileEmail?
    let mobile: GSLoginDataUserProfileMobile?
    let image:String?
    let referralCode: String?
    let referralLink: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email, mobile
        case image
        case referralCode = "referral_code"
        case referralLink = "referral_link"
    }
    
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
    
            firstName = values.decodeSafely(.firstName)
            lastName = values.decodeSafely(.lastName)
            image = values.decodeSafely(.image)
            mobile = values.decodeSafely(.mobile)
            email = values.decodeSafely(.email)
            id = values.decodeSafely(.id)
            referralCode = values.decodeSafely(.referralCode)
            referralLink = values.decodeSafely(.referralLink)
        }
    
        init(firstName: String?, lastName:String?, image: String?, mobile:GSLoginDataUserProfileMobile?, email: GSLoginDataUserProfileEmail?, id: String?, referralCode: String?, referralLink: String?) {
    
            self.firstName = firstName
            self.lastName = lastName
            self.image = image
            self.mobile = mobile
            self.email = email
            self.id = id
            self.referralCode = referralCode
            self.referralLink = referralLink
        }
}

struct GSLoginDataUserProfileEmail: Codable {
    let id: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        id = values.decodeSafely(.id)
    }
}

struct GSLoginDataUserProfileMobile: Codable {
    let dialingCode, number: Int?
    
    enum CodingKeys: String, CodingKey {
        case dialingCode = "dialing_code"
        case number
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        dialingCode = values.decodeSafely(.dialingCode)
        number = values.decodeSafely(.number)
    }
}

// MARK: - Otp Model

struct GSOtpModel: Codable {
    let success: Bool?
    let message: String?
    let data: GSOtpData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        success = values.decodeSafely(.success)
        message = values.decodeSafely(.message)
        data = values.decodeSafely(.data)
    }
}

struct GSOtpData: Codable {
    let exp: Int64?
    let otp: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
     
        exp = values.decodeSafely(.exp)
        otp = values.decodeSafely(.otp)
    }
}
