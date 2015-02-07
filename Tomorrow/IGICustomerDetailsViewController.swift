//
//  IGICustomerDetailsViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

enum IGIGender: Int {
    case Unspecified, Male, Female
}

class IGICustomerDetailsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputField: IGITextField!
    @IBOutlet weak var maleAction: IGIButton!
    @IBOutlet weak var femaleAction: IGIButton!
    @IBOutlet weak var titleLabel: IGILabel!
    
    var selectedGender: IGIGender = .Unspecified
    var accessoryView: UIView?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = UIColor.clearColor()
        
        maleAction.addRoundedBorder()
        femaleAction.addRoundedBorder()
        
        addInfoAccessoryView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        inputField.becomeFirstResponder()
        
        playIntroductionAnimation()
    }
    
    func addInfoAccessoryView() {
        accessoryView = UIView()
        accessoryView?.alpha = 0
        accessoryView!.frame = CGRectMake(0, 0, view.frame.width, 50)
        accessoryView!.backgroundColor = UIColor.clearColor()
        
        let info = UIButton(frame: accessoryView!.frame)
        info.setTitle("Why is Tomorrow asking for this?", forState: UIControlState.Normal)
        info.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        info.titleLabel?.textAlignment = NSTextAlignment.Center
        info.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
        info.addTarget(self, action: "displayInfo", forControlEvents: UIControlEvents.TouchUpInside)
        accessoryView!.addSubview(info)
        
        inputField.inputAccessoryView = accessoryView!
    }
    
    func displayInfo() {
        let alert = UIAlertView(title: nil, message: "To better personalize Tomorrow. This information is never uploaded or shared anywhere.", delegate: self, cancelButtonTitle: "Got it!")
        alert.show()
    }
    
    @IBAction func toggleMaleAction(sender: AnyObject) {
        maleAction.updateColor(UIColor(red:0.18, green:0.67, blue:0.82, alpha:1), fill: UIColor(red:0.18, green:0.67, blue:0.82, alpha:0.2))
        femaleAction.updateColor(UIColor.whiteColor(), fill: UIColor.clearColor())
        selectedGender = .Female
        
        NSNotificationCenter.defaultCenter().postNotificationName("didChangeGender", object: "male")
    }
    
    @IBAction func toggleFemaleAction(sender: AnyObject) {
        maleAction.updateColor(UIColor.whiteColor(), fill: UIColor.clearColor())
        femaleAction.updateColor(UIColor(red:0.82, green:0.18, blue:0.73, alpha:1), fill: UIColor(red:0.82, green:0.18, blue:0.73, alpha:0.2))
        selectedGender = .Female
        
        NSNotificationCenter.defaultCenter().postNotificationName("didChangeGender", object: "female")
    }
    
    // MARK: Animation
    
    func playIntroductionAnimation() {
        titleLabel.revealView(constant: 50)
        inputField.revealView(constant: 130)
        maleAction.revealView(constant: 35)
        femaleAction.revealView(constant: 35)
        
        UIView.animateWithDuration(0.5, animations: {
            println()
            self.accessoryView?.alpha = 1.0
        })
    }
    
    func playDismissAnimation() {
        UIView.animateWithDuration(0.5, animations: {
            println()
            self.accessoryView?.alpha = 0.0
        })
        
        femaleAction.dismissView(constant: Int(view.bounds.size.height / 2))
        maleAction.dismissView(constant: Int(view.bounds.size.height / 2))
        
        inputField.dismissViewWithDelay(constant: Int(view.bounds.size.height), delay: 0.4)
        titleLabel.dismissViewWithDelay(constant: Int(view.bounds.size.height), delay: 0.6)
    }
    
    // Text Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        inputField.enabled = false
        
        NSUserDefaults.standardUserDefaults().setObject(textField.text, forKey: "name")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        playDismissAnimation()
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "advanceOnboarding", userInfo: nil, repeats: false)
        return true
    }
    
    func advanceOnboarding() {
        performSegueWithIdentifier("infoSegue", sender: self)
    }
}
