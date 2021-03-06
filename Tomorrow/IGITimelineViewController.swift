//
//  IGITimelineViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import pop
import Realm
import Batch.Ads

class IGITimelineViewController: GAITrackedViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, IGITimelineNodeDelegate, IGIMessageViewDelegate, BatchAdsDisplayDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var aboutView: IGICircularView!
    
    var allGoals: RLMResults?
    
    var activeUser: IGIUser?
    var activeGoal: IGIGoal?
    
    var shouldPlayIntroduction = false
    var shouldPlayTomorrowNodeIntroduction = false
    var introductionAnimationPlaying = false
    
    var shouldShowTomorrowNode = false
    var shouldShowTipNode = false
    var shouldShowRatingNode = false
    
    var showingModal = false
    
    var completedGoalCount  = 0         // unlimited
    var activeTaskCount     = 0         // max 3
    var specialtyNodeCount  = 0         // should be 1 or 0, we don't want to show a tip and a review at the same time

    // TODO: Add a way to cancel new task flow
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        let users = IGIUser.allObjects()
        activeUser = users[0] as? IGIUser
        
        assert(activeUser != nil, "User should not be nil")
        
        // First time loading the view should reveal the tomorrow node if needed
        shouldPlayTomorrowNodeIntroduction = shouldShowTomorrowNode
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        screenName = "Timeline Screen"
        
        tableView.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // let the view appear before we refresh everything
        refreshModelData()
        
        UIView.animateWithDuration(0.225, animations: {
            self.tableView.alpha = 1.0
        })
        
        // on load we want to be at the bottom of the table
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow:  activeRowCount() - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
    }
    
    // FIXME: The animation here is causing an issue with the transition
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if tableView.alpha == 0 {
            let scale = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
            scale.toValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
            tableView.layer.pop_addAnimation(scale, forKey: "restore-scale")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        showingModal = true
        
        if segue.identifier == "revealMessageSegue" {
            if let vc = segue.destinationViewController as? IGIMessageViewController {
                vc.delegate = self
            }
        } else if segue.identifier == "showAboutViewSegue" {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.view.alpha = 0.0
            })
        }
    }
    
    @IBAction func unwindToTimeline(sender: UIStoryboardSegue) {
        showingModal = false
        
        // let the view appear before we refresh everything
        introductionAnimationPlaying = false
        shouldPlayIntroduction = true // introduce the new tasks
    }
    
    @IBAction func unwindToTimelineFromAbout(sender: UIStoryboardSegue) {
        showingModal = false
        
        UIView.animateWithDuration(0.225, animations: { () -> Void in
            self.view.alpha = 1.0
        })
    }
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeRowCount()
    }
    
    func activeRowCount() -> Int {
        var rows = (shouldShowTomorrowNode) ? 1 : 0
        rows += completedGoalCount + activeTaskCount + specialtyNodeCount
        println("table refresh debug row count \(rows)")
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("timelineItemId") as! UITableViewCell
        var nodeView: IGITimelineNodeView?
        
        if cell.contentView.subviews.count == 0 {
            nodeView = IGITimelineNodeView()
            nodeView?.initializeLayout()
            cell.contentView.addSubview(nodeView!)
            
            nodeView!.delegate = self
            nodeView!.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        }
        else {
            nodeView = cell.contentView.subviews.first as? IGITimelineNodeView
        }
        
        // Cell Layout Handling
        
        if indexPath.row < completedGoalCount {                                     // Show completed goal nodes
            println("\(indexPath.row) - get goal")
            nodeView!.updateLayoutWithGoal(goalForIndexPath(indexPath)!)
            nodeView!.revealTimelineWithoutAnimation()
        }
        else if indexPath.row == completedGoalCount && specialtyNodeCount > 0 {     // Do we need to reveal a tip or rating node?
            
        }
        else if indexPath.row < (completedGoalCount + activeTaskCount + specialtyNodeCount) {          // Show tasks (if anything)
            println("\(indexPath.row) - get task")
            nodeView!.updateLayoutWithTask(taskForIndexPath(indexPath)!)

            // Only trigger the animation waterfall once & only if it should be played
            if !introductionAnimationPlaying {
                if !shouldPlayIntroduction {
                    nodeView!.revealTimelineWithoutAnimation()
                } else {
                    introductionAnimationPlaying = true
                    nodeView!.playTimelineAnimationDelayed(delay: 1.0)
                    println("task introduction reveal triggered")
                }
            }
        }
        else if shouldShowTomorrowNode {                                            // Show active tomorrow node last (if needed)
            println("\(indexPath.row) - get tomorrow node")
            nodeView!.updateLayoutAsTomorrowNode()
            
            // This could be revealed by us (completing all tasks > inserting row)
            if shouldPlayTomorrowNodeIntroduction {
                shouldPlayTomorrowNodeIntroduction = false
                nodeView!.playTimelineAnimationDelayed(delay: 1.0)
            } else {
                nodeView!.revealTimelineWithoutAnimation(delay: 1.5)
            }
        }
        
        return cell
    }
    
    // MARK: Timeline Delegate
    
    func nodeDidCompleteAnimation() {
        // Play the next cell
        for cell in tableView.visibleCells() {
            if var nodeView = cell.contentView.subviews[0] as? IGITimelineNodeView {
                if !nodeView.revealAnimationComplete {
                    nodeView.playTimelineAnimationDelayed(delay: 0.15)
                    
                    if let c = cell as? UITableViewCell, var path = tableView.indexPathForCell(c) {
                        // smooth out the scroll animation
                        UIView.animateWithDuration(1.0, animations: {
                            self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                        })
                    }
                    break
                } else {
                    introductionAnimationPlaying = false
                    shouldPlayIntroduction = false
                }
            }
        }
    }
    
    func nodeCompletionStatusUpdated() {
        if let status = activeGoal?.areAllTasksCompleted() {
            if status {
                if !shouldShowTomorrowNode {
                    shouldShowTomorrowNode = true
                    shouldPlayTomorrowNodeIntroduction = true
                    
                    let rows = tableView.numberOfRowsInSection(0)
                    
                    tableView.beginUpdates()
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: rows, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                    tableView.endUpdates()
                    
                    tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: rows, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                }
            }
            else if shouldShowTomorrowNode {
                // remove the tomorrow planning cell if the user changed their mind
                shouldShowTomorrowNode = false
                shouldPlayTomorrowNodeIntroduction = false
                
                let rows = tableView.numberOfRowsInSection(0)
                
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: rows - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                tableView.endUpdates()
            }
        }
    }
    
    func nodePlanTomorrowPressed() {
        if activeGoal == nil {
            acceptPressed()
        } else {
            // Confirm completion
            performSegueWithIdentifier("revealMessageSegue", sender: self)
        }
    }
    
    // MARK: Message Delegate
    
    func cancelPressed() {
        showingModal = false
    }
    
    func acceptPressed() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            // Proceed with Transition
            let scale = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
            scale.toValue = NSValue(CGPoint: CGPointMake(0.5, 0.5))
            self.tableView.layer.pop_addAnimation(scale, forKey: "scale-down")
            
            // Mark goal as completed
            if let completed = self.activeGoal?.goal_completed where completed == false {
                self.activeGoal?.setGoalCompleted()
            }
            
            UIView.animateWithDuration(0.225, animations: {
                self.tableView.alpha = 0.0
            },completion:  { (done) in
                self.performSegueWithIdentifier("taskInputSegue", sender: nil)
            })
        })
    }
    
    // MARK: Data
    
    func refreshModelData() {
        activeGoal = activeUser?.getCurrentGoal()
        allGoals = IGIGoal.allObjects()
        
        // If we don't have an active goal we need to show the tomorrow node
        if activeGoal == nil {
            shouldShowTomorrowNode = true
        }
        
        refreshTableView()
    }
    
    private func refreshTableView() {
        // Update counts & flags
        refreshCountStatus()
        
        // Refresh Table
        tableView.reloadData()
    }
    
    private func refreshCountStatus() {
        completedGoalCount  = 0
        activeTaskCount     = 0
        specialtyNodeCount  = 0
        
        if let results = allGoals {
            for item: RLMObject in results {
                if let goal = item as? IGIGoal {
                    if goal.goal_completed == true {
                        completedGoalCount++
                    } else {
                        // We have active tasks
                        activeTaskCount += Int(goal.tasks.count)
                        
                        // Is this goal complete?
                        refreshTomorrowNode()
                    }
                }
            }
        }
    
        if shouldShowTipNode || shouldShowRatingNode {
            specialtyNodeCount++
        }
    }
    
    private func refreshTomorrowNode() {
        if let goal = activeUser?.getCurrentGoal() where goal.goal_completed == false {
            shouldShowTomorrowNode = goal.areAllTasksCompleted()
        }
    }
    
    private func shouldRevealSpecialtyNode() -> Bool {
        if shouldShowTipNode || shouldShowRatingNode {
            return true
        }
        return false
    }
    
    // Nothing comes before a completed goal so we're fine with this index
    private func goalForIndexPath(indexPath: NSIndexPath) -> IGIGoal? {
        return allGoals?.objectAtIndex(UInt(indexPath.row)) as? IGIGoal
    }
    
    // Account for goals (unlimited) and a potnetial specialty row
    private func taskForIndexPath(indexPath: NSIndexPath) -> IGITask? {
        let index = completedGoalCount + specialtyNodeCount
        println("debug task index: \(indexPath.row - index)")
        return activeGoal?.tasks.objectAtIndex(UInt(indexPath.row - index)) as? IGITask
    }
    
    // MARK: Scroll Delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -20 {
            scrollView.setContentOffset(CGPointMake(0, -20), animated: false)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < 0 {
            scrollView.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentOffset.y < 0 {
            scrollView.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if showingModal {
            return
        }
        
        // if we're returning it's possible that the goal time elapsed
        refreshModelData()
        
        // show an advert if they haven't left a tip
        let leftTip = NSUserDefaults.standardUserDefaults().boolForKey("kDidLeaveDonation")
        let onboarded = NSUserDefaults.standardUserDefaults().boolForKey("kOnboardCompleted")
        if !leftTip && onboarded {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "displayAdPlacementDelayed", userInfo: nil, repeats: false)
        }
    }
    
    func displayAdPlacementDelayed() {
        BatchAds.displayAdForPlacement(BatchPlacementDefault, withDelegate: self)
    }
    
    // MARK: Ads
    func adDidAppear(placement: String!) {
        let build = GAIDictionaryBuilder.createEventWithCategory("advertising", action: "did_appear", label: nil, value: nil).build()
        GAI.sharedInstance().defaultTracker.send(build as [NSObject: AnyObject])
    }
    
    func adCancelled(placement: String!) {
    }
    
    func adNotDisplayed(placement: String!) {
        let build = GAIDictionaryBuilder.createEventWithCategory("advertising", action: "not_displayed", label: nil, value: nil).build()
        GAI.sharedInstance().defaultTracker.send(build as [NSObject: AnyObject])
    }
    
    func adClicked(placement: String!) {
        let build = GAIDictionaryBuilder.createEventWithCategory("advertising", action: "did_click", label: nil, value: nil).build()
        GAI.sharedInstance().defaultTracker.send(build as [NSObject: AnyObject])
    }
}
              