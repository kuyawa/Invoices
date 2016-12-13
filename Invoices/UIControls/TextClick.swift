//
//  ClickableLabel.swift
//  Invoices
//
//  Created by Mac Mini on 11/12/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

/*
    Subclass TextField to allow MouseClick
    Use Interface Builder for the same result
    labelNewInvoice.target = self
    labelNewInvoice.action = #selector(onNewInvoice(_:))
*/
 
class TextClick : NSTextField {

    //var isHovering = false
    //var prevColor = NSColor.black
    
   
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    /*
    override func resetCursorRects() {
        self.addCursorRect(self.bounds, cursor: .pointingHand())
    }
    */
    override func mouseDown(with event: NSEvent) {
        self.sendAction(self.action, to: self.delegate)
    }
    /*
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        Swift.print("Moved")
    }
 
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        Swift.print("Entered")
        if !isHovering {
            Swift.print("Hovered")
            self.wantsLayer = true
            prevColor = self.textColor!
            self.textColor = NSColor.blue
            isHovering = true
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        Swift.print("Exited")
        self.textColor = prevColor
        isHovering = false
    }
    */
}
