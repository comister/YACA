//
//  MeetingsViewController.swift
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


class MeetingsViewController: UIViewController {
    
    var backgroundGradient: CAGradientLayer? = nil
    var meeting: Meeting!
    var events: [EKEvent]?
    let eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var selectedCalendar: String?
    @IBOutlet weak var meetingCollectionView: UICollectionView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var calendarName: UILabel!
    
    override func viewDidLoad() {
        self.meetingCollectionView?.registerNib(UINib(nibName: "MeetingListCellHeader", bundle: nil), forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: "meetingCellHeader")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        //loadCalendars()
        
        // MARK: - Load Events from selected Calendar
        if (NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar") != nil) {
            self.selectedCalendar = NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar")
            calendarName.text = self.eventStore.calendarWithIdentifier(self.selectedCalendar!)?.title
        } else {
            //transition to settings
            performSegueWithIdentifier("showSettings", sender: self)
            return
        }
        
        loadEvents()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSettings" {
            if let controller = segue.destinationViewController as? SettingsViewController {
                if self.selectedCalendar == nil {
                    print("first run")
                }
            }
        }
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Meeting.statics.entityName)
        fetchRequest.predicate = NSPredicate(format: "meeting == %@", self.meeting)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Meeting.Keys.Name, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
}

// MARK: - CollectionView related methods
extension MeetingsViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        //something to do when clicked
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerCell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "meetingCellHeader", forIndexPath: indexPath) as? MeetingListCellHeader
        
        return headerCell!
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*
        let sectionInfo = self.fetchedResultsController.sections![section]
        print(String(sectionInfo.numberOfObjects) + " Objects to show")
        return sectionInfo.numberOfObjects
        */
        if let events = self.events {
            return events.count
        } else {
            return 1
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("meetingViewCell", forIndexPath: indexPath) as! MeetingListCell
        
        if let events = self.events {
            cell.event = events[indexPath.row] as EKEvent!
            cell.events = events
            cell.calendarName?.text = cell.event!.title
            //cell.contentView.tag = indexPath.row
            cell.cellIdentifier = "meetingParticipant_" + String(indexPath.row)
            cell.participantTable.reloadData()
        } else {
            cell.calendarName?.text = "No Events to show"
        }
        
        return cell
        
    }
}

// MARK: - Customize UI

extension MeetingsViewController {
    
    func configureUI() {
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clearColor()
        //let colorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        let colorTop = UIColor(red: 1, green: 0.680, blue: 0.225, alpha: 1.0).CGColor
        //let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 1, green: 0.594, blue: 0.128, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient!, atIndex: 0)
    }
    
}

// MARK: - Contact related actions
extension MeetingsViewController {
    
    
    
}

// MARK: - Calendar related actions
extension MeetingsViewController {
    
    func loadEvents() {
        checkCalendarAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                self.fetchEvents(self.eventStore, calendarIdentity: self.selectedCalendar!, completed: { (events: [EKEvent]) -> Void in
                    self.events = events
                    self.meetingCollectionView.hidden = false
                    self.meetingCollectionView.reloadData()

                })
            }
        }
    }
    
    func fetchEvents(eventStore: EKEventStore, calendarIdentity: String, completed: ([EKEvent]) -> ()) {
        let endDate = NSDate(timeIntervalSinceNow: 604800);   //This is 1 week in seconds
        let predicate = eventStore.predicateForEventsWithStartDate(NSDate(), endDate: endDate, calendars: [self.eventStore.calendarWithIdentifier(calendarIdentity)!])
        
        //let events = NSMutableArray(array: eventStore.eventsMatchingPredicate(predicate))
        
        completed(eventStore.eventsMatchingPredicate(predicate) as [EKEvent]!)
        
    }
    
    func checkCalendarAuthorizationStatus(completionHandler: (accessGranted: Bool) -> Void) {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        switch(status) {
        case EKAuthorizationStatus.Authorized:
            completionHandler(accessGranted: true)
            
        case EKAuthorizationStatus.Denied, EKAuthorizationStatus.NotDetermined:
            self.eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {(access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if status == EKAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.performSegueWithIdentifier("showSettings", sender: self)
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
        }
    }
}