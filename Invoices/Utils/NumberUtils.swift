//
//  NumberUtils.swift
//  Invoices
//
//  Created by Mac Mini on 11/21/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

extension Int {
    func plural(_ text: String) -> String {
        let word = text + (self == 1 ? "" : "s")
        return("\(self) \(word)")
    }
    
    // Inclusive
    func inRange(_ min: Int, _ max: Int) -> Bool {
        if self >= min && self <= max { return true }
        return false
    }
    
    // For use in templates
    func blankIfZero() -> String {
        if self == 0 { return "" }
        return "\(self)"
    }
}
