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

@objc(Notes)

class Note: NSManagedObject {
    
    struct Keys {
        static let Notes = "notes"
        static let CreatedAt = "createdAt"
    }
    
    struct statics {
        static let entityName = "Note"
    }
    
    @NSManaged var notes: String
    @NSManaged var createdAt: NSDate
    @NSManaged var meeting: Meeting
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Mark: - Standard initializer using dictionary
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(statics.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        // Dictionary
        notes = dictionary[Keys.Notes] as! String
        
        // set createdAt to actual Date, do not have to bother about this outside of the Model !
        createdAt = NSDate()
    }
}