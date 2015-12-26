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
    }

    static func getEmailFromEKParticipantDescription( attendee: EKParticipant? ) -> String? {
        
        if let currentParticipant = attendee {
            let descriptionDictionary = currentParticipant.description.componentsSeparatedByString("{")[1].componentsSeparatedByString("}")[0].componentsSeparatedByString("; ")
            var resultDict = [String:String]()
        
            for descriptionComponent in descriptionDictionary {
                let components = descriptionComponent.componentsSeparatedByString(" = ")
                resultDict[components[0]] = components[1]
            }
            return resultDict["email"]
        } else {
            return ""
        }
    }
    
    init(attendee: EKParticipant?, context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName(statics.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        name = attendee!.name
        email = Participant.getEmailFromEKParticipantDescription(attendee)!
        myself = attendee!.currentUser
        
        // Mark: - Try to find additional information based on available Contact information --- FINDING: this may be rarely used because of unavailability of Contactdata --- ADDITIONAL FUTURE TODO: Implement LDAP lookup instead for Contact lookup (Exchange)
        if let contact = self.findContactofAttendee(attendee!) {
            if let address = contact.postalAddresses.first {
                let location = address.value as! CNPostalAddress
                self.location = location.city
                RestCountriesClient.sharedInstance().getTimezoneByCountryCode(location.country) { data, error in
                    if let _ = error {
                        print("restcountriesclient throwed an error")
                    }
                    if let serverData = data {
                        self.timezone = serverData as? String
                    }
                }
                /* Obsolete REST API Call - unsufficient functionality of timezdb Service
                TimezdbClient.sharedInstance().getTimezoneByCity(location.city)  { data, error in }
                */
            }
        } else {
            // No information in Contacts found, this would be the place to refine search with other services/protocols ...
        }
        
    }
    
    // MARK: - Getting additional information from Contacts like country
    func findContactofAttendee(attendee: EKParticipant) -> CNContact? {
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
                print("no access to Contacts allowed")
            }
        }
        return eligibleContact
    }
}