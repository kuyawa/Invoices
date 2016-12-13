//
//  Alerts.swift
//  Invoices
//
//  Created by Mac Mini on 11/23/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation


/* 
  Use:
    AlertOK("Everything is OK").show()
    AlertOK(title:"Warning", info:"Something went wrong").show()
*/
class AlertOK {
    var title :String = "Warning"
    var info  :String = "Something went wrong"
    
    init(_ info: String){
        self.title = "Alert"
        self.info  = info
    }
    
    init(title: String, info: String){
        self.title = title
        self.info  = info
    }
    
    func show() {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = info
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}


/*
  Use:
    DialogYesNo("Everything is OK?").choice()
    DialogYesNo(title:"Warning", info:"Something went wrong").show()
*/
class DialogYesNo {
    var title :String = "Choice"
    var info  :String = "Would you like to proceed?"
    
    init(_ info: String){
        self.title = "Choice"
        self.info  = info
    }
    
    init(title: String, info: String){
        self.title = title
        self.info  = info
    }
    
    func choice() -> Bool{
        var ok = false
        let alert  = NSAlert()
        alert.messageText = title
        alert.informativeText = info
        alert.addButton(withTitle: "NO")
        alert.addButton(withTitle: "YES")
        ok = (alert.runModal() == NSAlertSecondButtonReturn )
        return ok
    }
}

