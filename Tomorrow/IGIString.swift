//
//  IGIStringExtension.swift
//  Tomorrow
//
//  Created by David McGraw on 3/11/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import Foundation

extension String {
    
    var length: Int { return countElements(self) }
    
    var capitalized: String { return capitalizedString }
    
    var lowercase: String { return lowercaseString }
    
    func trimLeadingWhitespace() -> String {
        if let range = rangeOfString("^\\s+", options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) {
            return stringByReplacingCharactersInRange(range, withString: "")
        }
        return self
    }
    
    func trimTrailingWhitespace() -> String {
        if let range = rangeOfString("\\s+$", options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) {
            return stringByReplacingCharactersInRange(range, withString: "")
        }
        return self
    }
    
    func trimLeadingAndTrailingWhitespace() -> String {
        return trimLeadingWhitespace().trimTrailingWhitespace()
    }
}