//
//  NSDate.extension.swift
//  YACA
//
//  Created by Andreas Pfister on 18/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

extension Date {
    
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateStringFormatter.locale = Locale.current // changed from Locale.system (SWIFT 2)
        let d = dateStringFormatter.date(from: dateString)
        self.init(timeInterval:0, since:d!)
    }
    
    static func dateFromMetOfficeString(_ string:String) -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-ddZ"
        dateStringFormatter.locale = Locale.current
        let d = dateStringFormatter.date(from: string)
        return Date(timeInterval:0, since:d!)
    }
    
    static func areDatesSameDay(_ dateOne:Date,dateTwo:Date) -> Bool {
        let calender = Calendar.current
        let flags: NSCalendar.Unit = [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year]
        let compOne: DateComponents = (calender as NSCalendar).components(flags, from: dateOne)
        let compTwo: DateComponents = (calender as NSCalendar).components(flags, from: dateTwo);
        return (compOne.day == compTwo.day && compOne.month == compTwo.month && compOne.year == compTwo.year);
    }
    
    static func stringFromDate(_ date:Date) -> NSString {
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "dd/MM/yyyy"
        let date_string = date_formatter.string(from: date)
        return date_string as NSString
    }
    
    static func stringTimeFromDate(_ date:Date) -> NSString {
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "HH:mm"
        let date_string = date_formatter.string(from: date)
        return date_string as NSString
    }
    
}
