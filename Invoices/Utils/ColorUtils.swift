//
//  ColorUtils.swift
//  Invoices
//
//  Created by Mac Mini on 11/4/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation


extension NSColor {
   
    // Use: NSColor(0xffffffff)
    convenience init(hex: Int) {
        var opacity : CGFloat = 1.0
        if hex > 0xffffff {
            opacity = CGFloat((hex >> 24) & 0xff) / 255
        }
        let parts = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255,
            A: opacity
        )
        //print(parts)
        self.init(red: parts.R, green: parts.G, blue: parts.B, alpha: parts.A)
    }
    
     // Use: NSColor(RGB:(128,255,255))
    convenience init(RGB: (Int, Int, Int)) {
        self.init(
            red  : CGFloat(RGB.0)/255,
            green: CGFloat(RGB.1)/255,
            blue : CGFloat(RGB.2)/255,
            alpha: 1.0
        )
    }

}
