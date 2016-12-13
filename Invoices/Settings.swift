//
//  Settings.swift
//  Invoices
//
//  Created by Mac Mini on 11/8/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation


// Load from Settings.info
// Update after user options changed


struct Settings {
    
    var system   = System()
    var options  = Options()
    var company  = Company()
    var invoice  = Invoice()
    
    struct System {
        var appVersion  = 1
        var dataVersion = 1
        var lastDayRun  = "2016-01-01"  // Saved separately in UserDefaults
    }
    
    struct Options {
        var country  = "US"
        var currency = "$"
    }
    
    struct Company {
        var name    = "Armonia Software Corp"
        var address = "123 Sunset Blvd - Miami FL 33166"
        var phones  = "Ph. 555-1234 - Fax 666-4321"
        var contact = "Email: sales@example.com"
        var website = "Visit us at http://example.com"
        
        var useImageHeader  = false
        var imageHeaderFile = ""
    }
    
    struct Invoice {
        var startNumber  = 1
        var nextNumber   = 1      // Select last invoiceNumber from database on init
        var taxRate      = 10.0
        var salute       = "We appreciate your business"
        var fineprint    = "For claims or returns contact our customer sales representative"
        var defaultTerms = "COD"
        var terms        = ["COD", "NET-7", "NET-15", "NET-30", "NET-60"]
        var template     = "InvoiceDefault"  // html file
    }
    
}

extension Settings {
    
    private func getFileName() -> String {
        let fileName = "Settings.info"
        return FileUtils.getConfigFolder().appendingPathComponent(fileName).path
    }

    mutating func load() {
        guard let dict = NSDictionary(contentsOfFile: getFileName()) else {
            self.save()     // Save defaults if not available
            Logger.log("Settings file created")
            return
        }
        self.fromDictionary(dict as! [String:Any])
        self.system.lastDayRun = getLastDayRun()
    }
    
    func save() {
        let dict = self.toDictionary()
        dict.write(toFile: getFileName(), atomically: false)
        Logger.log("Settings saved to file")
    }

    func toString() -> String {
        let dict = toDictionary()
        return dict.description
    }
    
    private func toDictionary(_ any: Any? = nil) -> NSDictionary {
        let obj = any ?? self
        let primitives = ["String", "Int", "Double", "Bool"]
        let mirror = Mirror(reflecting: obj)
        var objType = mirror.subjectType
        var dict = NSMutableDictionary()
        
        typealias Node = (String, Any)
        
        func parseValue(_ value: Any) -> Any {
            let valueType = String(describing: type(of: value))
            var node : Any = ""

            if primitives.contains(valueType) {
                switch valueType {
                case "String": node = value as! String; break
                case "Int"   : node = value as! Int; break
                case "Double": node = value as! Double; break
                case "Bool"  : if value as! Bool { node = true } else { node = false } ; break
                default      : node = value as! String; break
                }
            } else {
                // TODO: Improve looping by array type
                if valueType.hasPrefix("Array") {
                    node = value as! Array<String>
                } else { /* Class or Struct */
                    node = self.toDictionary(value)
                }
            }
            
            return node
        }
        
        for (key, val) in mirror.children {
            dict[key!] = parseValue(val)
        }
        
        return dict
        
    }
    
    mutating func fromDictionary(_ dict: [String:Any]) {
        // TODO: Research about reflection setting struct properties
        let _system  = dict["system" ] as! [String:Any]
        let _options = dict["options"] as! [String:Any]
        let _company = dict["company"] as! [String:Any]
        let _invoice = dict["invoice"] as! [String:Any]
        
        system.appVersion  = _system["appVersion" ] as! Int
        system.dataVersion = _system["dataVersion"] as! Int
        system.lastDayRun  = _system["lastDayRun"]  as! String

        options.country  = _options["country"  ] as! String
        options.currency = _options["currency" ] as! String
        
        company.name    = _company["name"   ] as! String
        company.address = _company["address"] as! String
        company.phones  = _company["phones" ] as! String
        company.contact = _company["contact"] as! String
        company.website = _company["website"] as! String
        
        company.useImageHeader  = _company["useImageHeader" ] as! Bool
        company.imageHeaderFile = _company["imageHeaderFile"] as! String
        
        invoice.startNumber  = _invoice["startNumber" ] as! Int
        invoice.startNumber  = _invoice["startNumber" ] as! Int
        invoice.taxRate      = _invoice["taxRate"     ] as! Double
        invoice.nextNumber   = _invoice["nextNumber"  ] as! Int
        invoice.salute       = _invoice["salute"      ] as! String
        invoice.fineprint    = _invoice["fineprint"   ] as! String
        invoice.defaultTerms = _invoice["defaultTerms"] as! String
        invoice.terms        = _invoice["terms"       ] as! [String]
    }
    
    //
    // LastDayRun will be saved individually as a data bit in UserDefaults not to alter settings everytime the app is run
    //
    
    func getLastDayRun() -> String {
        let defaults = UserDefaults.standard
        let value: String = defaults.string(forKey: "lastDayRun") ?? "2016-01-01"
        //let lastDay  = DateUtils.fromString(value!, format: "yyyy-MM-dd")
        //print("User default ",value)
        return value
    }

    func setLastDayRun(_ date: Date) {
        let value = DateUtils.trimTime(date)
        if value != self.system.lastDayRun {
            let defaults = UserDefaults.standard
            defaults.set(value, forKey: "lastDayRun")
            defaults.synchronize()
        }
    }
    
}

// END
