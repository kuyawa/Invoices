//
//  StatusBar.swift
//  Invoices
//
//  Created by Mac Mini on 10/29/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation
import Cocoa


class StatusBar :NSView {
    
    enum StatusType {
        case info, data, warn, error
    }

    var statusText :NSTextField?

    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.wantsLayer = true
        setBackground()
        setBorder()
    }

    func setTextControl(text: NSTextField?){
        statusText = text
    }
    
    func show(_ text: String) {
        show(text: text, type: .info) // Default
    }

    func show(text: String, type:StatusType) {
        statusText?.stringValue = text
        setStatusColor(for: type)
    }

    func setBackground(){
        self.layer?.backgroundColor = Theme.colors.mercury.cgColor
    }
    
    func setBorder() {
        self.layer?.borderWidth = 1
        self.layer?.borderColor = Theme.colors.silver.cgColor
    }
    
    func setStatusColor(for type: StatusType){
        //let CrayonLead = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) //x252525
        switch type {
        case .info : // white on black
            statusText?.textColor = NSColor.darkGray
            //statusBar.backgroundColor = CrayonLead
            break
        case .data : // green on black
            statusText?.textColor = NSColor.green
            //statusBar.backgroundColor = CrayonLead
            break
        case .warn : // yellow on black
            statusText?.textColor = NSColor.yellow
            //statusBar.backgroundColor = CrayonLead
            break
        case .error: // white on red
            //statusText.textColor = NSColor.white
            //statusBar.backgroundColor = NSColor.red
            statusText?.textColor = NSColor.red
            //statusBar.backgroundColor = CrayonLead
            break
        }
    }
}
