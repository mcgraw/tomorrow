//
//  IGITaskEntryViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Realm

enum IGITaskEntryStatus: Int {
    case Task1, Task2, Task3, Done, Editing
}

class IGITaskEntryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: IGILabel!
    @IBOutlet weak var inputField: IGITextField!
    
    var status: IGITaskEntryStatus = .Task1
    
    var userObject: IGIUser?
    var userGoal: IGIGoal?
    
    var taskUnderEdit: IGITask?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
        
        let users = IGIUser.allObjects()
        if users.count > 0 {
            userObject = users[0] as? IGIUser
            
            RLMRealm.defaultRealm().beginWriteTransaction()
            userGoal = IGIGoal()
            userGoal?.getDateAsString()
            userGoal?.user = userObject
            userObject?.goals.addObject(userGoal)
            IGIUser.createOrUpdateInDefaultRealmWithObject(userObject)
            RLMRealm.defaultRealm().commitWriteTransaction()
        } else {
            assertionFailure("Something went wrong! User does not exist so we cannot add taskss!")
        }
        
        inputField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        playIntroductionAnimation()
    }
    
    @IBAction func unwindToTaskEntry(sender: UIStoryboardSegue) {
        // Should not unwind back here without a goal under edit!
        let goalEditing = userObject?.getCurrentGoalUnderEdit()!
        if goalEditing == nil {
            assertionFailure("Don't unwind to edit if no goal is being edited!")
        }
        
        taskUnderEdit = goalEditing?.getCurrentTaskUnderEdit()
        if taskUnderEdit == nil {
            assertionFailure("Don't unwind to edit if a task is not being edited!")
        }
        
        titleLabel.text = "Edit Task"
        inputField.text = taskUnderEdit?.name.capitalizedString
        status = .Editing
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
        if status == .Editing {
            
            if taskUnderEdit?.name.lowercaseString == textField.text.lowercaseString {
                // Nothing changed, move back to the review screen
            } else {
                let goalEditing = userObject?.getCurrentGoalUnderEdit()!
                
                let task = userObject?.createNewTask(name: textField.text)
                task?.goals.addObject(goalEditing)
                goalEditing?.removeTaskAndReplace(taskUnderEdit!, replacement: task!)
                
                // Done
                taskUnderEdit?.edit_needed = false
            }
            status = .Done
        }
        else if status == .Task1 {
            userObject?.addNewTask(name: textField.text)
            status = .Task2
        }
        else if status == .Task2 {
            userObject?.addNewTask(name: textField.text)
            status = .Task3
        }
        else if status == .Task3 {
            userObject?.addNewTask(name: textField.text)
            status = .Done
            inputField.resignFirstResponder()
        }
        IGIUser.createOrUpdateInDefaultRealmWithObject(userObject)
        RLMRealm.defaultRealm().commitWriteTransaction()
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "advanceOnboarding", userInfo: nil, repeats: false)
        return true
    }
    
    func advanceOnboarding() {
        if status == .Done || status == .Editing {
            performSegueWithIdentifier("taskReviewSegue", sender: self)
        }
        else {
            inputField.text = ""
            
            if status == .Task2 {
                titleLabel.text = "Perfect! What else?"
            } else if status == .Task3 {
                titleLabel.text = "Great! Your final task?"
            }
            resetAndReplay()
        }
    }
}
