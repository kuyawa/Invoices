//
//  TemplateUtils.swift
//  Invoices
//
//  Created by Mac Mini on 12/10/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation


// Direct string replacement for simple master/detail templates
class Template {
    
    static func render(_ file: URL, with data: NSDictionary) -> String {
        let text = try? String.init(contentsOf: file)
        guard var html = text else { return "Template not found" }
        
        for (key,value) in data {
            let objType = type(of: value)
            if "\(objType)".contains("Dictionary") {
                // Loop over list of dictionaries like invoice items
                let iniTag = "{{\(key)}}"
                let endTag = "{{/\(key)}}"
                if !html.contains(iniTag) { continue }
                if !html.contains(endTag) { continue }
                let parts1 = html.components(separatedBy: iniTag)
                let parts2 = parts1.last?.components(separatedBy: endTag)
                let ini  = parts1.first  // save first part
                let loop = parts2?.first // loop this part
                let end  = parts2?.last  // save last part
                let list = value as! [NSMutableDictionary]
                var lines = ""
                
                for item in list {
                    var line = loop
                    for (itemKey,itemValue) in item {
                        let itemField = "{{\(itemKey)}}"
                        let itemText  = "\(itemValue)"
                        line = line?.replacingOccurrences(of: itemField, with: itemText)
                    }
                    lines.append(line!)
                }
                
                html = ini! + lines + end!
            } else {
                // Replace simple value
                let field = "{{\(key)}}"
                let text  = "\(value)"
                html = html.replacingOccurrences(of: field, with: text)
            }
        }
        
        return html
    }
    
}

// END
