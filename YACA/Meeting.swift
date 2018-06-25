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
import CoreLocation

protocol MeetingDelegate : class {
    func MeetingDidCreate()
    func ConnectivityProblem(_ status: Bool)
}

class Meeting: NSObject, CLLocationManagerDelegate {
    
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
    
    var locationManager: CLLocationManager!
    var locationStatus: String?
    var locationAvailable: Bool = false
    
    var meetingId: String
    var name: String
    var details: String?
    var starttime: Date
    var endtime: Date
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

        // Init Location Services
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        
        // Mark: - Convert EKParticipant to Participant and add to attendees
        if let eventAttendees = event.attendees {
            attendeesToCreate = eventAttendees.count
            for eventAttendee in eventAttendees {
                getParticipant(eventAttendee, context: self.sharedContext) {
                    participant, didUpdate, error in
                    
                    if participant != nil {
                        self.participantArray.append(participant!)
                        if didUpdate && error == nil {
                            self.delegate?.ConnectivityProblem(false)
                        }
                    }
                    if let connectivityError = error {
                        if didUpdate && (connectivityError.code == GoogleAPIClient.ErrorKeys.Timeout || connectivityError.code == GoogleAPIClient.ErrorKeys.Offline) {
                            // indicate connectivity problems through delegate
                            self.delegate?.ConnectivityProblem(true)
                        } else if connectivityError.code != GoogleAPIClient.ErrorKeys.Timeout && connectivityError.code != GoogleAPIClient.ErrorKeys.Offline {
                            self.delegate?.ConnectivityProblem(false)
                        }
                    }
                    self.attendeesToCreate -= 1
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
            } else if status == .authorizedWhenInUse || status == .restricted || status == .denied {
                let alertController = UIAlertController(
                    title: "Background Location Access Disabled",
                    message: "To be able to see information about your current location it is recommended to enable location access.",
                    preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                    if let url = URL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                }
                alertController.addAction(openAction)
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
    }
    
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }

    lazy var fetchedResultsControllerForNote: NSFetchedResultsController<Note> = {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Note.statics.entityName)
        fetchRequest.predicate = NSPredicate(format: "meetingId == %@", self.meetingId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Note.Keys.CreatedAt, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController as! NSFetchedResultsController<Note>
        
    }()
    
    func getNote(_ meetingId: String) -> Note? {
        self.meetingId = meetingId
        do {
            try fetchedResultsControllerForNote.performFetch()
        } catch _ { }
        
        if let note = fetchedResultsControllerForNote.fetchedObjects?.first {
            return note
        } else {
            return nil
        }
    }
    
    func getParticipant(_ attendee: EKParticipant, context: NSManagedObjectContext, completionHandler: @escaping (_ result: Participant?, _ didUpdate: Bool, _ error: NSError?) -> Void) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Participant.statics.entityName)
        fetchRequest.predicate = NSPredicate(format: "email == %@", attendee.getEmail())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Participant.Keys.Email, ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {}
        
