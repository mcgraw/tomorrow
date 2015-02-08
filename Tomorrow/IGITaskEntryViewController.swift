//
//  IGITaskEntryViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

enum IGITaskEntryStatus: Int {
    case Task1, Task2, Task3, Done
}

class IGITaskEntryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: IGILabel!
    @IBOutlet weak var inputField: IGITextField!
    
    var status: IGITaskEntryStatus = .Task1
    
    var userObject: IGIUser?
    var userGoal: IGIGoal?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
        
        let users = IGIUser.allObjects()
        if users.count > 0 {
            userObject = users[0] as? IGIUser
            
            RLMRealm.defaultRealm().beginWriteTransaction()
            userGoal = IGIGoal()
            userGoal?.user = userObject
            userObject?.goals.addObject(userGoal)
            IGIUser.createOrUpdateInDefaultRealmWithObject(userObject)
            RLMRealm.defaultRealm().commitWriteTransaction()
        } else {
            assertionFailure("Something went wrong! User does not exist so we cannot add taskss!")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        inputField.becomeFirstResponder()
        
        playIntroductionAnimation()
    }
    
    
    // MARK: Animation
    
    func playIntroductionAnimation() {
        titleLabel.revealView(constant: 50)
        inputField.revealView(constant: 170)
    }
    
    func playDismissAnimation() {
        inputField.dismissViewWithDelay(constant: Int(view.bounds.size.height), delay: 0.4)
        titleLabel.dismissViewWithDelay(constant: Int(view.bounds.size.height), delay: 0.6)
    }
    
    func resetAndReplay() {
        view.setNeedsUpdateConstraints()
        titleLabel.layoutConstraint?.constant = 60
        inputField.layoutConstraint?.constant = 180
        view.layoutIfNeeded()
        
        playIntroductionAnimation()
    }
    
    // Text Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        playDismissAnimation()
        
        RLMRealm.defaultRealm().beginWriteTransaction()
        if status == .Task1 {
            let task = IGITask()
            task.name = textField.text
            userGoal?.tasks.addObject(task)
            status = .Task2
        } else if status == .Task2 {
            let task = IGITask()
            task.name = textField.text
            userGoal?.tasks.addObject(task)
            status = .Task3
        } else if status == .Task3 {
            let task = IGITask()
            task.name = textField.text
            userGoal?.tasks.addObject(task)
            status = .Done
        }
        RLMRealm.defaultRealm().commitWriteTransaction()
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "advanceOnboarding", userInfo: nil, repeats: false)
        return true
    }
    
    func advanceOnboarding() {
        if status == .Done {
            performSegueWithIdentifier("taskReviewSegue", sender: self)
        } else {
            inputField.text = ""
            
            if status == .Task2 {
                titleLabel.text = "Perfect! What's #2?"
            } else if status == .Task3 {
                titleLabel.text = "Great! And your final task?"
            }
            resetAndReplay()
        }
    }
}
