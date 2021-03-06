//
//  IGITextField.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Spring
import pop

class IGITextField: SpringTextField {

    @IBOutlet weak var layoutConstraint: NSLayoutConstraint?
    
    weak var viewToReveal: UIView?
    
    var tempDismissValue: Int32?
    var separator: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        UITextField.appearance().tintColor = UIColor.whiteColor()
        
        separator = UILabel(frame: CGRectMake(0, frame.size.height - 2, frame.size.width, 2))
        separator?.backgroundColor = UIColor.whiteColor()
        addSubview(separator!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        separator?.frame = CGRectMake(0, frame.size.height - 2, frame.size.width, 2)
    }
    
    // MARK: Reveal
    
    func revealView(#constant: Int) {
        var anim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        anim.springBounciness = 2
        anim.springSpeed = 1
        anim.toValue = NSNumber(int: Int32(constant))
        layoutConstraint?.pop_addAnimation(anim, forKey: "movement")
        
        UIView.animateWithDuration(1.0, animations: {
            self.alpha = 1.0
        })
    }
    
    func revealViewWithDelay(#constant: Int, delay: CFTimeInterval) {
        var anim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        anim.beginTime = CACurrentMediaTime() + delay
        anim.springBounciness = 2
        anim.springSpeed = 1
        anim.toValue = NSNumber(int: Int32(constant))
        anim.name = "reveal-delay"
        anim.delegate = self
        layoutConstraint?.pop_addAnimation(anim, forKey: "movement")
    }
    
    func revealViewWithDelay(#constant: Int, delay: CFTimeInterval, view: UIView) {
        // reveal this view after the animation plays
        viewToReveal = view
        
        var anim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        anim.beginTime = CACurrentMediaTime() + delay
        anim.springBounciness = 2
        anim.springSpeed = 1
        anim.toValue = NSNumber(int: Int32(constant))
        anim.name = "reveal-delay"
        anim.delegate = self
        layoutConstraint?.pop_addAnimation(anim, forKey: "movement")
    }
    
    // MARK: Dismiss
    
    func dismissView(#constant: Int) {
        tempDismissValue = Int32(constant)
        
        var anim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        anim.springBounciness = 2
        anim.springSpeed = 1
        anim.toValue = NSNumber(int: Int32(layoutConstraint!.constant + 10))
        anim.name = "dismiss"
        anim.delegate = self
        layoutConstraint?.pop_addAnimation(anim, forKey: "movement")
    }
    
    func dismissViewWithDelay(#constant: Int, delay: CFTimeInterval) {
        tempDismissValue = Int32(constant)
        
        var anim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        anim.beginTime = CACurrentMediaTime() + delay
        anim.springBounciness = 2
        anim.springSpeed = 1
        anim.toValue = NSNumber(int: Int32(constant))
        anim.name = "dismiss-delay"
        anim.delegate = self
        layoutConstraint?.pop_addAnimation(anim, forKey: "movement")
    }
    
    // MARK: POP Delegate
    
    func pop_animationDidStart(anim: POPAnimation!) {
        if anim.name == "reveal-delay" {
            UIView.animateWithDuration(0.5, animations: {
                if let inputView = self.viewToReveal {
                    inputView.alpha = 1.0
                } else {
                    self.alpha = 1.0
                }
            })
        }
    }
    
    func pop_animationDidReachToValue(anim: POPAnimation!) {
        if anim.name == "dismiss" {
            var anim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            anim.springBounciness = 2
            anim.springSpeed = 1
            anim.toValue = NSNumber(int: tempDismissValue!) // should not be nil!
            layoutConstraint?.pop_addAnimation(anim, forKey: "movement")
            
            UIView.animateWithDuration(1.0, animations: {
                self.alpha = 0.0
            })
        }
    }
}
