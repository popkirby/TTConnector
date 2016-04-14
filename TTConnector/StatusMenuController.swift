//
//  StatusMenuController.swift
//  TTConnector
//
//  Created by popkirby on 2016/04/12.
//  Copyright © 2016年 popkirby. All rights reserved.
//

import Cocoa
import KeychainAccess

class StatusMenuController: NSObject {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var enableMenuItem: NSMenuItem!
    
    var preferencesWindow: PreferencesWindow!
    var autoLoginEnabled: Bool = false {
        didSet {
            if autoLoginEnabled {
                enableMenuItem.state = NSOnState
                connector = Connector()
            } else {
                enableMenuItem.state = NSOffState
                connector?.stopTimer()
                connector = nil
            }
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(autoLoginEnabled, forKey: "autoLoginEnabled")
        }
    }
    
    var connector: Connector?
    var connectedNotification: NSNotification?
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.template = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        let defaults = NSUserDefaults.standardUserDefaults()
        autoLoginEnabled = defaults.boolForKey("autoLoginEnabled") ?? false
        
        preferencesWindow = PreferencesWindow()
    }
    
    @IBAction func enableClicked(sender: NSMenuItem) {
        if autoLoginEnabled {
            print("Disable Auto Login")
            autoLoginEnabled = false
        } else {
            let keychain = Keychain(service: "info.pocka.TTConnector")
            let keys = keychain.allKeys()
            if keys.count == 0 || keys[0] == "" || keychain[keys[0]] == nil {
                let alert = NSAlert()
                alert.messageText = "User information is not set"
                alert.informativeText = "Please configure from Preferences."
                alert.runModal()
                return
            }
            
            print("Enable Auto Login")
            autoLoginEnabled = true
        }
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
}
