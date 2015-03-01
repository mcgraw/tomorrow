//
//  AppDelegate.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Batch
import Batch.Push
import Batch.Ads

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BatchAdsDisplayDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Register Notifications
        BatchPush.registerForRemoteNotifications()
        
        // Clear any notifications when the user opens the app
        BatchPush.dismissNotifications()
        
        // Setup Ads
        BatchAds.setupAds()
        
        // Start Batch
        Batch.startWithAPIKey("DEV54EF398118121451CB109F931AE")
        
        // Realm Migration Check
        RLMRealm.setSchemaVersion(1, forRealmAtPath: RLMRealm.defaultRealmPath()) { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 1 {
                // Nothing to do. Let realm detect properties.
            }
        }
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
    }    
}