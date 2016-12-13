//
//  HeaderBar.swift
//  Invoices
//
//  Created by Mac Mini on 10/30/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation

class HeaderBar : NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        setBackground()
    }
    
    func setBackground(){
        self.wantsLayer = true
        self.layer?.backgroundColor = Theme.colors.gray128.cgColor
    }
    
   
}
