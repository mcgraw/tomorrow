//
//  IGILoremIpsum.swift
//  Tomorrow
//
//  Created by David McGraw on 2/7/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

private let motivationPhrases = ["Great job!", "Excellent!", "Way to go!", "Crushed it!", "Easy peasy!", "You've got this!", "Nice progress!", "Heck yeah!", "You rock!", "Nailed it!", "Outstanding!", "Right on!", "Exceptional!"]

private let encouragement = ["Don't sweat it! Get after it Tomorrow!", "Tomorrow is a clean slate! Crush it!", "Stay motivated", "Get some rest. Conquer Tomorrow!", "I've got faith in you!", "You can do it!", "No worries, Tomorrow is another day", "Great try!"]

class IGILoremIpsum: NSObject {

    class func randomMotivationPhrase() -> String {
        return motivationPhrases[randomInteger(lowerBound: 0, upperBound: motivationPhrases.count)]
    }

    class func randomEncouragementPhrase() -> String {
        return encouragement[randomInteger(lowerBound: 0, upperBound: encouragement.count)]
    }

    class func randomInteger(#lowerBound: Int, upperBound: Int) -> Int {
        return  Int(arc4random_uniform(UInt32(upperBound) - UInt32(lowerBound))) + Int(lowerBound)
    }
}
