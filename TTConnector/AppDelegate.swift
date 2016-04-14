//
//  AppDelegate.swift
//  TTConnector
//
//  Created by popkirby on 2016/04/12.
//  Copyright © 2016年 popkirby. All rights reserved.
//

import Cocoa
import KeychainAccess

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(AppDelegate.didConnectedToTokyoTech(_:)), name: Connector.TTLoginedNotification, object: nil)
        
    }
    
    func didConnectedToTokyoTech(notification: NSNotification) {
        let userNC = NSUserNotificationCenter.defaultUserNotificationCenter()
        let userNotif = NSUserNotification()
        userNotif.title = "Logined to TokyoTech"
        userNotif.informativeText = "Maybe logined."
        
        userNC.deliverNotification(userNotif)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }

}

