//
//  IGITask.swift
//  Tomorrow
//
//  Created by David McGraw on 2/7/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGITask: RLMObject {
    dynamic var name = ""
    dynamic var motivation = ""
    
    dynamic var completed = false
    dynamic var completed_count = 0

    dynamic var edit_needed = false     // flag to inform the task entry view of an edit

    dynamic var goals = RLMArray(objectClassName: IGIGoal.className())
    
    override class func primaryKey() -> String! {
        return "name"
    }
    
    class func findTaskWithExistingKey(name: String) -> IGITask? {
        let searchValue = name.stringByReplacingOccurrencesOfString("'", withString: "\\", options: NSStringCompareOptions.allZeros, range: nil)
        let tasks = IGITask.objectsWhere("name == '\(searchValue)'")
        if tasks.count == 0 {
            return nil
        }
        return tasks.firstObject() as? IGITask
    }
    
    func updateTaskCompletionStatus(status: Bool) {
        RLMRealm.defaultRealm().beginWriteTransaction()
        self.completed = status
        RLMRealm.defaultRealm().commitWriteTransaction()
    }
    
    func removeTaskFromGoalWithDate(#date: NSDate) {
        let predicate = NSPredicate(format: "date == %@", date)
        if let goals = self.goals.objectsWithPredicate(predicate) as RLMResults? {
            if let goal = goals.firstObject() as? IGIGoal {
                let index = self.goals.indexOfObject(goal)
                self.goals.removeObjectAtIndex(index)
            }
        } 
    }
}
