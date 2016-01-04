//
//  Meeting.swift
//  YACA
//
//  Created by Andreas Pfister on 13/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import Contacts
import CoreData

protocol MeetingDelegate : class {
    func MeetingDidCreate()
}

class Meeting: NSObject {
    
    struct Keys {
        static let MeetingId = "meetingId"
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
    
    var meetingId: String
    var name: String
    var details: String?
    var starttime: NSDate
    var endtime: NSDate
    var location: String?
    var note: Note? {
        get {
            // always get from Core Data
            return getNote(self.meetingId)
        }
        set {}
    }
    
    // MARK: Keeps track of attendees under creation and fires delegate method as soon as at 0
    var attendeesToCreate: Int = 0 {
        didSet {
            if attendeesToCreate == 0 {
                self.delegate?.MeetingDidCreate()
            }
        }
    }
    
    var currentParticipant: EKParticipant?
    var participantArray = [Participant]()
    weak var delegate : MeetingDelegate?
    
    // Mark: - Overloaded initializer - being able to convert from an EKEvent
    init(event: EKEvent) {
        meetingId = event.eventIdentifier
        name = event.title
        details = event.description
        starttime = event.startDate
        endtime = event.endDate
        location = event.location
        super.init()

        // Mark: - Convert EKParticipant to Participant and add to attendees
        if let eventAttendees = event.attendees {
            attendeesToCreate = eventAttendees.count - 1
            for eventAttendee in eventAttendees {
                getParticipant(eventAttendee, context: self.sharedContext) {
                    participant, error in
                    if error == nil {
                        self.participantArray.append(participant!)
                    }
                    self.attendeesToCreate--
                }
            }
        }
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }

