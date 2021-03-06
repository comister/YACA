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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MeetingTitle.text = meetingName
        noteText.text = meetingNote
        
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    @IBAction func deleteNote(_ sender: AnyObject) {
        
        let confirmation = UIAlertController(title: "Delete Note", message: "Are you sure you want to permanently delete this note?", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
        }
        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
            self.sharedContext.delete(self.note!)
            self.dismiss(animated: true, completion: nil)
        }
        confirmation.addAction(confirmAction)
        confirmation.addAction(cancelAction)
        
        self.present(confirmation, animated: true, completion: nil)
    }
    
    @IBAction func closeNote(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
