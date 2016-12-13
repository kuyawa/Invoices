//
//  OptionsView.swift
//  Invoices
//
//  Created by Mac Mini on 11/9/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

// Load settings, modify and save
//
class OptionsView: NSViewController {

    var app = NSApp.delegate as! AppDelegate
    var DB  = Database()

    
    @IBOutlet weak var companyName    : NSTextField!
    @IBOutlet weak var companyAddress : NSTextField!
    @IBOutlet weak var companyPhones  : NSTextField!
    @IBOutlet weak var companyContact : NSTextField!
    @IBOutlet weak var companyWebsite : NSTextField!
    
    @IBOutlet weak var paperBlank     : NSView!
    @IBOutlet weak var paperName      : NSTextField!
    @IBOutlet weak var paperAddress   : NSTextField!
    @IBOutlet weak var paperPhones    : NSTextField!
    @IBOutlet weak var paperContact   : NSTextField!
    @IBOutlet weak var paperWebsite   : NSTextField!
    @IBOutlet weak var paperSalute    : NSTextField!
    @IBOutlet weak var paperFineprint : NSTextField!
    
    @IBOutlet weak var invoiceNumber  : NSTextField!
    @IBOutlet weak var taxRate        : NSTextField!
    @IBOutlet weak var terms          : NSSegmentedControl!
    @IBOutlet weak var salute         : NSTextField!
    @IBOutlet weak var fineprint      : NSTextField!
    @IBOutlet weak var footerBlank    : NSView!
    
    @IBAction func onHelp(_ sender: AnyObject) {
        let act = HelpView(nibName: "HelpView", bundle: nil)
        app.show(act!, with: ["Action": "Help.Options"])
    }
    
    @IBAction func onSave(_ sender: NSButton) {
        saveOptions()
    }
    
    @IBAction func onCancel(_ sender: NSButton) {
        closeWindow()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paperBlank.wantsLayer = true
        paperBlank.layer?.backgroundColor = Theme.colors.snow.cgColor
        footerBlank.wantsLayer = true
        footerBlank.layer?.backgroundColor = Theme.colors.snow.cgColor
    }
    
    override func viewDidAppear() {
        initialize()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        let field = obj.object as! NSTextField
        let newValue = field.stringValue
        
        switch field.identifier! {
        case "companyLine": paperName.stringValue      = newValue; break
        case "addressLine": paperAddress.stringValue   = newValue; break
        case "phoneLine"  : paperPhones.stringValue    = newValue; break
        case "contactLine": paperContact.stringValue   = newValue; break
        case "websiteLine": paperWebsite.stringValue   = newValue; break
        case "salute"     : paperSalute.stringValue    = newValue; break
        case "fineprint"  : paperFineprint.stringValue = newValue; break
        default: /* */  break
        }
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        let field    = obj.object as! NSTextField
        if field.identifier == "invoiceNumber" {
            let newValue = Int(field.intValue)  // Int32 to Int
            let maxValue = DB.context.getSequence("Invoices")
            print("Max number: ", maxValue, newValue)
            if newValue < maxValue {
                AlertOK("Next invoice number \(newValue) can not be less than last issued number \(maxValue)").show()
                field.integerValue = maxValue // Set it back to max
            }
        }
    }
    
    func initialize() {
        // Header settings
        
        companyName.stringValue    = app.settings.company.name
        companyAddress.stringValue = app.settings.company.address
        companyPhones.stringValue  = app.settings.company.phones
        companyContact.stringValue = app.settings.company.contact
        companyWebsite.stringValue = app.settings.company.website

        paperName.stringValue      = app.settings.company.name
        paperAddress.stringValue   = app.settings.company.address
        paperPhones.stringValue    = app.settings.company.phones
        paperContact.stringValue   = app.settings.company.contact
        paperWebsite.stringValue   = app.settings.company.website
        paperSalute.stringValue    = app.settings.invoice.salute
        paperFineprint.stringValue = app.settings.invoice.fineprint
        
        // Invoice settings
        
        invoiceNumber.integerValue = app.settings.invoice.startNumber
        taxRate.doubleValue        = app.settings.invoice.taxRate
        salute.stringValue         = app.settings.invoice.salute
        fineprint.stringValue      = app.settings.invoice.fineprint
        selectTerms(for: app.settings.invoice.defaultTerms)
        
        let nextNumber = DB.context.getSequence("Invoices")
        invoiceNumber.integerValue = nextNumber
        
        companyName.becomeFirstResponder()
    }
    
    func saveOptions() {
        // Save invoice number sequence
        let nextNumber = Int(invoiceNumber.integerValue)
        if nextNumber > app.settings.invoice.startNumber {
            DB.context.setSequence("Invoices", next: nextNumber)
        }
        
        app.settings.company.name         = companyName.stringValue
        app.settings.company.address      = companyAddress.stringValue
        app.settings.company.phones       = companyPhones.stringValue
        app.settings.company.contact      = companyContact.stringValue
        app.settings.company.website      = companyWebsite.stringValue
        
        app.settings.invoice.startNumber  = invoiceNumber.integerValue
        app.settings.invoice.taxRate      = taxRate.doubleValue
        app.settings.invoice.defaultTerms = getTermsFromSelection()
        app.settings.invoice.salute       = salute.stringValue
        app.settings.invoice.fineprint    = fineprint.stringValue
        
        app.settings.save()

        
        closeWindow()
    }

    func closeWindow() {
        app.goBack()
    }
    
    func getTermsFromSelection() -> String {
        // Could use terms.label(forSegment: sel)!
        var val = "COD"
        let sel = terms.selectedSegment
        switch sel {
        case 0 : val = "COD"   ; break
        case 1 : val = "NET-7" ; break
        case 2 : val = "NET-15"; break
        case 3 : val = "NET-30"; break
        default: val = "COD"   ; break
        }

        return val
    }

    func selectTerms(for value: String) {
        var sel = 0
        switch value {
        case "COD"            : sel = 0; break
        case "NET-7" , "NET7" : sel = 1; break
        case "NET-15", "NET15": sel = 2; break
        case "NET-30", "NET30": sel = 3; break
        default               : sel = 0; break
        }
        terms.setSelected(true, forSegment: sel)
    }
}
