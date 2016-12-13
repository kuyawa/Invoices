//
//  DataModel.swift
//  Invoices
//
//  Created by Mac Mini on 11/11/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation


class DataModel : NSObject {

    override var description : String { return self.toDictionary().description }
    
    var isNew      = false
    var isModified = false
    var isDeleted  = false
    
    func fromDictionary(_ dict: [String:Any], except: [String]? = [""]) {
        for (key,val) in dict {
            if (except?.index(of: key)) == nil {
                self.setValue(val, forKey: key)
            }
        }
    }
    
    func toDictionary(except: [String]? = [""]) -> Parameters {
        var data = [String:Any]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let key = child.label {
                if (except?.index(of: key)) == nil {
                    data[key] = child.value
                }
            }
        }
        
        return data
    }
    
    func toDictionary(fields: [String]) -> Parameters {
        let data = self.dictionaryWithValues(forKeys: fields)
        return data
    }
    
    func toDictionary() -> Parameters {
        let fields = self.getFields()
        let data   = self.dictionaryWithValues(forKeys: fields)
        return data
    }
    
    func toMutableDictionary() -> NSMutableDictionary {
        let fields = self.getFields()
        let data   = self.dictionaryWithValues(forKeys: fields)
        let dixy   = NSMutableDictionary(dictionary: data)
        return dixy
    }
    
    
    // Returns a list of fields from the table
    func getFields(except: [String]? = [""]) -> [String] {
        var keys = [String]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let key = child.label {
                if (except?.index(of: key)) == nil {
                    keys.append(key)
                }
            }
        }
        
        return keys
    }
    
    // Returns a list of :placeholders for sql binding
    func getPlaceholders(for fields: [String]) -> [String] {
        var keys = [String]()
        for field in fields {
            let key = ":"+field
            keys.append(key)
        }
        
        return keys
    }
    
    // OBSOLETE: Use mirror
    func getPlaceholders(except: [String]? = [""]) -> [String] {
        var keys = [String]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let key = child.label {
                if (except?.index(of: key)) == nil {
                    keys.append(":"+key)
                }
            }
        }
        
        return keys
    }
    
    // Dictionary of fields and placeholders
    // Placeholders are fields prepended with ":" for sql binding
    func getBindings(for fields: [String]) -> Parameters {
        var data = [String:Any]()
        for field in fields {
            let key = ":"+field
            data[key] = self.value(forKey: field)
        }
        
        return data
    }
    
    func getBindingsArray(for fields: [String]) -> [Any] {
        var data = [Any]()
        for field in fields {
            data.append(self.value(forKey: field)!)
        }
        
        return data
    }
    
    // OBSOLETE: Use mirror instead of object.keyValue
    func getBindingsFromMirror(for fields: [String]) -> Parameters {
        var data = [String:Any]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let label = child.label {
                if (fields.index(of: label)) != nil {
                    let key = ":"+label
                    data[key] = child.value
                }
            }
        }
        
        return data
    }
    
    
    // Insert into Invoices(field1, field2...) values(:field1, :field2...)
    func getSqlInsert(table: String, fields: [String]) -> String {
        let props  = getInsertFields(fields)
        let values = getInsertPositions(fields.count)
        let sql = "Insert into \(table)(\(props)) values(\(values));"
        return sql
    }
    
    // Update Invoices set field1 = :field1, field2 = :field2 where invoiceId = :invoiceId limit 1
    func getSqlUpdate(table: String, fields: [String], params: [Any], key: String, id: Int) -> String {
        let updates = getUpdateBindings(fields)
        //let updates = getUpdateValues(fields, params: params)
        let sql = "Update \(table) set \(updates) where \(key) = \(id);"
        return sql
    }
    
    // Delete from Invoices where invoiceId = :invoiceId limit 1
    func getSqlDelete(table: String, key: String) -> String {
        let sql = "Delete from \(table) where \(key) = ? limit 1;"
        //let sql = "Delete from \(table) where \(key) = :\(key) limit 1;"
        return sql
    }
    
    // Join all fields
    private func getInsertFields(_ fields: [String]) -> String {
        var places = [String]()
        for item in fields {
            places.append(item)
        }
        let inserts = places.joined(separator: ", ")
        
        return inserts
    }
    
    private func getInsertValues(_ fields: [String]) -> String {
        var places = [String]()
        for item in fields {
            places.append(":\(item)")
        }
        let inserts = places.joined(separator: ", ")
        
        return inserts
    }
    
    private func getInsertPositions(_ num: Int) -> String {
        var places = [String]()
        for _ in 0..<num {
            places.append("?")
        }
        let inserts = places.joined(separator: ", ")
        
        return inserts
    }
    
    // Not working, dunno why. Use direct values instead
    private func getUpdateBindings(_ fields: [String]) -> String {
        var places = [String]()
        for item in fields {
            places.append("\(item) = ?")
            //places.append("\(item) = :\(item)")
        }
        let updates = places.joined(separator: ", ")
        
        return updates
    }
    
    private func getUpdateValues(_ fields: [String], params: [String:Any]) -> String {
        var places = [String]()
        for item in fields {
            let key = ":"+item
            let val = "\(params[key]!)"
            if val.contains("'") {
                //let fixed = val.replacingOccurrences(of: "'", with: "\'")
                //places.append("\(item) = '\(fixed)'")
                places.append("\(item) = \"\(params[key]!)\"") // May break if apostrophe in string
            } else {
                places.append("\(item) = '\(params[key]!)'")
            }
        }
        let updates = places.joined(separator: ", ")
        
        return updates
    }
}

