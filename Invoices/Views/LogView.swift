//
//  LogView.swift
//  Invoices
//
//  Created by Mac Mini on 12/7/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

class LogView: NSViewController {

    let app = NSApp.delegate as! AppDelegate

    @IBOutlet var textView: NSTextView!
    
    @IBAction func goBack(_ sender: AnyObject) {
        app.goBack()
    }
    
    @IBAction func sendEmail(_ sender: AnyObject) {
        if let text = try? String(contentsOf: Logger.logFile) {
            let mail = MailComposer()
            mail.recipients = ["haxapp@gmail.com"]
            mail.subject    = "Invoices app log"
            mail.content    = text
            mail.send()
            return
        } else {
            AlertOK("Problems sending log file. Try again later").show()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLog()
    }
    
    func loadLog() {
        do {
            let text  = try String(contentsOf: Logger.logFile)
            let lines = text.components(separatedBy: .newlines)
            let fancy = NSMutableAttributedString()
            
            for line in lines.reversed() {
                let prefix = line.subtext(to: 4)
                fancy.append(prettify(for: prefix, text: line))
            }
            
            textView.textStorage?.append(fancy)
            textView.font = Theme.fonts.monaco
        } catch {
            print(error)
        }
        
    }
    
    func prettify(for prefix: String, text: String) -> NSAttributedString {
        let validPrefixes = ["DATA", "FAIL", "INFO", "TEXT", "WARN"]
        let text  = text.appending("\n")
        let fancy = NSMutableAttributedString()
        
        switch prefix {
        case "DATA" : fancy.append(text.colored(NSColor.blue  ))
        case "FAIL" : fancy.append(text.colored(NSColor.red   ))
        case "INFO" : fancy.append(text.colored(NSColor.black ))
        case "TEXT" : fancy.append(text.colored(NSColor.gray  ))
        case "WARN" : fancy.append(text.colored(NSColor.orange))
        default     : fancy.append(text.colored(NSColor.black ))
        }

        if text.characters.count > 12 && validPrefixes.contains(prefix) {
            let rangeForTime = NSRange(location: 5, length: 8)
            fancy.setAttributes([NSForegroundColorAttributeName: NSColor.lightGray], range: rangeForTime)
        }
        
        return fancy
    }
    
}
