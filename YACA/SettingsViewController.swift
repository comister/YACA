//
//  SettingsViewController.swift
//  YACA
//
//  Created by Andreas Pfister on 17/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import Contacts

class SettingsViewController: UIViewController {

    var backgroundGradient: CAGradientLayer? = nil
    let eventStore = EKEventStore()
    let contactStore = CNContactStore()
    var calendars: [EKCalendar]?
    var contacts: [CNContainer]?
    var groups: [CNGroup]?
    var selectedCalendar: String?
    var selectedContactGroup: String?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var showCalendars = true
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var calendarPicker: UIPickerView!
    @IBOutlet weak var pickCalendarButton: UIButton!
    @IBOutlet weak var pickContactsButton: UIButton!
    @IBOutlet weak var durationSegments: UISegmentedControl!
    @IBOutlet weak var storeIniCloud: UISwitch!
    
    override func viewDidLoad() {
        calendarPicker.delegate = self
        calendarPicker.dataSource = self
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadCalendars()
        //loadContactGroups() // <<-- obsolete, no contactgroups to select
        if NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar") != nil {
            dispatch_async(dispatch_get_main_queue()){
                self.pickCalendarButton.titleLabel?.text = NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendarName")
            }
            selectedCalendar = NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar")
            selectedContactGroup = NSUserDefaults.standardUserDefaults().stringForKey("selectedContactGroup")
            pickContactsButton.titleLabel?.text = NSUserDefaults.standardUserDefaults().stringForKey("selectedContactGroupName")
            durationSegments.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey("durationIndex")
            storeIniCloud.selected = NSUserDefaults.standardUserDefaults().boolForKey("iCloudOn")
        } else {
            //NSUserDefaults.standardUserDefaults().setValue(self.calendars!.first!.calendarIdentifier, forKey: "selectedCalendar")
            //selectedCalendar = self.calendars!.first!.calendarIdentifier
            welcomeLabel.hidden = false
            descriptionLabel.hidden = false
        }
    }

    @IBAction func durationClicked(sender: UISegmentedControl) {
        print(String(sender.selectedSegmentIndex))
        NSUserDefaults.standardUserDefaults().setValue(sender.selectedSegmentIndex, forKey: "durationIndex")
        var duration = 0
        switch sender.selectedSegmentIndex {
        case 0:
            duration = 86400
        case 1:
            duration = 604800
        case 3:
            duration = 2419200
        default:
            duration = 0
        }
        NSUserDefaults.standardUserDefaults().setValue(duration, forKey: "duration")
    }
    
    @IBAction func iCloudSwitchChanged(sender: UISwitch) {
        print(sender.on)
        NSUserDefaults.standardUserDefaults().setValue(sender.on, forKey: "iCloudOn")
    }
    
    func grantAccessClicked() {
        let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(openSettingsUrl!)
    }
    
    func showMessage(message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: "Open preferences", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.grantAccessClicked()
        }
        alertController.addAction(dismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}