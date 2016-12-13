//
//  Invoices.swift
//  Invoices
//
//  Created by Mac Mini on 11/2/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

class Invoices : DataQuery {
    
    func get(_ id: Int) -> InvoicesRow {
        var result = InvoicesRow()
        
        let sql = "Select invoiceId, invoiceNumber, issueDate, dueDate, terms, customerId, customerName, totalNet, status, statusText From Invoices Where invoiceId = :invoiceId"
        
        let rows = context.query(sql, params:[":invoiceId":id])
        for item in rows! {
            result = InvoicesRow().fromDictionary(item)
            break
        }
        
        return result
    }
    
    func all() -> [InvoicesRow] {
        var results = [InvoicesRow]()
        
        let sql = "Select invoiceId, invoiceNumber, issueDate, dueDate, terms, customerId, customerName, totalNet, status, statusText From Invoices Order by invoiceNumber desc"
        
        let rows = context.query(sql)
        for item in rows! {
            let invoice = InvoicesRow().fromDictionary(item)
            results.append(invoice)
        }
        
        return results
    }
    
    func byMonth(year: Int, month: Int) -> [InvoicesRow] {
        var results = [InvoicesRow]()
        let sql = "Select invoiceId, invoiceNumber, issueDate, dueDate, terms, customerId, customerName, totalNet, status, statusText From Invoices Where year = :year And month = :month Order by invoiceNumber desc"
        
        var data = Parameters()
        data[":year"]  = year
        data[":month"] = month
        
        let rows = context.query(sql, params: data)
        for item in rows! {
            let invoice = InvoicesRow().fromDictionary(item)
            results.append(invoice)
        }
        
        return results
    }

}

//---- Queries

class InvoicesRow : DataModel {
    var invoiceId     : Int    = 0
    var invoiceNumber : String = ""
    var issueDate     : Date   = Date()
    var dueDate       : Date   = Date()
    var terms         : String = ""
    var customerId    : Int    = 0
    var customerName  : String = ""
    var totalNet      : Double = 0.0
    var status        : Int    = 0
    var statusText    : String = ""
}

extension InvoicesRow {
    func fromDictionary(_ fields: Parameters) -> InvoicesRow {
        invoiceId     = AnyUtils.anyToInt(   fields["invoiceId"])
        invoiceNumber = AnyUtils.anyToString(fields["invoiceNumber"])
        issueDate     = AnyUtils.anyToDate(  fields["issueDate"])
        dueDate       = AnyUtils.anyToDate(  fields["dueDate"])
        terms         = AnyUtils.anyToString(fields["terms"])
        customerId    = AnyUtils.anyToInt(   fields["customerId"])
        customerName  = AnyUtils.anyToString(fields["customerName"])
        totalNet      = AnyUtils.anyToDouble(fields["totalNet"])
        status        = AnyUtils.anyToInt(   fields["status"])
        statusText    = AnyUtils.anyToString(fields["statusText"])

        return self
    }
    
    func isPastDue() -> Bool {
        //if status < InvoiceStatus.paid.rawValue && terms != "COD" && dueDate < Date() {
        if InvoiceStatus(rawValue: status) == .due { return true }
        return false
    }
    
    func isPaid() -> Bool {
        if InvoiceStatus(rawValue: status) == .paid { return true }
        return false
    }
    
    func getStatusText() -> String {
        var text = "New"
        let current = InvoiceStatus(rawValue: status)!
        
        switch current {
        case .new     : text = "New"
        case .sent    : text = "Sent"
        case .opened  : text = "Opened"
        case .pending : text = "Pending"
        case .shipped : text = "Shipped"
        case .received: text = "Received"
        case .due     : text = "Past due"
        case .paid    : text = "Paid"
        case .archived: text = "Archived"
        case .deleted : text = "Deleted"
        }
        
        // Extra massage
        if terms != "COD" && dueDate < Date() {
            text = "Past due"
        }
        
        return text
    }

}


// END
