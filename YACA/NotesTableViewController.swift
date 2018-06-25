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
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try self.fetchedResultsController.performFetch() // self.fetchedResultsController.performFetch()
        } catch _ { }
        self.allNotes = fetchedResultsController.fetchedObjects!
        self.tableView.reloadData()
        
    }
    
    // MARK: - Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Note.statics.entityName)
        //fetchRequest.predicate = NSPredicate(format: "meetingId == %@", self.meetingId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Note.Keys.CreatedAt, ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController as! NSFetchedResultsController<Note>
        
    }()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNote" {
            if let controller = segue.destination as? NoteViewController {
                controller.meetingName = self.meetingTitle
                controller.meetingNote = self.meetingNotes
                controller.note = self.selectedNote
            }
        }
    }
    
}

extension NotesTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesViewCell", for: indexPath) as! NotesTableCell
        //cell.textLabel?.text = allNotes[indexPath.row].meetingTitle
        cell.meetingLabel.text = allNotes[indexPath.row].meetingTitle
        cell.meetingNoteLabel.text = allNotes[indexPath.row].note
        cell.meetingNoteDate.text = dateFormatter.string(from: allNotes[indexPath.row].createdAt as Date)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotes.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show Notes, give opportunity to delete
        self.meetingNotes = allNotes[indexPath.row].note
        self.meetingTitle = allNotes[indexPath.row].meetingTitle
        self.selectedNote = allNotes[indexPath.row]
        performSegue(withIdentifier: "showNote", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete a note
        //confirmation required
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let confirmation = UIAlertController(title: "Delete Note", message: "Are you sure you want to permantently delete this note?", preferredStyle: UIAlertControllerStyle.actionSheet)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                
            }
            let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
                self.sharedContext.delete(self.allNotes[indexPath.row])
                self.allNotes.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
            confirmation.addAction(confirmAction)
            confirmation.addAction(cancelAction)
            
            self.present(confirmation, animated: true, completion: nil)
        }
        
    }
    
}
