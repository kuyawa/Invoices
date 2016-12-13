//
//  Migrations.swift
//  Invoices
//
//  Created by Mac Mini on 11/10/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

class Migrations {
    
    func createDatabase() {
        Logger.log("Creating database...")
        runJob("DataSchema")
    }
    
    // Fallthrough migrations up to date
    func migrate(from version: Int) {
        Logger.log("Migrating database...")
        //if version <= 1 { migration01() }
        //if version <= 2 { migration02() }
        //if version <= 3 { migration03() }
    }

    
    /*
        Create Sequences table
        Add record with values("invoices", 1, 1)
     */
    func migration01() {
        runJob("Migration01")
        // Extra massage here
    }
    
    func migration02() {
        runJob("Migration02")
    }
    
    func migration03() {
        //
    }
    
    func runJob(_ name: String) {
        let DS = DataServer()
        DS.connect()
        defer {
            DS.disconnect()
        }
        
        if let path = Bundle.main.path(forResource: name, ofType: "sql") {
            do {
                let schema = try String(contentsOfFile: path)
                let commands = schema.components(separatedBy: "--")
                
                for sql in commands {
                    let ok = DS.execute(sql)
                    if ok < 0 {
                        Logger.logFail("Error migrating database ", name)
                        return
                    }
                }
                Logger.log("Database migration successful ", name)
            } catch {
                Logger.logFail("Error migrating database ", name)
                Logger.logFail(error)
                return
            }
        } else {
            Logger.logFail("Error accessing migration file ", name)
            return
        }
        
        return
    }
    
}
