//
//  IGIPushNoAnimationSegue.swift
//  Tomorrow
//
//  Created by David McGraw on 4/2/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGIPushNoAnimationSegue: UIStoryboardSegue {
    
    override func perform() {
        let source = self.sourceViewController as UIViewController
        if let navigation = source.navigationController {
            let destination = destinationViewController as UIViewController
            destination.view.backgroundColor = UIColor.clearColor()

            navigation.pushViewController(destination, animated: false);
        }
    }
    
}