    lazy var fetchedResultsControllerForNote: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Note.statics.entityName)
        fetchRequest.predicate = NSPredicate(format: "meetingId == %@", self.meetingId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Note.Keys.CreatedAt, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func getNote(meetingId: String) -> Note? {
        self.meetingId = meetingId
        do {
            try fetchedResultsControllerForNote.performFetch()
        } catch _ { }
        
        if let note = fetchedResultsControllerForNote.fetchedObjects?.first {
            return note as? Note
        } else {
            return nil
        }
    }
    
    func getParticipant(attendee: EKParticipant, context: NSManagedObjectContext, completionHandler: (result: Participant? , error: NSError?) -> Void) {
        
        let fetchRequest = NSFetchRequest(entityName: Participant.statics.entityName)
        fetchRequest.predicate = NSPredicate(format: "email == %@", attendee.getEmail())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Participant.Keys.Email, ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {}
        
        // MARK: - check if participant exists in Coredata
        if let storedParticipants = fetchedResultsController.fetchedObjects?.first as? Participant {
            
            self.getLocationInformation(storedParticipants, context: self.sharedContext) { location, error in
                if let locationData = location {
                    if locationData["doesExist"] as! Bool == true {
                        if locationData[Location.Keys.Weather] != nil {
                            storedParticipants.location?.weather = locationData[Location.Keys.Weather] as? String
                            storedParticipants.location?.weather_description = locationData[Location.Keys.WeatherDescription] as? String
                            storedParticipants.location?.weather_temp = locationData[Location.Keys.WeatherTemperature] as? NSNumber
                            storedParticipants.location?.weather_temp_unit = locationData[Location.Keys.WeatherTemperatureUnit] as? NSNumber
                            storedParticipants.location?.lastUpdate = locationData[Location.Keys.LastUpdate]! as! NSDate
                        }
                        
                        CoreDataStackManager.sharedInstance().saveContext() {
                            completionHandler(result: storedParticipants, error: nil)
                        }
                        
                        return
                    } else {
                        storedParticipants.location = Location(dictionary: locationData, context: self.sharedContext)
                        CoreDataStackManager.sharedInstance().saveContext() {
                            completionHandler(result: storedParticipants, error: nil)
                        }
                        return
                    }
                } else {
                    //no GEOInformation
                    completionHandler(result: storedParticipants, error: nil)
                    return
                }
            }
        } else {
            let newParticipant = Participant(attendee: attendee, context: self.sharedContext) as Participant
            self.getLocationInformation(newParticipant, context: self.sharedContext) { location, error in
                if let locationData = location {
                    if locationData["doesExist"] as! Bool == true {
                        if locationData[Location.Keys.Weather] != nil {
                            newParticipant.location?.weather = locationData[Location.Keys.Weather] as? String
                            newParticipant.location?.weather_description = locationData[Location.Keys.WeatherDescription] as? String
                            newParticipant.location?.weather_temp = locationData[Location.Keys.WeatherTemperature] as? NSNumber
                            newParticipant.location?.weather_temp_unit = locationData[Location.Keys.WeatherTemperatureUnit] as? NSNumber
                            newParticipant.location?.lastUpdate = NSDate()
                        }
                        CoreDataStackManager.sharedInstance().saveContext() {
                            completionHandler(result: newParticipant, error: nil)
                            //self.attendeesToCreate--
                        }
                        return
                    } else {
                        newParticipant.location = Location(dictionary: locationData, context: self.sharedContext)
                        CoreDataStackManager.sharedInstance().saveContext() {
                            completionHandler(result: newParticipant, error: nil)
                            //self.attendeesToCreate--
                        }
                        return
                    }
                } else {
                    //no GEOInformation
                    completionHandler(result: newParticipant, error: nil)
                    //self.attendeesToCreate--
                    return
                }
            }
        }
    }
    
    func getLocationInformation(attendee: Participant, context: NSManagedObjectContext, completionHandler: (result: [String:AnyObject]? , error: NSError?) -> Void) {
        let geocoder = CLGeocoder()
        if let possibleAddressObject = self.findContactofAttendee(attendee) {
            if let addressObject = possibleAddressObject.postalAddresses.first {
                let location = addressObject.value as! CNPostalAddress
                let address = location.city + ", " + location.country
                geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                    if placemarks == nil {
                        completionHandler(result: nil, error: NSError(domain: "Was not able to determine coordinates for location", code: 0, userInfo: nil))
                        return
                    }
                    if let placemark = placemarks![0] as? CLPlacemark {

                        // MARK: - lookup Core Data for existing Location entry
                        // in addition, check on lastUpdate date and update if older than an hour
                        let fetchRequest = NSFetchRequest(entityName: Location.statics.entityName)
                        var compoundPredicates = [NSPredicate]()
                        compoundPredicates.append( NSPredicate(format: Location.Keys.Longitude + " == %lf", placemark.location!.coordinate.longitude ) )
                        compoundPredicates.append( NSPredicate(format: Location.Keys.Latitude + " == %lf", placemark.location!.coordinate.latitude ) )
                        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: compoundPredicates)
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Location.Keys.LastUpdate, ascending: false)]
                        
                        let fetchedResultsControllerForLocation = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                        
                        do {
                            try fetchedResultsControllerForLocation.performFetch()
                        } catch _ {}
                        
                        var returnDictionary = [String:AnyObject]()

                        if let storedLocation = fetchedResultsControllerForLocation.fetchedObjects?.first as? Location {
                            returnDictionary[Location.Keys.City] = storedLocation.city
                            returnDictionary[Location.Keys.Country] = storedLocation.country
                            returnDictionary[Location.Keys.Latitude] = storedLocation.latitude
                            returnDictionary[Location.Keys.Longitude] = storedLocation.longitude
                            returnDictionary[Location.Keys.TimezoneOffset] = storedLocation.timezoneOffset
                            returnDictionary[Location.Keys.LastUpdate] = storedLocation.lastUpdate
                            returnDictionary[Location.Keys.WeatherTemperatureUnit] = storedLocation.weather_temp_unit
                            returnDictionary["doesExist"] = true
                            
                            // MARK: - check for actuality of data and refresh if older than an hour
                            if NSDate().timeIntervalSinceDate(storedLocation.lastUpdate) > 3600 || storedLocation.weather == nil || storedLocation.weather_temp_unit != NSUserDefaults.standardUserDefaults().integerForKey("temperatureIndex") {
                                
                                GoogleAPIClient.sharedInstance().getTimeOfLocation(placemark.location!.coordinate.latitude, long: placemark.location!.coordinate.longitude) { timezoneInfo, timezoneError in
                                
                                    if let _ = timezoneError {
                                        completionHandler(result: nil, error: NSError(domain: "Not able to get result from google timezone API", code: 0, userInfo: nil))
                                    } else {
                                        returnDictionary[Location.Keys.TimezoneOffset] = timezoneInfo
                                    }
                                    
                                    OpenWeatherClient.sharedInstance().getWeatherByLatLong(placemark.location!.coordinate.latitude, long: placemark.location!.coordinate.longitude, unitIndex: NSUserDefaults.standardUserDefaults().integerForKey("temperatureIndex"))  { data, error in
                                        if let anError = error {
                                            completionHandler(result: returnDictionary, error: NSError(domain: "Not able to get result from openweather Client: " + anError.localizedDescription, code: 0, userInfo: nil))
                                        return
                                        } else {
                                            // this should never happen, but check to get sure
                                            if data != nil {
                                                returnDictionary[Location.Keys.Weather] = data!["weather"]
                                                returnDictionary[Location.Keys.WeatherDescription] = data!["weather_description"]
                                                returnDictionary[Location.Keys.WeatherTemperature] = data!["weather_temp"]
                                                returnDictionary[Location.Keys.WeatherTemperatureUnit] = NSUserDefaults.standardUserDefaults().integerForKey("temperatureIndex")
                                                returnDictionary[Location.Keys.LastUpdate] = NSDate()
                                            
                                            }
                                            completionHandler(result: returnDictionary, error: nil)
                                            return
                                        }
                                    }
                                }
                                
                            } else {
                                
                                //print("no update required, using \"cached\" information of " + location.city)
                                //print("Last Update happened : " + String(NSDate().timeIntervalSinceDate(storedLocation.lastUpdate)/60) + " minutes ago")
                                completionHandler(result: returnDictionary, error: nil)
                                return
                            }
                            
                        } else {
                            print(fetchedResultsControllerForLocation.fetchedObjects)
                            
                            GoogleAPIClient.sharedInstance().getTimeOfLocation(placemark.location!.coordinate.latitude, long: placemark.location!.coordinate.longitude) { timezoneInfo, timezoneError in
                                
                                if let anError = timezoneError {
                                    completionHandler(result: nil, error: anError)
                                    return
                                }
                                
                                OpenWeatherClient.sharedInstance().getWeatherByLatLong(placemark.location!.coordinate.latitude, long: placemark.location!.coordinate.longitude, unitIndex: NSUserDefaults.standardUserDefaults().integerForKey("temperatureIndex"))  { data, error in
                                    if let anError = error {
                                        completionHandler(result: nil, error: anError)
                                        return
                                    } else {
                                        // Create new Location
                                        let newLocationDict: [String:AnyObject] = [
                                            Location.Keys.City               : location.city,
                                            Location.Keys.Country            : location.country,
                                            Location.Keys.Latitude           : placemark.location!.coordinate.latitude,
                                            Location.Keys.Longitude          : placemark.location!.coordinate.longitude,
                                            Location.Keys.Weather            : data != nil ? data!["weather"]! : "",
                                            Location.Keys.WeatherDescription : data != nil ? data!["weather_description"]! : "",
                                            Location.Keys.WeatherTemperature : data != nil ? data!["weather_temp"]! : 0.0,
                                            Location.Keys.WeatherTemperatureUnit : NSUserDefaults.standardUserDefaults().integerForKey("temperatureIndex"),
                                            Location.Keys.LastUpdate         : NSDate(),
                                            Location.Keys.TimezoneOffset     : timezoneInfo!,
                                            "doesExist"                      : false
                                        ]
                                        completionHandler(result: newLocationDict, error: nil)
                                        return
                                    }
                                }
                            }
                        }
                    }
                })
            }
        } else {
            completionHandler(result: nil, error: nil)
            return
        }
    }
    
    // MARK: - Getting additional information from Contacts like country
    func findContactofAttendee(attendee: Participant) -> CNContact? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var eligibleContact: CNContact? = nil
        
        // if access allowed to Contacts, going to search for an eligible contact with same name than in event
        appDelegate.checkContactsAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                let store = CNContactStore()
                do {
                    // Fetching interesting information, whereat we only use PostalAddress at the moment
                    //let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey]
                    let keysToFetch = [CNContactPostalAddressesKey]
                    if let name = attendee.name {
                        let contacts = try store.unifiedContactsMatchingPredicate(CNContact.predicateForContactsMatchingName(name), keysToFetch: keysToFetch)
                        if let contact = contacts.first {
                            if (contact.isKeyAvailable(CNContactPostalAddressesKey)) {
                                eligibleContact = contact
                            } else {
                                // no address found, we are not able to determine where the person is coming from and can not show timezone as well as other information related to the location
                            }
                        }
                    }
                } catch _ {}
            } else {
                // MARK: - This scenario will be handled by the MeetingsViewController
                print("no access to Contacts allowed")
            }
        }
        return eligibleContact
    }
}