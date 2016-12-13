//
//  DateUtils.swift
//  Invoices
//
//  Created by Mac Mini on 11/1/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

class DateUtils {
    static func fromString(_ text: String) -> Date {
        // No format? use default
        return fromString(text, format: "yyyy-MM-dd HH:mm:ss")
    }
    
    static func fromString(_ text: String, format: String) -> Date {
        var date = Date(timeIntervalSince1970: 0)
        if !text.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            date = formatter.date(from: text)!
        }
        return date
    }
    
    static func trimTime(_ date :Date) -> String {
        let text = date.toString()
        return trimTime(text)
    }
    
    static func trimTime(_ date :Any) -> String {
        let text = fromString(date as! String).toString()
        return trimTime(text)
    }
    
    static func trimTime(_ date :String) -> String {
        let parts = date.components(separatedBy: " ")
        return parts.first!
    }

    static func getMonthName(_ month :Int) -> String {
        guard month > 0 && month < 13 else { return "error" }
        let index = month - 1   // 0 to 11
        let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        return months[index]
    }
    
}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let text = formatter.string(from: self)
        return text
    }
    
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let text = formatter.string(from: self)
        return text
    }
    
    func addDays(_ numDays: Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var days = DateComponents()
        days.day = numDays
        let date = calendar?.date(byAdding: days, to: self)
        
        return date!
    }
    
    func getYear() -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let year = calendar?.component(.year, from: self)
        return year!
    }
    
    func getMonth() -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let month = calendar?.component(.month, from: self)
        return month!
    }
    
    func getDay() -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let day = calendar?.component(.day, from: self)
        return day!
    }
    /*
    func getDayName() -> String {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let day = calendar?.component(.weekday, from: self)
        return day!
    }
    */
    func getWeekday() -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let day = calendar?.component(.weekdayOrdinal, from: self)
        return day!
    }
    
    func getHour() -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let hour = calendar?.component(.hour, from: self)
        return hour!
    }
    
    func getMinutes() -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let minutes = calendar?.component(.minute, from: self)
        return minutes!
    }
    
    func getSeconds() -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let seconds = calendar?.component(.second, from: self)
        return seconds!
    }
    
    func getMillis() -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let millis = calendar?.component(.nanosecond, from: self)
        return millis!
    }
    
    
}

