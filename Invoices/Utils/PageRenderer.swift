//
//  PageRenderer.swift
//  Invoices
//
//  Created by Mac Mini on 11/29/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation


class PageRenderer {
    
    func saveAsPdf(window: NSWindow) {
        let pdfPanel = NSPDFPanel()
        let pdfInfo  = NSPDFInfo()
        let options : [String: Any]? = nil
        pdfInfo.attributes.addEntries(from: options!)
        pdfPanel.beginSheet(with: pdfInfo, modalFor: window, completionHandler: onPdfReady)
    }
    
    func onPdfReady(_ result: Int) {
        print("PDF Result: ", result)
    }
}
