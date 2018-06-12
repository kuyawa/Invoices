//
//  InvoiceView.swift
//  Invoices
//
//  Created by Mac Mini on 11/4/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

class InvoiceView: NSViewController {

    enum DocumentAction {
        case New
        case Edit
        case Delete
    }

    var app = NSApp.delegate as! AppDelegate
    var DB  = Database()
    var PDF = PDFMagic()

    var viewAction : DocumentAction = DocumentAction.New
    var isInvoiceSaved = false
    var isNewCustomer  = true     // Used for auto adding new info to Customers table
    var customer       = Customer()
    var invoice        = Invoice()
    //var listItems    = [InvoiceLine]()
    
    
    // View controls
    @IBOutlet weak var actionBar      : ActionBar!
    @IBOutlet weak var headerBar      : HeaderBar!
    @IBOutlet weak var statusBar      : StatusBar!
    @IBOutlet weak var statusText     : NSTextField!
    @IBOutlet weak var scrollView     : NSScrollView!
    @IBOutlet weak var buttonSaveLabel: NSTextField!
    
    @IBOutlet weak var barPrev        : NSButton!
    @IBOutlet weak var barNext        : NSButton!
    @IBOutlet weak var barNumber      : NSTextField!
    @IBOutlet weak var barInfo        : NSTextField!

    // Invoice fields
    @IBOutlet weak var stampMail      : NSButton!
    @IBOutlet weak var stampPaid      : NSButton!
    
    @IBOutlet weak var companyName    : NSTextField!
    @IBOutlet weak var companyLine1   : NSTextField!
    @IBOutlet weak var companyLine2   : NSTextField!
    @IBOutlet weak var companyLine3   : NSTextField!
    @IBOutlet weak var companyLine4   : NSTextField!
    
    @IBOutlet weak var invoiceNumber  : NSTextField!
    @IBOutlet weak var issueDate      : NSTextField!
    @IBOutlet weak var dueDate        : NSTextField!
    @IBOutlet weak var terms          : NSTextField!
    @IBOutlet weak var totalAmount    : NSTextField!
    
    @IBOutlet weak var billToName     : NSTextField!
    @IBOutlet weak var billToAddress1 : NSTextField!
    @IBOutlet weak var billToAddress2 : NSTextField!
    @IBOutlet weak var billToCity     : NSTextField!
    @IBOutlet weak var billToState    : NSTextField!
    @IBOutlet weak var billToZip      : NSTextField!
    @IBOutlet weak var billToPhone    : NSTextField!
    @IBOutlet weak var billToEmail    : NSTextField!
    
    @IBOutlet weak var shipToName     : NSTextField!
    @IBOutlet weak var shipToAddress1 : NSTextField!
    @IBOutlet weak var shipToAddress2 : NSTextField!
    @IBOutlet weak var shipToCity     : NSTextField!
    @IBOutlet weak var shipToState    : NSTextField!
    @IBOutlet weak var shipToZip      : NSTextField!
    @IBOutlet weak var shipToPhone    : NSTextField!
    @IBOutlet weak var shipToEmail    : NSTextField!
    
    @IBOutlet weak var notes          : NSTextView!

    @IBOutlet weak var totalSub       : NSTextField!
    @IBOutlet weak var taxRate        : NSTextField!
    @IBOutlet weak var totalTaxes     : NSTextField!
    @IBOutlet weak var totalShipping  : NSTextField!
    @IBOutlet weak var totalNet       : NSTextField!
    
    @IBOutlet weak var salute         : NSTextField!
    @IBOutlet weak var fineprint      : NSTextField!
    
    @IBOutlet weak var tableItems     : NSTableView!
    @IBOutlet weak var itemCounter    : NSTextField!
    
    // Actions
    @IBAction func onInsertItem(_ sender: AnyObject) {
        insertItem()
    }
    @IBAction func onRemoveItem(_ sender: AnyObject) {
        removeItem()
    }
    
