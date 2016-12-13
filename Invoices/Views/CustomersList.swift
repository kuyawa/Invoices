//
//  CustomersList.swift
//  Invoices
//
//  Created by Mac Mini on 11/4/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

class CustomersList: NSViewController {

    enum CustomerAction {
        case New, Edit, Delete, Select
    }
    
    var app = NSApp.delegate as! AppDelegate
    var DB  = Database()
    
    var viewAction   = CustomerAction.Edit
    var isSelecting  = false
    var lastSelected = 0

    dynamic var customers : [Customer] = []
    dynamic var customer  : Customer!  = Customer()

    
    @IBOutlet weak var statusBar  : StatusBar!
    @IBOutlet weak var statusText : NSTextField!
    @IBOutlet weak var buttonSelect: NSButton!
    @IBOutlet weak var buttonSelectLabel: NSTextField!
    
    @IBOutlet dynamic var listCustomers : NSArrayController!

    @IBOutlet weak var tableCustomers : NSTableView!
    @IBOutlet weak var recordArea     : NSView!
    
    @IBOutlet weak var textName       : NSTextField!
    @IBOutlet weak var textAddress1   : NSTextField!
    @IBOutlet weak var textAddress2   : NSTextField!
    @IBOutlet weak var textCity       : NSTextField!
    @IBOutlet weak var textState      : NSTextField!
    @IBOutlet weak var textZip        : NSTextField!
    @IBOutlet weak var textPhone      : NSTextField!
    @IBOutlet weak var textEmail      : NSTextField!
    
    
    
    @IBAction func onBack(_ sender: NSButton) {
        app.goBack()
    }

    @IBAction func onSelect(_ sender: NSButton) {
        if isSelecting {
            let id = getSelectedId()
            app.goBack(with: ["Action": "Customer.Selected", "Id": id])
        }
    }

    @IBAction func onNewCustomer(_ sender: NSButton) {
        newCustomer()
    }
    
    @IBAction func onSaveCustomer(_ sender: NSButton) {
        saveCustomer()
    }
    
    @IBAction func onDeleteCustomer(_ sender: NSButton) {
        deleteCustomer()
    }

