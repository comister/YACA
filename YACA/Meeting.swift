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
    var participants: NSMutableSet?
    var note: Note?
    
    var participantArray: [Participant]?
    
    // Mark: - Standard initializer using dictionary
    init(dictionary: [String : AnyObject]) {
        // Dictionary
        meetingId = dictionary[Keys.MeetingId] as! String
        name = dictionary[Keys.Name] as! String
        details = dictionary[Keys.Details] as? String
        starttime = dictionary[Keys.StartTime] as! NSDate
        endtime = dictionary[Keys.EndTime] as! NSDate
        location = dictionary[Keys.Location] as? String
        
        // Mark: - Convert EKParticipant to Participant and add to attendees
        if let eventAttendees = dictionary[Keys.Participants] as? [EKParticipant] {
            for eventAttendee in eventAttendees {
                let newParticpant = Participant(attendee: eventAttendee, context: CoreDataStackManager.sharedInstance().managedObjectContext) as Participant
                self.participants?.addObject(newParticpant)
                participantArray?.append(newParticpant)
            }
        }
        
    }
    
    // Mark: - Overloaded initializer - being able to convert from an EKEvent
    init(event: EKEvent) {
        
        meetingId = event.eventIdentifier
        name = event.title
        details = event.description
        starttime = event.startDate
        endtime = event.endDate
        location = event.location
        super.init()
        note = getNote(event.eventIdentifier)
        
        // Mark: - Convert EKParticipant to Participant and add to attendees
        if let eventAttendees = event.attendees {
            
            self.participants?.addObjectsFromArray(event.attendees!)
            do {
                try self.fetchedResultsController.performFetch()
            } catch _ {}
            
            // TODO - marriage between core-data and event
            // Check for availability of contact in Core Data
            // In case not found, create new Participant + SAVE!
            // refresh API gathered data (they may have changed meanwhile)
            
            for eventAttendee in eventAttendees {
                eventAttendee
                //self.participants?.append(Participant(attendee: eventAttendee, context: CoreDataStackManager.sharedInstance().managedObjectContext) as Participant)
                let newParticpant = Participant(attendee: eventAttendee, context: CoreDataStackManager.sharedInstance().managedObjectContext) as Participant
                self.participants?.addObject(newParticpant)
                participantArray?.append(newParticpant)
            }
        }
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        var compoundPredicates = [NSPredicate]()
        for participant in self.participants! {
            compoundPredicates.append( NSPredicate(format: Participant.Keys.Email + " == %@", Participant.getEmailFromEKParticipantDescription( participant as? EKParticipant )! ) )
        }
        
        let fetchRequest = NSFetchRequest(entityName: Participant.statics.entityName)
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: compoundPredicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Participant.Keys.Name, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    lazy var fetchedResultsControllerForNote: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Note.statics.entityName)
        fetchRequest.predicate = NSPredicate(format: Note.Keys.MeetingId + " == %@", self.meetingId)
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