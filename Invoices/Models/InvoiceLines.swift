//
//  InvoiceLines.swift
//  Invoices
//
//  Created by Mac Mini on 11/2/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation



//---- QUERY

class InvoiceLines : DataQuery {
    
    // This query should never be called. Makes no sense
    func all() -> [InvoiceLine] {
        var results = [InvoiceLine]()
        
        let sql = "Select * From InvoiceLines"
        
        let rows = context.query(sql)
        for item in rows! {
            let line = InvoiceLine()
            line.fromDictionary(item)
            results.append(line)
        }
        
        return results
    }
    
    func byInvoice(id: Int) -> [InvoiceLine] {
        var results = [InvoiceLine]()
        let sql = "Select * From InvoiceLines Where invoiceId = :invoiceId Order by lineNumber"
        
        let rows = context.query(sql, params: [":invoiceId":id])
        for item in rows! {
            let line = InvoiceLine()
            line.fromDictionary(item)
            results.append(line)
        }
        
        return results
    }
}


// END
