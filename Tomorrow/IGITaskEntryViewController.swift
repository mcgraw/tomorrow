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
    var accessoryView: UIView?
    
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
        
        addInfoAccessoryView()
        
        titleLabel.text = "What is your most important task?"
        
        inputField.becomeFirstResponder()
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "playIntroductionAnimation", userInfo: nil, repeats: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if taskUnderEdit != nil {
            playIntroductionAnimation()
            inputField.becomeFirstResponder()
        }
    }
    
    @IBAction func unwindToTaskEntry(sender: UIStoryboardSegue) {
        // Should not unwind back here without a goal under edit!
        let goalEditing = userObject?.getCurrentGoalUnderEdit()!
        if goalEditing == nil {
            assertionFailure("Don't unwind to edit if no goal is being edited!")
        }
        
        taskUnderEdit = goalEditing?.getCurrentTaskUnderEdit()
        if taskUnderEdit == nil {
            if goalEditing?.tasks.count == 1 {
                status = .Task2
            } else if goalEditing?.tasks.count == 2 {
                status = .Task3
            }
            inputField.text = ""
        } else {
            inputField.text = taskUnderEdit?.getTaskTitle()
            status = .Editing
        }
        
        titleLabel.text = "Edit Task"
    }
    
    func addInfoAccessoryView() {
        accessoryView = UIView()
        accessoryView?.alpha = 0
        accessoryView!.frame = CGRectMake(0, 0, view.frame.width, 50)
        accessoryView!.backgroundColor = UIColor.clearColor()
        
        let info = UIButton(frame: accessoryView!.frame)
        info.setTitle("Skip... no more tasks.", forState: UIControlState.Normal)
        info.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        info.titleLabel?.textAlignment = NSTextAlignment.Center
        info.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
        info.addTarget(self, action: "taskEntryComplete:", forControlEvents: UIControlEvents.TouchUpInside)
        accessoryView!.addSubview(info)
        
        inputField.inputAccessoryView = accessoryView!
    }
    
    func taskEntryComplete(sender: AnyObject) {
        status = .Done
        inputField.resignFirstResponder()
        advanceOnboarding()
    }
    
    // MARK: Animation
    
    func playIntroductionAnimation() {
        titleLabel.revealView(constant: 50)
        inputField.revealView(constant: 170)
        
        if status == .Task2 {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.accessoryView!.alpha = 1.0
            })
        }
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
    
    func isDuplicateInput(input: String) -> Bool {
        let strip = input.trimLeadingAndTrailingWhitespace()
        for item in userGoal!.tasks {
            let task = item as! IGITask
            if task.name == strip.lowercaseString {
                return true
            }
        }
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if isDuplicateInput(textField.text) {
            let alert = UIAlertView(title: "Duplicate Task", message: "Please enter a unique task name", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return true
        }
        
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
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.titleLabel.alpha = 0
                self.inputField.alpha = 0
            })
            performSegueWithIdentifier("taskReviewSegue", sender: self)
        }
        else {
            inputField.text = ""
            
            if status == .Task2 {
                titleLabel.text = "What is your second most important task?"
            } else if status == .Task3 {
                titleLabel.text = "Great! Your final task?"
            }
            resetAndReplay()
        }
    }
}
