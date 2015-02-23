//
//  IGIGoal.swift
//  Tomorrow
//
//  Created by David McGraw on 2/7/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

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
    
    func setGoalCompleted() {
        RLMRealm.defaultRealm().beginWriteTransaction()
        goal_completed = true
        RLMRealm.defaultRealm().commitWriteTransaction()
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
            let task = item as IGITask
            if !task.completed {
                return false
            }
        }
        return true
    }
}
