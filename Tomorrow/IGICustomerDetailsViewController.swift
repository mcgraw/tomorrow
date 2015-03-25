//
//  IGICustomerDetailsViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Realm

enum IGIGender: Int {
    case Unspecified, Male, Female
}

class IGICustomerDetailsViewController: GAITrackedViewController, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var inputField: IGITextField!
    @IBOutlet weak var titleLabel: IGILabel!
    
    var selectedGender: IGIGender = .Unspecified
    var accessoryView: UIView?
    
    var userObject: IGIUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We only want to worry about one user object on the device
        RLMRealm.defaultRealm().beginWriteTransaction()
        let users = IGIUser.allObjects()
        if users.count == 0 {
            userObject = IGIUser()
            userObject?.userId = 1
            IGIUser.createOrUpdateInDefaultRealmWithObject(userObject)
        } else {
            userObject = users[0] as? IGIUser
        }
        RLMRealm.defaultRealm().commitWriteTransaction()
        
        println(RLMRealm.defaultRealm().path)
        
        inputField.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        screenName = "Onboard Name Screen"
        
        view.backgroundColor = UIColor.clearColor()
        
//        addInfoAccessoryView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        playIntroductionAnimation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        inputField.resignFirstResponder()
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
    
    // MARK: Animation
    
    func playIntroductionAnimation() {
        titleLabel.revealView(constant: 50)
        inputField.revealView(constant: 130)
        
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
        
        inputField.dismissViewWithDelay(constant: Int(view.bounds.size.height), delay: 0.4)
        titleLabel.dismissViewWithDelay(constant: Int(view.bounds.size.height), delay: 0.6)
    }
    
    // Text Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        inputField.selectable = false
        
        userObject?.setUserName(name: textField.text)
        
        playDismissAnimation()
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "advanceOnboarding", userInfo: nil, repeats: false)
        return true
    }
    
    func advanceOnboarding() {
        performSegueWithIdentifier("infoSegue", sender: self)
    }
}
