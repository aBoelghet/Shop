/* 
Copyright (c) 2018 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation

import Foundation
struct GSSignUpLoginRootClass : Codable {
    let success : Bool?
    let message : String?
    let data : GSLoginData?
    
    enum CodingKeys: String, CodingKey {
        
        case success = "success"
        case message = "message"
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent(GSLoginData.self, forKey: .data)
    }
    
}

struct GSLoginData : Codable {
    let user : GSLoginUser?
    let token : String?
    
    enum CodingKeys: String, CodingKey {
        
        case user = "user"
        case token = "token"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        user = try values.decodeIfPresent(GSLoginUser.self, forKey: .user)
        token = try values.decodeIfPresent(String.self, forKey: .token)
    }
    
}

struct GSLoginMobile : Codable {
    let dialing_code : Int?
    let number : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case dialing_code = "dialing_code"
        case number = "number"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dialing_code = try values.decodeIfPresent(Int.self, forKey: .dialing_code)
        number = try values.decodeIfPresent(Int.self, forKey: .number)
    }
    
}

struct GSLoginUser : Codable {
    let _id : String?
    let first_name : String?
    let last_name : String?
    let mobile : GSLoginMobile?
    let email_id : String?
    
    enum CodingKeys: String, CodingKey {
        
        case _id = "_id"
        case first_name = "first_name"
        case last_name = "last_name"
        case mobile = "mobile"
        case email_id = "email_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        first_name = try values.decodeIfPresent(String.self, forKey: .first_name)
        last_name = try values.decodeIfPresent(String.self, forKey: .last_name)
        mobile = try values.decodeIfPresent(GSLoginMobile.self, forKey: .mobile)
        email_id = try values.decodeIfPresent(String.self, forKey: .email_id)
    }
    
}
