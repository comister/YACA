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
    
    var meetings: [Meeting]? {
        didSet {
            print("didSet executed")
            //structureMeetings()
            //CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    var dates = [NSDate]()
    var weekStructure = [Int:[String:[Meeting]]]()
    var structureKeys = [Int:[String]]()
    var weeks = [Int]()
    var weekOfSection = [Int:Int]()
    var dayOfSection = [Int:String]()
    var sectionsRequired = 0
    var meetingId: String = ""
    
    
    init(meetings: [Meeting]?) {
        self.meetings = meetings
        //print(weekStructure)
    }
    
    init(events: [EKEvent]) {
        var localMeetings = [Meeting]()
        for event in events {
            localMeetings.append(Meeting(event: event))
        }
        self.meetings = localMeetings
        structureMeetings()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - iterate through each Event and fill up dates, afterwards sort
    func structureMeetings() {
        if let items = meetings {
            for item in items {
                let week = getCalendarWeek(item.starttime)
                
                if weeks.contains(week) == false {
                    weeks.append(week)
                    weekStructure[week] = [String:[Meeting]]()
                    structureKeys[week] = [String]()
                }
                
                let weekDayName = getSpecialWeekdayOfDate(item.starttime)
                if dates.contains(item.starttime) == false {
                    dates.append(item.starttime)
                    if structureKeys[week]!.contains(weekDayName) == false {
                        structureKeys[week]!.append(weekDayName)
                        weekStructure[week]![weekDayName] = [Meeting]()
                        weekOfSection[sectionsRequired] = week
                        dayOfSection[sectionsRequired] = weekDayName
                        sectionsRequired++
                    }
                }
                // NEED TO create weekDayName with first access !!!!
                //item.note = getNote(item.meetingId)
                weekStructure[week]![weekDayName]!.append(item)
            }
        }
        
        dates.sortInPlace({ $0.timeIntervalSinceReferenceDate < $1.timeIntervalSinceReferenceDate })
    }
    
    // MARK: - returns the weekday of a date, the special is because it does return the string today and tomorrow
    func getSpecialWeekdayOfDate(date: NSDate) -> String {
        
        if NSDate.areDatesSameDay(NSDate(), dateTwo: date) {
            print(String(date) + " = TODAY")
            return "TODAY"
        } else if NSDate.areDatesSameDay(NSDate(timeIntervalSinceNow: 86400), dateTwo: date) {
            print(String(date) + " = TOMORROW")
            return "TOMORROW"
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE"
            dateFormatter.locale = NSLocale(localeIdentifier: "en")
            print(String(date) + " = " + dateFormatter.stringFromDate(date))
            return dateFormatter.stringFromDate(date).uppercaseString
        }
    }
    func getCalendarWeek(date: NSDate) -> Int {
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar!.minimumDaysInFirstWeek = 4 // iso-week !
        return (calendar?.components(NSCalendarUnit.WeekOfYear, fromDate: date).weekOfYear)!
        
    }
}