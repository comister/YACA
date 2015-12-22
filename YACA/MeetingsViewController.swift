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
    var events = [EKEvent]()
    let eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var selectedCalendar: String?
    var duration: Int = 0
    var eventSource: Datasource?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var meetingCollectionView: UICollectionView!
    @IBOutlet weak var calendarName: UILabel!
    @IBOutlet weak var durationSgements: CustomSegmentedControl!
    
    override func viewDidLoad() {
        self.meetingCollectionView?.registerNib(UINib(nibName: "MeetingListCellHeader", bundle: nil), forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: "meetingCellHeader")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        
        // MARK: - Load Events from selected Calendar
        if (NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar") != nil) {
            self.selectedCalendar = NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar")
            calendarName.text = self.eventStore.calendarWithIdentifier(self.selectedCalendar!)?.title
        } else {
            //transition to settings
            /*
            dispatch_async(dispatch_get_main_queue()){
                self.performSegueWithIdentifier("showSettings", sender: self)
            }
            */
            return
        }
        // MARK: - Adjust custom control and set duration
        durationSgements.items = ["1 day", "1 week", "1 month"]
        durationSgements.font = UIFont(name: "Roboto-Regular", size: 12)
        durationSgements.borderColor = UIColor(white: 1.0, alpha: 0.3)
        durationSgements.addTarget(self, action: "changeDuration:", forControlEvents: .ValueChanged)
        
        self.duration = getDurationOfIndex(NSUserDefaults.standardUserDefaults().integerForKey("durationIndex"))
        loadEvents()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // MARK: - Apply value to segmented control after view is visible, otherwise uiview.animate is not working
        durationSgements.selectedIndex = NSUserDefaults.standardUserDefaults().integerForKey("durationIndex")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSettings" {
            if let controller = segue.destinationViewController as? SettingsViewController {
                if self.selectedCalendar == nil {
                    print("first run")
                    segue.perform()
                }
            }
        }
    }
    
    // MARK: - Returns seconds for 1 day (index=0), 1 week (index=1) and 1 month (index=2)
    func getDurationOfIndex(index: Int) -> Int {
        var duration = 0
        switch index {
        case 0:
            duration = 86400
        case 1:
            duration = 604800
        case 2:
            duration = 2419200
        default:
            duration = 0
        }
        return duration
    }
    
    func changeDuration(sender: AnyObject?) {
        let localDuration = getDurationOfIndex(durationSgements.selectedIndex)
        NSUserDefaults.standardUserDefaults().setValue(durationSgements.selectedIndex, forKey: "durationIndex")
        NSUserDefaults.standardUserDefaults().setValue(localDuration, forKey: "duration")
        self.duration = localDuration
        loadEvents()
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
        if let sections = eventSource?.sectionsRequired {
            print("")
            print("Having " + String(sections) + " Sections in CollectionView")
            return sections
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        //something to do when clicked
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        
        if kind ==
        
        let headerCell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "meetingCellHeader", forIndexPath: indexPath) as? MeetingListCellHeader
        
        /*
        if let currentWeek = eventSource?.weekStructure[(eventSource?.weekOfSection[indexPath.section])!] {
            if let currentDayObject = currentWeek[(eventSource?.dayOfSection[indexPath.section])!] {
                
            }
        }
        
        if let dayName = eventSource?.structureKeys[(eventSource?.weekOfSection[indexPath.section])!]![indexPath.section] {
            headerCell?.dayLabel.text = dayName.uppercaseString
        } else {
            headerCell?.dayLabel.text = "UNDEFINED"
        }
        */
        
        headerCell?.dayLabel.text = eventSource?.dayOfSection[indexPath.section]!.uppercaseString

        
        return headerCell!
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if let currentWeek = eventSource?.weekStructure[(eventSource?.weekOfSection[section])!] {
            if let currentDayObject = currentWeek[(eventSource?.dayOfSection[section])!] {
                return currentDayObject.count
            }
        }

        return 1
    }
    

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("meetingViewCell", forIndexPath: indexPath) as! MeetingListCell
        
        print( "Using section index: " + String(indexPath.section) )
        print( "Using weekofSection: " + String((eventSource?.weekOfSection[indexPath.section])!) )
        print( "" )
        
        if let currentWeek = eventSource?.weekStructure[(eventSource?.weekOfSection[indexPath.section])!] {
            if let currentDayObject = currentWeek[(eventSource?.dayOfSection[indexPath.section])!]?[indexPath.row] {
                cell.calendarName.text = currentDayObject.name
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                cell.timingLabel?.text = dateFormatter.stringFromDate(currentDayObject.starttime) + " - " + dateFormatter.stringFromDate(currentDayObject.endtime)
                cell.cellIdentifier = "meetingParticipant_" + String(indexPath.row)
                
                // TODO: Replace this, redundant information, can all be handled through actual Meeting object
                //cell.event = events![indexPath.row] as EKEvent!
                //cell.events = events
                
                cell.meeting = currentDayObject
                
                cell.participantTable.reloadData()
            }
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

// MARK: - Calendar related actions
extension MeetingsViewController {
    
    func loadEvents() {
        
        appDelegate.checkCalendarAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                self.fetchEvents(self.eventStore, calendarIdentity: self.selectedCalendar!, completed: { (events: [EKEvent]) -> Void in
                    for event in events{
                        if event.recurrenceRules?.count == 0 {
                            self.events.append(event)
                        }
                        
                        print("")
                        print("-------- " + event.title + " --------")
                        print(event.recurrenceRules)
                        print("-------- " + event.title + " --------")
                        print("")
                    }
                    // MARK: - Feed datasource and let it do the job to structure probably for CollectionView
                    self.eventSource = Datasource(events: self.events)
                    
                    self.meetingCollectionView.hidden = false
                    //self.meetingCollectionView.reloadData()

                })
            }
        }
    }
    
    func fetchEvents(eventStore: EKEventStore, calendarIdentity: String, completed: ([EKEvent]) -> ()) {
        let endDate = NSDate(timeIntervalSinceNow: NSTimeInterval(self.duration))
        let predicate = eventStore.predicateForEventsWithStartDate(NSDate(), endDate: endDate, calendars: [self.eventStore.calendarWithIdentifier(calendarIdentity)!])
        
        //let events = NSMutableArray(array: eventStore.eventsMatchingPredicate(predicate))
        
        completed(eventStore.eventsMatchingPredicate(predicate) as [EKEvent]!)
        
    }
}

extension MeetingsViewController: UICollectionViewDelegate {
    
    
    
}