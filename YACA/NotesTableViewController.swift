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
    
    override func viewDidLoad() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch _ { }
        self.allNotes = fetchedResultsController.fetchedObjects as! [Note]
        for var note in self.allNotes {
            print(note)
        }
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Note.statics.entityName)
        //fetchRequest.predicate = NSPredicate(format: "meetingId == %@", self.meetingId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Note.Keys.CreatedAt, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
}

extension NotesTableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notesViewCell", forIndexPath: indexPath)
        cell.textLabel?.text = allNotes[indexPath.row].meetingTitle
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotes.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Show Notes, give opportunity to delete
    }
    
}