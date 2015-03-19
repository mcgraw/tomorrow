//
//  IGITaskReviewViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Realm
import pop

class IGITaskReviewViewController: UIViewController {

    @IBOutlet weak var titleLabel: IGILabel!
    
    @IBOutlet weak var task1: IGILabel!
    @IBOutlet weak var task2: IGILabel!
    @IBOutlet weak var task3: IGILabel!
    
    @IBOutlet weak var completeAction: IGIButton!
    @IBOutlet weak var info: IGILabel!
    
    var userObject: IGIUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.userInteractionEnabled = false
        view.backgroundColor = UIColor.clearColor()
        
        let users = IGIUser.allObjects()
        if users.count > 0 {
            userObject = users[0] as? IGIUser
        } else {
            assertionFailure("Something went wrong! User does not exist so we cannot add taskss!")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let goal = userObject?.getCurrentGoalUnderEdit() {
            var index = 0
            let count = goal.tasks.count
            for item in goal.tasks {
                var task = item as! IGITask
                let title = task.name.capitalizedString
                if count == 3 {
                    if index == 0 {
                        task1?.text = title
                    } else if index == 1 {
                        task2?.text = title
                    } else if index == 2 {
                        task3?.text = title
                    }
                } else if count == 2 {
                    if index == 0 {
                        task1?.text = title
                    } else if index == 1 {
                        task2?.text = title
                    }
                } else if count == 1 {
                    task2?.text = title
                }
                index++
            }
        } else {
            assertionFailure("A goal should exist! No goal with edit_completed == false found.")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        playIntroductionAnimation()
    }
    
    @IBAction func completeActionPressed(sender: AnyObject) {
        UIView.animateWithDuration(0.4, animations: {
            self.titleLabel.alpha = 0.0
            self.completeAction.alpha = 0.0
            self.info.alpha = 0.0
        })
        
        // We're done editing this goal
        if let goal = userObject?.getCurrentGoalUnderEdit() {
            RLMRealm.defaultRealm().beginWriteTransaction()
            goal.edit_completed = true
            RLMRealm.defaultRealm().commitWriteTransaction()
        }
        
        let goals = IGIGoal.allObjects()
        println("Goal count is \(goals.count)")
        if goals.count > 1 {
            UIView.animateWithDuration(0.5, animations: {
                self.task1.alpha = 0
                self.task2.alpha = 0
                self.task3.alpha = 0
            }, completion: { (done) in
                self.transitionToTimeline()
            })
        } else {
            // Remove spacing constraints so they don't interfere with our animation
        
            // Jump the tasks before transitioning to the timeline
            task1.jumpAnimationToConstant(-300, delayStart: 0)
            task2.jumpAnimationToConstant(-300, delayStart: 0.3)
            task3.jumpAnimationToConstant(-300, delayStart: 0.6)
        
            NSTimer.scheduledTimerWithTimeInterval(1.2, target: self, selector: "transitionToTimeline", userInfo: nil, repeats: false)
        }
    }
    
    @IBAction func taskEditPressed(sender: AnyObject) {
        var tag: Int = (sender.tag - 1000) - 1
        userObject!.setTaskNeedsEdit(index: UInt(tag))
        
        UIView.animateWithDuration(0.3, animations: {
            self.titleLabel.alpha = 0.0
            self.task1.alpha = 0.0
            self.task2.alpha = 0.0
            self.task3.alpha = 0.0
            self.completeAction.alpha = 0.0
            self.info.alpha = 0.0
        }, completion: { (done) in
            println("") // sigh..
            
            self.performSegueWithIdentifier("unwindToTaskEdit", sender: self)
        })
    }
    
    func transitionToTimeline() {
        let total = userObject!.totalUserGoals()
        if total == 1 {
            performSegueWithIdentifier("completeTaskSegue", sender: self)
        } else {
            performSegueWithIdentifier("unwindToTimeline", sender: self)
        }
    }
    
    // MARK: Animation
    
    func playIntroductionAnimation() {
        titleLabel.revealView(constant: 50)
        
        var anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.toValue = 1.0
        anim.beginTime = CACurrentMediaTime() + 1.0
        task1.pop_addAnimation(anim, forKey: "alpha")
        
        anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.toValue = 1.0
        anim.beginTime = CACurrentMediaTime() + 2.0
        task2.pop_addAnimation(anim, forKey: "alpha")
        
        anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.toValue = 1.0
        anim.beginTime = CACurrentMediaTime() + 3.0
        task3.pop_addAnimation(anim, forKey: "alpha")
        
        completeAction.revealViewWithDelay(constant: 50, delay: 3.5)
        info.revealViewWithDelay(constant: 25, delay: 3.8)
        
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "unlockView", userInfo: nil, repeats: false)
    }
    
    func unlockView() {
        view.userInteractionEnabled = true
    }
}
   