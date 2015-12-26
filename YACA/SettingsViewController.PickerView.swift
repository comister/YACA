//
//  SettingsViewController.PickerView.swift
//  YACA
//
//  Created by Andreas Pfister on 24/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation
import UIKit

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func clickCalendar(sender: UIButton) {
        calendarPicker.hidden = false
        showCalendars = true
        self.calendarPicker.reloadAllComponents()
        var x = 0
        for var calendar in self.calendars! {
            if calendar.calendarIdentifier == self.selectedCalendar {
                calendarPicker.selectRow(x, inComponent: 0, animated: true)
            }
            x++
        }
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
            welcomeLabel.hidden = true
            descriptionLabel.hidden = true
        } else {
            pickContactsButton.titleLabel?.text = self.contacts![row].name
            NSUserDefaults.standardUserDefaults().setValue(self.contacts![row].identifier, forKey: "selectedContactGroup")
            NSUserDefaults.standardUserDefaults().setValue(self.contacts![row].name, forKey: "selectedContactGroupName")
            
        }
        pickerView.hidden = true
    }
}