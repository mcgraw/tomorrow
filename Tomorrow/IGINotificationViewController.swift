//
//  IGINotificationViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 3/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Batch.Push

class IGINotificationViewController: GAITrackedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        screenName = "Onboard Notification Screen"
    }
    
    func advanceOnboarding() {
        performSegueWithIdentifier("nameSegue", sender: self)
    }
    
    @IBAction func notificationAction(sender: AnyObject) {
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "button_press", label: "register_notifications", value: nil).build())
        
        BatchPush.registerForRemoteNotifications()
        advanceOnboarding()
    }
    
    @IBAction func skipAction(sender: AnyObject) {
        advanceOnboarding()
    }
}
