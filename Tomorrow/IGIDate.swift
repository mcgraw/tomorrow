//
//  IGIDate.swift
//  Tomorrow
//
//  Created by David McGraw on 3/20/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import Foundation

extension NSDate {
    
    // MARK: Convenience Initializers
    
    convenience init(year: Int, month: Int, day: Int) {
        let comps = NSDateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        if let date = NSCalendar.currentCalendar().dateFromComponents(comps) {
            self.init(timeInterval: 0, sinceDate: date)
        } else {
            self.init()
        }
    }
    
    convenience init(day: Int, hour: Int) {
        let comps = NSDate.components(fromDate: NSDate())
        comps.day = day
        comps.hour = hour
        if let date = NSCalendar.currentCalendar().dateFromComponents(comps) {
            self.init(timeInterval: 0, sinceDate: date)
        } else {
            self.init()
        }
    }
    
    // MARK: Comparisons
    
    func isAfterDay() -> Bool {
        let comps = self.components()
        let today = NSDate().components()
        return (today.year > comps.year || today.month > comps.day || today.day > comps.day)
    }
    
    func isAfterHour(hour: Int) -> Bool {
        let comps = self.components()
        let today = NSDate().components()
        return (today.year > comps.year || today.month > comps.month || today.day > comps.day || comps.hour > hour)
    }
    
    func isBeforeHour(hour: Int) -> Bool {
        let comps = self.components()
        let today = NSDate().components()
        return (today.month < comps.month || today.day < comps.day || comps.hour < hour)
    }
    
    func haveDaysElapsed(days: Int) -> Bool {
        let diff = NSDate.difference(fromDate: NSDate(), toDate: self)
        print(diff.day)
        return diff.day >= days
    }
    
    func haveDaysElapsedIngoringTime(days: Int) -> Bool {
        let thisComps = NSDate.componentsIgnoreTime(fromDate: self)
        let todayComps = NSDate.componentsIgnoreTime(fromDate: NSDate())
        let diff = NSDate.difference(fromDate: NSCalendar.currentCalendar().dateFromComponents(thisComps)!, toDate: NSCalendar.currentCalendar().dateFromComponents(todayComps)!)
        print(diff.day)
        return diff.day >= days
    }
    
    // MARK: Accessors
    
    func year() -> Int { return self.components().year }
    func month() -> Int { return self.components().month }
    func day() -> Int { return self.components().day }
    func hour() -> Int { return self.components().hour }
    
    // MARK: Components
    
    private class func componentFlags() -> NSCalendarUnit { return .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond | .CalendarUnitWeekday | .CalendarUnitWeekdayOrdinal | .CalendarUnitTimeZone }
    
    private class func components(#fromDate: NSDate) -> NSDateComponents! {
        return NSCalendar.currentCalendar().components(NSDate.componentFlags(), fromDate: fromDate)
    }
    
    private class func componentsIgnoreTime(#fromDate: NSDate) -> NSDateComponents! {
        let comps = NSCalendar.currentCalendar().components(NSDate.componentFlags(), fromDate: fromDate)
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        return comps
    }
    
    private class func difference(#fromDate: NSDate, toDate: NSDate) -> NSDateComponents! {
        return NSCalendar.currentCalendar().components(NSDate.componentFlags(), fromDate: fromDate, toDate: toDate, options: NSCalendarOptions.allZeros)
    }
    
    private func components() -> NSDateComponents {
        return NSDate.components(fromDate: self)!
    }
    
}