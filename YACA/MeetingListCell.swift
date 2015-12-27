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
        //collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        participantTable.registerClass(UITableView.self, forCellReuseIdentifier: "meetingParticipants")
        participantsButton.imageView!.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        notesButton.imageView!.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        notesButton.imageView!.tintColor = UIColor.blueColor()
        addStoreNotifications()
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
        
    }
    
    func handleStoresWillRemove(notification: NSNotification) { }
    
    func handleStoresWillChange(notification: NSNotification) {
        CoreDataStackManager.sharedInstance().saveContext()
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
        saveButton.layer.addAnimation(animation, forKey: "animateOpacity")
    }
    
    func stopSaveAnimation() {
        saveButton.layer.removeAnimationForKey("animateOpacity")
        saveButton.hidden = true
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
        notesButton.imageView!.tintColor = .None
        participantsButton.imageView!.tintColor = UIColor.blueColor()
    }
    
    func notesArea() {
        participantTable.hidden = true
        notesText.hidden = false
        notesButton.backgroundColor = UIColor.whiteColor()
        participantsButton.backgroundColor = .None
        notesButton.imageView!.tintColor = UIColor.blueColor()
        participantsButton.imageView!.tintColor = .None
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
    
    func doSaveNote() {
        if self.meeting.note == nil {
            let noteDictionary = [
                Note.Keys.Note: notesText.text,
                Note.Keys.MeetingId: self.meeting.meetingId,
                Note.Keys.MeetingTitle: self.meeting.name
            ]
            self.meeting.note = Note(dictionary: noteDictionary, context: self.sharedContext)
        } else {
            self.meeting.note?.note = notesText.text
            self.meeting.note?.meetingTitle = self.meeting.name
        }
        CoreDataStackManager.sharedInstance().saveContext()
        startSaveAnimation()
    }
    
    func textViewDidChange(textView: UITextView) { }
    
    func textViewDidBeginEditing(textView: UITextView) {
        saveButton.hidden = false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        doSaveNote()
    }
}