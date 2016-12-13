//
//  LogUtils.swift
//  Invoices
//
//  Created by Mac Mini on 12/6/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

enum LogType : String {
    case Data="DATA", Fail="FAIL", Info="INFO", Text="TEXT", Warn="WARN"
}

/*
 Logger.logText("Testing logger")
 Logger.logInfo("Hello", "Taylor Swift")
 Logger.logData("Employee:", ["Name":"Megan", "Age":25, "Hired":Date()])
 Logger.logWarn("Printer not available")
 Logger.logFail("Error 123", "Database not available")
*/
 
class Logger {
    
    static var isDebugging = true
    static var logFile : URL {
        let today = Date().toString(format: "yyyyMMdd")
        let name  = "Log.\(today).txt"
        return FileUtils.getConfigPath(name)
    }
    
    static func log(_ args: Any...) {
        logWrite(.Info, args:args)
    }
    
    static func logData(_ args: Any...){
        logWrite(.Data, args:args)
    }
    
    static func logFail(_ args: Any...){
        logWrite(.Fail, args:args)
    }
    
    static func logInfo(_ args: Any...){
        logWrite(.Info, args:args)
    }
    
    static func logText(_ args: Any...){
        logWrite(.Text, args:args)
    }
    
    static func logWarn(_ args: Any...){
        logWrite(.Warn, args:args)
    }
    
    
    // ie. FAIL 2016.12.08 08:55.30 - Database not found
    private static func logWrite(_ kind:LogType, args: [Any]){
        let prefix  = kind.rawValue
        let now     = Date().toString(format: "HH:mm:ss")
        var text    = String()
        
        for item in args {
            text.append("\(item) ")
        }
        
        let info = "\(prefix) \(now) \(text)"

        if isDebugging {
            print(info)
        }
        
        FileUtils.appendToFile(logFile, text: info)
    }
}
