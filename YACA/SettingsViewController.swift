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
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var calendarPicker: UIPickerView!
    @IBOutlet weak var pickCalendarButton: UIButton!
    @IBOutlet weak var durationSegments: UISegmentedControl!
    @IBOutlet weak var storeIniCloud: UISwitch!
    @IBOutlet weak var temperatureSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        calendarPicker.delegate = self
        calendarPicker.dataSource = self
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadCalendars()
        if NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar") != nil {
            //dispatch_async(dispatch_get_main_queue()){
            print(NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendarName"))
                self.pickCalendarButton.titleLabel?.text = NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendarName")
            //}
            selectedCalendar = NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar")
            durationSegments.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey("durationIndex")
            temperatureSegment.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey("temperatureIndex")
        } else {
            welcomeLabel.hidden = false
            descriptionLabel.hidden = false
            
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "temperatureIndex")
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "durationIndex")
        }
    }

    @IBAction func durationClicked(sender: UISegmentedControl) {
        NSUserDefaults.standardUserDefaults().setInteger(sender.selectedSegmentIndex, forKey: "durationIndex")
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
    
    @IBAction func metricsChanged(sender: UISegmentedControl) {
        NSUserDefaults.standardUserDefaults().setInteger(sender.selectedSegmentIndex, forKey: "temperatureIndex")
    }
    
    
    @IBAction func iCloudSwitchChanged(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "iCloudOn")
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

// MARK: - Calendar related actions
extension SettingsViewController {
    func loadCalendars() {
        appDelegate.checkCalendarAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                self.calendars = self.eventStore.calendarsForEntityType(EKEntityType.Event)
            }
        }
    }
}

// MARK: - configure the UI for SettingsViewController
extension SettingsViewController {
    func configureUI() {
        //not configuring Settings screen, looks strange with all this orange here
        /*
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 1, green: 0.680, blue: 0.225, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 1, green: 0.594, blue: 0.128, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient!, atIndex: 0)
        */
    }
}


extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func clickCalendar(sender: UIButton) {
        calendarPicker.hidden = false
        self.calendarPicker.reloadAllComponents()
        var x = 0
        for calendar in self.calendars! {
            if calendar.calendarIdentifier == self.selectedCalendar {
                calendarPicker.selectRow(x, inComponent: 0, animated: true)
            }
            x++
        }
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
        NSUserDefaults.standardUserDefaults().setValue(self.calendars![row].title, forKey: "selectedCalendarName")
        welcomeLabel.hidden = true
        descriptionLabel.hidden = true
        pickerView.hidden = true
    }
}