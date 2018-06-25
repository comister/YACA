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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var calendarPicker: UIPickerView!
    @IBOutlet weak var pickCalendarButton: UIButton!
    @IBOutlet weak var durationSegments: UISegmentedControl!
    @IBOutlet weak var temperatureSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        calendarPicker.delegate = self
        calendarPicker.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCalendars()
        if UserDefaults.standard.string(forKey: "selectedCalendar") != nil {
            let buttonText = UserDefaults.standard.string(forKey: "selectedCalendarName")
            //pickCalendarButton.titleLabel?.text = buttonText
            pickCalendarButton.setTitle(buttonText, for: UIControlState())
            selectedCalendar = UserDefaults.standard.string(forKey: "selectedCalendar")
            durationSegments.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "durationIndex")
            temperatureSegment.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "temperatureIndex")
        } else {
            welcomeLabel.isHidden = false
            descriptionLabel.isHidden = false
            
            UserDefaults.standard.set(0, forKey: "temperatureIndex")
            UserDefaults.standard.set(0, forKey: "durationIndex")
        }
    }

    @IBAction func durationClicked(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "durationIndex")
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
        UserDefaults.standard.setValue(duration, forKey: "duration")
    }
    
    @IBAction func metricsChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "temperatureIndex")
    }
}

// MARK: - Calendar related actions
extension SettingsViewController {
    
    func grantAccessClicked() {
        let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(openSettingsUrl!)
    }
    
    func showMessage(_ message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (action) -> Void in
            self.grantAccessClicked()
        }
        
        let dismissAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { (action) -> Void in
            DispatchQueue.main.async {

            }
        }
        
        alertController.addAction(dismissAction)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadCalendars() {
        appDelegate.checkCalendarAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                self.calendars = self.eventStore.calendars(for: EKEntityType.event)
            } else {
                self.showMessage("You have not allowed access to Calendar. This application does not work without this access! You can change this Setting in the global Settings. Should I bring you there?", title: "No access to Calendar")
            }
        }
    }
}

// MARK: - Everything related to the PickerViewmfor Calendar Selection
extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func clickCalendar(_ sender: UIButton) {
        calendarPicker.isHidden = false
        self.calendarPicker.reloadAllComponents()
        var x = 0
        for calendar in self.calendars! {
            if calendar.calendarIdentifier == self.selectedCalendar {
                calendarPicker.selectRow(x, inComponent: 0, animated: true)
            }
            x += 1
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let calendars = self.calendars {
            return calendars.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return self.calendars![row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //select calendar, store identifier in user defaults and hide pickerView !
        pickCalendarButton.titleLabel?.text = self.calendars![row].title
        UserDefaults.standard.setValue(self.calendars![row].calendarIdentifier, forKey: "selectedCalendar")
        UserDefaults.standard.setValue(self.calendars![row].title, forKey: "selectedCalendarName")
        welcomeLabel.isHidden = true
        descriptionLabel.isHidden = true
        pickerView.isHidden = true
    }
}
