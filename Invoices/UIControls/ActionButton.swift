//
//  ActionButton.swift
//  Invoices
//
//  Created by Mac Mini on 11/4/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

class ActionButton: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        self.wantsLayer = true
        setBackground()
        setBorder()
    }
    
    func setBackground(){
        self.layer?.backgroundColor = Theme.colors.silver.cgColor
    }
    
    func setBorder() {
        self.layer?.borderWidth = 1
        self.layer?.borderColor = Theme.colors.magnesium.cgColor
    }

}
