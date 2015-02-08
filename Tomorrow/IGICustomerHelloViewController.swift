//
//  IGICustomerHelloViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGICustomerHelloViewController: UIViewController, POPAnimationDelegate {

    @IBOutlet weak var titleLabel: IGILabel!
    
    @IBOutlet weak var message1: IGILabel!
    @IBOutlet weak var message2: IGILabel!
    @IBOutlet weak var message3: IGILabel!
    @IBOutlet weak var message4: IGILabel!
    
    @IBOutlet weak var continueAction: IGIButton!
    
    @IBOutlet weak var topThree: IGILabel!
    
    var userObject: IGIUser?
    var step = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let users = IGIUser.allObjects()
        if users.count > 0 {
            userObject = users[0] as? IGIUser
        } else {
            assertionFailure("No users found!")
        }
    
        // user object should not be nil!
        if userObject!.firstName == "" {
            titleLabel.text = "Hello!"
        } else {
            var name = userObject!.firstName
            titleLabel.text = "Hello, \(name)"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        playIntroductionAnimation()
    }
    
    @IBAction func continueAction(sender: AnyObject) {
        if step == 1 {
            continueAction.dismissView(constant: -100)
            topThree.dismissViewWithDelay(constant: -Int(view.bounds.size.height), delay: 0.5)
            
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "advanceOnboarding", userInfo: nil, repeats: false)
        } else {
            UIView.animateWithDuration(0.225, animations: {
                self.continueAction.alpha = 0.0
            })
            
            playDismissAnimation()
        }
    }
    
    func advanceOnboarding() {
        performSegueWithIdentifier("taskInputSegue", sender: self)
    }
    
    // MARK: Animation
    
    func playIntroductionAnimation() {
        titleLabel.revealView(constant: 50)
 
        var anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.toValue = 1.0
        anim.beginTime = CACurrentMediaTime() + 1.5
        message1.pop_addAnimation(anim, forKey: "alpha")
        
        anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.toValue = 1.0
        anim.beginTime = CACurrentMediaTime() + 2.9
        message2.pop_addAnimation(anim, forKey: "alpha")
        
        anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.toValue = 1.0
        anim.beginTime = CACurrentMediaTime() + 3.4
        message3.pop_addAnimation(anim, forKey: "alpha")
        
        var scale = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        scale.toValue = NSValue(CGPoint: CGPointMake(1.2, 1.2))
        scale.beginTime = CACurrentMediaTime() + 3.4
        scale.name = "scale-up"
        scale.delegate = self
        message3.layer.pop_addAnimation(scale, forKey: "scale-up")
        
        anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.toValue = 1.0
        anim.beginTime = CACurrentMediaTime() + 4.0
        message4.pop_addAnimation(anim, forKey: "alpha")
        
        continueAction.revealViewWithDelay(constant: 50, delay: 4.5)
    }
    
    func playDismissAnimation() {
        var anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.toValue = 0.0
        titleLabel.pop_addAnimation(anim, forKey: "alpha")
        message1.pop_addAnimation(anim, forKey: "alpha")
        message2.pop_addAnimation(anim, forKey: "alpha")
        message3.pop_addAnimation(anim, forKey: "alpha")
        message4.pop_addAnimation(anim, forKey: "alpha")
        
        step++
        NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "playSecondaryAnimation", userInfo: nil, repeats: false)
    }
    
    func playSecondaryAnimation() {
        var anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.toValue = 1.0
        anim.beginTime = CACurrentMediaTime() + 0.5
        topThree.pop_addAnimation(anim, forKey: "alpha")
        
        continueAction.revealViewWithDelay(constant: 50, delay: 0.8)
    }
    
    // MARK: Animation Delegate
    
    func pop_animationDidReachToValue(anim: POPAnimation!) {
        var scale = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        scale.toValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
        scale.springBounciness = 3
        scale.springSpeed = 5
        message3.layer.pop_addAnimation(scale, forKey: "scale-up")
    }
}
