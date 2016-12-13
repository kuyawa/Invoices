//
//  Invoice.swift
//  Invoices
//
//  Created by Mac Mini on 11/11/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

// let invoice = Invoice(DB) // Instance in memmory
// invoice.insert() // sets its own ID to the newly created record
// invoice.update()
// invoice.delete()
// invoice.get(id)
// let invoices = Invoices.all()                             // list of InvoicesQuery
// let invoices = Invoices.byMonth(year: 2016, month: 11)    // list of InvoicesQuery

// WARNING: Changing this file implies a database migration

enum InvoiceStatus : Int {
    case new
    case sent
    case opened
    case pending
    case shipped
    case received
    case due
    case paid
    case archived  /* gray */
    case deleted   /* gray and strikethrough */
}

enum InvoiceTerms {
    case Net0
    case Net7
    case Net15
    case Net30
}

class Invoice : DataModel {
    dynamic var invoiceId     : Int    = 0       // autonum, primary, zero when new
    dynamic var invoiceNumber : String = ""      // sequence
    dynamic var issueDate     : Date   = Date()  // default now
    dynamic var month         : Int    = 0
    dynamic var year          : Int    = 0
    dynamic var terms         : String = "COD"
    dynamic var dueDate       : Date   = Date()
    dynamic var customerId    : Int    = 0
    dynamic var customerName  : String = ""
    dynamic var billToName    : String = ""
    dynamic var billToLine1   : String = ""
    dynamic var billToLine2   : String = ""
    dynamic var billToCity    : String = ""
    dynamic var billToState   : String = ""
    dynamic var billToZip     : String = ""
    dynamic var billToCountry : String = ""
    dynamic var billToPhone   : String = ""
    dynamic var billToEmail   : String = ""
    dynamic var shipToName    : String = ""
    dynamic var shipToLine1   : String = ""
    dynamic var shipToLine2   : String = ""
    dynamic var shipToCity    : String = ""
    dynamic var shipToState   : String = ""
    dynamic var shipToZip     : String = ""
    dynamic var shipToCountry : String = ""
    dynamic var shipToPhone   : String = ""
    dynamic var shipToEmail   : String = ""
    dynamic var taxRate       : Double = 0.0
    dynamic var totalSub      : Double = 0.0
    dynamic var totalTax      : Double = 0.0
    dynamic var totalShipping : Double = 0.0
    dynamic var totalNet      : Double = 0.0
    dynamic var notes         : String = ""
    dynamic var status        : Int    = 0
    dynamic var statusText    : String = "New"
    dynamic var items         : [InvoiceLine] = [InvoiceLine]()


    func setMonthYear() {
        month = issueDate.getMonth()
        year  = issueDate.getYear()
    }
    
    func setDueDate() {
        switch terms {
        case "COD"    : dueDate = issueDate; break
        case "NET-7" , "NET7"  : dueDate = issueDate.addDays( 7); break
        case "NET-15", "NET15" : dueDate = issueDate.addDays(15); break
        case "NET-30", "NET30" : dueDate = issueDate.addDays(30); break
        case "NET-60", "NET60" : dueDate = issueDate.addDays(60); break
        default       : dueDate = issueDate; break
        }
    }
    
    func isPastDue() -> Bool {
        //if status < InvoiceStatus.paid.rawValue && terms != "COD" && dueDate < Date() {
        if status == InvoiceStatus.due.rawValue {
            return true
        }
        
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
    
    func trimBlankItems() {
        var counter = 0
        while items.last != nil {
            if items.last!.descript.isEmpty {
                items.removeLast()
                counter += 1
            } else {
                break
            }
        }
    }
    
    func flushDeletedItems() {
        // Delete in reverse to avoid index unsync
        var index = self.items.count-1
        while index > 0 {
            if items[index].isDeleted {
                items.remove(at: index)
            }
            index -= 1
        }
    }

}

// Database access
extension Invoice {
    
    func save(in context: DataServer) {
        Logger.logData("Saving invoice id: ", invoiceId)
        trimBlankItems()
        if invoiceId < 1 { // New invoice, id not generated yet
            insert(in: context)
        } else {
            update(in: context)
        }
        flushDeletedItems()
    }
    
    func insert(in context: DataServer) {
        // Map data to sql and insert
        let exclude = ["invoiceId", "items"]
        let fields  = getFields(except: exclude)
        let params  = getBindingsArray(for: fields)
        let sql     = getSqlInsert(table: Schema.Invoices.tableName, fields: fields)
        let newId   = context.execute(sql, values: params)
        invoiceId   = newId
        
        // Save all line items
        for item in items {
            item.save(in: context, parentId: newId)
        }
        
        context.nextSequence("Invoices")  // Next invoice number only after saving new
    }
    
