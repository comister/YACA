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
        static let WeatherDescription = "weather_description"
        static let WeatherTemperature = "weather_temp"
        static let WeatherTemperatureUnit = "weather_temp_unit"
        static let TimezoneOffset = "timezoneOffset"
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
    @NSManaged var timezoneOffset: NSNumber?
    @NSManaged var country: String?
    @NSManaged var city: String?
    @NSManaged var weather: String?
    @NSManaged var weather_description: String?
    @NSManaged var weather_temp: NSNumber?
    @NSManaged var weather_temp_unit: NSNumber?
    @NSManaged var lastUpdate: Date
    @NSManaged var people: [Participant]?

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: statics.entityName, in: context)!
        super.init(entity: entity, insertInto: context)
        // Dictionary
        country = dictionary[Keys.Country] as? String
        city = dictionary[Keys.City] as? String
        weather = dictionary[Keys.Weather] as? String
        timezoneOffset = dictionary[Keys.TimezoneOffset] as? NSNumber
        longitude = dictionary[Keys.Longitude] as? NSNumber
        latitude = dictionary[Keys.Latitude] as? NSNumber
        weather_description = dictionary[Keys.WeatherDescription] as? String
        weather_temp = dictionary[Keys.WeatherTemperature] as? NSNumber
        weather_temp_unit = dictionary[Keys.WeatherTemperatureUnit] as? NSNumber
        lastUpdate = Date()
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
