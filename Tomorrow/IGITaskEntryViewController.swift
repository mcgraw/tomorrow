//
//  IGITaskEntryViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

enum IGITaskStatus: Int {
    case Task1, Task2, Task3, Done
}

class IGITaskEntryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: IGILabel!
    @IBOutlet weak var inputField: IGITextField!
    
    var status: IGITaskStatus = .Task1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
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
        
        if status == .Task1 {
            NSUserDefaults.standardUserDefaults().setObject(textField.text, forKey: "task1")
            status = .Task2
        } else if status == .Task2 {
            NSUserDefaults.standardUserDefaults().setObject(textField.text, forKey: "task2")
            status = .Task3
        } else if status == .Task3 {
            NSUserDefaults.standardUserDefaults().setObject(textField.text, forKey: "task3")
            status = .Done
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
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
