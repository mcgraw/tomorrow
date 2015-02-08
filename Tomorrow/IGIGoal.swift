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
    
    // What day was the goal created?
    dynamic var date: NSDate = NSDate()
    
    // Many tasks available
    dynamic var tasks = RLMArray(objectClassName: IGITask.className())
}
