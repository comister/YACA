//
//  Datasource.swift
//  YACA
//
//  Created by Andreas Pfister on 18/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

class Datasource {
    
    var meetings: [Meeting]?
    var dates: [NSDate]?
    var weekStructure: [String:[NSDate]]?
    
    init(meetings: [Meeting]?) {
        self.meetings = meetings
        structureMeetings()
        print(weekStructure)
    }
    
    // MARK: - iterate through each Event and fill up dates, afterwards sort
    func structureMeetings() {
        if let items = meetings {
            for item in items {
                if dates?.contains(item.starttime) == false {
                    dates?.append(item.starttime)
                    weekStructure![getSpecialWeekdayOfDate(item.starttime)]?.append(item.starttime)
                }
            }
        }
        
        dates?.sortInPlace({ $0.timeIntervalSinceReferenceDate > $1.timeIntervalSinceReferenceDate })
    }
    
    // MARK: - returns the weekday of a date, the special is because it does return the string today and tomorrow
    func getSpecialWeekdayOfDate(date: NSDate) -> String {
        
        if NSDate.areDatesSameDay(NSDate(), dateTwo: date) {
            return "TODAY"
        } else if NSDate.areDatesSameDay(NSDate(timeIntervalSinceNow: 86400), dateTwo: date) {
            return "TOMORROW"
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.stringFromDate(date)
        }
        return ""
    }
}