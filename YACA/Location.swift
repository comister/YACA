//
//  Location.swift
//  YACA
//
//  Created by Andreas Pfister on 27/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

@objc(Location)

class Location: NSManagedObject {

    struct Keys {
        static let Country = "country"
        static let City = "city"
        static let Weather = "weather"
        static let Timezone = "timezone"
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let LastUpdate = "lastUpdate"
        static let People = "people"
    }
    
    struct statics {
        static let entityName = "Location"
    }
    
    @NSManaged var longitude: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var timezone: String?
    @NSManaged var country: String?
    @NSManaged var city: String?
    @NSManaged var weather: String?
    @NSManaged var lastUpdate: NSDate
    @NSManaged var people: [Participant]?

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(statics.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        // Dictionary
        
        country = dictionary[Keys.Country] as? String
        city = dictionary[Keys.City] as? String
        weather = dictionary[Keys.Weather] as? String
        timezone = dictionary[Keys.Timezone] as? String
        longitude = dictionary[Keys.Longitude] as? NSNumber
        latitude = dictionary[Keys.Latitude] as? NSNumber
        lastUpdate = NSDate()
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}
