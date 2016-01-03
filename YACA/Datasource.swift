//
//  Datasource.swift
//  YACA
//
//  Handles interaction between CoreData and Calendar fetching to cache effectively
//
//  Created by Andreas Pfister on 18/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import EventKit

class Datasource {
    
    static let sharedInstance = Datasource()
    
    var meetings: [Meeting]?
    var working: Bool = false
    
    var daysOfMeeting = [NSDate:[Meeting]]()
    var sortedMeetingArray = [NSDate]()
    var meetingId: String = ""
    
    func loadMeetings(meetings: [Meeting]?) {
        self.meetings = meetings
    }
    
    func loadMeetings(events: [EKEvent]) {
        var localMeetings = [Meeting]()
        for event in events {
            localMeetings.append(Meeting(event: event))
        }
        self.meetings = localMeetings
        
        //CoreDataStackManager.sharedInstance().saveContext() {
        self.structureMeetings()
        //}
    }
    
    private init() {
        
    }
    
    // MARK: - iterate through each Event and fill up dates, afterwards sort
    func structureMeetings() {
        
        // new day, new structure ...
        daysOfMeeting = [NSDate:[Meeting]]()
        sortedMeetingArray = [NSDate]()
        
        if let items = meetings {
            for item in items {
                let day = getDayOfDate(item.starttime)
                if daysOfMeeting[day] == nil {
                    daysOfMeeting[day] = [Meeting]()
                }
                daysOfMeeting[day]?.append(item)
            }
            self.sortedMeetingArray = Array(daysOfMeeting.keys).sort({ $0.timeIntervalSinceReferenceDate < $1.timeIntervalSinceReferenceDate })
        }
        
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
            dateFormatter.locale = NSLocale(localeIdentifier: "en")
            return dateFormatter.stringFromDate(date).uppercaseString
        }
    }
    
    func getDayOfDate(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: date)
        return calendar.dateFromComponents(components)!
    }
    
    func getTimeOfDate(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: date)
        return String(components.hour) + ":" + String(components.minute)
    }
    
    func getCalendarWeek(date: NSDate) -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar!.minimumDaysInFirstWeek = 4 // iso-week !
        return (calendar?.components(NSCalendarUnit.WeekOfYear, fromDate: date).weekOfYear)!
    }
}