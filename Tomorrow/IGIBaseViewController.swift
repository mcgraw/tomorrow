//
//  IGIBaseViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGIBaseViewController: UIViewController {
    
    @IBOutlet weak var currentGradient: IGIGradientView!
    @IBOutlet weak var temporaryGradient: IGIGradientView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "genderChanged:", name: "didChangeGender", object: nil)
        
        let startColor = UIColor(red:0.19, green:0.12, blue:0.53, alpha:1)
        let endColor = UIColor(red:0.52, green:0.8, blue:1, alpha:1)
        currentGradient.updateGradientLayer(startColor, endColor: endColor)
        temporaryGradient.alpha = 0.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        performSegueWithIdentifier("onboardTitleSegue", sender: self)
    }
    
    // MARK: Notification
    
    func genderChanged(notification: NSNotification) {
        let obj = notification.object as String
        
        if obj == "female" {
            let startColor = UIColor(red:0.19, green:0.12, blue:0.53, alpha:1)
            let endColor = UIColor(red:1, green:0.69, blue:0.47, alpha:1)
            temporaryGradient.updateGradientLayer(startColor, endColor: endColor)
        } else if obj == "male" {
            let startColor = UIColor(red:0.11, green:0.48, blue:0.72, alpha:1)
            let endColor = UIColor(red:0.87, green:0.85, blue:0.96, alpha:1)
            temporaryGradient.updateGradientLayer(startColor, endColor: endColor)
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "crossFadeNewColor", userInfo: nil, repeats: false)
    }
    
    func crossFadeNewColor() {
        UIView.animateWithDuration(0.5, animations: {
            self.currentGradient.alpha = 0.0
            self.temporaryGradient.alpha = 0.8
        }, completion: { (done) in
            println()
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "flipCurrentGradient", userInfo: nil, repeats: false)
        })
    }
    
    func flipCurrentGradient() {
        currentGradient.updateGradientLayer(temporaryGradient.startColor!, endColor: temporaryGradient.endColor!)
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "revealPrimaryGradientLayer", userInfo: nil, repeats: false)
    }
    
    func revealPrimaryGradientLayer() {
        currentGradient.alpha = 0.8
        temporaryGradient.alpha = 0.0
    }
}
