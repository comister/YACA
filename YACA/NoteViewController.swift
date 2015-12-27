//
//  NoteViewController.swift
//  YACA
//
//  Created by Andreas Pfister on 24/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
    
    @IBOutlet weak var MeetingTitle: UILabel!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var deleteNote: UIButton!
    
    var meetingName: String?
    var meetingNote: String?
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        MeetingTitle.text = meetingName
        noteText.text = meetingNote
        
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    @IBAction func deleteNote(sender: AnyObject) {
        
        let confirmation = UIAlertController(title: "Delete Note", message: "Are you sure you want to permantently delete this note?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            self.sharedContext.deleteObject(self.note!)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        confirmation.addAction(confirmAction)
        confirmation.addAction(cancelAction)
        
        self.presentViewController(confirmation, animated: true, completion: nil)
    }
    
    @IBAction func closeNote(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
