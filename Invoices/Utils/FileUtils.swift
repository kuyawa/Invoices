//
//  FileUtils.swift
//  Invoices
//
//  Created by Mac Mini on 11/23/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

// app.folders.database
struct AppFolders {
    var company     : URL { return FileUtils.getCompanyFolder() }
    var application : URL { return FileUtils.getAppFolder() }
    var archives    : URL { return FileUtils.getArchivesFolder() }
    var config      : URL { return FileUtils.getConfigFolder() }
    var database    : URL { return FileUtils.getDatabaseFolder() }
    var templates   : URL { return FileUtils.getTemplatesFolder() }
}

extension Bundle {
    func url(file: String) -> URL {
        let name = NSString(string: file).deletingPathExtension
        let ext  = NSString(string: file).pathExtension
        let url  = Bundle.main.url(forResource: name, withExtension: ext)!
        return url
    }
}

class FileUtils {
    static let companyFolderName   = "Armonia"
    static let appFolderName       = "Invoices"
    static let archivesFolderName  = "Archives"
    static let configFolderName    = "Config"
    static let databaseFolderName  = "Database"
    static let templatesFolderName = "Templates"
    
    static func getAppName() -> String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
    
    static func getCompanyFolder() -> URL {
        let filer = FileManager.default
        let docs  = filer.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url   = docs.appendingPathComponent(companyFolderName, isDirectory: true)
        return url
    }
    
    static func getAppFolder() -> URL {
        let filer = FileManager.default
        let docs  = filer.urls(for: .documentDirectory, in: .userDomainMask).first!
        let main  = docs.appendingPathComponent(companyFolderName, isDirectory: true)
        let url   = main.appendingPathComponent(getAppName(), isDirectory: true)
        return url
    }
    
    static func getArchivesFolder() -> URL {
        return getAppFolder().appendingPathComponent(archivesFolderName, isDirectory: true)
    }
    
    static func getConfigFolder() -> URL {
        return getAppFolder().appendingPathComponent(configFolderName, isDirectory: true)
    }
    
    static func getDatabaseFolder() -> URL {
        return getAppFolder().appendingPathComponent(databaseFolderName, isDirectory: true)
    }
    
    static func getTemplatesFolder() -> URL {
        return getAppFolder().appendingPathComponent(templatesFolderName, isDirectory: true)
    }
    
    static func verifyAppFolders() {
        let mainFolder   = getCompanyFolder()
        let appFolder    = getAppFolder()
        let appArchives  = getArchivesFolder()
        let appConfig    = getConfigFolder()
        let appDatabase  = getDatabaseFolder()
        let appTemplates = getTemplatesFolder()
        
        verifyFolder(mainFolder)       //Documents/Armonia/
        verifyFolder(appFolder)        //Documents/Armonia/Invoices
        verifyFolder(appArchives)      //Documents/Armonia/Invoices/Archives
        verifyFolder(appConfig)        //Documents/Armonia/Invoices/Config
        verifyFolder(appDatabase)      //Documents/Armonia/Invoices/Database
        verifyFolder(appTemplates)     //Documents/Armonia/Invoices/Templates
    }

    static func verifyInitialResources() {
        let schemaName     = "DataSchema.sql"
        let templateName   = "InvoiceDefault.html"
        
        let schemaSource   = Bundle.main.url(file: schemaName)
        let templateSource = Bundle.main.url(file: templateName)

        let schemaTarget   = getDatabaseFolder().appendingPathComponent(schemaName)
        let templateTarget = getTemplatesFolder().appendingPathComponent(templateName)

        if !fileExists(schemaTarget) {
            Logger.log("Saving DataSchema in ./Database")
            fileCopy(from: schemaSource, to: schemaTarget)
        }
        if !fileExists(templateTarget) {
            Logger.log("Saving Invoice Template in ./Templates")
            fileCopy(from: templateSource, to: templateTarget)
        }
    }
    
    static func fileExists(_ url: URL) -> Bool {
        if FileManager.default.fileExists(atPath: url.path) {
            return true
        }
        
        return false
    }
    
    static func fileCopy(from source: URL, to target: URL) {
        do {
            try FileManager.default.copyItem(at: source, to: target)
        } catch {
            Logger.logFail("Error copying file to", source)
            Logger.logFail(error)
        }
    }
    
    static func verifyFolder(_ url: URL) {
        let filer = FileManager.default
        let path  = url.path
        var isDir :ObjCBool = false
        
        do {
            if filer.fileExists(atPath: path, isDirectory: &isDir) {
                if isDir.boolValue {
                    //print("Folder exists in \(path)")
                    return
                } else {
                    print("Exists as file. Creating as folder")
                }
            } else {
                print("Folder does not exist. Creating new folder in ", path)
            }
            
            // Create new folder
            try filer.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            
        } catch let error as NSError {
            Logger.logFail("Error verifying folder: ", path)
            Logger.logFail(error)
        }
        
    }

    static func getArchivePath(_ name: String) -> URL {
        let folder = getArchivesFolder()
        let url    = folder.appendingPathComponent(name)
        return url
    }
    
    static func getConfigPath(_ name: String) -> URL {
        let folder = getConfigFolder()
        let url    = folder.appendingPathComponent(name)
        return url
    }
    
    static func getTemplatePath(_ name: String) -> URL {
        let folder = getTemplatesFolder()
        let url    = folder.appendingPathComponent(name).appendingPathExtension("html")
        return url
    }
    
    static func appendToFile(_ file: URL, text: String) {
        do {
            let data = text.appending("\n").data(using: .utf8)
            if FileUtils.fileExists(file) {
                let handle = try FileHandle(forWritingTo: file)
                defer {
                    handle.closeFile()
                }
                handle.seekToEndOfFile()
                handle.write(data!)
            } else {
                try data?.write(to: file, options: .atomic)
            }
        } catch {
            Logger.logFail("Error writing to file \(file)")
            Logger.logFail(error)
        }
    }
    
    static func listFiles(folder: URL, pattern: String? = "") -> [String] {
        verifyFolder(folder)

        var names = [String]()
        let props  = [URLResourceKey.localizedNameKey, URLResourceKey.creationDateKey]
        
        if let fileArray = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: props, options: .skipsHiddenFiles) {
            var results = [(String,Date)]()
            
            for url in fileArray {
                do {
                    var created = try url.resourceValues(forKeys: [URLResourceKey.creationDateKey])
                    let name = url.lastPathComponent
                    let pair = (name, created.creationDate!)
                    
                    if !(pattern?.isEmpty)! {
                        if !name.match(pattern!) { continue }
                    }
                    
                    results.append(pair)
                } catch {
                    Logger.logFail("Error reading folder \(folder)")
                    Logger.logFail(error)
                }
            }
            
            let ordered = results.sorted(by: { $0.0 < $1.0 }) // sort by name
            //let ordered = results.sorted(by: { $0.1 < $1.1 }) // sort descending creation dates
            names = ordered.map { $0.0 } // extract file names
            
        }
        
        return names
    }
    
    static func getFileInfo(_ file: URL) -> [FileAttributeKey: Any]? {
        do {
            let info = try FileManager.default.attributesOfItem(atPath: file.path)
            return info
        } catch {
            Logger.logFail("Error getting info for file \(file)")
            Logger.logFail(error)
        }
        
        return nil
    }
    
    static func deleteFile(_ path: URL) {
        do {
            if fileExists(path) {
                try FileManager.default.removeItem(at: path)
            }
        } catch {
            Logger.logFail("Error deleting file \(path)")
            Logger.logFail(error)
        }
    }
    

}


// End
