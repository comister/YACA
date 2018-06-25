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

protocol DataSourceDelegate : class {
    func DataSourceFinishedProcessing()
    func DataSourceStartedProcessing()
    func ConnectivityProblem(_ status: Bool)
}

class Datasource: MeetingDelegate {
    
    static let sharedInstance = Datasource()
    
    
    var meetings: [Meeting]?
    weak var delegate : DataSourceDelegate?
    
    var daysOfMeeting = [Date:[Meeting]]()
    var sortedMeetingArray = [Date]()
    var meetingId: String = ""
    
    // MARK: Keeps track of meetings under creation and fires delegate method as soon as at 0
    var meetingsToCreate: Int = 0 {
        didSet {
            if meetingsToCreate == 0 {
                self.delegate?.DataSourceFinishedProcessing()
            }
        }
    }
    
    func loadMeetings(_ meetings: [Meeting]?) {
        self.meetings = meetings
    }
    
    func loadMeetings(_ events: [EKEvent]) {
        self.delegate?.DataSourceStartedProcessing()
        var localMeetings = [Meeting]()
        meetingsToCreate = events.count
        for event in events {
            let meeting = Meeting(event: event)
            meeting.delegate = self
            localMeetings.append(meeting)
            if (event.attendees == nil) {
                MeetingDidCreate()
            }
        }
        self.meetings = localMeetings
        
        //CoreDataStackManager.sharedInstance().saveContext() {
        self.structureMeetings()
        //}
    }
    
    // MARK: - prohibits the creation of an instance outside the singleton pattern
    fileprivate init() { }
    
    // MARK: - iterate through each Event and fill up dates, afterwards sort
    func structureMeetings() {
        
        // new day, new structure ...
        daysOfMeeting = [Date:[Meeting]]()
        sortedMeetingArray = [Date]()
        
        if let items = meetings {
            for item in items {
                let day = getDayOfDate(item.starttime as Date)
                if daysOfMeeting[day] == nil {
                    daysOfMeeting[day] = [Meeting]()
                }
                daysOfMeeting[day]?.append(item)
            }
            self.sortedMeetingArray = Array(daysOfMeeting.keys).sorted(by: { $0.timeIntervalSinceReferenceDate < $1.timeIntervalSinceReferenceDate })
        }
        
    }
    
    func MeetingDidCreate() {
        self.meetingsToCreate -= 1
    }
    
    //pass through delegate
    func ConnectivityProblem(_ status: Bool) {
        self.delegate?.ConnectivityProblem(status)
    }
    
    // MARK: - returns the weekday of a date, the special is because it does return the string today and tomorrow
    func getSpecialWeekdayOfDate(_ date: Date) -> String {
        if Date.areDatesSameDay(Date(), dateTwo: date) {
            return "TODAY"
        } else if Date.areDatesSameDay(Date(timeIntervalSinceNow: 86400), dateTwo: date) {
            return "TOMORROW"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            dateFormatter.locale = Locale(identifier: "en")
            return dateFormatter.string(from: date).uppercased()
        }
    }
    
    // MARK: - Just return the day as NSDate, removing/avoiding time
    func getDayOfDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year], from: date)
        return calendar.date(from: components)!
    }
    
    // MARK: - Just return Time of date
    func getTimeOfDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: date)
        return String(describing: components.hour) + ":" + String(describing: components.minute)
    }
    
    // MARK: - Returns the week of Year
    func getCalendarWeek(_ date: Date) -> Int {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.minimumDaysInFirstWeek = 4 // iso-week !
        return ((calendar as NSCalendar?)?.components(NSCalendar.Unit.weekOfYear, from: date).weekOfYear)!
    }
}
