//
//  DataJobs.swift
//  Invoices
//
//  Created by Mac Mini on 11/23/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

class DataJobs : DataQuery {

    func checkInvoicesPastdue() {
        let sql  = "Update Invoices set status = 7 where duedate > issuedate and status < 7 and terms <> 'COD'"
        let recs = context.execute(sql)
        Logger.logInfo("Invoices past due: ", recs)
    }
    
    func purgeLogFiles() {
        // Keep only last seven days
        let path  = FileUtils.getConfigFolder()
        let files = FileUtils.listFiles(folder: path, pattern: "Log.*.txt")
        let today = Date()
        let last7 = today.addDays(-7).toString(format: "yyyyMMdd")
        
        for name in files {
            let date = name.matchFirst("(\\d{8})")
            if date < last7 {
                let path = FileUtils.getConfigPath(name)
                FileUtils.deleteFile(path)
            }
        }
        
        Logger.log("Log files purged")
    }
    
}
