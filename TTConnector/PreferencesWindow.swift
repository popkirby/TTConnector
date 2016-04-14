//
//  PreferencesWindow.swift
//  TTConnector
//
//  Created by popkirby on 2016/04/12.
//  Copyright © 2016年 popkirby. All rights reserved.
//

import Cocoa
import KeychainAccess

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    
    override var windowNibName: String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let keychain = Keychain(service: "info.pocka.TTConnector")
        let keys = keychain.allKeys()
        if keys.count > 0 {
            usernameTextField.stringValue = keys[0]
            passwordTextField.stringValue = keychain[keys[0]] ?? ""
        }
        
        self.window?.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)

    }
    
    func windowWillClose(notification: NSNotification) {
        let keychain = Keychain(service: "info.pocka.TTConnector")
        let keys = keychain.allKeys()
        
        for key in keys {
            print("Removing keychain item for key: \(key)")
            // 消えるけどなぜかMacはキレるので例外は無視
            try? keychain.remove(key)
        }
        
        print("Set keychain item for key: \(usernameTextField.stringValue)")
        if (usernameTextField.stringValue != "") {
            keychain[usernameTextField.stringValue] = passwordTextField.stringValue
        }
    }
    
    
    
}
