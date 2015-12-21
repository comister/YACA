//
//  Meeting.swift
//  YACA
//
//  Created by Andreas Pfister on 13/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import CoreData
import EventKit

@objc(Meeting)

class Meeting: NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let Details = "details"
        static let StartTime = "starttime"
        static let EndTime = "endtime"
        static let Location = "location"
        static let Participants = "participants"
    }
    
    struct statics {
        static let entityName = "Meeting"
    }
    
    @NSManaged var name: String
    @NSManaged var details: String
    @NSManaged var starttime: NSDate
    @NSManaged var endtime: NSDate
    @NSManaged var location: String
    @NSManaged var participants: [Participant]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Mark: - Standard initializer using dictionary
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(statics.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        // Dictionary
        name = dictionary[Keys.Name] as! String
        details = dictionary[Keys.Details] as! String
        starttime = dictionary[Keys.StartTime] as! NSDate
        endtime = dictionary[Keys.EndTime] as! NSDate
        location = dictionary[Keys.Location] as! String
        
        // Mark: - Convert EKParticipant to Participant and add to attendees
        if let eventAttendees = dictionary[Keys.Participants] as? [EKParticipant] {
            for eventAttendee in eventAttendees {
                self.participants?.append(Participant(attendee: eventAttendee, context: CoreDataStackManager.sharedInstance().managedObjectContext))
            }
        }
        
    }
    
    // Mark: - Overloaded initializer - being able to convert from an EKEvent
    init(event: EKEvent, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName(statics.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        name = event.title
        details = event.description
        starttime = event.startDate
        endtime = event.endDate
        location = event.location!
        
        // Mark: - Convert EKParticipant to Participant and add to attendees
        if let eventAttendees = event.attendees {
            for eventAttendee in eventAttendees {
                self.participants?.append(Participant(attendee: eventAttendee, context: CoreDataStackManager.sharedInstance().managedObjectContext))
            }
        }
    }
}