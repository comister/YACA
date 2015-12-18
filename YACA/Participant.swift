//
//  Participant.swift
//  YACA
//
//  Created by Andreas Pfister on 13/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import CoreData

@objc(Participant)

class Participant: NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let Location = "location"
    }
    
    struct statics {
        static let entityName = "Participant"
    }
    
    @NSManaged var name: String
    @NSManaged var location: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(statics.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        // Dictionary
        name = dictionary[Keys.Name] as! String
        location = dictionary[Keys.Location] as! String
        
        //path = dictionary[Keys.Path] as? String
        /*
        if dictionary[Keys.Pin] != nil {
        pin = dictionary[Keys.Pin] as! Pin
        }
        */
    }
}