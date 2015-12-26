//
//  CoreDataStackManager.swift
//  YACA
//
//  Created by Andreas Pfister on 03/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import CoreData

private let SQLITE_FILE_NAME = "yaca.sqlite"
private let MODEL_NAME = "YACA"
private let STORE_NAME = "YACA"

class CoreDataStackManager {
    
    // MARK: - Shared Instance
    
    /**
    *  This class variable provides an easy way to get access
    *  to a shared instance of the CoreDataStackManager class.
    */
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
        
        return Static.instance
    }
    
    // MARK: - The Core Data stack. The code has been moved, unaltered, from the AppDelegate.
    
    lazy var applicationDocumentsDirectory: NSURL = {
        
        print("Instantiating the applicationDocumentsDirectory property")
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        
        print("Instantiating the managedObjectModel property")
        
        let modelURL = NSBundle.mainBundle().URLForResource(MODEL_NAME, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    /**
     * The Persistent Store Coordinator is an object that the Context uses to interact with the underlying file system. Usually
     * the persistent store coordinator object uses an SQLite database file to save the managed objects. But it is possible to
     * configure it to use XML or other formats.
     *
     * Typically you will construct your persistent store manager exactly like this. It needs two pieces of information in order
     * to be set up:
     *
     * - The path to the sqlite file that will be used. Usually in the documents directory
     * - A configured Managed Object Model. See the next property for details.
     */
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        print("Instantiating the persistentStoreCoordinator property")
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        let storeOptions = [
                NSPersistentStoreUbiquitousContentNameKey    : STORE_NAME,
                NSMigratePersistentStoresAutomaticallyOption : true,
                NSInferMappingModelAutomaticallyOption       : true
        ]
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: storeOptions as! [NSObject : AnyObject])
        } catch var error as NSError {
            var dict = [NSObject : AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        print("Instantiating the managedObjectContext property")
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    // Changed Jasons code to support Swift 2.0
    
    func saveContext () {
        if let context = self.managedObjectContext {
            context.performBlock { () -> Void in
                if context.hasChanges {
                    do {
                        try context.save()
                        context.reset()
                    } catch let error as NSError {
                        NSLog("Unresolved error \(error), \(error.userInfo)")
                        abort()
                    }
                }
            }
        }
    }
    
    // MARK: - iCloud
    // This handles the updates to the data via iCloud updates
    
    func registerCoordinatorForStoreNotifications (coordinator : NSPersistentStoreCoordinator) {
        
        let nc : NSNotificationCenter = NSNotificationCenter.defaultCenter();
        
        nc.addObserver(self, selector: "handleStoresWillChange",
            name: NSPersistentStoreCoordinatorStoresWillChangeNotification,
            object: coordinator)
        
        nc.addObserver(self, selector: "handleStoresDidChange:",
            name: NSPersistentStoreCoordinatorStoresDidChangeNotification,
            object: coordinator)
        
        nc.addObserver(self, selector: "handleStoresWillRemove:",
            name: NSPersistentStoreCoordinatorWillRemoveStoreNotification,
            object: coordinator)
        
        nc.addObserver(self, selector: "handleStoreChangedUbiquitousContent:",
            name: NSPersistentStoreDidImportUbiquitousContentChangesNotification,
            object: coordinator)
    }
    
    func handleStoresWillChange(notification: NSNotification) {
        print("==============")
        print("willChange")
        print("==============")
    }
    
    func handleStoresDidChange(notification: NSNotification) {
        print("==============")
        print("didChange")
        print("==============")
    }
    
    func handleStoresWillRemove(notification: NSNotification) {
        print("==============")
        print("willRemove")
        print("==============")
    }
    
    func handleStoreChangedUbiquitousContent(notification: NSNotification) {
        print("==============")
        print("handleStoreChangedUbiquitousContent --> there is something new in iCloud")
        print("==============")
    }
    
    
    
    
    func persistentStoreWillChange(notification: NSNotification) {
        print("Something to be changed, in CoreDataStackManager !!")
        saveContext()
    }
    
    
    
}