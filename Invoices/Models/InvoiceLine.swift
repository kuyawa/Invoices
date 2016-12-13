//
//  InvoiceLine.swift
//  Invoices
//
//  Created by Mac Mini on 11/11/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

class InvoiceLine : DataModel {
    dynamic var lineId        : Int    = 0         // required, autonum, primary
    dynamic var invoiceId     : Int    = 0         // required, index
    dynamic var lineNumber    : Int    = 0
    dynamic var quantity      : Int    = 0
    dynamic var descript      : String = ""
    dynamic var annotation    : String = ""        // extended description
    dynamic var unitOfMeasure : String = ""
    dynamic var unitPrice     : Double = 0.0
    dynamic var amount        : Double = 0.0
    dynamic var taxable       : Bool   = false
    dynamic var taxRate       : Double = 0.0
    dynamic var taxAmount     : Double = 0.0
    dynamic var total         : Double = 0.0
}

// Dictionary conversion
extension InvoiceLine {
    func fromDictionary(_ fields :Parameters) {
        lineId        = AnyUtils.anyToInt(   fields["lineId"])
        invoiceId     = AnyUtils.anyToInt(   fields["invoiceId"])
        lineNumber    = AnyUtils.anyToInt(   fields["lineNumber"])
        quantity      = AnyUtils.anyToInt(   fields["quantity"])
        descript      = AnyUtils.anyToString(fields["descript"])
        unitOfMeasure = AnyUtils.anyToString(fields["unitOfMeasure"])
        annotation    = AnyUtils.anyToString(fields["annotation"])
        unitPrice     = AnyUtils.anyToDouble(fields["unitPrice"])
        amount        = AnyUtils.anyToDouble(fields["amount"])
        taxable       = AnyUtils.anyToBool(  fields["taxable"])
        taxRate       = AnyUtils.anyToDouble(fields["taxRate"])
        taxAmount     = AnyUtils.anyToDouble(fields["taxAmount"])
        total         = AnyUtils.anyToDouble(fields["total"])
    }
}

// Database access
extension InvoiceLine {
    
    func save(in context: DataServer) {
        if self.lineId < 1 {
            self.insert(in: context)
        } else {
            self.update(in: context)
        }
    }
    
    func save(in context: DataServer, parentId: Int) {
        if self.lineId < 1 {
            self.invoiceId = parentId // assign parentId once parent has been inserted
            self.insert(in: context)
        } else {
            if self.isModified {
                self.update(in: context)
            } else if self.isDeleted {
                self.delete(in: context)
            }
        }
    }
    
    func insert(in context: DataServer) {
        if self.isDeleted { return }
        
        let exclude = ["lineId"]
        let fields  = self.getFields(except: exclude)
        let params  = self.getBindingsArray(for: fields)
        let sql     = self.getSqlInsert(table: Schema.InvoiceLines.tableName, fields: fields)
        let newId   = context.execute(sql, values: params)
        
        // Assign newId from database to self
        self.lineId = newId
        if newId < 1 {
            Logger.logFail("Error \(newId) inserting invoice line \(lineNumber) for invoice \(invoiceId)")
        }
    }
    
    func update(in context: DataServer) {
        let exclude = ["lineId"]
        let fields  = self.getFields(except: exclude)
        let params  = self.getBindingsArray(for: fields)
        let sql     = self.getSqlUpdate(table: Schema.InvoiceLines.tableName, fields: fields, params: params, key: Schema.InvoiceLines.tableKey, id: lineId)
        let num     = context.execute(sql, values: params)
        if num < 0 {
            Logger.logFail("Error \(num) updating invoice line \(lineNumber) for invoice \(invoiceId)")
        }
    }
    
    func delete(in context: DataServer) {
        let sql = "Delete from InvoiceLines where lineId = :lineId limit 1"
        let num = context.execute(sql, values: [lineId])
        if num < 1 {
            Logger.log("Error \(num) deleting invoice line \(lineNumber) for invoice \(invoiceId)")
        }
    }
    
    func get(id :Int, in context: DataServer) {
        let sql  = "Select * from InvoiceLines where lineId = :lineId limit 1"
        let rows = context.query(sql, params: [":lineId": lineId])
        if let row = rows?.first {
            self.fromDictionary(row)
        } else {
            Logger.logWarn("Line item \(id) not found")
        }
    }
    
}
