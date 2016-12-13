//
//  DataQueries.swift
//  Invoices
//
//  Created by Mac Mini on 11/2/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation


/* USE:
 
 let listInvoices = InvoicesQuery(with: params).fetch()
 
*/


/*
class InvoicesAll : DataQuery {
    var results = [InvoicesQueryRow]()
    var sql = "Select invoiceId, invoiceNumber, issueDate, dueDate, terms, customerId, customerName, totalNet, status, statusText From Invoices Order by issueDate desc"

    func fetch() -> [InvoicesQueryRow] {
        let rows = context.query(sql)
        for item in rows! {
            let invoice = InvoicesQueryRow().fromDictionary(item)
            results.append(invoice)
        }
        return results
    }
}
*/

/*
class InvoicesByMonth : DataQuery {
    var results = [InvoicesQueryRow]()
    var sql = "Select invoiceId, invoiceNumber, issueDate, dueDate, terms, customerId, customerName, totalNet, status, statusText From Invoices Where year = :year And month = :month Oder by issueDate desc"
    
    func fecth(year: Int, month: Int) -> [InvoicesQueryRow] {
        var data = Parameters()
        data["year"]  = year
        data["month"] = month
    
        let rows = context.query(sql, with: data)
        for item in rows! {
            let invoice = InvoicesQueryRow().fromDictionary(item)
            results.append(invoice)
        }
        return results
    }
}
*/

