//
//  SettingsViewController.Contacts.swift
//  YACA
//
//  Created by Andreas Pfister on 24/12/15.
//  Copyright © 2015 AP. All rights reserved.
//
// MARK: - Contact related actions (obsolete, not used anymore)

extension SettingsViewController {
    
    func loadContactGroups() {
        appDelegate.checkContactsAuthorizationStatus { (accessGranted) -> Void in
            if accessGranted {
                do {
                    self.contacts = try self.contactStore.containersMatchingPredicate(nil)
                    self.groups = try self.contactStore.groupsMatchingPredicate(nil)
                } catch {
                    print("Error fetching Contact groups")
                }
            }
        }
    }
}