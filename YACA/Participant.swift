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
//import AddressBook

@objc(Participant)

class Participant: NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let Location = "location"
        static let Meeting = "meeting"
        static let Weather = "weather"
        static let Timezone = "timezone"
        static let MySelf = "myself"
    }
    
    struct statics {
        static let entityName = "Participant"
    }
    
    @NSManaged var name: String?
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
        
        name = attendee!.name
        myself = attendee!.currentUser
        
        if let contact = self.findContactofAttendee(attendee!) {
            let location = contact.postalAddresses.first!.value as! CNPostalAddress
            self.location = location.city
            TimezdbClient.sharedInstance().getTimezoneByCity(location.city)  { data, error in
                print("Searched for timezone information of city " + location.city)
            }
        }
        
    }
    
    func findContactofAttendee(attendee: EKParticipant) -> CNContact? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var eligibleContact: CNContact? = nil
        
        appDelegate.checkContactsAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                let store = CNContactStore()
                /*
                var allContainers: [CNContainer] = []
                do {
                    allContainers = try store.containersMatchingPredicate(nil)
                    print(allContainers)
                } catch {
                    print("Error fetching containers")
                }
                */
                do {
                    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey]
                    if let name = attendee.name {
                        var predicates = [NSPredicate]()
                        predicates.append(CNContact.predicateForContactsInContainerWithIdentifier(NSUserDefaults.standardUserDefaults().stringForKey("selectedContactGroup")!))
                        predicates.append(CNContact.predicateForContactsMatchingName(name))
                        
                        let predicateCompound = NSCompoundPredicate.init(andPredicateWithSubpredicates: predicates)
                        
                        let contacts = try store.unifiedContactsMatchingPredicate(CNContact.predicateForContactsMatchingName(name), keysToFetch: keysToFetch)

                        if let contact = contacts.first {
                            print(contact)
                            if (contact.isKeyAvailable(CNContactPostalAddressesKey)) {
                                eligibleContact = contact
                            } else {
                                // no address found, we are not able to determine where the person is coming from and can not show timezone as well as other infomration related to the location
                            }
                        }
                    }
                } catch _ {}
            }
        }
        return eligibleContact
    }
    
    func updateParticipant(participant: CNContact) {
        print(participant.postalAddresses)
    }
    
}