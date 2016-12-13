//
//  Customers.swift
//  Invoices
//
//  Created by Mac Mini on 11/2/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation


class Customer : DataModel {
    enum fields {
        case customerId, name, address1, address2, city, state, zip, country, phone, email
    }

    dynamic var customerId    : Int    = 0          // required, autonum, primary
    dynamic var name          : String = ""
    dynamic var address1      : String = ""
    dynamic var address2      : String = ""
    dynamic var city          : String = ""
    dynamic var state         : String = ""
    dynamic var zip           : String = ""
    dynamic var country       : String = ""
    dynamic var phone         : String = ""
    dynamic var email         : String = ""
    //dynamic var balance     : Double = 0.0        // PREPARE MIGRATION!
}


extension Customer {
    
    
    func fromDictionary(_ fields :Parameters) {
        customerId    = AnyUtils.anyToInt(   fields["customerId"])
        name          = AnyUtils.anyToString(fields["name"])
        address1      = AnyUtils.anyToString(fields["address1"])
        address2      = AnyUtils.anyToString(fields["address2"])
        city          = AnyUtils.anyToString(fields["city"])
        state         = AnyUtils.anyToString(fields["state"])
        zip           = AnyUtils.anyToString(fields["zip"])
        country       = AnyUtils.anyToString(fields["country"])
        phone         = AnyUtils.anyToString(fields["phone"])
        email         = AnyUtils.anyToString(fields["email"])
    }
    
    func save(in context: DataServer) {
        Logger.logData("Saving customer: ", customerId)
        if customerId < 1 { // New customer, id not generated yet
            insert(in: context)
        } else {
            update(in: context)
        }
    }
    
    func insert(in context: DataServer) {
        // Map data to sql and insert
        let exclude = ["customerId"]
        let fields = getFields(except: exclude)
        let params = getBindingsArray(for: fields)
        let sql    = getSqlInsert(table: Schema.Customers.tableName, fields: fields)
        let newId  = context.execute(sql, values: params)
        customerId = newId
        Logger.logData("New customerId:", customerId)
    }
    
    func update(in context: DataServer) {
        let exclude = ["customerId"]
        let fields  = getFields(except: exclude)
        let params  = getBindingsArray(for: fields)
        let sql     = getSqlUpdate(table: Schema.Customers.tableName, fields: fields, params: params, key: Schema.Customers.tableKey, id: customerId)
        let num     = context.execute(sql, values: params)
        
        if num < 1 {
            Logger.logFail("Error \(num) updating customer ", customerId)
        }
    }
    
    func delete(in context: DataServer) {
        let sql = getSqlDelete(table: Schema.Customers.tableName, key: Schema.Customers.tableKey)
        let num = context.execute(sql, values: [customerId])
        
        if num < 1 {
            Logger.logFail("Error \(num) deleting customer", customerId)
        }
    }
    
    func get(_ id :Int, from context: DataServer) {
        let sql  = "Select * from Customers where customerId = :customerId limit 1"
        let rows = context.query(sql, params: [":customerId":id])
        if let row = rows?.first {
            fromDictionary(row)
        }
    }
}


// END
