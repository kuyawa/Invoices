//
//  AnyUtils.swift
//  Invoices
//
//  Created by Mac Mini on 11/2/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

class AnyUtils {
    static func anyToString(_ obj :Any) -> String {
        let value :String = obj as! String
        return value
    }
    
    static func anyToNSString(_ obj :Any) -> NSString {
        let value :NSString = obj as! NSString
        return value
    }
    
    static func anyToInt(_ obj :Any) -> Int {
        let value :Int = obj as! Int
        return value
    }
    
    static func anyToDouble(_ obj :Any) -> Double {
        let value :Double = obj as! Double
        return value
    }
    
    // Receives only dates in 'yyyy-mm-dd hh:mm:ss' format
    static func anyToDate(_ obj :Any) -> Date {
        var date = Date()
        let text :String = obj as! String
        if !text.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            date = formatter.date(from: text)!
        }
        return date
    }

    // Only values of "1" will be accepted as true
    static func anyToBool(_ obj :Any) -> Bool {
        let text :String = String(describing: obj)
        if !text.isEmpty && text == "1" {
            return true
        }
        return false
    }
}
