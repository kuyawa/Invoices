//
//  NotifyExtension.swift
//  Invoices
//
//  Created by Mac Mini on 11/5/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation

/* Use:
 
 let note = Message(name: "FindCustomer", data: ["customerId":123])
 app.show(CustomerView, with: note)
 app.show(CustomerView, with: Message(name: "FindCustomer", data: ["customerId":123]))
 
 let note = Message(name: "InvoiceCancelled", data: ["invoiceId":12345])
 app.goBack(with: note)
 
*/


protocol Notifiable {
    func notify(_ message: Parameters?)
}

extension NSViewController : Notifiable {
    func notify(_ message: Parameters?) {
        print("NSViewController notified")
    }
}



/*
public class Message {
    var name : String = ""
    var data = Parameters()
    
    init(){}
    
    init(name: String) {
        self.name = name
    }
    
    init(name: String, data: Parameters) {
        self.name = name
        self.data = data
    }
}
*/


// End
