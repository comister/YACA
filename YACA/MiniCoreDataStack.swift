//
//  MiniCoreDataStack.swift
//  YACA
//
//  Created by Andreas Pfister on 28/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import CoreData

protocol MiniCoreDataStackDelegate : class {
    func MiniCoreDataStackDidSaveContext()
}

@objc(MiniCoreDataStack)

class MiniCoreDataStack: NSObject {
    
    struct Constants {
        static let persistentStoreName          = "YACA"
        static let persistentModelName          = "YACA"
        static let contextSaveNotification      = "MiniCoreDataStackDidSaveContextNotification"
    }
    
    private var managedObjectModel : NSManagedObjectModel
    private var persistentStoreCoordinator : NSPersistentStoreCoordinator? = nil
    private var store : NSPersistentStore?
    private let defaultCenter = NSNotificationCenter.defaultCenter()
    
    var defaultContext : NSManagedObjectContext!
    
    var stackIsLoaded : Bool = false
    
    weak var delegate : MiniCoreDataStackDelegate?
    
    class var defaultModel: NSManagedObjectModel {
        return NSManagedObjectModel.mergedModelFromBundles(nil)!
    }
    
    class var sharedInstance: MiniCoreDataStack  {
        struct Singleton {
            static let instance = MiniCoreDataStack()
        }
        return Singleton.instance
    }
    
    
    class func storesDirectory() -> NSURL {
        let applicationDocumentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory,inDomains: .UserDomainMask).last! as NSURL
        return applicationDocumentsDirectory
    }
    
    private func storeURLForName(name:String) -> NSURL {
        return MiniCoreDataStack.storesDirectory().URLByAppendingPathComponent("\(name).sqlite")
    }
    
    func localStoreOptions() -> NSDictionary {
        return [
            NSPersistentStoreUbiquitousContentNameKey:Constants.persistentStoreName,
            NSInferMappingModelAutomaticallyOption:true,
            NSMigratePersistentStoresAutomaticallyOption:true
        ]
    }
    
    init( model : NSManagedObjectModel = MiniCoreDataStack.defaultModel){
        managedObjectModel = model
    }
    
    
    func openStore(completion:(()->Void)?) {
        print("\(NSStringFromClass(self.dynamicType)):  \(__FUNCTION__)")
        
        let tempPersistenStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            try tempPersistenStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.storeURLForName(Constants.persistentModelName), options: self.localStoreOptions() as [NSObject : AnyObject])
        } catch let error as NSError {
            print("\(NSStringFromClass(self.dynamicType)): !!! Could not add persistent store !!!")
            print(error.localizedDescription)
        } catch {}
        
        self.persistentStoreCoordinator = tempPersistenStoreCoordinator
            
            
        defaultContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        defaultContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        defaultContext.persistentStoreCoordinator = persistentStoreCoordinator
            
            
        self.stackIsLoaded = true
        print("\(NSStringFromClass(self.dynamicType)):  Store loaded")
            
        if let completionClosure = completion {
            completionClosure()
        }
            
    }
    
    private func saveContext(context: NSManagedObjectContext? = MiniCoreDataStack.sharedInstance.defaultContext!, completition : (()->() )?) {
        if !self.stackIsLoaded {
            return
        }
        
        if let moc = context {
            if moc.hasChanges {
                do {
                    try moc.save()
                    //moc.reset()
                } catch let error as NSError {
                    NSLog("Unresolved error \(error), \(error.userInfo)")
                    abort()
                } catch {}
            }
            
            //Call delegate method
            delegate?.MiniCoreDataStackDidSaveContext()
            
            //Send notification message
            defaultCenter.postNotificationName(Constants.contextSaveNotification, object: self)
            
            //Perform completition closure
            if let closure = completition {
                closure()
            }
        }
    }
    
    func save(context: NSManagedObjectContext? = MiniCoreDataStack.sharedInstance.defaultContext!,completition : (()->() )? ) {
        //Perform save on main thread
        
        if (NSThread.isMainThread()) {
            saveContext(context,completition: completition)
        }else {
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.saveContext(context, completition : completition)
            }
        }
    }
    
    
    func fetchResultsControllerForEntity(entity : NSEntityDescription, predicate:   NSPredicate? = nil, sortDescriptors:[NSSortDescriptor]? = nil, sectionNameKeyPath:String? = nil, cacheName: String? = nil,inManagedContext context : NSManagedObjectContext? = nil ) ->NSFetchedResultsController {
        
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = entity
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 25
        
        let aContext = context ?? self.defaultContext!
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: aContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        } catch { }
        
        
        return fetchedResultsController
    }
    
    func executeFetchRequest(request : NSFetchRequest, context: NSManagedObjectContext? = nil) -> [NSManagedObject] {
        var fetchedObjects = [NSManagedObject]()
        
        let managedContext = context ?? defaultContext
        
        managedContext?.performBlockAndWait{
            do {
                let result = try managedContext?.executeFetchRequest(request)
                if let managedObjects = result as? [NSManagedObject] {
                    fetchedObjects = managedObjects
                }
            } catch let error as NSError {
                print(error)
            } catch {}
        }
        
        return fetchedObjects
    }
    
    func insertEntityWithClassName(className :String, andAttributes attributesDictionary : NSDictionary? = nil, andContext context : NSManagedObjectContext = MiniCoreDataStack.sharedInstance.defaultContext ) -> NSManagedObject {
        let entity = NSEntityDescription.insertNewObjectForEntityForName(className, inManagedObjectContext: context) 
        if let attributes = attributesDictionary {
            attributes.enumerateKeysAndObjectsUsingBlock({
                (dictKey : AnyObject!, dictObj : AnyObject!, stopBool) -> Void in
                entity.setValue(dictObj, forKey: dictKey as! String)
            })
        }
        return entity
    }
    
    func deleteEntity(entity: NSManagedObject){
        self.defaultContext!.deleteObject(entity)
    }
    
}