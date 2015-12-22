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
    
    var tapRecognizer: UITapGestureRecognizer? = nil
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
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    private func updateContent() {
        calendarName.text = meeting.name
        //timingLabel.text = meeting.starttime
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        timingLabel.text = dateFormatter.stringFromDate(meeting.starttime) + " - " + dateFormatter.stringFromDate(meeting.endtime)
        
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
        participantTable.delegate = self
        participantTable.dataSource = self
        participantTable.reloadData()
        //collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        participantTable.registerClass(UITableView.self, forCellReuseIdentifier: "meetingParticipants")
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.notesText.endEditing(true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return super.tag
    }
    */
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let partArray = meeting.participantArray {
            print("---------")
            print( "Having " + String(partArray.count) + " items for Participants" )
            print("---------")
            return partArray.count
        } else {
            return 0
        }
        /*
        if event?.attendees != nil {
            //print(event?.attendees?.count)

            return (event?.attendees?.count)!
        } else {
            //print(event)
            return 0
        }
        */
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // MARK: - Create cells programmatically - try to dequeue, if not possible create new cell with new identifier
        let identifier = cellIdentifier!
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
        }
        //_ = Participant(attendee: event?.attendees?[indexPath.row], context: self.sharedContext)
        //let cell = tableView.dequeueReusableCellWithIdentifier("meetingParticipants", forIndexPath: indexPath) as! UITableViewCell
        
        //let allObjects: NSArray = meeting.participants.
        print("-----------------")
        print(" At index " + String(indexPath.row))
        print(meeting.participantArray)
        print("-----------------")
        if let participantArray = meeting.participantArray {
            cell?.textLabel?.text = ( participantArray[indexPath.row].name != nil ? participantArray[indexPath.row].name : participantArray[indexPath.row].email )
        }
        
        //cell!.textLabel?.text = event?.attendees?[indexPath.row].name
        return cell!
    }
    
}

// MARK: - Toolbarbuttons
extension MeetingListCell {
    
    @IBAction func participantsButton(sender: UIButton) {
        participantTable.hidden = false
        notesText.hidden = true
        participantsButton.backgroundColor = UIColor.whiteColor()
        notesButton.backgroundColor = .None
    }
    
    @IBAction func notesButton(sender: UIButton) {
        participantTable.hidden = true
        notesText.hidden = false
        notesButton.backgroundColor = UIColor.whiteColor()
        participantsButton.backgroundColor = .None
    }
    
}
