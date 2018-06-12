//
//  StringUtils.swift
//  Invoices
//
//  Created by Mac Mini on 11/2/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation

// string.toDouble
extension String {

    // To numbers
    
    func toDouble() -> Double {
        let locale = Locale.current
        let currencySymbol = locale.currencySymbol!
        var text = self.replacingOccurrences(of: currencySymbol, with: "")//"$"
//         var text = self.replacingOccurrences(of: "$", with: "")
        text = text.replacingOccurrences(of: ",", with: "")
        if let value = NumberFormatter().number(from: text)?.doubleValue {
            return value
        }
        return 0.0
    }
    
    func toInteger() -> Int {
        if let value = NumberFormatter().number(from: self)?.intValue {
            return value
        }
        return 0
    }
    
    // Attributed
    
    func strikethrough() -> NSAttributedString {
        let fancy = [NSStrikethroughStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let text  = NSAttributedString(string: self, attributes: fancy)
        return text
    }
    
    func colored(_ color: NSColor) -> NSMutableAttributedString {
        let fancy = [NSForegroundColorAttributeName: color]
        let text  = NSMutableAttributedString(string: self, attributes: fancy)
        return text
    }
    
    // Substring
    
    func subtext(from pos: Int) -> String {
        guard pos >= 0 else { return "" }
        if pos > self.characters.count { return  "" }
        let first = self.index(self.startIndex, offsetBy: pos)
        let text = self.substring(from: first)
        return text
    }
    
    func subtext(to pos: Int) -> String {
        var end = pos
        if pos > self.characters.count { end = self.characters.count }
        let last = self.index(self.startIndex, offsetBy: end)
        let text = self.substring(to: last)
        return text
    }

    func subtext(from ini: Int, to end: Int) -> String {
        guard ini >= 0 else { return "" }
        guard end >= 0 else { return "" }
        var fin = end
        if ini > self.characters.count { return  "" }
        if end > self.characters.count { fin = self.characters.count }
        let first = self.index(self.startIndex, offsetBy: ini)
        let last  = self.index(self.startIndex, offsetBy: fin)
        let range = first ..< last
        let text = self.substring(with: range)
        
        return text
    }
    
    // Regex
    
    func match(_ pattern: String) -> Bool {
        guard self.characters.count > 0 else { return false }
        if let first = self.range(of: pattern, options: .regularExpression) {
            let match = self.substring(with: first)
            return !match.isEmpty
        }

        return false
    }
    
    func matchFirst(_ pattern: String) -> String {
        guard self.characters.count > 0 else { return "" }
        if let first = self.range(of: pattern, options: .regularExpression) {
            let match = self.substring(with: first)
            return match
        }
        
        return ""
    }
    
    func matchAll(_ pattern: String) -> [String] {
        var matches = [String]()
        guard self.characters.count > 0 else { return matches }
        let all = NSRange(location: 0, length: self.characters.count)
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let results = regex.matches(in: self, options: [], range: all)
            
            for item in results {
                let first = item.rangeAt(1)
                let range = self.rangeIndex(first)
                let match = self.substring(with: range)
                
                matches.append(match)
            }
        } catch {
            print(error)
        }
        
        return matches
    }
    
    // Painful conversion from a Range to a Range<String.Index>
    func rangeIndex(_ range: NSRange) -> Range<String.Index> {
        let index1 = self.utf16.index(self.utf16.startIndex, offsetBy: range.location, limitedBy: self.utf16.endIndex)
        let index2 = self.utf16.index(index1!, offsetBy: range.length, limitedBy: self.utf16.endIndex)
        let bound1 = String.Index(index1!, within: self)!
        let bound2 = String.Index(index2!, within: self)!
        let result = Range<String.Index>(uncheckedBounds: (bound1, bound2))
        
        return result
    }
    


}
