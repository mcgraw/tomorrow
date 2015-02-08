//
//  IGITimelineNodeView.swift
//  Tomorrow
//
//  Created by David McGraw on 2/7/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

enum IGINodeStatus {
    case Task,          // default node state, just show a single task label
         CompletedDay,  // day completed will only toggle the headline w/ tasks
         Completed,     // show task label, along with a date + motivation
         Failed,
         AllTasks,
         Tip,           // friendly nudge for a tip
         Review,        // friendly nudge for an app review
         PlanTomorrow   // plan tasks for tomorrow!
}

let kStatusTaskColor = UIColor(red: 66.0/255.0, green: 110.0/255.0, blue: 173.0/255.0, alpha: 1.0)
let kStatusCompletedDayColor = UIColor(red: 66.0/255.0, green: 173.0/255.0, blue: 94.0/255.0, alpha: 1.0)
let kStatusCompletedColor = UIColor(red: 66.0/255.0, green: 173.0/255.0, blue: 94.0/255.0, alpha: 1.0)
let kStatusFailedColor = UIColor(red: 173.0/255.0, green: 66.0/255.0, blue: 66.0/255.0, alpha: 1.0)
let kStatusTipColor = UIColor(red: 172.0/255.0, green: 173.0/255.0, blue: 66.0/255.0, alpha: 1.0)
let kStatusReviewColor = UIColor(red: 127.0/255.0, green: 66.0/255.0, blue: 173.0/255.0, alpha: 1.0)
let kStatusPlanTomorrowColor = UIColor.clearColor()

// TODO: should show 'Streak: 4 days' on the top right corner

class IGITimelineNodeView: UIView, POPAnimationDelegate {
    
    // Each node will have a line, node, task headline, and a node icon
    var line: UIView = UIView()
    var node: UIView = UIView()
    var nodeIcon: UIImageView = UIImageView()
    var headline: UILabel = UILabel()
    
    // Gestures
    var iconTapGesture: UITapGestureRecognizer?
    
    // A node may or may not have any of these
    var upperSubMessage: UILabel?
    var lowerSubMessage: UILabel?
    
    var nodeStatus: IGINodeStatus = .PlanTomorrow
    
    var taskFirstRevealAnimation = true
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeBaseLayoutStyle()
        
        // for top & bottom nodes
        line.layer.cornerRadius = 1
        line.layer.masksToBounds = true
        
        
        // Task Layout
//        shrinkAnimationForNode()
        
//        headline.text = "Write Chapter 5"
        
        
        
        // Completed Day
//        let headlineOriginX = node.frame.origin.x + node.frame.size.width + 10
//        let datePositionY = headline.frame.origin.y - 25
//        upperSubMessage = UILabel(frame: CGRectMake(headlineOriginX, datePositionY, 320, 20))
//        upperSubMessage!.textColor = UIColor.whiteColor()
//        upperSubMessage!.text = "January 23rd, 2015"
//        upperSubMessage!.font = UIFont(name: "AvenirNext-UltraLight", size: 16)
//        addSubview(upperSubMessage!)
//        
//        var image = UIImage(named: "checkmark")
//        node.backgroundColor = kStatusCompletedDayColor
//        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//        nodeIcon.image = image
//    
//        headline.text = "Tasks Completed"
//        headline.alpha = 1.0
//        lowerSubMessage?.alpha = 1.0
//        lowerSubMessage?.text = IGILoremIpsum.randomMotivationPhrase()
        
        // Tip
//        var image = UIImage(named: "tip")
//        node.backgroundColor = kStatusTipColor
//        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//        nodeIcon.image = image
//        
//        headline.text = "Enjoying the app?"
//        lowerSubMessage?.text = "Tap to support the development of Tomorrow and other apps like this!"
//        lowerSubMessage?.frame = CGRectMake(lowerSubMessage!.frame.origin.x, lowerSubMessage!.frame.origin.y, lowerSubMessage!.frame.size.width, 50)
//    
//        line.frame = CGRectMake(line.frame.origin.x, line.frame.origin.y, line.frame.size.width, bounds.size.height + 25)
//        line.alpha = 1.0
//        node.alpha = 1.0
//        headline.alpha = 1.0
//        lowerSubMessage?.alpha = 1.0
        
