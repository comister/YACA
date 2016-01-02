//
//  NotesTableViewController.swift
//  YACA
//
//  Created by Andreas Pfister on 22/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController {
    
    var meetingId: String = ""
    var allNotes = [Note]()
    var meetingTitle: String?
    var meetingNotes: String?
    var selectedNote: Note?
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try self.fetchedResultsController.performFetch()
        } catch _ { }
        self.allNotes = fetchedResultsController.fetchedObjects as! [Note]
        self.tableView.reloadData()
        
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Note.statics.entityName)
        //fetchRequest.predicate = NSPredicate(format: "meetingId == %@", self.meetingId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Note.Keys.CreatedAt, ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNote" {
            if let controller = segue.destinationViewController as? NoteViewController {
                controller.meetingName = self.meetingTitle
                controller.meetingNote = self.meetingNotes
                controller.note = self.selectedNote
            }
        }
    }
    
}

extension NotesTableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notesViewCell", forIndexPath: indexPath) as! NotesTableCell
        //cell.textLabel?.text = allNotes[indexPath.row].meetingTitle
        cell.meetingLabel.text = allNotes[indexPath.row].meetingTitle
        cell.meetingNoteLabel.text = allNotes[indexPath.row].note
        cell.meetingNoteDate.text = dateFormatter.stringFromDate(allNotes[indexPath.row].createdAt)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotes.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Show Notes, give opportunity to delete
        self.meetingNotes = allNotes[indexPath.row].note
        self.meetingTitle = allNotes[indexPath.row].meetingTitle
        self.selectedNote = allNotes[indexPath.row]
        performSegueWithIdentifier("showNote", sender: self)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //delete a note
        //confirmation required
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let confirmation = UIAlertController(title: "Delete Note", message: "Are you sure you want to permantently delete this note?", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                
            }
            let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
                self.sharedContext.deleteObject(self.allNotes[indexPath.row])
                self.allNotes.removeAtIndex(indexPath.row)
                self.tableView.reloadData()
            }
            confirmation.addAction(confirmAction)
            confirmation.addAction(cancelAction)
            
            self.presentViewController(confirmation, animated: true, completion: nil)
        }
        
    }
    
}