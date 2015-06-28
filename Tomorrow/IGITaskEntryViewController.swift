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

class IGITaskEntryViewController: GAITrackedViewController, UIAlertViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: IGILabel!
    @IBOutlet weak var inputField: IGITextField!
    @IBOutlet weak var cancelAction: IGIButton!
    
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
            IGIUser.createOrUpdateInDefaultRealmWithValue(userObject)
            RLMRealm.defaultRealm().commitWriteTransaction()
        } else {
            assertionFailure("Something went wrong! User does not exist so we cannot add taskss!")
        }
        
        addInfoAccessoryView()
        
        titleLabel.text = "What is your most important task?"
        
        inputField.becomeFirstResponder()
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "playIntroductionAnimation", userInfo: nil, repeats: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let total = userObject!.totalUserGoals()
        if (taskUnderEdit != nil) || total > 1 {
            cancelAction.hidden = false;
        } else {
            cancelAction.hidden = true;
        }
        
        screenName = "Task Entry Screen"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        playIntroductionAnimation()
        inputField.becomeFirstResponder()
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
    
    @IBAction func cancelEntry(sender: AnyObject) {
        if taskUnderEdit != nil {
            playDismissAnimation()
            status = .Done
            
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "advanceOnboarding", userInfo: nil, repeats: false)
        } else {
            inputField.resignFirstResponder()
            let alert = UIAlertView(title: "Are you sure?", message: "This action will return you to the timeline.", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "Yes")
            alert.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            println("Canceled");
        } else {
            playDismissAnimation()
            status = .Done
            
            IGIGoal.cleanInvalidGoals()
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "returnToTimeline", userInfo: nil, repeats: false)
        }
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
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.titleLabel.alpha = 1.0
            self.inputField.alpha = 1.0
        })
        
        let total = userObject!.totalUserGoals()
        if (taskUnderEdit != nil) || total > 1 {
            cancelAction.animation = "fadeIn"
            cancelAction.animate()
        }
        
        titleLabel.animation = "slideUp"
        titleLabel.curve = "easeIn"
        titleLabel.animate()
        
        inputField.animation = "slideUp"
        inputField.curve = "easeIn"
        inputField.animate()
        
        if status == .Task2 {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.accessoryView!.alpha = 1.0
            })
        }
    }
    
    func playDismissAnimation() {
        
        let total = userObject!.totalUserGoals()
        if (taskUnderEdit != nil) || total > 1 {
            cancelAction.animation = "fadeOut"
            cancelAction.animate()
        }
        
        titleLabel.animation = "fall"
        titleLabel.animate()
        
        inputField.animation = "fall"
        inputField.animate()
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.titleLabel.alpha = 0.0
            self.inputField.alpha = 0.0
        })
    }
    
    func resetAndReplay() {
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
    
    func hasChangedOriginalInput(input: String) -> Bool {
        let strip = input.trimLeadingAndTrailingWhitespace().lowercaseString
        if let task = taskUnderEdit?.name where (task == strip) {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if hasChangedOriginalInput(textField.text) && isDuplicateInput(textField.text) {
            let alert = UIAlertView(title: "Duplicate Task", message: "Please enter a unique task name", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return true
        }
        
        if textField.text.length == 0 {
            return false
        }
        
        playDismissAnimation()
        
        RLMRealm.defaultRealm().beginWriteTransaction()
        if status == .Editing {
            
            if taskUnderEdit?.name.lowercaseString == textField.text.lowercaseString {
                // Nothing changed, move back to the review screen
                println("Nothing changed. Continue");
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
        IGIUser.createOrUpdateInDefaultRealmWithValue(userObject)
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
    
    func returnToTimeline() {
        performSegueWithIdentifier("unwindToTimeline", sender: self)
    }
}
