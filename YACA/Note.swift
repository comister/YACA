//
//  Notes.swift
//  YACA
//
//  Created by Andreas Pfister on 21/12/15.
//  Copyright © 2015 AP. All rights reserved.
//
import Foundation
import CoreData
import EventKit

@objc(Note)

class Note: NSManagedObject {
    
    struct Keys {
        static let Note = "note"
        static let MeetingId = "meetingId"
        static let MeetingTitle = "meetingTitle"
        static let CreatedAt = "createdAt"
    }
    
    struct statics {
        static let entityName = "Note"
    }
    
    @NSManaged var note: String
    @NSManaged var meetingId: String
    @NSManaged var meetingTitle: String
    @NSManaged var createdAt: Date
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // Mark: - Standard initializer using dictionary
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: statics.entityName, in: context)!
        super.init(entity: entity, insertInto: context)
        // Dictionary
        note = dictionary[Keys.Note] as! String
        meetingId = dictionary[Keys.MeetingId] as! String
        meetingTitle = dictionary[Keys.MeetingTitle] as! String
        // set createdAt to actual Date, do not have to bother about this outside of the Model !
        createdAt = Date()
    }
}
