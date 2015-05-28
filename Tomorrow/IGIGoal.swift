//
//  IGIGoal.swift
//  Tomorrow
//
//  Created by David McGraw on 2/7/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Realm

class IGIGoal: RLMObject {
    // Owned by one user
    dynamic var user: IGIUser?
    
    // Knock out the expensive formatter work
    dynamic var date_str: String = ""
    
    // What day was the goal created?
    dynamic var date: NSDate = NSDate()
    
    // Many tasks available
    dynamic var tasks = RLMArray(objectClassName: IGITask.className())
    
    // If the customer is editing a goal, this'll let us know
    dynamic var edit_completed = false
    
    // When all tasks are complete, or the day has advanced, mark completed
    dynamic var goal_completed = false
    
    // When the day has advanced and tasks were not completed
    dynamic var goal_failed = false
    
    // List of failed titles
    dynamic var failed_goals: String = ""
    
    class func cleanInvalidGoals() {
        RLMRealm.defaultRealm().beginWriteTransaction()
        let goals = IGIGoal.allObjects()
        for item in goals {
            if let goal = item as? IGIGoal {
                // Delete any invalid goals that were being built
                if goal.edit_completed == false {
                    println("Deleting incomplete goal")
                    RLMRealm.defaultRealm().deleteObject(goal)
                }
            }
        }
        RLMRealm.defaultRealm().commitWriteTransaction()
    }
    
    class func cleanElapsedGoals() {
        RLMRealm.defaultRealm().beginWriteTransaction()
        let goals = IGIGoal.allObjects()
        for item in goals {
            if let goal = item as? IGIGoal where goal.goal_completed == false {
                if (goal.date.isBeforeHour(9) && goal.date.isAfterDay()) ||
                    goal.date.haveDaysElapsedIngoringTime(2) {
                        println("Goal incomplete! Mark as failed")
                        goal.goal_completed = true
                        goal.goal_failed = true
                        goal.failed_goals = goal.getFailedGoalsAsStringList()
                        
                        let build = GAIDictionaryBuilder.createEventWithCategory("milestone", action: "goal_failed", label: nil, value: nil).build()
                        GAI.sharedInstance().defaultTracker.send(build as [NSObject: AnyObject])
                }
            }
            
        }
        RLMRealm.defaultRealm().commitWriteTransaction()
    }
    
    class func countCompletedTasks() -> Int {
        // https://github.com/realm/realm-cocoa/issues/1490
//        let pred = NSPredicate(format: "completed_count.@count")
//        let total = IGIGoal.objectsWithPredicate(pred)
        var count = 0
        let tasks = IGITask.allObjects()
        for item in tasks {
            if let task = item as? IGITask {
                count += task.completed_count
            }
        }
        return count
    }
    
    func getFailedGoalsAsStringList() -> String {
        var failed = ""
        var count = tasks.count
        for item in tasks {
            if let task = item as? IGITask where task.completed == false {
                if failed.length > 0 {
                    failed += ","
                }
                failed += task.name
            }
        }
        return failed
    }
    
    func getCurrentTaskUnderEdit() -> IGITask? {
        let tasks: RLMResults? = self.tasks.objectsWhere("edit_needed == true")
        
        // We should not have multiple tasks under edit
        if tasks?.count > 1 {
            assertionFailure("More than 1 task is under editing mode! There should be 1!")
        }
        return tasks?.firstObject() as? IGITask
    }
    
    func removeTaskAndReplace(task: IGITask, replacement: IGITask) {
        let index = self.tasks.indexOfObject(task)
        self.tasks.replaceObjectAtIndex(index, withObject: replacement)
        task.removeTaskFromGoalWithDate(date: self.date)
    }
    
    // We may be completing a goal with a failed task
    func setGoalCompleted() {
        RLMRealm.defaultRealm().beginWriteTransaction()
        for item in tasks {
            if let task = item as? IGITask where task.failed == true {
                goal_failed = true
                failed_goals = getFailedGoalsAsStringList()
                println("Mark goal complete with failed goals: \(failed_goals)")
            }
        }
        goal_completed = true
        RLMRealm.defaultRealm().commitWriteTransaction()
        
        if goal_failed {
            let build = GAIDictionaryBuilder.createEventWithCategory("milestone", action: "goal_failed", label: nil, value: nil).build()
            GAI.sharedInstance().defaultTracker.send(build as [NSObject: AnyObject])
        } else {
            let build = GAIDictionaryBuilder.createEventWithCategory("milestone", action: "goal_completed", label: nil, value: nil).build()
            GAI.sharedInstance().defaultTracker.send(build as [NSObject: AnyObject])
        }
    }
    
    func getDateAsString() -> String {
        if date_str == "" {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM d, y"
            date_str = formatter.stringFromDate(self.date)
        }
        return date_str
    }
    
    func areAllTasksCompleted() -> Bool {
        for item in tasks {
            if let task = item as? IGITask where (task.completed == false && task.failed == false) {
                return false
            }
        }
        return true
    }
    
    func countIncompleteTasks() -> Int {
        let items = split(failed_goals) { $0 == "," }
        return items.count
    }
    
    func didFailTask(task: IGITask) -> Bool {
        let items = split(failed_goals) { $0 == "," }
        for str in items {
            if str == task.name {
                return true
            }
        }
        return false
    }
}
