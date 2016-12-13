//
//  PrintView.swift
//  Invoices
//
//  Created by Mac Mini on 11/17/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import WebKit
import Stencil

class PrintView: NSViewController {

    let app = NSApp.delegate as! AppDelegate

    @IBOutlet weak var webView: WebView!
    
    @IBAction func onBack(_ sender: NSButton) {
        app.goBack()
    }
    
    @IBAction func onPrint(_ sender: NSButton) {
        printHtml()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func notify(_ message: Parameters?) {
        guard let message = message else { return }
        let action   = message["Action"]  as! String
        let content  = message["Content"] as! String
        let relative = FileUtils.getTemplatesFolder()
        //let data   = message["Data"]   as! [String:Any]
        switch action {
        case "Print.Invoice" : preview(content, url: relative);  break
        default: break
        }
    }
    
    func preview(_ content: String, url: URL) {
        webView.mainFrame.loadHTMLString(content, baseURL: url)
    }
    
    func previewPDF(_ file: URL) {
        let data = FileManager.default.contents(atPath: file.path)
        webView.mainFrame.load(data, mimeType: "application/pdf", textEncodingName: "UTF-8", baseURL: nil)
    }
    
    func printHtml() {
        webView.print(self)
    }
    
}
