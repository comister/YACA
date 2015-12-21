//
//  Datasource.swift
//  YACA
//
//  Created by Andreas Pfister on 18/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Datasource {
    
    var meetings: [Meeting]? {
        get {
            return self.meetings
        }
        set {
            structureMeetings()
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    var dates: [NSDate]?
    var weekStructure: [String:[Meeting]]?
    
    init(meetings: [Meeting]?) {
        self.meetings = meetings
        print(weekStructure)
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Meeting.statics.entityName)
        //fetchRequest.predicate = NSPredicate(format: "meeting == %@", self.meeting)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Meeting.Keys.Name, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func getMeetings() {
        
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
                    weekStructure![getSpecialWeekdayOfDate(item.starttime)]?.append(item)
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