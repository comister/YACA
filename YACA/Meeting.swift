//
//  Meeting.swift
//  YACA
//
//  Created by Andreas Pfister on 13/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import CoreData

@objc(Meeting)

class Meeting: NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let Notes = "notes"
        static let StartTime = "starttime"
        static let EndTime = "starttime"
        static let Duration = "duration"
        static let Location = "location"
        static let Attendees = "attendees"
    }
    
    struct statics {
        static let entityName = "Meeting"
    }
    
    @NSManaged var name: String
    @NSManaged var notes: String
    @NSManaged var starttime: NSDate
    @NSManaged var duration: NSNumber
    @NSManaged var location: String
    @NSManaged var attendees: [Participant]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(statics.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        // Dictionary
        name = dictionary[Keys.Name] as! String
        notes = dictionary[Keys.Notes] as! String
        starttime = dictionary[Keys.StartTime] as! NSDate
        location = dictionary[Keys.Location] as! String
        duration = dictionary[Keys.Duration] as! NSNumber
        
        //path = dictionary[Keys.Path] as? String
        /*
        if dictionary[Keys.Pin] != nil {
        pin = dictionary[Keys.Pin] as! Pin
        }
        */
    }
}