//
//  PdfUtils.swift
//  Invoices
//
//  Created by Mac Mini on 11/29/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation
import Quartz
import WebKit


class PDFMagic : NSObject {
    
    var fileName      = URL(string: "Test.pdf")
    var printInfo     = NSPrintInfo()
    var relativePath  = URL(string: ".")
    var openWhenReady = false
    var removeBlanks  = false

    func save(_ html: String) {
        // TODO: if items > 15 frame is not enough, prints only one page
        let frame   = NSRect(x: 0, y: 0, width: 500, height: 610)
        let webView = WebView(frame: frame)
        webView.frameLoadDelegate = self
        webView.mainFrame.loadHTMLString(html, baseURL: relativePath) // wait for delegate
    }

    // TODO: callback when pdf is ready
    // func save(_ html: String, callback: () -> NSData)

    func removeBlankPages() {
        if let pdf = PDFDocument(url: fileName!) {
            // While last page is blank remove
            var lastIndex = pdf.pageCount-1
            while lastIndex > 0 {
                if let lastPage = pdf.page(at: lastIndex) {
                    if lastPage.numberOfCharacters < 10 {
                        pdf.removePage(at: lastIndex)
                        print("Page removed at #", lastIndex)
                        lastIndex = pdf.pageCount-1
                    } else {
                        break
                    }
                } else {
                    break
                }
            }

            pdf.write(to: fileName!)
        }
        
    }

}


extension PDFMagic : WebFrameLoadDelegate {
    
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        guard sender != nil else { return }
        
        let options : [String:Any] = [NSPrintJobDisposition: NSPrintSaveJob, NSPrintJobSavingURL: self.fileName!]
        self.printInfo = NSPrintInfo(dictionary: options)  // assign to instance for later use in callback

        let job = NSPrintOperation(view: sender, printInfo: self.printInfo)
        job.showsPrintPanel    = false
        job.showsProgressPanel = false
        job.run()

        if removeBlanks {
            removeBlankPages()
        }
        
        if openWhenReady {
            NSWorkspace.shared().open(fileName!)
        }
    }
    
}


// End
