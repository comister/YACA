//
//  Meeting.swift
//  YACA
//
//  Created by Andreas Pfister on 13/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import EventKit
import CoreData

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
    var currentParticipant: EKParticipant?
    
    var participantArray = [Participant]()
        
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
            
            //self.participants?.addObjectsFromArray(eventAttendees)
            /*
            do {
                try self.fetchedResultsController.performFetch()
            } catch _ {}
            */
            // TODO - marriage between core-data and attendee
            // Check for availability of contact in Core Data
            // In case not found, create new Participant + SAVE!
            // refresh API gathered data (they may have changed meanwhile)
            for eventAttendee in eventAttendees {

                
                //TODO: BUG !!! uses always the same participant ....
                self.currentParticipant = eventAttendee
                
                do {
                    try self.fetchedResultsController.performFetch()
                } catch _ {}
                
                if let storedParticipants = fetchedResultsController.fetchedObjects?.first as? Participant {
                    print("Found participant in Core Data (\(storedParticipants.email) --- \(eventAttendee.name))")
                    participantArray.append(storedParticipants)
                } else {
                    let newParticpant = Participant(attendee: eventAttendee, context: self.sharedContext) as Participant
                    CoreDataStackManager.sharedInstance().saveContext()
                    participantArray.append(newParticpant)
                }
            }
        }
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Would be possible to fetch all necessary participants from Coredata at once by using compoundPredicate, decided to switch back, there is no direct impact on performance and one-by-one facilitates the Object idea in a better manner (IMO)
        /*
        var compoundPredicates = [NSPredicate]()
        for participant in self.participants! {
            compoundPredicates.append( NSPredicate(format: Participant.Keys.Email + " == %@", Participant.getEmailFromEKParticipantDescription( participant as? EKParticipant )! ) )
        }
        */
        
        let fetchRequest = NSFetchRequest(entityName: Participant.statics.entityName)
        fetchRequest.predicate = NSPredicate(format: "email == %@", Participant.getEmailFromEKParticipantDescription( self.currentParticipant )!)
        //fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: compoundPredicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Participant.Keys.Email, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    lazy var fetchedResultsControllerForNote: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Note.statics.entityName)
        fetchRequest.predicate = NSPredicate(format: "meetingId == %@", self.meetingId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Note.Keys.CreatedAt, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func getNote(meetingId: String) -> Note? {
        
        // fetch Notes from CoreData, fetch Meetings & participants from system Calendar
        // Meeting will be related to Notes through meetingId, with that we have a proper reference to get proper notes of meetings
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
    
}