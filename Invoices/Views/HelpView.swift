//
//  HelpView.swift
//  Invoices
//
//  Created by Mac Mini on 11/17/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import WebKit

class HelpView: NSViewController {

    var app = NSApp.delegate as! AppDelegate

    @IBOutlet weak var webView: WebView!
    
    @IBAction func onBack(_ sender: NSButton) {
        app.goBack()
    }
    
    @IBAction func onHome(_ sender: NSButton) {
        showHtml("index")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func notify(_ message: Parameters?) {
        guard let message = message else {
            showHtml("index")
            return
        }
        
        let action = message["Action"] as! String
        switch action {
        case "Help.Index"       : showHtml("index"    )
        case "Help.InvoicesList": showHtml("invoices" )
        case "Help.InvoicesView": showHtml("invoice"  )
        case "Help.Customers"   : showHtml("customers")
        case "Help.Options"     : showHtml("options"  )
        default                 : showHtml("index"    )
        }
    }
    
    func showHtml(_ name: String) {
        let url = Bundle.main.url(forResource: name, withExtension: "html")
        let request = URLRequest(url: url!)
        webView.mainFrame.load(request)
    }
    
    func printHtml() {
        webView.print(self)
    }
    
}