        // Review
//        var image = UIImage(named: "rate")
//        node.backgroundColor = kStatusReviewColor
//        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//        nodeIcon.image = image
//
//        headline.text = "Review Tomorrow!"
//        lowerSubMessage?.text = "Consider reviewing Tomorrow on iTunes! It's easy and helps a lot!"
//        lowerSubMessage?.frame = CGRectMake(lowerSubMessage!.frame.origin.x, lowerSubMessage!.frame.origin.y, lowerSubMessage!.frame.size.width, 50)
//
//        line.frame = CGRectMake(line.frame.origin.x, line.frame.origin.y, line.frame.size.width, bounds.size.height + 25)
//        line.alpha = 1.0
//        node.alpha = 1.0
//        headline.alpha = 1.0
//        lowerSubMessage?.alpha = 1.0
        
        // Plan
//        line.frame = CGRectMake(line.frame.origin.x, line.frame.origin.y, line.frame.size.width, bounds.size.height / 2 - node.bounds.size.height / 2 + 25)
//        nodeIcon.alpha = 0
//        node.backgroundColor = kStatusPlanTomorrowColor
//
//        let logoT = UILabel(frame: CGRectMake(4, 7, node.bounds.width - 8, node.bounds.height - 11))
//        logoT.text = "T"
//        logoT.textColor = UIColor.whiteColor()
//        logoT.textAlignment = NSTextAlignment.Center
//        logoT.font = UIFont(name: "AvenirNext-Medium", size: 30)
//        node.addSubview(logoT)
//        
//        let planView = FBShimmeringView(frame: headline.frame)
//        let plan = UILabel(frame: planView.frame)
//        plan.text = "Let's Plan Tomorrow!"
//        plan.font = UIFont(name: "AvenirNext-UltraLight", size: 30)
//        plan.textColor = UIColor.whiteColor()
//        addSubview(planView)
//        planView.contentView = plan
//        planView.shimmering = true
        
    }
    
    init(state: IGINodeStatus, withTask: NSString) {
        super.init()
    }
    
    // MARK: Animation
    
    func playTimelineAnimation() {
        let anim = POPBasicAnimation(propertyNamed: kPOPViewFrame)
        anim.toValue = NSValue(CGRect: CGRectMake(line.frame.origin.x, line.frame.origin.y, line.frame.size.width, bounds.size.height/2 + 25))
        anim.duration = 0.5
        anim.delegate = self
        anim.name = "timeline-animate"
        line.pop_addAnimation(anim, forKey: anim.name)
    }
    
    func resetTimelineNode() {
        headline.alpha = 0
        upperSubMessage?.alpha = 0
        lowerSubMessage?.alpha = 0
        
        line.frame = CGRectMake(46, -25, line.frame.size.width, 0)
        node.center = CGPointMake(line.center.x, bounds.size.height/2)
        
        shrinkAnimationForNode()
        
        let anim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        anim.toValue = NSValue(CGPoint: CGPointMake(2.0, 2.0))
        headline.layer.pop_addAnimation(anim, forKey: "headline-scale-up")
    }
    
    // MARK: Private Zone
    
    private func finishTimelineAnimation() {
        let anim = POPBasicAnimation(propertyNamed: kPOPViewFrame)
        anim.toValue = NSValue(CGRect: CGRectMake(line.frame.origin.x, line.frame.origin.y, line.frame.size.width, bounds.size.height))
        anim.duration = 0.5
        line.pop_addAnimation(anim, forKey: anim.name)
    }
    
    private func shrinkAnimationForNode() {
        let anim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        anim.toValue = NSValue(CGPoint: CGPointMake(0.05, 0.05))
        node.layer.pop_addAnimation(anim, forKey: "shrink-node")
        
        UIView.animateWithDuration(0.225, animations: {
            self.node.alpha = 0
        })
    }
    
    private func revealAnimationForNodeAndText() {
        let nodeAnim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        nodeAnim.toValue = NSValue(CGPoint: CGPointMake(1.2, 1.2))
        nodeAnim.delegate = self
        nodeAnim.name = "reveal-node"
        node.layer.pop_addAnimation(nodeAnim, forKey: nodeAnim.name)
        
        let headlineAnim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        headlineAnim.toValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
        headlineAnim.springBounciness = 14
        headlineAnim.springSpeed = 10
        headlineAnim.delegate = self
        headlineAnim.name = "headline-display"
        headline.layer.pop_addAnimation(headlineAnim, forKey: headlineAnim.name)
        
        UIView.animateWithDuration(0.225, animations: {
            self.node.alpha = 1
        })
        
        UIView.animateWithDuration(1.2, animations: {
            self.upperSubMessage?.alpha = 1
            self.lowerSubMessage?.alpha = 1
        })
    }
    
    // MARK: POP Delegate
    
    func pop_animationDidReachToValue(anim: POPAnimation!) {
        if anim.name == "timeline-animate" {
            // reveal the node, begin moving the rest of the way
            revealAnimationForNodeAndText()
        }
        else if anim.name == "headline-display" {
            // text displayed, conintue timeline node
            finishTimelineAnimation()
        }
        else if anim.name == "reveal-node" {
            // we over-expanded, so restore to 1x
            let anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
            anim.toValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
            node.layer.pop_addAnimation(anim, forKey: anim.name)
        }
    }
    
    func pop_animationDidStart(anim: POPAnimation!) {
        if anim.name == "headline-display"{
            UIView.animateWithDuration(0.225, animations: {
                
                if self.nodeStatus == .Completed {
                    self.headline.alpha = 0.5
                } else {
                    self.headline.alpha = 1
                }
            })
        }
    }
    
    // MARK: Touch
    
    func iconTapGesturePressed(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            if nodeStatus == .Task {
                nodeStatus = .Completed
                toggleAnimationForTask()
            } else if nodeStatus == .Completed {
                nodeStatus = .Task
                toggleAnimationForTask()
            } else if nodeStatus == .CompletedDay {
                nodeStatus = .AllTasks
                toggleAnimationForCompletedDay()
            } else if nodeStatus == .AllTasks {
                nodeStatus = .CompletedDay
                toggleAnimationForCompletedDay()
            }
        }
    }
    
    private func toggleAnimationForTask() {
        if nodeStatus == .Completed || nodeStatus == .Task {
            // hide icon
            let anim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
            anim.toValue = NSValue(CGPoint: CGPointMake(0.05, 0.05))
            nodeIcon.layer.pop_addAnimation(anim, forKey: "shrink-icon")
            
            let revealAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
            revealAnimation.toValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
            revealAnimation.springBounciness = 16
            revealAnimation.springSpeed = 10
            revealAnimation.beginTime = CACurrentMediaTime() + 0.3
            nodeIcon.layer.pop_addAnimation(revealAnimation, forKey: revealAnimation.name)
            
            // switch & reveal new icon
            var image: UIImage?
            if nodeStatus == .Completed {
                lowerSubMessage?.text = IGILoremIpsum.randomMotivationPhrase()
                image = UIImage(named: "checkmark")
                node.backgroundColor = kStatusCompletedColor
                
                if let message = lowerSubMessage {
                    let originalSubMessageCenter = message.center
                    message.center = CGPointMake(message.center.x, message.center.y - 10)
                    
                    let anim = POPBasicAnimation(propertyNamed: kPOPViewCenter)
                    anim.toValue = NSValue(CGPoint: originalSubMessageCenter)
                    message.pop_addAnimation(anim, forKey: "slide-down-sub-message")
                }
            } else {
                image = UIImage(named: "waiting")
                node.backgroundColor = kStatusTaskColor
            }
            
            image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            nodeIcon.image = image
            
            UIView.animateWithDuration(0.225, animations: {
                if self.nodeStatus == .Completed {
                    self.headline.alpha = 0.25
                    self.lowerSubMessage?.alpha = 1.0
                } else {
                    self.headline.alpha = 1.0
                    self.lowerSubMessage?.alpha = 0.0
                }
            })
        }
    }
    
    private func toggleAnimationForCompletedDay() {
        if nodeStatus == .AllTasks || nodeStatus == .CompletedDay {
            UIView.animateWithDuration(0.225, animations: {
                self.headline.alpha = 0.0
                self.upperSubMessage?.alpha = 0.0
                self.lowerSubMessage?.alpha = 0.0
            }, completion: { (done) in
                if self.nodeStatus == .AllTasks {
                    self.headline.font = UIFont(name: "AvenirNext-Regular", size: 16)
                    self.upperSubMessage?.font = UIFont(name: "AvenirNext-Regular", size: 16)
                    self.lowerSubMessage?.font = UIFont(name: "AvenirNext-Bold", size: 16)
                    
                    // signal which tasks failed
                    self.lowerSubMessage?.textColor = kStatusFailedColor
                    
                    // update text with tasks
                    self.upperSubMessage?.text = "Write chapter 5"
                    self.headline.text = "Walk dogs"
                    self.lowerSubMessage?.text = "Enjoy a glass of wine"
                } else {
                    self.headline.font = UIFont(name: "AvenirNext-Regular", size: 30)
                    self.upperSubMessage?.font = UIFont(name: "AvenirNext-UltraLight", size: 16)
                    self.lowerSubMessage?.font = UIFont(name: "AvenirNext-UltraLight", size: 16)
                    
                    // update colors
                    self.upperSubMessage?.textColor = UIColor.whiteColor()
                    self.headline.textColor = UIColor.whiteColor()
                    self.lowerSubMessage?.textColor = UIColor.whiteColor()
                    
                    // update text with tasks
                    self.upperSubMessage?.text = "January 23rd, 2015"
                    self.headline.text = "Tasks Completed"
                    self.lowerSubMessage?.text = IGILoremIpsum.randomMotivationPhrase()
                }
                
                UIView.animateWithDuration(0.225, animations: {
                    self.headline.alpha = 1.0
                    self.upperSubMessage?.alpha = 1.0
                    self.lowerSubMessage?.alpha = 1.0
                })
            })
        }
    }
    
    // MARK: Initialize
    
    private func initializeBaseLayoutStyle() {
        backgroundColor = UIColor.clearColor()
        
        line.backgroundColor = UIColor.whiteColor()
        
        node.frame = CGRectMake(0, 0, 40, 40)
        node.backgroundColor = UIColor(red: 66.0/255.0, green: 110.0/255.0, blue: 173.0/255.0, alpha: 1.0)
        node.layer.cornerRadius = self.node.bounds.size.width/2
        node.layer.masksToBounds = true
        node.layer.borderColor = UIColor.whiteColor().CGColor
        node.layer.borderWidth = 2
        
        // Initialize the icon for the node
        nodeIcon = UIImageView(frame: CGRectMake(4, 4, node.bounds.width - 8, node.bounds.height - 8))
        nodeIcon.contentMode = UIViewContentMode.ScaleAspectFit
        nodeIcon.tintColor = UIColor.whiteColor()
        var image = UIImage(named: "waiting")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        nodeIcon.image = image
        node.addSubview(nodeIcon)
        
        line.frame = CGRectMake(46, -25, 2, 0)
        node.center = CGPointMake(line.center.x, bounds.size.height/2)
        
        addSubview(line)
        addSubview(node)
        
        // Headline exists for all states
        let headlineOriginX = node.frame.origin.x + node.frame.size.width + 10
        headline = UILabel(frame: CGRectMake(headlineOriginX, node.frame.origin.y, 320, node.bounds.size.height))
        headline.textColor = UIColor.whiteColor()
        headline.text = ""
        headline.numberOfLines = 0
        headline.font = UIFont(name: "AvenirNext-Regular", size: 30)
        headline.alpha = 0
        addSubview(headline)
        
        let subHeadlinePositionY = headline.frame.origin.y + headline.frame.size.height + 5
        lowerSubMessage = UILabel(frame: CGRectMake(headlineOriginX, subHeadlinePositionY, 320, 20))
        lowerSubMessage!.textColor = UIColor.whiteColor()
        lowerSubMessage!.font = UIFont(name: "AvenirNext-UltraLight", size: 16)
        lowerSubMessage!.alpha = 0
        lowerSubMessage!.numberOfLines = 0
        addSubview(lowerSubMessage!)
        
        // Gestures
        iconTapGesture = UITapGestureRecognizer(target: self, action: "iconTapGesturePressed:")
        node.addGestureRecognizer(iconTapGesture!)
    }
}
