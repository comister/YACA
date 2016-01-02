//
//  MeetingListCell.swift
//  YACA
//
//  Created by Andreas Pfister on 13/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import CoreData

class MeetingListCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var calendarName: UILabel!
    @IBOutlet weak var participantTable: UITableView!
    @IBOutlet weak var timingLabel: UILabel!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var participantsButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var participantDetails: UIView!
    @IBOutlet weak var participantDetailsName: UILabel!
    @IBOutlet weak var participantDetailsWeather: UILabel!
    @IBOutlet weak var participantDetailsWeatherTemperature: UILabel!
    @IBOutlet weak var participantDetailsLastUpdate: UILabel!
    @IBOutlet weak var participantDetailsLocation: UILabel!
    @IBOutlet weak var participantDetailsWeatherDescription: UILabel!
    @IBOutlet weak var participantDetailsTime: UILabel!
    @IBOutlet weak var participantDetailsMeetingTime: UILabel!
    @IBOutlet weak var bottomWeatherLine: UIView!
    
    var backgroundGradient: CAGradientLayer? = nil
    
    @IBAction func closeParticipantDetails(sender: UIButton) {
        UIView.animateWithDuration(0.5, animations: {
            self.participantDetails.alpha = 0
        }, completion: { (finished: Bool) -> () in
            self.participantDetails.alpha = 1
            self.participantDetails.hidden = true
            
        })
    }
    
    var event: EKEvent?
    var events: [EKEvent]?
    var cellIdentifier: String?
    
    var meeting: Meeting! {
        didSet {
            updateContent()
        }
    }
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    private func updateContent() {
        calendarName.text = meeting.name
        //timingLabel.text = meeting.starttime
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        timingLabel.text = dateFormatter.stringFromDate(meeting.starttime) + " - " + dateFormatter.stringFromDate(meeting.endtime)
        notesArea()
    }
    
    // MARK: - apply some radius to the Cell
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        // do something
        super.init(frame: frame)
        addStoreNotifications()
    }

    deinit {
        removeStoreNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addStoreNotifications()
    }
    
    func addStoreNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleStoresWillChange:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: self.sharedContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleStoresDidChange:", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: self.sharedContext)
        NSNotificationCenter.defaultCenter().addObserver( self, selector: "mergeChanges:", name: NSManagedObjectContextDidSaveNotification,object: self.sharedContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleStoresWillRemove:",
            name: NSPersistentStoreCoordinatorWillRemoveStoreNotification,
            object: self.sharedContext)
    }
    
    func removeStoreNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresWillChangeNotification,object: nil )
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification,object: nil )
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification,object: nil )
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorWillRemoveStoreNotification,object: nil )
    }
    
    func handleStoresWillRemove(notification: NSNotification) { }
    
    func handleStoresWillChange(notification: NSNotification) {
        CoreDataStackManager.sharedInstance().saveContext() {
            print("StoreWillChange notification fired and context saved successfully")
        }
    }
    
    func handleStoresDidChange(notification: NSNotification) {
        self.stopSaveAnimation()
    }
    
    func mergeChanges(notification: NSNotification) {
        self.sharedContext.performBlock {
            self.sharedContext.mergeChangesFromContextDidSaveNotification(notification)
            self.postRefetchDatabaseNotification()
        }
        self.stopSaveAnimation()
    }
    
    func postRefetchDatabaseNotification() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(
                "kRefetchDatabaseNotification", // can be observed in any other ViewController
                object: nil);
        })
    }
    
    func persistentStoreDidImportUbiquitousContentChanges(notification: NSNotification) {
        self.mergeChanges(notification);
    }
    
    func startSaveAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.4
        animation.repeatCount = 9999
        animation.autoreverses = true
        animation.fromValue = 1.0
        animation.toValue = 0.1
        saveButton.hidden = false
        deleteButton.hidden = false
        saveButton.layer.addAnimation(animation, forKey: "animateOpacity")
    }
    
    func stopSaveAnimation() {
        saveButton.layer.removeAnimationForKey("animateOpacity")
        saveButton.hidden = true
        deleteButton.hidden = true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print( "clicked participant, show some info" )
        
        if let location = meeting.participantArray[indexPath.row].location {
            participantDetails.hidden = false
            UIView.transitionWithView(participantDetails, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: nil, completion: nil)
            participantDetailsName.text = ( meeting.participantArray[indexPath.row].name != nil ? meeting.participantArray[indexPath.row].name : meeting.participantArray[indexPath.row].email )
            
            participantDetailsLastUpdate.text = "Last update: " + ( Int(round(NSDate().timeIntervalSinceDate(location.lastUpdate)/60)) < 60 ? " just a moment ago":String(Int(round(NSDate().timeIntervalSinceDate(location.lastUpdate)/60))) + " minutes ago")
            
            participantDetailsLocation.text = location.city! + (location.country != "" ? ", " + location.country! : "")
            if let weather = location.weather {
                participantDetailsWeather.text = OWFontIcons[weather]
                participantDetailsWeatherTemperature.text = String(location.weather_temp!.unsignedIntValue) + (location.weather_temp_unit == 0 ? "°C":"°F")
                print("__________ UNIT __________")
                print(location)
                participantDetailsWeatherDescription.text = location.weather_description
                
            } else {
                participantDetailsWeather.text = ""
                print(meeting.participantArray[indexPath.row].location)
            }
            
            if let timeOffset = location.timezoneOffset {
                let dateFormatter = NSDateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
                dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
                print(dateFormatter.stringFromDate(NSDate(timeInterval: (timeOffset as Double), sinceDate: NSDate())))
                participantDetailsTime.text = "" + dateFormatter.stringFromDate(NSDate(timeInterval: (timeOffset as Double), sinceDate: NSDate()))
                dateFormatter.dateFormat = "HH:mm"
                participantDetailsMeetingTime.text = dateFormatter.stringFromDate(NSDate(timeInterval: (timeOffset as Double), sinceDate: meeting.starttime)) + " - " + dateFormatter.stringFromDate(NSDate(timeInterval: (timeOffset as Double), sinceDate: meeting.endtime))
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meeting.participantArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // MARK: - Create cells programmatically - try to dequeue, if not possible create new cell with new identifier
        let identifier = cellIdentifier!
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
        }
        
        // Use Name to display, use email if name does not exist
        cell?.textLabel?.text = ( meeting.participantArray[indexPath.row].name != nil ? meeting.participantArray[indexPath.row].name : meeting.participantArray[indexPath.row].email )
        
        if meeting.participantArray[indexPath.row].location != nil {
            cell?.imageView?.image = UIImage(named: "pin")
        } else {
            cell?.imageView?.image = UIImage().blank_x1
        }
        
        // show yourself in blue color, all others in black
        if meeting.participantArray[indexPath.row].myself {
            cell?.textLabel?.textColor = UIColor.blueColor()
        } else {
            cell?.textLabel?.textColor = UIColor.blackColor()
        }
        
        return cell!
    }
    
}

