//
//  IGITask.swift
//  Tomorrow
//
//  Created by David McGraw on 2/7/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Realm

class IGITask: RLMObject {
    
    dynamic var name = ""
    dynamic var name_cased = ""
    dynamic var motivation = ""
    
    dynamic var failed = false
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
    
    func getTaskTitle() -> String {
        if name_cased != "" {
            return name_cased.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        }
        return name.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!.capitalizedString
    }
    
    func updateTaskCompletionStatus(status: Bool) {
        RLMRealm.defaultRealm().beginWriteTransaction()
        completed = status
        failed = false
        if status {
            completed_count += 1
        } else {
            completed_count -= 1
        }
        RLMRealm.defaultRealm().commitWriteTransaction()
    }
    
    func updateTaskCompletionFailed() {
        RLMRealm.defaultRealm().beginWriteTransaction()
        failed = true
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
