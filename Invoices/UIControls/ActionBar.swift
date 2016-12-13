//
//  ActionBar.swift
//  Invoices
//
//  Created by Mac Mini on 11/4/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation

class ActionBar : NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        setBackground()
    }
    
    func setBackground(){
        self.wantsLayer = true
        self.layer?.backgroundColor = Theme.colors.mercury.cgColor
    }

    func validate() {
        // implement in view to enable/disable buttons
    }
}
