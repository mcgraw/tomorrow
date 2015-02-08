//
//  IGIUser.swift
//  Tomorrow
//
//  Created by David McGraw on 2/7/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGIUser: RLMObject {
    dynamic var userId = 0
    dynamic var firstName = ""
    dynamic var gender = ""
    
    // user can have many goals (composed of 3+ tasks)
    dynamic var goals = RLMArray(objectClassName: IGIGoal.className())
    
    override class func primaryKey() -> String! {
        return "userId"
    }
}