    @IBAction func onSaveInvoice(_ sender: NSButton) {
        saveInvoice()
    }

    @IBAction func onGoBack(_ sender: NSButton) {
        goBack()
    }

    @IBAction func onDeleteInvoice(_ sender: NSButton) {
        // Ask for deletion
        deleteInvoice()
    }
    
    @IBAction func onSelectCustomer(_ sender: NSButton) {
        selectCustomer()
    }
    
    @IBAction func onSendInvoice(_ sender: NSButton) {
        sendInvoice()
    }
    
    @IBAction func onPrintInvoice(_ sender: NSButton) {
        printInvoice()
    }
    
    @IBAction func onStampPaid(_ sender: AnyObject) {
        togglePaidStamp()
    }
    
    @IBAction func onStampMail(_ sender: AnyObject) {
        toggleMailStamp()
    }
    
    @IBAction func onPrevInvoice(_ sender: NSButton) {
        goPrevInvoice()
    }
    
    @IBAction func onNextInvoice(_ sender: NSButton) {
        goNextInvoice()
    }
    
    @IBAction func onEditRow(_ sender: NSView) {
        let row = tableItems.row(for: sender)
        print("Edited row: ", row.description)
    }
    
    @IBAction func onEditCell(_ sender: NSTextField) {
        guard let cellId = sender.superview?.identifier else { return }
        //print("Edited cell \(cellId):", sender.stringValue)
        let row = tableItems.selectedRow
        
        switch cellId {
        case "quantity":
            invoice.items[row].quantity = sender.stringValue.toInteger()
            invoice.items[row].isModified = true
            recalcRowAmount(row)
            recalcTotals()
            break
        case "descript":
            invoice.items[row].descript = sender.stringValue
            invoice.items[row].isModified = true
            break
        case "unitprice":
            invoice.items[row].unitPrice = sender.stringValue.toDouble()
            invoice.items[row].isModified = true
            recalcRowAmount(row)
            recalcTotals()
            break
        case "unitofmeasure":
            invoice.items[row].unitOfMeasure = sender.stringValue
            invoice.items[row].isModified = true
            
            recalcRowAmount(row)
            recalcTotals()
            break
        default: /* Unkown cell */
            break
        }
    }
    

    
    // View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignDefaultValues()
    }

    override func viewDidAppear() {
        //print("Did appear")
    }
    
    override func notify(_ message: Parameters?) {
        guard let message = message else { return }
        let action = message["Action"] as! String
        //print(action)
        
        switch action {
        case "Invoice.New":
            viewAction = DocumentAction.New
            viewInitialize(for: DocumentAction.New)
        case "Invoice.Edit":
            viewAction = DocumentAction.Edit
            let id = message["Id"] as! Int
            viewInitialize(for: DocumentAction.Edit, with: id)
            break
        case "Customer.Selected":
            let id = message["Id"] as! Int
            print("Selected customer: ", id)
            if id > 0 {
                showCustomerInfo(id)
            }
            break
        default:
            print("No action")
            break
        }
        //print(action)
        //print(viewAction)
    }

    
    // Custom Methods
    
    func assignDefaultValues() {
        // Document format
        companyName.stringValue  = app.settings.company.name
        companyLine1.stringValue = app.settings.company.address
        companyLine2.stringValue = app.settings.company.phones
        companyLine3.stringValue = app.settings.company.contact
        companyLine4.stringValue = app.settings.company.website
        salute.stringValue       = app.settings.invoice.salute
        fineprint.stringValue    = app.settings.invoice.fineprint
    }

    func viewInitialize(for action: DocumentAction, with id: Int? = 0) {

        if action == DocumentAction.New {
            newDocument()
            billToName.becomeFirstResponder()   // Select first field for edition
        } else {
            editDocument(id!)
        }
        
        setupData()
        
        guard let text = statusText else { return }
        statusBar.setTextControl(text: text)
        statusBar.show("Ready")
        
    }
    
    func newDocument() {
        
        // Default values
        let number = DB.getSequence("Invoices")
        invoice.invoiceNumber = String(format: "%06d", number)
        invoice.issueDate = Date()
        invoice.setMonthYear()
        invoice.terms = app.settings.invoice.defaultTerms
        invoice.setDueDate()
        invoice.taxRate = app.settings.invoice.taxRate
        
        // Attach values to fields
        invoiceNumber.stringValue = invoice.invoiceNumber
        issueDate.stringValue     = invoice.issueDate.toString(format: "MM/dd/yyyy")
        terms.stringValue         = invoice.terms
        dueDate.stringValue       = invoice.dueDate.toString(format: "MM/dd/yyyy")
        totalAmount.stringValue   = invoice.totalNet.toMoney()
        
        let tax = String(format: "%.2f", invoice.taxRate)
        totalSub.stringValue      = invoice.totalSub.toMoney()
        taxRate.stringValue       = "Taxes \(tax)%"
        totalTaxes.stringValue    = invoice.totalTax.toMoney()
        totalNet.stringValue      = invoice.totalNet.toMoney()
        
        // Header bar
        barNumber.stringValue = "Invoice #\(invoice.invoiceNumber)"
        barInfo.stringValue   = "New Invoice"
        
        // Disable navigation buttons
        barPrev.isEnabled = false
        barNext.isEnabled = false
        
        // Hide stamps
        hideMailStamp()
        hidePaidStamp()
        
    }
    
    func editDocument(_ id: Int) {
        // Get invoice from DB
        invoice.get(id, in: DB.context)
        // TODO: if not found?
        
        // Populate fields
        invoiceNumber.stringValue  = invoice.invoiceNumber
        issueDate.stringValue      = invoice.issueDate.toString(format: "MM/dd/yyyy")
        terms.stringValue          = invoice.terms
        dueDate.stringValue        = invoice.dueDate.toString(format: "MM/dd/yyyy")
        totalAmount.stringValue    = invoice.totalNet.toMoney()
        
        billToName.stringValue     = invoice.billToName
        billToAddress1.stringValue = invoice.billToLine1 
        billToAddress2.stringValue = invoice.billToLine2
        billToCity.stringValue     = invoice.billToCity
        billToState.stringValue    = invoice.billToState
        billToZip.stringValue      = invoice.billToZip
        billToPhone.stringValue    = invoice.billToPhone
        billToEmail.stringValue    = invoice.billToEmail

        shipToName.stringValue     = invoice.shipToName
        shipToAddress1.stringValue = invoice.shipToLine1
        shipToAddress2.stringValue = invoice.shipToLine2
        shipToCity.stringValue     = invoice.shipToCity
        shipToState.stringValue    = invoice.shipToState
        shipToZip.stringValue      = invoice.shipToZip
        shipToPhone.stringValue    = invoice.shipToPhone
        shipToEmail.stringValue    = invoice.shipToEmail
        
        notes.string               = invoice.notes

        let tax = String(format: "%.2f", invoice.taxRate)
        totalSub.stringValue      = invoice.totalSub.toMoney()
        taxRate.stringValue       = "Taxes \(tax)%"
        totalTaxes.stringValue    = invoice.totalTax.toMoney()
        totalNet.stringValue      = invoice.totalNet.toMoney()
        
        // Header bar
        barNumber.stringValue = "Invoice #\(invoice.invoiceNumber)"
        barInfo.stringValue   = "Edit Invoice"
        
        // Enable navigation buttons
        barPrev.isEnabled = true
        barNext.isEnabled = true
        
        // Show stamps
        willShowMailStamp()
        willShowPaidStamp()
    }
    
    //-- Actions
    
    func goBack() {
        var notifyAction : String
        var note: Parameters
        if isInvoiceSaved {
            if viewAction == DocumentAction.New {
                notifyAction = "Invoice.New.Save"
            } else {
                notifyAction = "Invoice.Edit.Save"
            }
            note = ["Action": notifyAction, "Id": invoice.invoiceId]
        } else {
            if viewAction == DocumentAction.New {
                notifyAction = "Invoice.New.Cancel"
            } else {
                notifyAction = "Invoice.Edit.Cancel"
            }
            note = ["Action": notifyAction]  // Id not needed
        }
        app.goBack(with: note)
    }

    func saveInvoice() {
        buttonSaveLabel.stringValue = "Saving"
        gatherData()
        validateData()
        invoice.save(in: DB.context)
        if isNewCustomer {
            saveNewCustomer()
        }
        DispatchQueue.main.async { self.generatePDF() }
        buttonSaveLabel.stringValue = "Saved"
        isInvoiceSaved = true
    }
    
    func cancelInvoice() {
        // Go Back
        var notifyAction = "Invoice.New.Cancel"
        if viewAction == DocumentAction.Edit {
            notifyAction = "Invoice.Edit.Cancel"
        }
        let note: Parameters = ["Action": notifyAction]
        app.goBack(with: note)
    }
    
    func deleteInvoice() {
        var note: Parameters = ["Action": "Invoice.New.Delete"]
        print(viewAction)
        switch viewAction {
        case .Edit :
            let id = invoice.invoiceId
            note = ["Action": "Invoice.Edit.Delete", "Id": id]
            invoice.delete(in: DB.context)
            break
        default:
            note = ["Action": "Invoice.New.Delete"]
            break
        }
        app.goBack(with: note)
    }

    func gatherData() {
        
        invoice.invoiceNumber = invoiceNumber.stringValue
        invoice.issueDate     = DateUtils.fromString(issueDate.stringValue, format: "MM/dd/yyyy")
        invoice.terms         = terms.stringValue
        invoice.setMonthYear()
        invoice.setDueDate()

        invoice.customerName  = billToName.stringValue
        invoice.billToName    = billToName.stringValue
        invoice.billToLine1   = billToAddress1.stringValue
        invoice.billToLine2   = billToAddress2.stringValue
        invoice.billToCity    = billToCity.stringValue
        invoice.billToState   = billToState.stringValue
        invoice.billToZip     = billToZip.stringValue
        invoice.billToCountry = "US"
        invoice.billToPhone   = billToPhone.stringValue
        invoice.billToEmail   = billToEmail.stringValue

        invoice.shipToName    = shipToName.stringValue
        invoice.shipToLine1   = shipToAddress1.stringValue
        invoice.shipToLine2   = shipToAddress2.stringValue
        invoice.shipToCity    = shipToCity.stringValue
        invoice.shipToState   = shipToState.stringValue
        invoice.shipToZip     = shipToZip.stringValue
        invoice.shipToCountry = "US"
        invoice.shipToPhone   = shipToPhone.stringValue
        invoice.shipToEmail   = shipToEmail.stringValue

        /* Already calculated
        invoice.taxRate       = 0.0 // get from settings
        invoice.totalSub      = 0.0 // sum items
        invoice.totalTax      = 0.0 // calc from subtotal * taxrate
        invoice.totalShipping = 0.0 // entry field
        invoice.totalNet      = 0.0 // sum all totals
        */

        invoice.notes = notes.string!
        
    }
    
    func validateData() {
        //
    }
    
    func setupData() {
        tableItems.delegate = self
        tableItems.dataSource = self
        tableItems.target = self
        // TODO: doubleClick to edit
        //tableItems.doubleAction = #selector(InvoiceView.onSelectedItem(_:))
        
        // Invoice items
        invoice.items = InvoiceLines(in: DB.context).byInvoice(id: invoice.invoiceId) // from DB
        if invoice.items.count < 1 {
            let first = getBlankLine(1)
            first.quantity = 1
            first.descript = "<new item>"
            invoice.items.append(first)
            
            for index in 2..<15 {
                invoice.items.append(getBlankLine(index))
            }
        }
        //print("Line items ", invoice.items.count)

        tableItems.reloadData()
        recalcTotals()
    }
    
    func getBlankLine(_ number: Int? = 0) -> InvoiceLine {
        let blank        = InvoiceLine()
        blank.isNew      = true
        blank.lineNumber = number!
        return blank
    }

    func calcInvoiceTotal() {
        // Calculate subtotal, taxes, total
        var subtotal = 0.0
        for item in invoice.items {
            if !item.isDeleted {
                subtotal += item.total
            }
        }

        let taxtotal = subtotal * invoice.taxRate / 100
        let nettotal = subtotal + taxtotal
        invoice.totalSub = subtotal
        invoice.totalTax = taxtotal
        invoice.totalNet = nettotal
     
        //return invoice.totalNet
    }
    
    func setInvoiceTotal() {
        totalSub.stringValue    = invoice.totalSub.toMoney()
        totalTaxes.stringValue  = invoice.totalTax.toMoney()
        totalNet.stringValue    = invoice.totalNet.toMoney()
        totalAmount.stringValue = invoice.totalNet.toMoney()
    }
    
    func setItemsCount() {
        var sum = 0
        for item in invoice.items {
            if !item.isDeleted {
                sum += item.quantity
            }
        }
        //var plural = "s"
        //if sum == 1 { plural = "" }
        //itemCounter.stringValue = "\(sum) Item\(plural)"
        itemCounter.stringValue = sum.plural("Item")
    }
    
    func insertItem() {
        // TODO: Insert below current line, reorder line numbers
        let number = getLastLineNumber() + 1
        let line   = getBlankLine(number)
        invoice.items.append(line)
        let last = invoice.items.count - 1
        let cols : IndexSet = [0,1,2,3,4]
        tableItems.insertRows(at: [last], withAnimation: .slideDown)
        tableItems.reloadData(forRowIndexes: [last], columnIndexes: cols)
        tableItems.scrollRowToVisible(last)
        tableItems.selectRowIndexes([last], byExtendingSelection: false)
    }

    func removeItem() {
        let selected = tableItems.selectedRow
        guard selected.inRange(0, invoice.items.count-1) else { return }
        invoice.items[selected].isDeleted = true
        invoice.items[selected].quantity  = 0
        invoice.items[selected].unitPrice = 0.0
        invoice.items[selected].unitOfMeasure = ""
        invoice.items[selected].amount = 0.0
        invoice.items[selected].total  = 0.0
        let cols : IndexSet = [0,1,2,3,4]
        tableItems.reloadData(forRowIndexes: [selected], columnIndexes: cols)
        recalcTotals()
    }
    /*
    func removeItemOLD() {
        /*
         Removing items from table will cause sync problems with items.array if we just mark them as deleted
         So don't remove, strikethrough
         For each cell in row, strike it
         */
        let selected = tableItems.selectedRow
        guard selected.inRange(0, invoice.items.count-1) else { return }
        invoice.items[selected].isDeleted = true
        invoice.items.remove(at: selected)
        tableItems.removeRows(at: [selected], withAnimation: .slideUp)
        var last = selected
        if last == invoice.items.count { last -= 1 } // last row removed, select previous
        tableItems.selectRowIndexes([last], byExtendingSelection: false)
        recalcTotals()
    }
    */
    func reorderItems() {
        for (index, item) in invoice.items.enumerated() {
            item.lineNumber = index
        }
    }
    
    func getLastLineNumber() -> Int {
        var max = 0
        for item in invoice.items {
            if item.lineNumber > max { max = item.lineNumber }
        }
        return max
    }
    
    func recalcRowAmount(_ row: Int){
        let item = invoice.items[row]
//         item.amount = Double(item.quantity) * item.unitPrice
        item.amount = Double(item.unitOfMeasure.toDouble()) * item.unitPrice
        
        // No taxes yet
        item.total = item.amount
        // Update row
        let cols: IndexSet = [0,1,2,3,4]
        tableItems.reloadData(forRowIndexes: [row], columnIndexes: cols)
        
    }
    
    func recalcTotals(){
        calcInvoiceTotal()
        setInvoiceTotal()
        setItemsCount()
    }
    
    func selectCustomer() {
        let act = CustomersList(nibName: "CustomersList", bundle: nil)
        app.show(act!, with:["Action": "Customer.Select"])
        // On notify, update fields
    }
    
    func showCustomerInfo(_ id: Int) {
        invoice.customerId = id
        isNewCustomer = false
        customer.get(id, from: DB.context)
        billToName.stringValue     = customer.name
        billToAddress1.stringValue = customer.address1
        billToAddress2.stringValue = customer.address2
        billToCity.stringValue     = customer.city
        billToState.stringValue    = customer.state
        billToZip.stringValue      = customer.zip
        billToPhone.stringValue    = customer.phone
        billToEmail.stringValue    = customer.email
    }
    
    func saveNewCustomer() {
        if billToName.stringValue.isEmpty { return }
        if invoice.customerId > 0 { return }
        if !isNewCustomer { return }
        customer = Customer()
        customer.name     = billToName.stringValue
        customer.address1 = billToAddress1.stringValue
        customer.address2 = billToAddress2.stringValue
        customer.city     = billToCity.stringValue
        customer.state    = billToState.stringValue
        customer.zip      = billToZip.stringValue
        customer.phone    = billToPhone.stringValue
        customer.email    = billToEmail.stringValue
        customer.save(in: DB.context)
    }
    
    func getInvoiceTemplate() -> String {
        // TODO: Allow user to specify invoice template
        let defaultTemplate = "InvoiceDefault"
        var invoiceTemplate = app.settings.invoice.template
        
        if invoiceTemplate.isEmpty {
            invoiceTemplate = defaultTemplate
        }
        
        return invoiceTemplate
    }
    
    func parseInvoiceTemplate(_ name: String, with data: NSDictionary) -> String {
        let url  = FileUtils.getTemplatePath(name)
        let html = Template.render(url, with: data)
        return html
    }
    
    func printInvoice() {
        let name = getInvoiceTemplate()
        let data = invoice.dataToPrint()
        let html = parseInvoiceTemplate(name, with: data)
        let act  = PrintView(nibName: "PrintView", bundle: nil)
        app.show(act!, with: ["Action": "Print.Invoice", "Content": html])
    }
    
    func sendInvoice() {
        AlertOK(title:"Send email", info:"Mailing service may take a while to initiate in another window").show()
        
        let pdfUrl = getPdfFileName(for: invoice.invoiceNumber)
        if !FileUtils.fileExists(pdfUrl) {
            generatePDF()
        }
        
        Logger.log("Sending pdf: ", pdfUrl.lastPathComponent)
        
        let mail = MailComposer()
        mail.recipients  = [invoice.billToEmail]
        mail.subject     = "\(app.settings.company.name) - Invoice \(invoice.invoiceNumber)"
        mail.content     = "Invoice ready, attached as pdf."
        //mail.sendAsHtml  = true
        mail.attachments = [pdfUrl]
        mail.send()
        
        // Change status to sent
        invoice.status = 1
        invoice.statusText = "Sent"
        if viewAction == .Edit {
            invoice.updateStatus(in: DB.context)
        }
        stampMail.isHidden = false
    }
    
    func getPdfFileName(for number: String) -> URL {
        let seq  = String(format: number, "%06d")
        let name = "Invoice\(seq).pdf"
        let url  = FileUtils.getArchivePath(name)
        return url
    }
    
    func generatePDF() {
        // Template parsing for final html
        let name = getInvoiceTemplate()
        let data = invoice.dataToPrint()
        let html = parseInvoiceTemplate(name, with: data)
        
        // PDF file information
        let url  = getPdfFileName(for: invoice.invoiceNumber)
        let path = FileUtils.getTemplatesFolder()   // relative path for html composing
        
        print("Generating PDF for ", url.lastPathComponent)

        // PDFMagic
        PDF = PDFMagic()
        PDF.fileName      = url
        PDF.relativePath  = path
        PDF.openWhenReady = false
        PDF.save(html)
    }
    
    func goPrevInvoice() {
        let id = invoice.getPrevId(in: DB.context)
        viewAction = DocumentAction.Edit
        viewInitialize(for: DocumentAction.Edit, with: id)
    }
    
    func goNextInvoice() {
        let id = invoice.getNextId(in: DB.context)
        viewAction = DocumentAction.Edit
        viewInitialize(for: DocumentAction.Edit, with: id)
    }
    
    func togglePaidStamp() {
        if invoice.status < 7 {
            invoice.status = 7
            invoice.statusText = "Paid"
            stampPaid.isHidden = false
        } else {
            invoice.status = 6
            invoice.statusText = "Due"
            stampPaid.isHidden = true
        }
        if viewAction == .Edit {
            invoice.updateStatus(in: DB.context)
            isInvoiceSaved = true
        }
    }
    
    func toggleMailStamp() {
        if invoice.status == 1 {
            invoice.status = 0
            invoice.statusText = "New"
            stampMail.isHidden = true
        } else {
            invoice.status = 1
            invoice.statusText = "Sent"
            stampMail.isHidden = false
        }
        if viewAction == .Edit {
            invoice.updateStatus(in: DB.context)
            isInvoiceSaved = true
        }
    }

    func hideMailStamp() {
        stampMail.isHidden = true
    }
    
    func hidePaidStamp() {
        stampPaid.isHidden = true
    }
    
    func willShowMailStamp() {
        if invoice.status > 0 {
            stampMail.isHidden = false
        } else {
            stampMail.isHidden = true
        }
    }
    
    func willShowPaidStamp() {
        if invoice.status > 6 {
            stampPaid.isHidden = false
        } else {
            stampPaid.isHidden = true
        }
    }
}



