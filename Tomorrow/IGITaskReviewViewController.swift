//
//  IGITaskReviewViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGITaskReviewViewController: UIViewController {

    @IBOutlet weak var titleLabel: IGILabel!
    
    @IBOutlet weak var task1: IGIButton!
    @IBOutlet weak var task2: IGIButton!
    @IBOutlet weak var task3: IGIButton!
    
    @IBOutlet weak var completeAction: IGIButton!
    @IBOutlet weak var info: IGILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: replace with model
        task1.setTitle(NSUserDefaults.standardUserDefaults().objectForKey("task1") as String!, forState: UIControlState.Normal)
        task2.setTitle(NSUserDefaults.standardUserDefaults().objectForKey("task2") as String!, forState: UIControlState.Normal)
        task3.setTitle(NSUserDefaults.standardUserDefaults().objectForKey("task3") as String!, forState: UIControlState.Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
                
        playIntroductionAnimation()
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
    }
    
    func playDismissAnimation() {
//        inputField.dismissViewWithDelay(constant: Int(view.bounds.size.height), delay: 0.4)
        titleLabel.dismissViewWithDelay(constant: Int(view.bounds.size.height), delay: 0.6)
    }
    
}
   