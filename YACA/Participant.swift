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

@objc(Participant)

class Participant: NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let Location = "location"
        static let Meeting = "meeting"
        static let Weather = "weather"
        static let Timezone = "timezone"
        static let MySelf = "myself"
        static let Email = "email"
    }
    
    struct statics {
        static let entityName = "Participant"
    }
    
    @NSManaged var name: String?
    @NSManaged var email: String
    @NSManaged var location: String?
    @NSManaged var weather: String?
    @NSManaged var timezone: String?
    @NSManaged var myself: Bool
    @NSManaged var meeting: Meeting!
    
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
        location = dictionary[Keys.Location] as? String
        weather = dictionary[Keys.Weather] as? String
        timezone = dictionary[Keys.Timezone] as? String
        myself = dictionary[Keys.MySelf] as! Bool
        
        if dictionary[Keys.Meeting] != nil {
            meeting = dictionary[Keys.Meeting] as! Meeting
        }
        
    }

    init(attendee: EKParticipant?, context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(statics.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        let descriptionDictionary = attendee!.description.componentsSeparatedByString("{")[1].componentsSeparatedByString("}")[0].componentsSeparatedByString("; ")
        var resultDict = [String:String]()
        
        for descriptionComponent in descriptionDictionary {
            let components = descriptionComponent.componentsSeparatedByString(" = ")
            resultDict[components[0]] = components[1]
        }
        
        print("")
        print("---------------------------------------")
        print(resultDict)
        print("---------------------------------------")
        print("")
        print(resultDict["email"])
        
        print("---------------------------------------")
        print("")
        
        
        name = attendee!.name
        email = resultDict["email"]! as String
        myself = attendee!.currentUser
        
        // Mark: - Try to find additional information based on available Contact information --- FINDING: this may be rarely used because of unavailability of Contactdata --- ADDITIONAL FUTURE TODO: Implement LDAP lookup instead for Contact lookup (Exchange)
        if let contact = self.findContactofAttendee(attendee!) {
            if let address = contact.postalAddresses.first {
                let location = address.value as! CNPostalAddress
                self.location = location.city
                RestCountriesClient.sharedInstance().getTimezoneByCountryCode(location.country) { data, error in
                    if let serverData = data {
                        self.timezone = serverData as? String
                    }
                }
                /* Obsolete REST API Call - unsufficient functionality of timezdb Service
                TimezdbClient.sharedInstance().getTimezoneByCity(location.city)  { data, error in }
                */
            }
        } else {
            /*
            print("")
            print("Nothing found")
            print("")
            print(attendee)
            print("")
            */
        }
        
    }
    
    func findContactofAttendee(attendee: EKParticipant) -> CNContact? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var eligibleContact: CNContact? = nil
        
        appDelegate.checkContactsAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                let store = CNContactStore()
                do {
                    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey]
                    if let name = attendee.name {

                        let contacts = try store.unifiedContactsMatchingPredicate(CNContact.predicateForContactsMatchingName(name), keysToFetch: keysToFetch)

                        if let contact = contacts.first {
                            print(contact)
                            if (contact.isKeyAvailable(CNContactPostalAddressesKey)) {
                                eligibleContact = contact
                            } else {
                                // no address found, we are not able to determine where the person is coming from and can not show timezone as well as other information related to the location
                            }
                        }
                    }
                } catch _ {}
            }
        }
        return eligibleContact
    }
}