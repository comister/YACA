//
//  NSDate.extension.swift
//  YACA
//
//  Created by Andreas Pfister on 18/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

extension NSDate {
    
    convenience init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateStringFormatter.locale = NSLocale.systemLocale()
        let d = dateStringFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:d!)
    }
    
    class func dateFromMetOfficeString(string:String) -> NSDate {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-ddZ"
        dateStringFormatter.locale = NSLocale.systemLocale()
        let d = dateStringFormatter.dateFromString(string)
        return NSDate(timeInterval:0, sinceDate:d!)
    }
    
    class func areDatesSameDay(dateOne:NSDate,dateTwo:NSDate) -> Bool {
        let calender = NSCalendar.currentCalendar()
        let flags: NSCalendarUnit = [NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year]
        let compOne: NSDateComponents = calender.components(flags, fromDate: dateOne)
        let compTwo: NSDateComponents = calender.components(flags, fromDate: dateTwo);
        return (compOne.day == compTwo.day && compOne.month == compTwo.month && compOne.year == compTwo.year);
    }
    
    class func stringFromDate(date:NSDate) -> NSString {
        let date_formatter = NSDateFormatter()
        date_formatter.dateFormat = "dd/MM/yyyy"
        let date_string = date_formatter.stringFromDate(date)
        return date_string
    }
    
    class func stringTimeFromDate(date:NSDate) -> NSString {
        let date_formatter = NSDateFormatter()
        date_formatter.dateFormat = "HH:mm"
        let date_string = date_formatter.stringFromDate(date)
        return date_string
    }
    
}