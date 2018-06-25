//
//  CoreDataStackManager.swift
//  YACA
//
//  Created by Andreas Pfister on 03/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataStackManagerDelegate : class {
    func CoreDataStackManagerDidSaveContext()
}

class CoreDataStackManager {
    
    struct Constants {
        static let persistentStoreSqlFile       = "yaca.sqlite"
        static let persistentModelName          = "YACA"
        static let contextSaveNotification      = "CoreDataStackManagerDidSaveContextNotification"
    }
    
    fileprivate let defaultCenter = NotificationCenter.default
    weak var delegate : CoreDataStackManagerDelegate?
    
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
    
    lazy var applicationDocumentsDirectory: URL = {
        
        print("Instantiating the applicationDocumentsDirectory property")
        
        let urls = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        
        print("Instantiating the managedObjectModel property")
        
        let modelURL = Bundle.main.url(forResource: Constants.persistentModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
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
        let url = self.applicationDocumentsDirectory.appendingPathComponent(Constants.persistentStoreSqlFile)
        
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error as NSError {
            var dict = [AnyHashable: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as! [String : Any])
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
        //var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }()
    
    func saveContext(_ context: NSManagedObjectContext? = CoreDataStackManager.sharedInstance().managedObjectContext!,completition : (()->() )? ) {
        //Perform save on main thread
        if (Thread.isMainThread) {
            saveContextFunction(context,completition: completition)
        }else {
            OperationQueue.main.addOperation(){
                self.saveContextFunction(context, completition : completition)
            }
        }
    }
    
    // MARK: - Core Data Saving support
    fileprivate
    func saveContextFunction(_ context: NSManagedObjectContext? = CoreDataStackManager.sharedInstance().managedObjectContext!,completition : (()->() )? ) {
        if let context = self.managedObjectContext {
            context.performAndWait { () -> Void in
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch let error as NSError {
                        NSLog("Unresolved error \(error), \(error.userInfo)")
                        abort()
                    }
                    
                    //Call delegate method --> not used anymore but keep alive
                    self.delegate?.CoreDataStackManagerDidSaveContext()
                    //Send notification message --> not used anymore but keep alive
                    self.defaultCenter.post(name: Notification.Name(rawValue: Constants.contextSaveNotification), object: self)
                    
                }
                //Perform completition closure
                if let closure = completition {
                    closure()
                }
            }
        }
    }
}
