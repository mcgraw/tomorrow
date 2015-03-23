//
//  AppDelegate.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Realm
import Batch
import Batch.Push
import Batch.Ads
import Batch.Unlock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BatchAdsDisplayDelegate, BatchUnlockDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Register Notifications
        BatchPush.registerForRemoteNotifications()
        
        // Clear any notifications when the user opens the app
        BatchPush.dismissNotifications()
        
        // Setup Ads
        BatchAds.setupAds()
        
        // Unlock
        BatchUnlock.setupUnlockWithDelegate(self)
        
        // Start Batch
        Batch.startWithAPIKey("DEV54EF398118121451CB109F931AE")
        
        // Realm Migration Check
        RLMRealm.setSchemaVersion(2, forRealmAtPath: RLMRealm.defaultRealmPath()) { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 1 {
                // Nothing to do. Let realm detect properties.
            }
        }
        
        // If we crashed, or the user left the app, let's start the entry over
        IGIGoal.cleanInvalidGoals()
                
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        
        // If we're returning we need to check if goal progress has elapsed
        IGIGoal.cleanElapsedGoals()
        
        // show an advert if they haven't left a tip
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "showAdvert", userInfo: nil, repeats: false)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
    }
    
    func automaticOfferRedeemed(offer: BatchOffer!) {
        println(offer.offerAdditionalParameters())
        
        for feature in offer.features() as [BatchFeature] {
            let reference = feature.reference()
            let value = feature.value()
            
            // unlock
            println("ref \(reference) & val \(value)")
        }
    }
    
    func showAdvert() {
        // show an advert if they haven't left a tip
        let leftTip = NSUserDefaults.standardUserDefaults().boolForKey("kDidLeaveDonation")
        if !leftTip {
            println("Display advert")
            BatchAds.displayAdForPlacement(BatchPlacementDefault)
        }
    }
}