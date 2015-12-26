//
//  NoteViewController.swift
//  YACA
//
//  Created by Andreas Pfister on 24/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet weak var MeetingTitle: UILabel!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var deleteNote: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func deleteNote(sender: AnyObject) {
        
    }
    
    @IBAction func closeNote(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
