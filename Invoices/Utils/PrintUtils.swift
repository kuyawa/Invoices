//
//  PrintUtils.swift
//  Invoices
//
//  Created by Mac Mini on 11/28/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation
import Quartz
import WebKit


// DEPRECATED: REMOVE
class PrintUtils : NSObject {
    
    static func preview() {
        // Preview html in webView
        print("Preview: Not ready")
    }
    
    static func previewPDF(file: URL) {
        // Preview pdf in webView
    }
    
    static func toPrinter() {
        // Send HTML to printer
        print("toPrinter: Not ready")
    }
    
    func toPDF(html: String, file: URL) {
        // Save HTML to PDF
        //let pageWidth : CGFloat = 595.2
        //let pageHeight: CGFloat = 841.8
        //let page = CGRect(x: 0.0, y: 0.0, width: pageWidth, height: pageHeight)
        // TODO: continue tomorrow. appcoda.com/pdf-generation-ios
        
        // test1
        //let options = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        //let pdfData = html.data(using: .utf8)!
        //print("---- PDF data:")
        //dump(pdfData)
        
        //do {
            //let content = NSAttributedString(html: pdfData, options: options, documentAttributes: nil)
            //let content = try? NSAttributedString(data: pdfData, options: options, documentAttributes: nil)
            //print("---- PDF content:")
            //dump(content)
            //let range   = NSRange(location: 0, length: (content?.length)!)
            //guard content != nil else { return }
            //let result: Data?  = try content?.data(from: range, documentAttributes: [:])
            //guard result != nil else { return }
            //dump(result)
            //let pdfDoc  = PDFDocument(data: result!)
            
            // test2
            //let pdfDoc  = PDFDocument(data: pdfData)
            //if pdfDoc != nil { pdfDoc?.write(to: file) }
            //let page = PDFPage()
            // page?
            
            // test3
        /*
            let htmlx = "Hello <b>World!</b> thanks bye"
            let root = URL.init(string: ".")
            let size = NSRect.init(x: 0, y: 0, width: 612, height: 792)
            let webView = WebView(frame: size)
            webView.frameLoadDelegate = self
            webView.mainFrame.loadHTMLString(htmlx, baseURL: root)
            //delay(1)
        */
        //} catch {
        //    print(error)
        //}
        //let pdfDoc  = PDFDocument(data: pdfData)
        //pdfDoc?.write(to: file)

        
        /*
         let pasteboard = NSPasteboard.init()
         webView.writePDF(inside: page, to: pasteboard)
         */
    }
    
    
}

