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
        /*get {
            return self.meetings
        }*/
        didSet {
            print("didSet executed")
            structureMeetings()
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    var dates: [NSDate]?
    var weekStructure: [String:[Meeting]]?
    var structureKeys: [String]?
    
    init(meetings: [Meeting]?) {
        self.meetings = meetings
        print(weekStructure)
    }
    
    init(events: [EKEvent]) {
        var localMeetings = [Meeting]()
        for event in events {
            localMeetings.append(Meeting(event: event, context: self.sharedContext))
        }
        self.meetings = localMeetings
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Notes.statics.entityName)
        //fetchRequest.predicate = NSPredicate(format: "meeting == %@", self.meeting)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Meeting.Keys.Name, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func getMeetings() {
        
        // fetch Notes from CoreData, fetch Meetings & participants from system Calendar
        // Meeting will be related to Notes, with that we have a proper reference to get proper notes of meetings
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            let myViewController = UIViewController()
            let errorMessage = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            errorMessage.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            myViewController.presentViewController(errorMessage, animated: true, completion: nil)
        }
        
    }
    
    
    // MARK: - iterate through each Event and fill up dates, afterwards sort
    func structureMeetings() {
        if let items = meetings {
            for item in items {
                if dates?.contains(item.starttime) == false {
                    dates?.append(item.starttime)
                    let weekDayName = getSpecialWeekdayOfDate(item.starttime)
                    weekStructure![weekDayName]?.append(item)
                    structureKeys?.append(weekDayName)
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
    }
}