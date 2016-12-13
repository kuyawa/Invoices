//
//  ViewController.swift
//  Invoices
//
//  Created by Mac Mini on 10/29/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let app = NSApp.delegate as! AppDelegate

    // Available to all views from Help menu
    @IBAction func showLog(_ sender: Any?) {
        let act = LogView(nibName: "LogView", bundle: nil)
        app.show(act!)
    }
    
    // Available to all views from Help menu
    func showHelp(_ sender: Any?) {
        let act = HelpView(nibName: "HelpView", bundle: nil)
        app.show(act!, with: ["Action":"Help.Index"])
    }
    
    // Main view
    override func viewDidAppear() {
        let act = MainView(nibName: "MainView", bundle: nil)
        app.show(act!)
    }
    
}


// End
