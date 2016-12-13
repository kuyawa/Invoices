//
//  InvoicesList.swift
//  Invoices
//
//  Created by Mac Mini on 11/4/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

class InvoicesList: NSViewController {

    // Globals
    var app = NSApp.delegate as! AppDelegate
    var DB  = Database()

    var listInvoices = [InvoicesRow]()
    var lastSelected : Int = 0
    var firstTime    = false
    
    var currentDate  = Date()
    var currentYear  = Date().getYear()
    var currentMonth = Date().getMonth()
    
    // ActionBar
    @IBOutlet weak var actionBar  : ActionBar!

    // HeaderBar
    @IBOutlet weak var monthName     : NSTextField!
    @IBOutlet weak var totalInvoices : NSTextField!
    
    // Status Bar
    @IBOutlet weak var statusBar  : StatusBar!
    @IBOutlet weak var statusText : NSTextField!
    
    // Form controls
    @IBOutlet weak var tableInvoices : NSTableView!
    
    
    // Toolbar
    @IBAction func onCancel(_ sender: NSButton) {
        app.goBack()
    }

    @IBAction func onNewInvoice(_ sender: NSButton) {
        let act = InvoiceView(nibName: "InvoiceView", bundle: nil)
        app.show(act!, with: ["Action": "Invoice.New"])
    }
    
    @IBAction func onEditInvoice(_ sender: NSButton) {
        let id  = getSelectedInvoiceId()
        let act = InvoiceView(nibName: "InvoiceView", bundle: nil)
        app.show(act!, with: ["Action": "Invoice.Edit", "Id": id])
    }

    @IBAction func onSendInvoice(_ sender: NSButton) {
        let id  = getSelectedInvoiceId()
        let act = InvoiceView(nibName: "InvoiceView", bundle: nil)
        app.show(act!, with: ["Action": "Invoice.Send", "Id": id])
    }
    
    @IBAction func onPrintInvoice(_ sender: NSButton) {
        let id = getSelectedInvoiceId()
        let act = InvoiceView(nibName: "InvoiceView", bundle: nil)
        app.show(act!, with: ["Action": "Invoice.Print", "Id": id])
    }

    @IBAction func onCustomers(_ sender: NSButton) {
        let act = CustomersList(nibName: "CustomersList", bundle: nil)
        app.show(act!, with: ["Action": "Customer.List"])
    }
    
    @IBAction func onOptions(_ sender: NSButton) {
        let act = OptionsView(nibName: "OptionsView", bundle: nil)
        app.show(act!)
    }
    
    // Month Navigation
    @IBAction func onPrevMonth(_ sender: NSButton) {
        goPrevMonth()
    }
    
    @IBAction func onNextMonth(_ sender: NSButton) {
        goNextMonth()
    }
    
    @IBAction func onThisMonth(_ sender: NSButton) {
        goThisMonth()
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstTime = true
        viewInitialize()
    }

    override func viewDidAppear() {
        if firstTime {
            currentYear  = Date().getYear()
            currentMonth = Date().getMonth()
            setMonthLabel(year: currentYear, month: currentMonth)
            reloadData()
            selectFirstRow()
            setFocusOnTable()
            firstTime = false
        }

        updateViewState()
    }
    
    /*
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            print("REPRESENTED OBJECT")
        }
    }
    */