    @IBAction func onPrintCustomer(_ sender: NSButton) {
        printCustomersList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear() {
        loadData()
    }
    
    override func notify(_ message: Parameters?) {
        guard let message = message else { return }
        let action = message["Action"] as! String
        print(action)
        switch action {
        case "Customer.List":
            break
        case "Customer.Select":
            setViewForSelection()
            break
        default:
            break
        }
    }
    
    // ACTIONS
    
    func initialize() {
        recordArea.wantsLayer = true
        recordArea.layer?.backgroundColor = Theme.colors.snow.cgColor
        recordArea.layer?.borderColor = Theme.colors.silver.cgColor
        recordArea.layer?.borderWidth = 1.0
        
        statusBar.setTextControl(text: statusText)
        statusBar.show("Ready")
    }
    
    func setViewForSelection() {
        isSelecting = true
        buttonSelect.isHidden = false
        buttonSelectLabel.isHidden = false
        buttonSelect.isEnabled = true
        buttonSelectLabel.isEnabled = true
        //buttonSelect.layer?.opacity = 1.0
        //buttonSelectLabel.layer?.opacity = 1.0
    }
    
    func loadData() {
        customers = Customers(in: DB.context).all()
        listCustomers.content = customers
        if customers.count < 1 {
            newCustomer()
        }
        setDoubleClick()
        showCustomersCount()
        selectFirstCustomer()
    }
    
    func setDoubleClick() {
        tableCustomers.doubleAction = #selector(CustomersList.onSelect(_:))
    }
    
    func showCustomersCount() {
        statusBar.show(customers.count.plural("customer"))
    }
    
    func selectFirstCustomer() {
        if tableCustomers.numberOfRows > 0 {
            tableCustomers.selectRowIndexes([0], byExtendingSelection: false)
            customer = customers[0]
        }
    }
    
    func getSelectedId() -> Int {
        guard tableCustomers.selectedRow >= 0 else { return 0 }
        lastSelected = tableCustomers.selectedRow
        
        if customers.count > lastSelected {
            customer = customers[lastSelected]
        }
        
        print("Selected #\(lastSelected) ID: \(customer.customerId)")
        return customer.customerId
    }
    
    func newCustomer() {
        viewAction = CustomerAction.New
        var selected = 0
        
        textName.stringValue     = ""
        textAddress1.stringValue = ""
        textAddress2.stringValue = ""
        textCity.stringValue     = ""
        textState.stringValue    = ""
        textZip.stringValue      = ""
        textPhone.stringValue    = ""
        textEmail.stringValue    = ""

        if tableCustomers.numberOfRows < 1 {
            customer = Customer()
            customer.name = "<new customer>"
            customers = [Customer]()
            customers.append(customer)
            listCustomers.content = customers
            tableCustomers.reloadData()
            tableCustomers.selectRowIndexes([selected], byExtendingSelection: false)
        } else {
            customer = Customer()
            customer.name = "<new customer>"
            customers = listCustomers.content as! [Customer]
            customers.append(customer)
            listCustomers.content = customers
            // find new record
            selected = tableCustomers.numberOfRows-1 // last row
            let cols: IndexSet = [0,1]
            tableCustomers.reloadData(forRowIndexes: [selected], columnIndexes: cols)
            tableCustomers.scrollRowToVisible(selected)
            tableCustomers.selectRowIndexes([selected], byExtendingSelection: false)
        }
        
        showCustomersCount()
        focusOnName()
    }

    func saveCustomer() {
        var selected = tableCustomers.selectedRow
        
        if viewAction == CustomerAction.New {
            customer = gatherData()
            customer.save(in: self.DB.context)
            customers[selected] = customer
            listCustomers.content = customers
            let newId = customer.customerId
            
            // Add to table
            let cols: IndexSet = [0,1]
            tableCustomers.reloadData(forRowIndexes: [selected], columnIndexes: cols)

            // Select new record in table
            for (index, item) in customers.enumerated() {
                if item.customerId == newId {
                    selected = index
                    break
                }
            }
            tableCustomers.selectRowIndexes([selected], byExtendingSelection: false)

        } else {
            guard let row = listCustomers.selectedObjects.first as! Customer! else {
                print("No customer selected")
                return
            }
            self.customer = row
            self.customer.save(in: self.DB.context)
        }
        
        viewAction = CustomerAction.Edit  // back to edit
        focusOnTable()
    }
    
    func gatherData() -> Customer {
        // Bindings should solve this
        let new = Customer()
        
        new.customerId = 0
        new.name       = textName.stringValue
        new.address1   = textAddress1.stringValue
        new.address2   = textAddress2.stringValue
        new.city       = textCity.stringValue
        new.state      = textState.stringValue
        new.zip        = textZip.stringValue
        new.phone      = textPhone.stringValue
        new.email      = textEmail.stringValue
        
        return new
    }
    
    func gatherData(_ row: Customer) -> Customer {
        // Bindings should solve this
        let new = Customer()
        new.customerId = row.customerId
        new.name       = row.name
        new.address1   = row.address1
        new.address2   = row.address2
        new.city       = row.city
        new.state      = row.state
        new.zip        = row.zip
        new.phone      = row.phone
        new.email      = row.email
        return new
        
    }
    
    func deleteCustomer() {
        var selected = tableCustomers.selectedRow
        guard let customer = listCustomers.selectedObjects.first as! Customer! else {
            print("No customer selected")
            return
        }
        
        //DispatchQueue.main.async {
        customer.delete(in: self.DB.context)
        //}
        
        // Remove from customers and listCustomers
        customers.remove(at: selected)
        
        //tableCustomers.removeRows(at: [selected], withAnimation: .slideUp)  // Remove from table
        if selected >= customers.count { selected -= 1 }  // If last item was deleted then select previous
        if selected >= 0 && tableCustomers.numberOfRows > 0 {
            tableCustomers.selectRowIndexes([selected], byExtendingSelection: false)
        }
        
        showCustomersCount()
        focusOnTable()
    }
    
    func printCustomersList() {
        // TODO: Report all customers alphabetically
    }
    
    func focusOnTable() {
        view.window?.makeFirstResponder(tableCustomers)
        tableCustomers.becomeFirstResponder()
    }
    
    func focusOnName() {
        textName.becomeFirstResponder()
    }
    
}


/*
//---- Table customers

extension CustomersList : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return customers.count
    }
}

extension CustomersList : NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        lastSelected = tableCustomers.selectedRow
        if customers.count > lastSelected {
            customer = customers[lastSelected]
        }
        print("Selected: ", lastSelected)
    }
}
*/

// END

