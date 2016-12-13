//
//  MoneyUtils.swift
//  Invoices
//
//  Created by Mac Mini on 11/1/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation


// double.toMoney
extension Double {
    func toMoney() -> String {
        let value = NSNumber(value: self) 
        let text  = NumberFormatter.localizedString(from: value, number: .currency)
        //let text = String(format:"%.2f", self)
        return text
    }
    func toMoney(blankIfZero : Bool) -> String {
        if self == 0.0 { return "" }
        return self.toMoney()
    }
}


class Money {
    var value :Double = 1.0
    
    var text : String {
        get {
            return String(format:"%.2f", value)
        }
        set {
            value = Double(newValue) ?? 1.0
        }
    }
    
    init(){
        self.value = 1.0  // Use 1.0 to avoid division by zero
    }
    
    init(_ value :Double){
        self.value = value
    }
    
    init(text :String){
        if text.isEmpty {
            self.text = "1.0"
        } else {
            self.text = text
        }
    }
}

class MoneyUtils {
    static func moneyToText(_ value :Double) -> String {
        return String(format:"%.2f", value)
    }
    
    static func anyToText(_ value :Any) -> String {
        return String(format:"%.2f", Double(value as! String) ?? 1.0)
    }
    
    static func anyToCurrency(_ text :Any) -> String {
        let number = (text as! String).toDouble()
        let value = NSNumber(value: number)
        let currency = NumberFormatter.localizedString(from: value, number: .currency)
        //let currency = String(format:"%.2f", value)
        return currency
    }

    static func currency(_ money :Double) -> String {
        let value = NSNumber(value: money)
        let currency = NumberFormatter.localizedString(from: value, number: .currency)
        return currency
    }
}

