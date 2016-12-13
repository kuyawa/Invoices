//
//  Theme.swift
//  Invoices
//
//  Created by Mac Mini on 11/11/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation

// Relies on ColorUtils extensions for RGB and HEX initializers

struct Theme {
    struct colors {
        static var snow      = NSColor(RGB:(255,255,255))
        static var mercury   = NSColor(RGB:(230,230,230))
        static var silver    = NSColor(RGB:(204,204,204))
        static var magnesium = NSColor(RGB:(180,180,180))
        static var tin       = NSColor(RGB:(128,128,128))  // #808080
        static var iron      = NSColor(RGB:( 76, 76, 76))  // #4c4c4c
        static var tungsten  = NSColor(RGB:( 51, 51, 51))  // #333333
        static var lead      = NSColor(RGB:( 25, 25, 25))
        static var black     = NSColor(RGB:(  0,  0,  0))

        static var gray192   = NSColor(RGB:(192,192,192))
        static var gray128   = NSColor(RGB:(128,128,128))
        static var gray64    = NSColor(RGB:( 64, 64, 64))

        static var clover    = NSColor(RGB:(  0,128,  0))
        static var moss      = NSColor(RGB:(  0,128, 64))
        
        static var mist      = NSColor(hex: 0xe2e8ef)
        static var warn      = NSColor(hex: 0xaa0000)
        
        static var due       = NSColor(hex: 0xaa0000) // red
        static var paid      = NSColor(hex: 0x0000aa) // blue

        static var coltanDark  = NSColor(hex: 0x79838f) // gray dark
        static var coltanLight = NSColor(hex: 0xe2e6eb) // gray light
        static var coltanText  = NSColor(hex: 0x6a6f75) // gray text
    }

    struct fonts {
        static var normal    = NSFont(name: "System"        , size: 12.0)
        static var helvetica = NSFont(name: "Helvetica Neue", size: 12.0)
        static var monaco    = NSFont(name: "Monaco"        , size: 12.0)
    }
}

