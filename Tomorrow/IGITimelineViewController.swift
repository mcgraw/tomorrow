//
//  IGITimelineViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Batch.Ads

class IGITimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IGITimelineNodeDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var allGoals: RLMResults?
    
    var activeUser: IGIUser?
    var activeGoal: IGIGoal?
    
    var shouldPlayIntroduction = false
    var shouldPlayTomorrowNodeIntroduction = false
    var introductionAnimationPlaying = false
    
    var shouldShowTomorrowNode = false
    var shouldShowTipNode = false
    var shouldShowRatingNode = false
    
    var completedGoalCount  = 0         // unlimited
    var activeTaskCount     = 0         // max 3
    var specialtyNodeCount  = 0         // should be 1 or 0, we don't want to show a tip and a review at the same time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let users = IGIUser.allObjects()
        activeUser = users[0] as? IGIUser
        activeGoal = activeUser?.getCurrentGoal()
        allGoals = IGIGoal.allObjects()
        
        if allGoals?.count == 1 {
            shouldPlayIntroduction = true
        }
        
        // let the view appear before we refresh everything
        refreshModelData()
        
        // First time loading the view should reveal the tomorrow node if needed
        shouldPlayTomorrowNodeIntroduction = shouldShowTomorrowNode
        
        tableView.reloadData()
    }

    // MARK: Table View
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = (shouldShowTomorrowNode) ? 1 : 0
        rows += completedGoalCount + activeTaskCount + specialtyNodeCount
        println("table refresh debug row count \(rows)")
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("timelineItemId") as UITableViewCell
        var nodeView: IGITimelineNodeView?
        
        if cell.contentView.subviews.count == 0 {
            nodeView = IGITimelineNodeView()
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
            nodeView!.updateLayoutWithGoal(goalForIndexPath(indexPath))
            nodeView!.revealTimelineWithoutAnimation()
        }
        else if indexPath.row == completedGoalCount && specialtyNodeCount > 0 {     // Do we need to reveal a tip or rating node?
            
        }
        else if indexPath.row < (completedGoalCount + activeTaskCount + specialtyNodeCount) {          // Show tasks (if anything)
            println("\(indexPath.row) - get task")
            nodeView!.updateLayoutWithTask(taskForIndexPath(indexPath))

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
                nodeView!.playTimelineAnimationDelayed(delay: 1.0)
            } else {
                // The task animation reveal will trigger an animation if needed
            }
        }
        
        return cell
    }
    
    // MARK: Timeline Delegate
    
    func nodeDidCompleteAnimation() {
        // Play the next cell
        for cell in tableView.visibleCells() {
            var nodeView = cell.contentView.subviews[0] as IGITimelineNodeView
            if !nodeView.revealAnimationComplete {
                nodeView.playTimelineAnimationDelayed(delay: 0.15)
                
                if var path = tableView.indexPathForCell(cell as UITableViewCell) {
                    // smooth out the scroll animation
                    UIView.animateWithDuration(1.0, animations: {
                        self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                    })
                }
                break;
            }
        }
    }
    
    func nodeCompletionStatusUpdated() {
        if let status = activeGoal?.areAllTasksCompleted() {
            if status {
                shouldShowTomorrowNode = true
                shouldPlayTomorrowNodeIntroduction = true
                
                let rows = tableView.numberOfRowsInSection(0)
                
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: rows, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
                
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
        // Mark goal as completed
        activeGoal?.setGoalCompleted()
        
        // Proceed with Transition
        let scale = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        scale.toValue = NSValue(CGPoint: CGPointMake(0.5, 0.5))
        tableView.layer.pop_addAnimation(scale, forKey: "scale-down")
        
        UIView.animateWithDuration(0.225, animations: {
            self.tableView.alpha = 0.0
        }, { (done) in
            self.performSegueWithIdentifier("taskInputSegue", sender: nil)
        })
    }
    
    // MARK: Data
    
    func refreshModelData() {
        allGoals = IGIGoal.allObjects()
        
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
                let goal = item as IGIGoal
                if goal.goal_completed == true {
                    completedGoalCount++
                } else {
                    // We have active tasks
                    activeTaskCount += 3
                    
                    // Is this goal complete?
                    refreshTomorrowNode()
                }
            }
        }
    
        if shouldShowTipNode || shouldShowRatingNode {
            specialtyNodeCount++
        }
    }
    
    private func refreshTomorrowNode() {
        if let goal = activeUser?.getCurrentGoal() {
            if goal.goal_completed == false {
                shouldShowTomorrowNode = goal.areAllTasksCompleted()
            }
        }
    }
    
    private func shouldRevealSpecialtyNode() -> Bool {
        if shouldShowTipNode || shouldShowRatingNode {
            return true
        }
        return false
    }
    
    // Nothing comes before a completed goal so we're fine with this index
    private func goalForIndexPath(indexPath: NSIndexPath) -> IGIGoal {
        return allGoals?.objectAtIndex(UInt(indexPath.row)) as IGIGoal
    }
    
    // Account for goals (unlimited) and a potnetial specialty row
    private func taskForIndexPath(indexPath: NSIndexPath) -> IGITask {
        let index = completedGoalCount + specialtyNodeCount
        println("debug task index: \(indexPath.row - index)")
        return activeGoal?.tasks.objectAtIndex(UInt(indexPath.row - index)) as IGITask
    }
}
              