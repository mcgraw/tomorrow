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
    
    func isGoalComplete() -> Bool {
        if let goal = getCurrentGoal() {
            return goal.areAllTasksCompleted()
        }
        return false
    }
    
    func setTaskNeedsEdit(#index: UInt) {
        let incomplete_goals: RLMResults? = self.goals.objectsWhere("edit_completed == false")
        let goal: IGIGoal = incomplete_goals!.firstObject() as IGIGoal
        let task: IGITask = goal.tasks.objectAtIndex(index) as IGITask
        
        RLMRealm.defaultRealm().beginWriteTransaction()
        task.edit_needed = true
        IGITask.createOrUpdateInDefaultRealmWithObject(task)
        RLMRealm.defaultRealm().commitWriteTransaction()
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
        var task = IGITask.findTaskWithExistingKey(name.lowercaseString)
        if task == nil {
            task = IGITask()
            task?.name = name.lowercaseString
        }
        return task!
    }
    
    func addNewTask(#name: String) -> IGITask {
        let goalEditing: IGIGoal? = self.getCurrentGoalUnderEdit()!
    
        assert(goalEditing != nil, "Can't add a task without a goal under edit")
        
        // Create a new task object & remove this one from the current goal
        var task = IGITask.findTaskWithExistingKey(name.lowercaseString)
        if task == nil {
            println("Creating new task: \(name)")
            task = IGITask()
            task?.name = name.lowercaseString
            task?.goals.addObject(goalEditing)
            goalEditing!.tasks.addObject(task)
        } else {
            println("Task already exists. Add it to the new goal!")
            task?.completed = false
            task?.goals.addObject(goalEditing)
            goalEditing!.tasks.addObject(task)
        }
        
        return task!
    }
    
    func totalUserGoals() -> Int {
        return Int(goals.count)
    }
}
