//
//  AppDelegate.swift
//  YACA
//
//  Created by Andreas Pfister on 03/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import UIKit
import Contacts
import EventKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let contactStore = CNContactStore()
    let eventStore = EKEventStore()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - Adding this function to AppDelegate to have access from everywhere
    func checkContactsAuthorizationStatus(completionHandler: (accessGranted: Bool) -> Void) {
        let status = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch(status) {
        case CNAuthorizationStatus.Authorized:
            completionHandler(accessGranted: true)
            
        case CNAuthorizationStatus.Denied, CNAuthorizationStatus.NotDetermined:
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if status == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            //show dialog to transition to screen to allow access to contacts
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
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
                            //show dialog and transition to settings
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
        }
    }
}

