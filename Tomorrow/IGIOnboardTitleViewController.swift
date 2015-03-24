//
//  IGIOnboardTitleViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import pop

class IGIOnboardTitleViewController: UIViewController {

    @IBOutlet weak var logoIcon: IGIView!
    @IBOutlet weak var logoTitle: IGILabel!
    @IBOutlet weak var continueAction: IGIButton!
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var checkImage: UIImageView!
    
    var hasPlayedAnimation = false
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if hasPlayedAnimation == false {
            hasPlayedAnimation = true
            playIntroductionAnimation()
        }
    }

    @IBAction func continueActionPressed(sender: AnyObject) {
        playDismissAnimation()
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "advanceOnboarding", userInfo: nil, repeats: false)
    }
    
    func advanceOnboarding() {
        performSegueWithIdentifier("pushSegue", sender: self)

    }
    
    // MARK: Animation
    
    func playIntroductionAnimation() {
        logoIcon.revealViewWithDelay(constant: 80, delay: 0.0, view: logoTitle)
        
        continueAction.revealView(constant: 50)
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "showCheck", userInfo: nil, repeats: false)
    }
    
    func showCheck() {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.checkImage.alpha = 0.35
        })
    }
    
    func playDismissAnimation() {
        continueAction.dismissView(constant: -Int(100))
        logoTitle.dismissViewWithDelay(constant: -Int((view.bounds.size.height / 2) + 60), delay: 0.5)
        logoIcon.dismissViewWithDelay(constant: -Int((view.bounds.size.height / 2) + 60), delay: 0.6)
    }
}
