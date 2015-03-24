//
//  IGINotificationViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 3/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Batch.Push

class IGINotificationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
    }
    
    func advanceOnboarding() {
        performSegueWithIdentifier("nameSegue", sender: self)
    }
    
    @IBAction func notificationAction(sender: AnyObject) {
        BatchPush.registerForRemoteNotifications()
        advanceOnboarding()
    }
    
    @IBAction func skipAction(sender: AnyObject) {
        advanceOnboarding()
    }
}
