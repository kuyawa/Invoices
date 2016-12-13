//
//  AppDelegate.swift
//  Invoices
//
//  Created by Mac Mini on 10/29/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var settings  = Settings()      // app.settings.invoices.autoSaveAsPDF
    var folders   = AppFolders()    // app.folders.templates
    
    
    // App lifecycle, these methods happen in this order
    func applicationWillFinishLaunching(_ notification: Notification) {
        //super.applicationWillFinishLaunching(notification)
        //print("App will launch")
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        //super.applicationWillBecomeActive(notification)
        //print("App becoming active")
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Logger.logText("Hello!")
        
        // Check app integrity after main view has been loaded
        settings.load()
        checkApplicationFolders()
        checkInitialResources()
        checkDatabaseIntegrity()
        runDailyJobs()
    }

    // Add this handler to all apps, close on red button click
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        Logger.logText("Goodbye!")
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        //print("[Exit]")
    }
    
    
    // Check application integrity
    
    func checkApplicationFolders() {
        FileUtils.verifyAppFolders()         // Docs/Armonia/Invoices
    }
    
    func checkInitialResources() {
        FileUtils.verifyInitialResources()  // schema.sql, invoice template, etc
    }
    
    func checkDatabaseIntegrity() {
        let DS = DataServer()
        DS.connect()
        DS.verifyDatabase(version: settings.system.dataVersion)
    }
    
    func runDailyJobs() {
        let today = DateUtils.trimTime(Date())
        let lastDayRun = settings.system.lastDayRun
        if lastDayRun != today {
            settings.setLastDayRun(Date())
            Logger.log("Execute daily jobs")
            DataJobs().purgeLogFiles()
            DataJobs().checkInvoicesPastdue()
        }
    }
    

    
    // APP DIRECTOR 

    // Use: 
    //  let act = MainView(nibName: "MainView", bundle: nil)
    //  app.show(act!)
    func show<ControllerType:NSViewController>(_ newController: ControllerType, with message: Parameters? = nil) {
        let newView = newController.view
        
        if let frame = NSApp.mainWindow?.contentView?.frame {
            newView.frame = frame                           // Resize the view to the window instead
        }
        
        guard let main = NSApp.mainWindow?.contentViewController else { return }
        
        if main.childViewControllers.count < 1 {            // if no controllers, then it's main controller
            main.addChildViewController(newController)                // add new controller
            main.view.addSubview(newView)                   // add new view to main view
            if message != nil {
                newController.notify(message)
            }
        } else {
            let current = main.childViewControllers.last    // get lasr controller as current before adding new
            main.addChildViewController(newController)                // add new controller
            main.transition(from: current!, to: newController, options: [.crossfade]){
                if message != nil {
                    newController.notify(message)
                }
            }
        }
        
    }

    // Use:
    //  app.goBack()
    func goBack(with message: Parameters? = nil) {
        
        guard let main = NSApp.mainWindow?.contentViewController else { return }

        // Can't remove first controller
        guard main.childViewControllers.count > 1 else { return }
        
        // Remove last view and controller if available
        guard let current = main.childViewControllers.last else { return }
        
        let prevIndex = main.childViewControllers.count - 2
        let previous  = main.childViewControllers[prevIndex]
        
        main.transition(from: current, to: previous, options: [.crossfade]){
            if message != nil {
                previous.notify(message)
            }
        }
        
        main.childViewControllers.removeLast()
    }
    


}