    func update(in context: DataServer) {
        let exclude = ["invoiceId", "items"]
        let fields  = getFields(except: exclude)
        let params  = getBindingsArray(for: fields)
        let sql     = getSqlUpdate(table: Schema.Invoices.tableName, fields: fields, params: params, key: Schema.Invoices.tableKey, id: invoiceId)
        let num     = context.execute(sql, values: params)
        
        if num < 1 {
            Logger.logFail("Error \(num) updating invoice \(invoiceId)")
            // TODO: Alert user
            return
        }
        
        // Save all line items
        for item in items {
            item.save(in: context, parentId: invoiceId)
        }
    }
    
    func updateStatus(in context: DataServer) {
        let sql     = "Update Invoices Set status = ?, statusText = ? Where invoiceId = ? Limit 1"
        let params  = [status, statusText, invoiceId] as [Any]
        let num     = context.execute(sql, values: params)
        
        if num < 1 {
            Logger.logFail("Error \(num) updating invoice \(invoiceId)")
        }
    }
    
    func delete(in context: DataServer) {
        let sql = getSqlDelete(table: Schema.Invoices.tableName, key: Schema.Invoices.tableKey)
        let num = context.execute(sql, values: [invoiceId])
        
        if num < 1 {
            Logger.logFail("Error \(num) deleting invoice \(invoiceId)")
            // TODO: Alert user
            return
        }
        
        // Delete line items
        let sql2 = "Delete From InvoiceLines Where invoiceId = ?"
        _ = context.execute(sql2, values: [invoiceId])
    }
    
    func get(_ id :Int, in context: DataServer) {
        let sql  = "Select * From Invoices where invoiceId = :invoiceId Limit 1"
        let rows = context.query(sql, params: [":invoiceId": id])
        if let row = rows?.first {
            fromDictionary(row)
            getItems(in: context)
        } else {
            Logger.logWarn("Invoice id \(id) not found")
        }
    }
    
    func getPrevId(in context: DataServer) -> Int {
        let current = invoiceId
        if current < 1 {
            return 0
        }
        
        let sql = "Select invoiceId From Invoices Where invoiceId < :invoiceId Order by invoiceId Desc Limit 1"
        let rows = context.query(sql, params: [":invoiceId": current])
        if let row = rows?.first {
            let prevId = row["invoiceId"] as! Int
            if prevId > 0 { return prevId }
        }
        
        return 0
    }

    func getNextId(in context: DataServer) -> Int {
        let current = invoiceId
        if current < 1 {
            return 0
        }
        
        let sql = "Select invoiceId From Invoices Where invoiceId > :invoiceId Order by invoiceId Limit 1"
        let rows = context.query(sql, params: [":invoiceId": current])
        if let row = rows?.first {
            let nextId = row["invoiceId"] as! Int
            if nextId > 0 { return nextId }
        }
        
        return 0
    }
    
    func getPrev(in context: DataServer) {
        let current = invoiceId
        if current < 1 {
            getLast(in: context)
            return
        }
        
        let sql = "Select invoiceId From Invoices Where invoiceId < :invoiceId Order by invoiceId Desc Limit 1"
        let rows = context.query(sql, params: [":invoiceId": current])
        if let row = rows?.first {
            let prevId = row["invoiceId"] as! Int
            self.get(prevId, in: context)
        }
    }
    
    func getNext(in context: DataServer) {
        let current = invoiceId
        if current < 1 {
            getLast(in: context)
            return
        }
        
        let sql = "Select invoiceId From Invoices Where invoiceId > :invoiceId Order by invoiceId Limit 1"
        let rows = context.query(sql, params: [":invoiceId": current])
        if let row = rows?.first {
            let nextId = row["invoiceId"] as! Int
            self.get(nextId, in: context)
        }
    }
    
    func getLast(in context: DataServer) {
        print("Get last")
        // if action new or invoiceid > max, use max invoiceId in DB: goLast
        // Select invoiceId From Invoices Where invoiceId > ? Order by invoiceId Limit 1
    }
    
