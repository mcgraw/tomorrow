//
//  IGITimelineViewController.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGITimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IGITimelineNodeDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var allGoals: RLMResults?
    
    var activeUser: IGIUser?
    var activeGoal: IGIGoal?
    
    var shouldPlayIntroduction = false
    
    var shouldShowTomorrowNode = false
    var shouldShowTipNode = false
    var shouldShowRatingNode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let users = IGIUser.allObjects()
        activeUser = users[0] as? IGIUser
        activeGoal = activeUser?.getCurrentGoal()
        allGoals = IGIGoal.allObjects()
    }
    
    // MARK: Table View 
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int = 0
        
        // Total goals minus 1 (the goal we're working on)
        if let goals = allGoals {
            rows += Int(goals.count - 1)
        }
        
        // 3 tasks (the goal we're working on
        if activeGoal != nil {
            rows += 3
        }
        
        // Specialty Rows
        rows += shouldShowTomorrowNode ? 1 : 0
        rows += shouldShowTipNode ? 1 : 0
        rows += shouldShowRatingNode ? 1 : 0
        
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
        
        if indexPath.row == 0 && shouldPlayIntroduction {
            nodeView!.playTimelineAnimationDelayed(delay: 1.0)
        }
        
        if allGoals!.count == 1 {
            if indexPath.row < 3 {
                let task = activeGoal?.tasks.objectAtIndex(UInt(indexPath.row)) as? IGITask
                nodeView!.updateLayoutWithTask(task!)
            } else if shouldShowTomorrowNode {
                nodeView!.updateLayoutAsTomorrowNode()
                nodeView!.playTimelineAnimationDelayed(delay: 0.5)
            }
        }
        
    
//        var goal: IGIGoal? = allGoals?.objectAtIndex(UInt(indexPath.row)) as? IGIGoal
//        if (goal?.goal_completed == true) {
//            nodeView!.updateLayoutWithGoal(goal!)
//        } else if allGoals!.count == 1 {
//            let task = activeGoal?.tasks.objectAtIndex(UInt(indexPath.row)) as? IGITask
//            nodeView!.updateLayoutWithTask(task!)
//        } else {
//            let task = activeGoal?.tasks.objectAtIndex(UInt(indexPath.row - (allGoals!.count - 1))) as? IGITask
//            nodeView!.updateLayoutWithTask(task!)
//        }
        
        
        
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
                
                let rows = tableView.numberOfRowsInSection(0)
                
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: rows, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                tableView.endUpdates()
                
            }
            else if shouldShowTomorrowNode {
                // remove the tomorrow planning cell if the user changed their mind
                shouldShowTomorrowNode = false
                
                let rows = tableView.numberOfRowsInSection(0)
                
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: rows - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                tableView.endUpdates()
            }
        }
    }
    
    // MARK: Data
    
    func refreshModelData() {
        allGoals = IGIGoal.allObjects()
        
        tableView.reloadData()
    }
    
}
              