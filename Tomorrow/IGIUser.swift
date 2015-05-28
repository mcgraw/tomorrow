//
//  IGIUser.swift
//  Tomorrow
//
//  Created by David McGraw on 2/7/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit
import Realm

class IGIUser: RLMObject {
    dynamic var userId = 0
    dynamic var firstName = ""
    dynamic var gender = ""
    
    // user can have many goals (composed of 3+ tasks)
    dynamic var goals = RLMArray(objectClassName: IGIGoal.className())
    
    override class func primaryKey() -> String! {
        return "userId"
    }
    
    class func getCurrentUser() -> IGIUser? {
        let users = IGIUser.allObjects()
        if users.count > 0 {
            return users[0] as? IGIUser
        }
        return nil
    }
    
    func getFirstName() -> String {
        return firstName.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!.capitalizedString
    }
    
    func isGoalComplete() -> Bool {
        if let goal = getCurrentGoal() {
            return goal.areAllTasksCompleted()
        }
        return false
    }
    
    func setTaskNeedsEdit(#index: UInt) {
        let incomplete_goals: RLMResults? = self.goals.objectsWhere("edit_completed == false")
        if let goal = incomplete_goals?.firstObject() as? IGIGoal {
            if index < goal.tasks.count {
                if let task = goal.tasks.objectAtIndex(index) as? IGITask {
                    task.realm.beginWriteTransaction()
                    task.edit_needed = true
                    IGITask.createOrUpdateInDefaultRealmWithValue(task)
                    task.realm.commitWriteTransaction()
                }
            }
        }
    }
    
    func setUserName(#name: String?) {
        if name != nil {
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            let strip = name!.trimLeadingAndTrailingWhitespace()
            firstName = strip
            IGIUser.createOrUpdateInDefaultRealmWithValue(self)
            realm.commitWriteTransaction()
        }
    }
    
    func setUserGender(#type: String) {
        realm.beginWriteTransaction()
        gender = type
        IGIUser.createOrUpdateInDefaultRealmWithValue(self)
        realm.commitWriteTransaction()
    }
    
    func getCurrentGoalUnderEdit() -> IGIGoal? {
        let incomplete_goals: RLMResults? = self.goals.objectsWhere("edit_completed == false")
        
        // We should not have multiple goals under edit
        if incomplete_goals?.count > 1 {
            assertionFailure("More than 1 goal is under editing mode! There should be 1!")
        }
        
        return incomplete_goals?.firstObject() as? IGIGoal
    }
    
    func getCurrentGoal() -> IGIGoal? {
        let incomplete_goals: RLMResults? = self.goals.objectsWhere("goal_completed == false")
        
        // We should not have multiple goals under edit
        if incomplete_goals?.count > 1 {
            assertionFailure("More than 1 goal is marked not completed! There should be 1!")
        }
        
        return incomplete_goals?.firstObject() as? IGIGoal
    }
    
    func createNewTask(#name: String) -> IGITask {
        // Create a new task object & remove this one from the current goal
        let strip = name.trimLeadingAndTrailingWhitespace()
        var task = IGITask.findTaskWithExistingKey(strip.lowercase)
        if task == nil {
            task = IGITask()
            task?.name = strip.lowercase
        }
        return task!
    }
    
    func addNewTask(#name: String) -> IGITask {
        let goalEditing: IGIGoal? = self.getCurrentGoalUnderEdit()!
    
        assert(goalEditing != nil, "Can't add a task without a goal under edit")
        
        // Create a new task object & remove this one from the current goal
        let original = name
        let strip = name.trimLeadingAndTrailingWhitespace()
        var task = IGITask.findTaskWithExistingKey(strip.lowercase)
        if task == nil {
            println("Creating new task: \(strip)")
            task = IGITask()
            task?.name = strip.lowercase
            task?.goals.addObject(goalEditing)
            goalEditing!.tasks.addObject(task)
            
            let build = GAIDictionaryBuilder.createEventWithCategory("task", action: "add", label: original, value: nil).build()
            GAI.sharedInstance().defaultTracker.send(build as [NSObject: AnyObject])
            
        } else {
            println("Task already exists. Add it to the new goal!")
            task?.completed = false
            task?.failed = false
            task?.goals.addObject(goalEditing)
            goalEditing!.tasks.addObject(task)
        }
        
        return task!
    }
    
    func totalUserGoals() -> Int {
        return Int(goals.count)
    }
}
