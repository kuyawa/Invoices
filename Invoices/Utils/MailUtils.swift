//
//  MailUtils.swift
//  Invoices
//
//  Created by Mac Mini on 11/28/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation
import Cocoa


class MailComposer {
    var recipients  = [String]()
    var carbonCopy  = [String]()
    var blankCopy   = [String]()
    var subject     = "<no subject>"
    var content     = "<no content>"
    var attachments = [URL]()
    var sendAsHtml  = false

    func send() {
        guard let mail = NSSharingService(named: NSSharingServiceNameComposeEmail) else {
            Logger.logWarn("Mail service not available")
            AlertOK("Mail service not available").show()
            return
        }
        
        var items = [Any]()
        
        if sendAsHtml {
            // FIXME: NOT WORKING
            let options = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
            let data = content.data(using: .utf8)!
            let html = NSAttributedString(html: data, options: options, documentAttributes: nil)
            items.append(html)
        } else {
            items.append(content)
        }
        
        mail.recipients = recipients
        mail.subject    = subject

        if attachments.count > 0 {
            for url in attachments {
                items.append(url)
            }
        }

        mail.perform(withItems: items)
    }
}
