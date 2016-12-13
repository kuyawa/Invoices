//
//  MainView.swift
//  Invoices
//
//  Created by Mac Mini on 11/12/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

class MainView: NSViewController, NSTextDelegate {

    var app = NSApp.delegate as! AppDelegate
    
    @IBOutlet weak var sideArea: NSView!
    @IBOutlet weak var menuArea: NSView!
    
    @IBOutlet weak var labelNewInvoice   : NSTextField!
    @IBOutlet weak var labelListInvoices : NSTextField!
    @IBOutlet weak var labelCustomers    : NSTextField!
    @IBOutlet weak var labelOptions      : NSTextField!
    
    @IBAction func onNewInvoice(_ sender: AnyObject) {
        let act = InvoiceView(nibName: "InvoiceView", bundle: nil)
        app.show(act!, with: ["Action": "Invoice.New"])
    }
    
    @IBAction func onListInvoices(_ sender: AnyObject) {
        let act = InvoicesList(nibName: "InvoicesList", bundle: nil)
        app.show(act!)
    }
    
    @IBAction func onCustomers(_ sender: AnyObject) {
        let act = CustomersList(nibName: "CustomersList", bundle: nil)
        app.show(act!)
    }
    
    @IBAction func onOptions(_ sender: AnyObject) {
        let act = OptionsView(nibName: "OptionsView", bundle: nil)
        app.show(act!)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func initialize() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = Theme.colors.snow.cgColor
        
        self.sideArea.wantsLayer = true
        if let layer = self.sideArea.layer {
            layer.backgroundColor = Theme.colors.gray64.cgColor
            layer.borderColor = Theme.colors.lead.cgColor
            layer.borderWidth = 1.0
            layer.opacity = 0.1
        }
    }
    
}
