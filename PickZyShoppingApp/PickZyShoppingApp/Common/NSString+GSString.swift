//
//  NSString+PRString.swift
//  PR Cards
//
//  Created by Ratheesh Mac Mini on 10/05/18.
//  Copyright © 2018 PR Networks. All rights reserved.
//

import Foundation

extension String{
    
    func stringWithEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    func numbersFromString() -> String{
        
        let result = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        return result
    }
    func lettersFromString() -> String{
        
        let result = self.trimmingCharacters(in: .whitespaces)
        return result
    }
    func specialCharacterFromString() -> String{
        
        let result = self.components(separatedBy: CharacterSet.punctuationCharacters.inverted).joined(separator: "")
        return result
    }
    func removeEnclosedWhieteSpace() -> String{
        
        let result = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return result
    }
    
    func attributedString(stringArray:[String], foregroundColorArray:[UIColor]) -> NSAttributedString {
        
        let combination = NSMutableAttributedString()
        
        if stringArray.count != foregroundColorArray.count { return NSAttributedString.init() }
        
        for index in 0..<stringArray.count {
            
            let stringAtIndex = stringArray[index]
            let colorAtIndex = foregroundColorArray[index]
            let attributedItem = NSAttributedString(string: stringAtIndex, attributes: [NSAttributedStringKey.foregroundColor: colorAtIndex])
            combination.append(attributedItem)
        }
        
        return combination
    }
    
    func getAttributedString(firstString:String, firstFont:UIFont, firstColor:UIColor, secondString:String, secondFont:UIFont, secondColor:UIColor) -> NSAttributedString {
        
        let yourAttributes = [NSAttributedStringKey.foregroundColor: firstColor, NSAttributedStringKey.font: firstFont]
        let yourOtherAttributes = [NSAttributedStringKey.foregroundColor: secondColor, NSAttributedStringKey.font: secondFont]
        
        let partOne = NSMutableAttributedString(string: firstString, attributes: yourAttributes)
        let partTwo = NSMutableAttributedString(string: secondString, attributes: yourOtherAttributes)
        
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
        
        return combination
    }
    
    //VAlidation For Password
    func isValidPassword() -> Bool {
        
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[.$@$!%*?&])[A-Za-z\\d$@$!%*?&.^)(_#]{6,30}"
        let passTest      = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        let alphabatResult   = passTest.evaluate(with: self)
        return alphabatResult
    }
    
    func isValidPhone() -> Bool {
        let phoneRegex = "[0-9]{10}"
        let phoneTesting = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTesting.evaluate(with: self)
    }
    
    func isValidPwd() -> Bool {
        let passwordRegex = "[A-Za-z0-9@$*_]{6,30}"
        let passTest      = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passTest.evaluate(with: self)
    }
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTesting = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTesting.evaluate(with: self)
    }
    func validZipCode()->Bool{
        let postalcodeRegex = "^[0-9]{6}(-[0-9]{4})?$"
        let pinPredicate = NSPredicate(format: "SELF MATCHES %@", postalcodeRegex)
        let bool = pinPredicate.evaluate(with: self) as Bool
        return bool
    }
    
    func isValidUPI()-> Bool {
        let emailRegex = "^([A-Za-z0-9.])+@[A-Za-z0-9]+$"
        let emailTesting = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTesting.evaluate(with: self)
    }
}
