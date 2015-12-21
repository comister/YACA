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

    let eventStore = EKEventStore()
    let contactStore = CNContactStore()
    var calendars: [EKCalendar]?
    var contacts: [CNContainer]?
    var groups: [CNGroup]?
    var selectedCalendar: String?
    var selectedContactGroup: String?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var showCalendars = true
    
    @IBOutlet weak var calendarPicker: UIPickerView!
    @IBOutlet weak var pickCalendarButton: UIButton!
    @IBOutlet weak var pickContactsButton: UIButton!
    @IBOutlet weak var durationSegments: UISegmentedControl!
    @IBOutlet weak var storeIniCloud: UISwitch!
    
    override func viewDidLoad() {
        calendarPicker.delegate = self
        calendarPicker.dataSource = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadCalendars()
        loadContactGroups()
        if NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar") != nil {
            selectedCalendar = NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar")
            pickCalendarButton.titleLabel?.text = NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendarName")
            selectedContactGroup = NSUserDefaults.standardUserDefaults().stringForKey("selectedContactGroup")
            pickContactsButton.titleLabel?.text = NSUserDefaults.standardUserDefaults().stringForKey("selectedContactGroupName")
            durationSegments.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey("durationIndex")
            storeIniCloud.selected = NSUserDefaults.standardUserDefaults().boolForKey("iCloudOn")
        } else {
            NSUserDefaults.standardUserDefaults().setValue(self.calendars!.first!.calendarIdentifier, forKey: "selectedCalendar")
            selectedCalendar = self.calendars!.first!.calendarIdentifier
        }
    }
    
    @IBAction func dismissSettings(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
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

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    @IBAction func clickCalendar(sender: UIButton) {
        calendarPicker.hidden = false
        showCalendars = true
        self.calendarPicker.reloadAllComponents()
    }
    
    @IBAction func clickContacts(sender: AnyObject) {
        calendarPicker.hidden = false
        showCalendars = false
        self.calendarPicker.reloadAllComponents()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if showCalendars {
            if let calendars = self.calendars {
                return calendars.count
            }
        } else {
            if let contacts = self.contacts {
                return contacts.count
            }
        }
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if showCalendars {
            return self.calendars![row].title
        } else {
            return self.contacts![row].name
            
            
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //select calendar, store identifier in user defaults and hide pickerView !
        if showCalendars {
            pickCalendarButton.titleLabel?.text = self.calendars![row].title
            NSUserDefaults.standardUserDefaults().setValue(self.calendars![row].calendarIdentifier, forKey: "selectedCalendar")
            NSUserDefaults.standardUserDefaults().setValue(self.calendars![row].title, forKey: "selectedCalendarName")
        } else {
            pickContactsButton.titleLabel?.text = self.contacts![row].name
            NSUserDefaults.standardUserDefaults().setValue(self.contacts![row].identifier, forKey: "selectedContactGroup")
            NSUserDefaults.standardUserDefaults().setValue(self.contacts![row].name, forKey: "selectedContactGroupName")
            
        }
        pickerView.hidden = true
    }
}

// MARK: - Calendar related actions
extension SettingsViewController {
    
    func loadCalendars() {
        appDelegate.checkCalendarAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                self.calendars = self.eventStore.calendarsForEntityType(EKEntityType.Event)
                var x = 0
                for var calendar in self.calendars! {
                    if calendar.calendarIdentifier == self.selectedCalendar {
                        self.calendarPicker.selectRow(x, inComponent: 0, animated: true)
                    }
                    x++
                }
            }
        }
    }
}

// MARK: - Contact related actions
extension SettingsViewController {
    
    func loadContactGroups() {
        appDelegate.checkContactsAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                do {
                    self.contacts = try self.contactStore.containersMatchingPredicate(nil)
                    self.groups = try self.contactStore.groupsMatchingPredicate(nil)
                    print(self.groups)
                } catch {
                    print("Error fetching Contact groups")
                }

            }
        }
    }
    
}