// MARK: - Toolbarbuttons
extension MeetingListCell {
    
    func participantArea() {
        participantTable.hidden = false
        notesText.hidden = true
        
        participantsButton.backgroundColor = UIColor.whiteColor()
        notesButton.backgroundColor = .None
    }
    
    func notesArea() {
        participantTable.hidden = true
        notesText.hidden = false
        
        notesButton.backgroundColor = UIColor.whiteColor()
        participantsButton.backgroundColor = .None
    }
    
    @IBAction func participantsButton(sender: UIButton) {
        participantArea()
    }
    
    @IBAction func notesButton(sender: UIButton) {
        notesArea()
    }
    
}

extension MeetingListCell: UITextViewDelegate {
    
    @IBAction func saveNote(sender: UIButton) {
        self.endEditing(true)
    }
    
    @IBAction func deleteNote(sender: UIButton) {
        self.endEditing(true)
        notesText.text = ""
        doSaveNote()
    }
    
    func doSaveNote() {
        // a new note to be created
        if self.meeting.note == nil {
            if notesText.text == "" {
                return
            }
            let noteDictionary = [
                Note.Keys.Note: notesText.text,
                Note.Keys.MeetingId: self.meeting.meetingId,
                Note.Keys.MeetingTitle: self.meeting.name
            ]
            self.meeting.note = Note(dictionary: noteDictionary, context: self.sharedContext)
        // an existing note to be updated
        } else {
            if notesText.text == "" {
                self.sharedContext.deleteObject(self.meeting.note!)
            } else {
                self.meeting.note?.note = notesText.text
                self.meeting.note?.meetingTitle = self.meeting.name
            }
        }
        startSaveAnimation()
        CoreDataStackManager.sharedInstance().saveContext() {
            self.stopSaveAnimation()
        }
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        saveButton.hidden = false
        deleteButton.hidden = false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        doSaveNote()
    }
    
    func configureUI() {
        
    }
    
}

extension UIImage {
    var blank_x1: UIImage {
        get {
            UIGraphicsBeginImageContextWithOptions(CGRectMake(0, 0, 22, 22).size, false, 0)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
}