//
//  NotesTableViewController.swift
//  YACA
//
//  Created by Andreas Pfister on 22/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        
    }
    
}

extension NotesTableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notesViewCell", forIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Show Notes, give opportunity to delete
    }
    
}