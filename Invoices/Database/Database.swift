//
//  Database.swift
//  Invoices
//
//  Created by Mac Mini on 10/29/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

struct Schema {
    struct Invoices {
        static let tableName = "Invoices"
        static let tableKey  = "invoiceId"
    }
    
    struct InvoiceLines {
        static let tableName = "InvoiceLines"
        static let tableKey  = "lineId"
    }
    
    struct Customers {
        static let tableName = "Customers"
        static let tableKey  = "customerId"
    }
}


class Database {
    
    public var context : DataServer
    
    // Connection to SQLite automatically created and disposed
    init() {
        self.context = DataServer()
        self.context.connect()
    }
    
    // Use context already created and connected
    init(use context: DataServer) {
        self.context = context
    }
    
    func getSequence(_ name: String) -> Int {
        let next = context.getSequence(name)
        return next
    }
    
    func getTables() {
        //
    }

    func getFields(table: String) {
        //
    }
    
}

// End
