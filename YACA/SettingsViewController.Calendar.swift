//
//  SettingsViewController.Calendar.swift
//  YACA
//
//  Created by Andreas Pfister on 24/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation
import EventKit

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