        // MARK: - check if participant exists in Coredata
        if let storedParticipants = fetchedResultsController.fetchedObjects?.first as? Participant {
            self.getLocationInformation(storedParticipants, context: self.sharedContext) { location, didUpdate, error in
                
                if let locationData = location {
                    if locationData["doesExist"] as! Bool == true {
                        if locationData[Location.Keys.Weather] != nil {
                            // Change NSManagedObject ONLY in main thread !!
                            DispatchQueue.main.async {
                                storedParticipants.location?.weather = locationData[Location.Keys.Weather] as? String
                                storedParticipants.location?.weather_description = locationData[Location.Keys.WeatherDescription] as? String
                                storedParticipants.location?.weather_temp = locationData[Location.Keys.WeatherTemperature] as? NSNumber
                                storedParticipants.location?.weather_temp_unit = locationData[Location.Keys.WeatherTemperatureUnit] as? NSNumber
                                storedParticipants.location?.lastUpdate = locationData[Location.Keys.LastUpdate]! as! Date
                            }
                        }
                        
                        CoreDataStackManager.sharedInstance().saveContext() {
                            completionHandler(storedParticipants, didUpdate, nil)
                        }
                        return
                    } else {
                        DispatchQueue.main.async {
                            storedParticipants.location = Location(dictionary: locationData, context: self.sharedContext)
                        }
                        CoreDataStackManager.sharedInstance().saveContext() {
                            completionHandler(storedParticipants, didUpdate, nil)
                        }
                        return
                    }
                } else {
                    //no GEOInformation
                    CoreDataStackManager.sharedInstance().saveContext() {
                        completionHandler(storedParticipants, didUpdate, error)
                    }
                    return
                }
            }
        } else {
            let newParticipant = Participant(attendee: attendee, context: self.sharedContext) as Participant
            self.getLocationInformation(newParticipant, context: self.sharedContext) { location, didUpdate, error in
                if let locationData = location {
                    if locationData["doesExist"] as! Bool == true {
                        if locationData[Location.Keys.Weather] != nil {
                            DispatchQueue.main.async {
                                newParticipant.location?.weather = locationData[Location.Keys.Weather] as? String
                                newParticipant.location?.weather_description = locationData[Location.Keys.WeatherDescription] as? String
                                newParticipant.location?.weather_temp = locationData[Location.Keys.WeatherTemperature] as? NSNumber
                                newParticipant.location?.weather_temp_unit = locationData[Location.Keys.WeatherTemperatureUnit] as? NSNumber
                                newParticipant.location?.lastUpdate = Date()
                            }
                        }
                        CoreDataStackManager.sharedInstance().saveContext() {
                            completionHandler(newParticipant, didUpdate, nil)
                        }
                        return
                    } else {
                        DispatchQueue.main.async {
                            newParticipant.location = Location(dictionary: locationData, context: self.sharedContext)
                        }
                        CoreDataStackManager.sharedInstance().saveContext() {
                            completionHandler(newParticipant, didUpdate, nil)
                        }
                        return
                    }
                } else {
                    //no GEOInformation
                    CoreDataStackManager.sharedInstance().saveContext() {
                        completionHandler(newParticipant, didUpdate, error)
                    }
                    return
                }
            }
        }
    }
    
    func getLocationInformation(_ attendee: Participant?, context: NSManagedObjectContext, completionHandler: @escaping (_ result: [String:AnyObject]? , _ didUpdate: Bool, _ error: NSError?) -> Void) {
        
        var coordinateDetermination: CLLocationCoordinate2D?
        var location: [String:String] = ["country":"","city":""]
        
        //Retrieving current location if attendee is the user itself
        if attendee == nil {
            completionHandler(nil, false, NSError(domain: "Not ready yet, waiting for different authorizations -- this usually happens at startup only", code: 0, userInfo: nil))
            return
        }
        if attendee!.myself {
            if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                coordinateDetermination = locationManager.location?.coordinate
                
                self.getLocationDetails(coordinateDetermination, locationDescription: location, context: context) { location, didUpdate, error in    
                    completionHandler(location, didUpdate, error)
                    return
                }
                
                // MARK: - We dont do that anymore ( to unresponsive in case of no network connectivity and no possibility to control any timeouts), pulling information about city from openweather
                /*
                geocoder.reverseGeocodeLocation(locationManager.location!) {
                    placemarks, error in
                    
                    if placemarks == nil {
                        completionHandler(result: nil, didUpdate: true, error: NSError(domain: "GEOCoder",code: -1001, userInfo: nil))
                        return
                    }
                    
                    if let placemark = placemarks![0] as? CLPlacemark {
                        location["country"] = placemark.country
                        location["city"] = placemark.locality
                        self.getLocationDetails(coordinateDetermination, locationDescription: location, context: context) { location, didUpdate, error in
                            
                            completionHandler(result: location, didUpdate: didUpdate, error: error)
                            return
                        }
                    }
                }*/
            }

        } else if let possibleAddressObject = self.findContactofAttendee(attendee!.name) {
            
            if let addressObject = possibleAddressObject.postalAddresses.first {
                let contactsLocation = addressObject.value
                location["country"] = contactsLocation.country
                location["city"] = contactsLocation.city
                
                let address = contactsLocation.city + (contactsLocation.country != "" ? ", " + contactsLocation.country : "")
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in

                    if placemarks == nil {
                        if error != nil {
                            completionHandler(nil, false, NSError(domain: "GEOCoder",code: -1001, userInfo: nil))
                        } else {
                            completionHandler(nil, false, NSError(domain: "Was not able to determine coordinates for location", code: 0, userInfo: nil))
                        }
                        return
                    }
                    
                    if let placemark = placemarks![0] as? CLPlacemark {
                        coordinateDetermination = placemark.location?.coordinate
                        
                        self.getLocationDetails(coordinateDetermination, locationDescription: location, context: context) { location, didUpdate, error in
                            
                            completionHandler(location, didUpdate, error)
                            return
                        }
                    }
                })
            }
        }
    }
    
    func getLocationDetails(_ coordinateDetermination: CLLocationCoordinate2D?, locationDescription: [String:String], context: NSManagedObjectContext, completionHandler: @escaping (_ result: [String:AnyObject]? , _ didUpdate: Bool, _ error: NSError?) -> Void) {
        
        if let coordinates = coordinateDetermination {
            
            // MARK: - lookup Core Data for existing Location entry
            // in addition, check on lastUpdate date and update if older than an hour
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Location.statics.entityName)
            var compoundPredicates = [NSPredicate]()
            compoundPredicates.append( NSPredicate(format: Location.Keys.Longitude + " == %lf", coordinates.longitude ) )
            compoundPredicates.append( NSPredicate(format: Location.Keys.Latitude + " == %lf", coordinates.latitude ) )
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: compoundPredicates)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: Location.Keys.LastUpdate, ascending: false)]
            
            let fetchedResultsControllerForLocation = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            do {
                try fetchedResultsControllerForLocation.performFetch()
            } catch _ {}
            
            var returnDictionary = [String:AnyObject]()
            
            if let storedLocation = fetchedResultsControllerForLocation.fetchedObjects?.first as? Location {
                returnDictionary[Location.Keys.City] = storedLocation.city as AnyObject
                returnDictionary[Location.Keys.Country] = storedLocation.country as AnyObject
                returnDictionary[Location.Keys.Latitude] = storedLocation.latitude
                returnDictionary[Location.Keys.Longitude] = storedLocation.longitude
                returnDictionary[Location.Keys.TimezoneOffset] = storedLocation.timezoneOffset
                returnDictionary[Location.Keys.LastUpdate] = storedLocation.lastUpdate as AnyObject
                returnDictionary[Location.Keys.WeatherTemperatureUnit] = storedLocation.weather_temp_unit
                returnDictionary["doesExist"] = true as AnyObject
                
                // MARK: - check for actuality of data and refresh if older than an hour
                if Date().timeIntervalSince(storedLocation.lastUpdate as Date) > 3600 || storedLocation.weather == nil || Int(truncating: storedLocation.weather_temp_unit!) != UserDefaults.standard.integer(forKey: "temperatureIndex") {
                    
                    GoogleAPIClient.sharedInstance().getTimeOfLocation( lat: NSNumber(value: coordinates.latitude), long: NSNumber(value: coordinates.longitude)) { timezoneInfo, timezoneError in
                        
                        if let _ = timezoneError {
                            completionHandler(nil, true, timezoneError)
                            return
                        } else {
                            returnDictionary[Location.Keys.TimezoneOffset] = timezoneInfo as AnyObject
                        }
                        
                        OpenWeatherClient.sharedInstance().getWeatherByLatLong(NSNumber(value: coordinates.latitude), long: NSNumber(value: coordinates.longitude), unitIndex: UserDefaults.standard.integer(forKey: "temperatureIndex"))  { data, error in
                            if let _ = error {
                                completionHandler(returnDictionary, true, error)
                                return
                            } else {
                                // this should never happen, but check to get sure
                                if data != nil {
                                    returnDictionary[Location.Keys.Weather] = data!["weather"]
                                    returnDictionary[Location.Keys.WeatherDescription] = data!["weather_description"]
                                    returnDictionary[Location.Keys.WeatherTemperature] = data!["weather_temp"]
                                    returnDictionary[Location.Keys.WeatherTemperatureUnit] = UserDefaults.standard.integer(forKey: "temperatureIndex") as AnyObject
                                    returnDictionary[Location.Keys.LastUpdate] = Date() as AnyObject
                                    
                                }
                                completionHandler(returnDictionary, true, nil)
                                return
                            }
                        }
                    }
                    
                } else {
                    completionHandler(returnDictionary, false, nil)
                    return
                }
                
            } else {
                GoogleAPIClient.sharedInstance().getTimeOfLocation(lat: NSNumber(value: coordinates.latitude), long: NSNumber(value: coordinates.longitude)) { timezoneInfo, timezoneError in
                    
                    if let anError = timezoneError {
                        completionHandler(nil, true, anError)
                        return
                    }
                    
                    OpenWeatherClient.sharedInstance().getWeatherByLatLong(NSNumber(value: coordinates.latitude), long: NSNumber(value: coordinates.longitude), unitIndex: UserDefaults.standard.integer(forKey: "temperatureIndex"))  { data, error in
                        if let anError = error {
                            completionHandler(nil, true, anError)
                            return
                        } else {
                            // Create new Location
                            let newLocationDict: [String:AnyObject] = [
                                Location.Keys.City               : locationDescription["city"] != "" ? locationDescription["city"] as AnyObject : data != nil ? data!["city"] as AnyObject : "" as AnyObject,
                                Location.Keys.Country            : locationDescription["country"] != "" ? locationDescription["country"] as AnyObject : data != nil ? data!["country"] as AnyObject : "" as AnyObject,
                                Location.Keys.Latitude           : coordinates.latitude as AnyObject,
                                Location.Keys.Longitude          : coordinates.longitude as AnyObject,
                                Location.Keys.Weather            : data != nil && data!["weather"] != nil ? data!["weather"] as AnyObject : "" as AnyObject,
                                Location.Keys.WeatherDescription : data != nil && data!["weather_description"] != nil ? data!["weather_description"] as AnyObject : "" as AnyObject,
                                Location.Keys.WeatherTemperature : data != nil && data!["weather_temp"] != nil ? data!["weather_temp"] as AnyObject : 0.0 as AnyObject,
                                Location.Keys.WeatherTemperatureUnit : UserDefaults.standard.integer(forKey: "temperatureIndex") as AnyObject,
                                Location.Keys.LastUpdate         : Date() as AnyObject,
                                Location.Keys.TimezoneOffset     : timezoneInfo! as AnyObject,
                                "doesExist"                      : false as AnyObject
                            ]
                            completionHandler(newLocationDict, true, nil)
                            return
                        }
                    }
                }
            }
        } else {
            completionHandler(nil, false, nil)
            return
        }
    }
    
    // MARK: - Getting additional information from Contacts like country
    func findContactofAttendee(_ attendeeName: String?) -> CNContact? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var eligibleContact: CNContact? = nil
        
        // if access allowed to Contacts, going to search for an eligible contact with same name than in event
        appDelegate.checkContactsAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                let store = CNContactStore()
                do {
                    // Fetching interesting information, whereat we only use PostalAddress at the moment
                    //let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey]
                    let keysToFetch = [CNContactPostalAddressesKey]
                    
                    if let name = attendeeName {
                        let contacts = try store.unifiedContacts(matching: CNContact.predicateForContacts(matchingName: name), keysToFetch: keysToFetch as [CNKeyDescriptor])
                        if let contact = contacts.first {
                            if (contact.isKeyAvailable(CNContactPostalAddressesKey)) {
                                if contact.postalAddresses.count > 0 {
                                    eligibleContact = contact
                                }
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
