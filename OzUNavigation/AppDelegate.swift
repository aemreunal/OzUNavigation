//
//  AppDelegate.swift
//  OzUNavigation
//
//  Created by A. Emre Ünal on 12/05/15.
//  Copyright (c) 2015 A. Emre Ünal. All rights reserved.
//

import UIKit
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let idJson = "{\"projectId\":1,\"secret\":\"56E7C5F1-A20E-481E-AF24-24938D7C31A8\"}";

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        KingfisherManager.sharedManager.downloader.trustedHosts = Set(["localhost", "127.0.0.1"])
        KingfisherManager.sharedManager.downloader.requestModifier = {
            (request: NSMutableURLRequest) in
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body:NSString = self.getRequestBodyString(fromString: self.idJson)
            request.HTTPBody = NSData(base64EncodedString: body as String, options: NSDataBase64DecodingOptions.allZeros)
        }
        return true
    }

    func getRequestBodyString(fromString string: NSString) -> NSString {
        let plainData = string.dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return base64String
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

