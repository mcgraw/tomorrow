//
//  IGIBaseViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGIBaseViewController: UIViewController {
    
    @IBOutlet weak var currentGradient: IGIGradientView?
    @IBOutlet weak var temporaryGradient: IGIGradientView?
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var shouldPlayIntroduction = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "genderChanged:", name: "didChangeGender", object: nil)
        
//        let startColor = UIColor(red:0.19, green:0.12, blue:0.53, alpha:1)
//        let endColor = UIColor(red:0.52, green:0.8, blue:1, alpha:1)
        let startColor = UIColor(red:0.11, green:0.48, blue:0.72, alpha:1)
        let endColor = UIColor(red:0.87, green:0.85, blue:0.96, alpha:1)
        currentGradient?.updateGradientLayer(startColor, endColor: endColor)
        temporaryGradient?.alpha = 0.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        // if we've onboarded, the base controller should load the timeline
        let users = IGIUser.allObjects()
        if users.count == 0 {
            performSegueWithIdentifier("onboardTitleSegue", sender: self)
        } else {
            if let user = users.firstObject() as? IGIUser {
                if user.goals.count == 0 {
                    performSegueWithIdentifier("onboardTitleSegue", sender: self)
                } else {
                    loadTimelineView()
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "timelineSegue" {
            if let vc = segue.destinationViewController as? IGITimelineViewController {
                vc.shouldPlayIntroduction = shouldPlayIntroduction
            }
        }
    }
    
    @IBAction func unwindToBaseController(sender: UIStoryboardSegue) {
        shouldPlayIntroduction = true // just completed a new entry, fancy reveal time
    
        NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "loadTimelineView", userInfo: nil, repeats: false)
    }
    
    func loadTimelineView() {
        UIView.animateWithDuration(1.0, animations: {
            self.backgroundImage.alpha = 0.0
            }, completion: { (done) in
                self.backgroundImage.image = UIImage(named: "background5")
                
                UIView.animateWithDuration(0.5, animations: {
                    self.backgroundImage.alpha = 1.0
                })
        })
        
        navigationController?.dismissViewControllerAnimated(false, completion: nil)
        
        performSegueWithIdentifier("timelineSegue", sender: self)
    }
    
    // MARK: Notification
    
    func genderChanged(notification: NSNotification) {
        if let obj = notification.object as? String {
            if obj == "female" {
                let startColor = UIColor(red:0.19, green:0.12, blue:0.53, alpha:1)
                let endColor = UIColor(red:1, green:0.69, blue:0.47, alpha:1)
                temporaryGradient?.updateGradientLayer(startColor, endColor: endColor)
            } else if obj == "male" {
                let startColor = UIColor(red:0.11, green:0.48, blue:0.72, alpha:1)
                let endColor = UIColor(red:0.87, green:0.85, blue:0.96, alpha:1)
                temporaryGradient?.updateGradientLayer(startColor, endColor: endColor)
            }
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "crossFadeNewColor", userInfo: nil, repeats: false)
    }
    
    func crossFadeNewColor() {
        UIView.animateWithDuration(0.5, animations: {
            self.currentGradient?.alpha = 0.0
            self.temporaryGradient?.alpha = 0.8
        }, completion: { (done) in
            println()
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "flipCurrentGradient", userInfo: nil, repeats: false)
        })
    }
    
    func flipCurrentGradient() {
        if let cgradient = currentGradient {
            if let tgradient = temporaryGradient {
                // Colors must be there!
                cgradient.updateGradientLayer(tgradient.startColor!, endColor: tgradient.endColor!)
            }
        }
        
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "revealPrimaryGradientLayer", userInfo: nil, repeats: false)
    }
    
    func revealPrimaryGradientLayer() {
        currentGradient?.alpha = 0.8
        temporaryGradient?.alpha = 0.0
    }
}