    func getItems(in context: DataServer) {
        let sql = "Select * From InvoiceLines Where invoiceId = :invoiceId Order by lineNumber"
        
        let rows = context.query(sql, params: [":invoiceId": invoiceId])
        
        for item in rows! {
            let row = InvoiceLine()
            row.fromDictionary(item)
            items.append(row)
        }
    }
   
}


// Dictionary conversion
extension Invoice {
    func fromDictionary(_ fields :Parameters) {
        // TODO: auto convert [String:Any] to Fields
        invoiceId     = AnyUtils.anyToInt(   fields["invoiceId"])
        invoiceNumber = AnyUtils.anyToString(fields["invoiceNumber"])
        issueDate     = AnyUtils.anyToDate(  fields["issueDate"])
        month         = AnyUtils.anyToInt(   fields["month"])
        year          = AnyUtils.anyToInt(   fields["year"])
        terms         = AnyUtils.anyToString(fields["terms"])
        dueDate       = AnyUtils.anyToDate(  fields["dueDate"])
        customerId    = AnyUtils.anyToInt(   fields["customerId"])
        customerName  = AnyUtils.anyToString(fields["customerName"])
        billToName    = AnyUtils.anyToString(fields["billToName"])
        billToLine1   = AnyUtils.anyToString(fields["billToLine1"])
        billToLine2   = AnyUtils.anyToString(fields["billToLine2"])
        billToCity    = AnyUtils.anyToString(fields["billToCity"])
        billToState   = AnyUtils.anyToString(fields["billToState"])
        billToZip     = AnyUtils.anyToString(fields["billToZip"])
        billToCountry = AnyUtils.anyToString(fields["billToCountry"])
        billToPhone   = AnyUtils.anyToString(fields["billToPhone"])
        billToEmail   = AnyUtils.anyToString(fields["billToEmail"])
        shipToName    = AnyUtils.anyToString(fields["shipToName"])
        shipToLine1   = AnyUtils.anyToString(fields["shipToLine1"])
        shipToLine2   = AnyUtils.anyToString(fields["shipToLine2"])
        shipToCity    = AnyUtils.anyToString(fields["shipToCity"])
        shipToState   = AnyUtils.anyToString(fields["shipToState"])
        shipToZip     = AnyUtils.anyToString(fields["shipToZip"])
        shipToCountry = AnyUtils.anyToString(fields["shipToCountry"])
        shipToPhone   = AnyUtils.anyToString(fields["shipToPhone"])
        shipToEmail   = AnyUtils.anyToString(fields["shipToEmail"])
        taxRate       = AnyUtils.anyToDouble(fields["taxRate"])
        totalSub      = AnyUtils.anyToDouble(fields["totalSub"])
        totalTax      = AnyUtils.anyToDouble(fields["totalTax"])
        totalShipping = AnyUtils.anyToDouble(fields["totalShipping"])
        totalNet      = AnyUtils.anyToDouble(fields["totalNet"])
        notes         = AnyUtils.anyToString(fields["notes"])
        status        = AnyUtils.anyToInt(   fields["status"])
        statusText    = AnyUtils.anyToString(fields["statusText"])
    }
    
    func dataToPrint() -> NSMutableDictionary {
        let data = self.toMutableDictionary()
        var settings = Settings()
        settings.load()
        
        // Header
        data["companyName"]  = settings.company.name
        data["companyLine1"] = settings.company.address
        data["companyLine2"] = settings.company.phones
        data["companyLine3"] = settings.company.contact
        data["companyLine4"] = settings.company.website
        
        data["issueDate"]    = self.issueDate.toString(format: "dd MMM yyyy")
        data["dueDate"]      = self.dueDate.toString(format: "dd MMM yyyy")
        data["billToLine3"]  = "\(self.billToCity) \(self.billToState) \(self.billToZip)"
        data["shipToLine3"]  = "\(self.shipToCity) \(self.shipToState) \(self.shipToZip)"
        
        // Totals
        data["subtotal"]     = self.totalSub.toMoney()
        data["totalTaxes"]   = self.totalTax.toMoney()
        data["totalInvoice"] = self.totalNet.toMoney()
        
        // Footer
        data["salute"]       = settings.invoice.salute
        data["fineprint"]    = settings.invoice.fineprint

        // Items
        var lines = [NSMutableDictionary]()
        for item in self.items {
            let line = item.toMutableDictionary()
            line["quantity"]  = item.quantity.blankIfZero()
            line["descript"]  = item.descript
            line["unitPrice"] = item.unitPrice.toMoney(blankIfZero: true)
            line["unitOfMeasure"] = item.unitOfMeasure
            line["total"] = item.total.toMoney(blankIfZero: true)
            lines.append(line)
        }
        
        data["items"] = lines
        
        return data
        
        // Sample data
        
        /*
         let data : [String:Any] = [
         "companyName"   : "Apple Computer Corp",
         "companyLine1"  : "One Infinite Loop",
         "companyLine2"  : "Cupertino CA 95210",
         "companyLine3"  : "Phone: 1-800-APPLE",
         "companyLine4"  : "Visit us at http://apple.com",
         
         "invoiceNumber" : "012345",
         "issueDate"     : "11 NOV 2016",
         "terms"         : "COD",
         "dueDate"       : "11 NOV 2016",
         
         "billToName"    : "Taylor Swift",
         "billToLine1"   : "One huge Mansion",
         "billToLine2"   : "Second floor",
         "billToLine3"   : "Beverly Hills CA 95210",
         "billToPhone"   : "1-555-SWIFT",
         "billToEmail"   : "taylor@swift.org",
         
         "shipToName"    : "Same",
         
         "items":[
            ["quantity":1, "descript":"iPhone 7S", "unitOfMeasure": "ea", "unitPrice": "$1,234.50", "total": "$1,234.50"],
            ["quantity":1, "descript":"iMac 27"  , "unitOfMeasure": "ea", "unitPrice": "$2,540.00", "total": "$2,540.00"]
         ],
         
         "notes"         : "Priority mail. Next day delivery.",
         
         "subtotal"      : "$3,814.50",
         "taxRate"       :     "10.00",
         "totalTaxes"    :   "$381.45",
         "totalInvoice"  : "$4,195.95",
         
         "salute"        : "Thanks for shopping with us",
         "fineprint"     : "For claims and returns contact customer service"
         ]
         */

    }
}


