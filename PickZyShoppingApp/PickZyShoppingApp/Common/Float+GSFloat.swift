//
//  Float+PRFloat.swift
//  PR Cards
//
//  Created by Ratheesh Mac Mini on 10/05/18.
//  Copyright © 2018 PR Networks. All rights reserved.
//

import Foundation

extension Float
{
    var cleanValue: String {
        
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