    override func notify(_ message: Parameters?) {
        guard let message = message else { return }
        let action = message["Action"] as! String
        switch action {
        case "Invoice.New.Cancel", "Invoice.New.Delete", "Invoice.Edit.Cancel":
            print("Action cancelled")
            break
        case "Invoice.New.Save":
            let id = message["Id"] as! Int
            print("New invoice \(id) saved")
            reloadData()
            selectRow(forId: id)
            break
        case "Invoice.Edit.Save":
            let id = message["Id"] as! Int
            print("Invoice \(id) saved")
            reloadRow(lastSelected, id: id)
            selectRow(forIndex: lastSelected)
            break
        case "Invoice.Edit.Delete":
            let id = message["Id"] as! Int
            print("Invoice \(id) deleted")
            reloadData()
            break
        default:
            break
        }
        
        setFocusOnTable()
    }
    
    

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        // print("Menu action for \(menuItem.title)")
        // TODO: enable/disable all items
        // if menuItem.title == "Refresh" { return false }
        return true
    }

    
    // TOOLBAR ACTIONS
    struct ToolbarState {
        var newInvoice  = true
        var viewInvoice = false
        var sendInvoice = false
        var customers   = true
        var options     = true
    }
    
    var toolbar = ToolbarState()
    
    override func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        var enabled = false
        if item.itemIdentifier == "newInvoiceTool"  { enabled = toolbar.newInvoice }
        if item.itemIdentifier == "viewInvoiceTool" { enabled = toolbar.viewInvoice }
        if item.itemIdentifier == "sendInvoiceTool" { enabled = toolbar.sendInvoice }
        if item.itemIdentifier == "customersTool"   { enabled = toolbar.customers }
        if item.itemIdentifier == "optionsTool"     { enabled = toolbar.options }
        return enabled
    }
    
    
    
    
    //----  UI Methods ----------------------------------------
    //
    
    func viewInitialize() {
        statusBar.setTextControl(text: statusText)
        statusBar.show("Ready")
    }
    
    func updateViewState() {
        // Enable/disable toolbar buttons
        //toolbar.viewInvoice = (listInvoices.count > 0)
    }
    
    func loadInitialData() {
        currentYear  = Date().getYear()
        currentMonth = Date().getMonth()
        reloadData()
    }
    
    func reloadData() {
        tableInvoices.delegate = self
        tableInvoices.dataSource = self
        tableInvoices.target = self
        tableInvoices.doubleAction = #selector(InvoicesList.onSelectedInvoice(_:))

        // Invoices by month
        listInvoices = Invoices(in: DB.context).byMonth(year: currentYear, month: currentMonth)
        tableInvoices.reloadData()
        let total = getInvoicesTotal()
        setInvoicesTotal(total)
        setInvoicesCount(listInvoices.count)
    }
    
    func reloadRow(_ index: Int, id: Int) {
        listInvoices[index] = Invoices().get(id)
        let cols : IndexSet = [0,1,2,3,4,5,6]
        tableInvoices.reloadData(forRowIndexes: [index], columnIndexes: cols)
        let total = getInvoicesTotal()
        setInvoicesTotal(total)
        setInvoicesCount(listInvoices.count)
    }
    
    func getInvoicesTotal() -> Double {
        var total = 0.0
        for item in listInvoices {
            total += item.totalNet
        }
        return total
    }
    
    func setInvoicesTotal(_ total: Double) {
        totalInvoices.stringValue = "Total sales of the month: " + total.toMoney()
    }
    
    func setInvoicesCount(_ count: Int) {
        var plural = "s"
        if count == 1 { plural = "" }
        statusBar.show("\(count) Invoice\(plural)")
    }
    
    func setMonthLabel(_ name :String) {
        monthName.stringValue = name
    }
    
    func setMonthLabel(year :Int, month: Int) {
        let name = DateUtils.getMonthName(month)
        monthName.stringValue = "\(name) \(year)"
    }

    

    // Double click on the table
    @IBAction func onSelectedInvoice(_ sender: AnyObject) {
        let id = getSelectedInvoiceId()
        viewInvoice(id)
    }
    
    func getSelectedInvoiceId() -> Int {
        guard tableInvoices.selectedRow >= 0 else { return 0 }
        print("Selected Row: ", tableInvoices.selectedRow)
        self.lastSelected = tableInvoices.selectedRow
        let invoice = listInvoices[self.lastSelected]
        let id = invoice.invoiceId
        print("Selected Invoice ID: ", id)
        return id
    }
    
    func setFocusOnTable() {
        view.window?.makeFirstResponder(tableInvoices)
        tableInvoices.becomeFirstResponder()
    }
    
    func selectFirstRow() {
        if tableInvoices.numberOfRows > 0 {
            tableInvoices.selectRowIndexes([0], byExtendingSelection: false)
        }
    }
    
    func selectRow(forId id: Int) {
        print("Select row id: ", id)
        for (index, item) in listInvoices.enumerated() {
            if item.invoiceId == id {
                tableInvoices.selectRowIndexes([index], byExtendingSelection: false)  // select this one
                break
            }
        }
    }
    
    func selectRow(forIndex index: Int) {
        print("Select row index: ", index)
        if tableInvoices.numberOfRows < 1 { return } // no rows
        
        var num = 0
        if index > tableInvoices.numberOfRows { num = tableInvoices.numberOfRows - 1 }
        if index < tableInvoices.numberOfRows { num = index }
        if index < 0 { num = 0 }
        
        tableInvoices.selectRowIndexes([num], byExtendingSelection: false)
    }
    
    func viewInvoice(_ id: Int) {
        print("View Invoice Id: ", id)
        let act = InvoiceView(nibName: "InvoiceView", bundle: nil)
        app.show(act!, with: ["Action": "Invoice.Edit", "Id": id])
    }
    
    func goPrevMonth() {
        currentMonth -= 1
        if currentMonth < 1 {
            currentMonth = 12
            currentYear -= 1
        }
        showInvoices(year: currentYear, month: currentMonth)
    }
    
    func goNextMonth() {
        currentMonth += 1
        if currentMonth > 12 {
            currentMonth = 1
            currentYear += 1
        }
        showInvoices(year: currentYear, month: currentMonth)
    }
    
    func goThisMonth() {
        currentYear  = Date().getYear()
        currentMonth = Date().getMonth()
        showInvoices(year: currentYear, month: currentMonth)
    }
    
    func showInvoices(year: Int, month: Int) {
        setMonthLabel(year: year, month: month)
        reloadData()
    }
    
}




