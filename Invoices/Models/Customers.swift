//
//  Customers.swift
//  Invoices
//
//  Created by Mac Mini on 11/15/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

class Customers : DataQuery {
    
    func all() -> [Customer] {
        var results = [Customer]()
        
        let sql = "Select * from Customers Order by name"
        
        let rows = self.context.query(sql)
        for item in rows! {
            let customer = Customer()
            customer.fromDictionary(item)
            results.append(customer)
        }
        
        return results
    }
    
    func byLetter(char: String) -> [Customer] {
        var results = [Customer]()
        let sql = "Select * From Customers Where name[0] = :letter Order by name"
        
        var data = Parameters()
        data[":letter"] = char
        
        let rows = self.context.query(sql, params: data)
        for item in rows! {
            let customer = Customer()
            customer.fromDictionary(item)
            results.append(customer)
        }
        
        return results
    }
    
}


// END
