//
//  Connector.swift
//  TTConnector
//
//  Created by popkirby on 2016/04/12.
//  Copyright © 2016年 popkirby. All rights reserved.
//

import Foundation
import KeychainAccess
import Reachability
import CoreWLAN

class Connector: NSObject {
    static let ConnReachableNotification = "ConnReachableNotification"
    static let ConnUnreachableNotification = "ConnUnreachableNotification"
    static let TTLoginedNotification = "TTLoginedNotification"
    
    private let LOGIN_URL = "https://wlanauth.noc.titech.ac.jp/login.html"
    private let TT_SSID = "TokyoTech"
    private let PING_URL = "https://www.google.com/"
    private let PING_INTERVAL = 10.0
    
    var reachability: Reachability?
    weak var pingTimer: NSTimer?
    
    override init() {
        super.init()
        setup()
    }
    
    deinit {
        reachability?.stopNotifier()
        stopTimer()
        reachability = nil
        pingTimer = nil
    }
    
    // MARK: TokyoTech related
    
    func loginTT() {
        // obtain user data from keychain
        let keychain = Keychain(service: "info.pocka.TTConnector")
        let keys = keychain.allKeys()
        
        let username = keys[0]
        let password = keychain[username]
        
        print("Obtained username: \(username)")
        
        if password == nil {
            print("password is nil; maybe account is not read/registered")
            return
        }
        
        // create request
        let request = NSMutableURLRequest(URL: NSURL(string: LOGIN_URL)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = buildQueryWithString([
            "username": username,
            "password": password!,
            "buttonClicked": "4",
            "err_flag": "0"
        ])
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (_, _, _) in
            self.loginTTCallback()
        }
        
        task.resume()
    }
    
    func isTTConnected() -> Bool {
        if let ssid = getSSID() {
            if ssid == "TokyoTech" {
                return true
            }
        }
        return false
    }
    
    func isTTLogined() -> Bool {
        let session = NSURLSession.sharedSession()
        var result: Bool = false
        
        // wait until pinging complete
        let semaphore = dispatch_semaphore_create(0)
        
        let task = session.dataTaskWithURL(NSURL(string: PING_URL)!) {
            (_, _, err) in
            if err == nil {
                result = true
            }
            
            dispatch_semaphore_signal(semaphore)
        }
        
        task.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return result
    }
    
    // MARK: Reachability
    
    func setup() {
        reachability = try! Reachability.reachabilityForInternetConnection()
        
        reachability?.whenReachable = { _ in
            print("Became reachable")
            self.enableAutoLogin()
        }
        
        reachability?.whenUnreachable = { _ in
            print("Became unreachable")
            self.stopTimer()
        }
        
        try! reachability?.startNotifier()
    }
    
    // MARK: Callback functions
    
    func enableAutoLogin() {
        if isTTConnected() {
            if !isTTLogined() {
                // connected to TokyoTech, but not logined
                // attempt to login
                print("Connected to Tokyotech, but not logined")
                loginTT()
            } else {
                print("Connected to TokyoTech, and logined")
                startTimer()
                // connected to TokyoTech, and logined
            }
        } else {
            // not connected to TokyoTech
            print("Not Connected to Tokyoteh")
            stopTimer()
        }
    }
    
    func stopTimer() {
        // stop timer
        print("Attempt to stop timer")
        pingTimer?.invalidate()
    }
    
    func loginTTCallback() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName("TTLoginedNotification", object: self)
        
        // start timer
        startTimer()
        
    }
    
    func startTimer() {
        if pingTimer == nil {
            print("Starting timer...")
            let timer = NSTimer(timeInterval: PING_INTERVAL, target: self, selector: #selector(Connector.enableAutoLogin), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            pingTimer = timer
        }
    }
    
    // MARK: Utilities
    
    func getSSID() -> String? {
        return CWWiFiClient.sharedWiFiClient().interface()?.ssid()
    }
    
    
    func buildQueryWithString(aDict: Dictionary<String, String>) -> NSData? {
        var parts: [String] = []
        for (key, value) in aDict {
            parts.append("\(key)=\(value)")
        }
        
        let queryString = parts.joinWithSeparator("&")
        return queryString.dataUsingEncoding(NSUTF8StringEncoding)
    }
    

}