//---- Table invoices

extension InvoicesList : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return listInvoices.count
    }
}

extension InvoicesList : NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // Will use image for invoice status: sent, due, archived
        var image  : NSImage? = NSImage.init(named: NSImageNameGoRightTemplate)
        var text   : String = ""
        var cellId : String = ""
        
        let item = listInvoices[row]
        
        if tableColumn == tableView.tableColumns[0] {
            cellId = "invoiceNumber"
            text   = item.invoiceNumber
        } else if tableColumn == tableView.tableColumns[1] {
            cellId = "issueDate"
            text   = DateUtils.trimTime(item.issueDate)
        } else if tableColumn == tableView.tableColumns[2] {
            cellId = "dueDate"
            text   = DateUtils.trimTime(item.dueDate)
        } else if tableColumn == tableView.tableColumns[3] {
            cellId = "customerName"
            text   = item.customerName
        } else if tableColumn == tableView.tableColumns[4] {
            cellId = "totalNet"
            text   = MoneyUtils.currency(item.totalNet)
        } else if tableColumn == tableView.tableColumns[5] {
            cellId = "statusText"
            text   = item.getStatusText()
        } else if tableColumn == tableView.tableColumns[6] {
            cellId = "paidIcon"
            image  = NSImage(named: NSImageNameStatusNone)
            text   = ""
        }
        
        // If pastdue color in red, if paid color in blue, else in black
        if let cell = tableView.make(withIdentifier: cellId, owner: nil) as? NSTableCellView {
            cell.imageView?.image = image ?? nil
            cell.textField?.stringValue = text
            
            if item.isPaid() {
                /*
                if cellId == "totalNet" || cellId == "statusText" {
                    cell.textField?.textColor = Theme.colors.paid
                }
                */
                if cellId == "paidIcon" {
                    cell.imageView?.image  = NSImage(named: NSImageNameStatusAvailable)
                }
            }
            
            if item.isPastDue() {
                if cellId == "invoiceNumber"
                || cellId == "issueDate"
                || cellId == "dueDate"
                || cellId == "customerName"
                || cellId == "totalNet"
                || cellId == "statusText" {
                    cell.textField?.textColor = Theme.colors.due
                }
            }
            
            if item.isPastDue() && cellId == "paidIcon" {
                cell.imageView?.image  = NSImage(named: NSImageNameStatusUnavailable)
            }
            
            return cell
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.lastSelected = tableInvoices.selectedRow
        updateViewState()
    }
}


// END
