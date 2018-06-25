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
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let contactStore = CNContactStore()
    let eventStore = EKEventStore()
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataStackManager.sharedInstance().saveContext() {
            print("saved Core Data context, now shutting down !")
        }
    }
    
    // MARK: - Adding this function to AppDelegate to have access from everywhere (which would be possible otherwise as well, for sure)
    func checkContactsAuthorizationStatus(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch(status) {
        case CNAuthorizationStatus.authorized:
            completionHandler(true)
            
        case CNAuthorizationStatus.denied, CNAuthorizationStatus.notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if status == CNAuthorizationStatus.denied {
                        completionHandler(false)
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    func checkCalendarAuthorizationStatus(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch(status) {
        case EKAuthorizationStatus.authorized:
            completionHandler(true)
            
        case EKAuthorizationStatus.denied, EKAuthorizationStatus.notDetermined:
            self.eventStore.requestAccess(to: EKEntityType.event, completion: {(access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if status == EKAuthorizationStatus.denied {
                        completionHandler(false)
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    func backgroundThread(_ delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            
            let popTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: popTime) {
                    completion()
                }
            }
        }
    }
}

