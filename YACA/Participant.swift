//
//  Participant.swift
//  YACA
//
//  Created by Andreas Pfister on 13/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import EventKit
import Contacts
import CoreLocation

@objc(Participant)

class Participant: NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let MySelf = "myself"
        static let Email = "email"
    }
    
    struct statics {
        static let entityName = "Participant"
    }
    
    @NSManaged var name: String?
    @NSManaged var email: String
    @NSManaged var myself: Bool
    @NSManaged var location: Location?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(statics.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        // Dictionary
        
        name = dictionary[Keys.Name] as? String
        email = dictionary[Keys.Email] as! String
        myself = dictionary[Keys.MySelf] as! Bool
    }

    init(attendee: EKParticipant?, context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(statics.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        name = attendee!.name
        email = attendee!.getEmail()
        myself = attendee!.currentUser
    }
}