//---- Table Invoice Items

extension InvoiceView : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return invoice.items.count
    }
}

extension InvoiceView : NSTableViewDelegate {
    /*
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if invoice.items[row].isDeleted { return nil }
        return tableView.rowView(atRow: row, makeIfNecessary: true)
    }
    */
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        //var image  : NSImage? = NSImage.init(named: NSImageNameGoRightTemplate)
        var text   : String = ""
        var cellId : String = ""
        
        guard row < invoice.items.count  else {
            print("Error: Row overflow")
            return nil
        }
        
        let item = invoice.items[row]
        
        if tableColumn == tableView.tableColumns[0] {
            cellId = "quantity"
            if item.quantity == 0 {
                text = ""
            } else {
                text = String(item.quantity)
            }
        } else if tableColumn == tableView.tableColumns[1] {
            cellId = "descript"
            text   = item.descript
        } else if tableColumn == tableView.tableColumns[2] {
            cellId = "unitprice"
            text   = item.unitPrice.toMoney(blankIfZero: true)
        } else if tableColumn == tableView.tableColumns[3] {
            cellId = "unitofmeasure"
            text   = item.unitOfMeasure
        } else if tableColumn == tableView.tableColumns[4] {
            cellId = "total"
            text   = item.total.toMoney(blankIfZero: true)
        }
        
        
        if let cell = tableView.make(withIdentifier: cellId, owner: nil) as? NSTableCellView {
            //cell.imageView?.image = image ?? nil
            cell.textField?.stringValue = text
            // Edition handler
            cell.textField?.target = self
            cell.textField?.action = #selector(InvoiceView.onEditCell(_:))
            
            if cellId == "descript" && item.isDeleted {
                cell.textField?.textColor = Theme.colors.gray192
                cell.textField?.attributedStringValue = text.strikethrough()
            } else {
                cell.textField?.textColor = Theme.colors.black
                cell.textField?.attributedStringValue = NSAttributedString(string: "")
                cell.textField?.stringValue = text
            }
            
            return cell
        }
        
        return nil
    }
    
}



// END
