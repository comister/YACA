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

class SettingsViewController: UIViewController {

    let eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var firstRun: Bool = false
    var selectedCalendar: String?
    
    @IBOutlet weak var calendarPicker: UIPickerView!
    @IBOutlet weak var pickCalendarButton: UIButton!
    
    override func viewDidLoad() {
        calendarPicker.delegate = self
        calendarPicker.dataSource = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadCalendars()
        if !firstRun {
            selectedCalendar = NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar")
            pickCalendarButton.titleLabel?.text = eventStore.calendarWithIdentifier(selectedCalendar!)?.title
        } else {
            NSUserDefaults.standardUserDefaults().setValue(self.calendars![0].calendarIdentifier, forKey: "selectedCalendar")
            selectedCalendar = self.calendars![0].calendarIdentifier
        }
    }
    
    @IBAction func dismissSettings(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let calendars = self.calendars {
            return calendars.count
        } else {
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.calendars![row].title
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //select calendar, store identifier in user defaults and hide pickerView !
        pickCalendarButton.titleLabel?.text = self.calendars![row].title
        NSUserDefaults.standardUserDefaults().setValue(self.calendars![row].calendarIdentifier, forKey: "selectedCalendar")
        print(self.calendars![row].calendarIdentifier)
        pickerView.hidden = true
    }
}

// MARK: - Calendar related actions
extension SettingsViewController {
    
    func loadCalendars() {
        checkCalendarAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                self.calendars = self.eventStore.calendarsForEntityType(EKEntityType.Event)
                self.calendarPicker.reloadAllComponents()
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
    
    func checkCalendarAuthorizationStatus(completionHandler: (accessGranted: Bool) -> Void) {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        switch(status) {
        case EKAuthorizationStatus.Authorized:
            completionHandler(accessGranted: true)
            
        case EKAuthorizationStatus.Denied, EKAuthorizationStatus.NotDetermined:
            self.eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {(access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if status == EKAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.showMessage("Your settings disallowing access to the Calendar ! You can change it here !", title: "No access")
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
        }
    }
}