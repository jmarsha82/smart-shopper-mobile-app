//
//  PersistenceHelper.swift
//  smartShopper
//
//  Created  2/28/21.
//

import Foundation
import CoreData
import os.log

// MARK: - Start

// How to set up core Data:
// https://ali-akhtar.medium.com/mastering-in-coredata-part-5-relationship-between-entities-in-core-data-b8fea1b50efb

/// Singelton to handle saving and deleting from CoreData
class PersistenceHelper {
    // Creating a static object seemed like the cleanest way to maintain all the auto generated code

    // only the PersistenceHelper class can create instances of itself
    private init() {}

    // MARK: - Core Data stack
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Custom Lists
    /// Making this public static... so I can keep the mess here
    static public func getCustomLists() -> CustomLists? {
        let fetchRequest: NSFetchRequest<CustomLists> = CustomLists.fetchRequest()
        do {
            let item = try  PersistenceHelper.context.fetch(fetchRequest)

            return (item.count > 0 ? item.first : CustomLists(context: PersistenceHelper.context))
        } catch {
            os_log("Failed to obtain Shower Persistence items", type: .error)
        }
        return nil
    }
    // MARK: - Filters
    static public func createFiltersList() -> Filters {
        let filters: [Filter] = []
        let filtersList = Filters(context: context)
        filtersList.num = 0
        filtersList.filters = NSSet(array: filters)
        saveContext()
        return filtersList
    }
    static public func getFiltersList() -> Filters? {
        let fetchRequest: NSFetchRequest<Filters> = Filters.fetchRequest()
        do {
            let results = try  PersistenceHelper.context.fetch(fetchRequest)
            return (results.count > 0 ? results.first : nil)
        } catch {
            print("request failure")
            os_log("Failed to obtain Filter Persistence items", type: .error)
        }
        return nil
    }
    // MARK: - Scanned Food
    /// Tries to look for saved scanned food, will return an empty list if not scanned food are found or an
    /// error occurs
    static public func getScannedFood() -> [ScannedFood] {
        let fetchRequest: NSFetchRequest<ScannedFood> = ScannedFood.fetchRequest()
        do {
            let results = try  PersistenceHelper.context.fetch(fetchRequest)
            return (results.count > 0 ? results : [])
        } catch {
            os_log("Error: %@", log: .default, type: .error, String(describing: error))
        }
        return []
    }
    /// Deletes the given object from Core Data if it exists. Does not save context. 
    static public func removeScannedFood(scannedFood: ScannedFood) {
        let fetchRequest: NSFetchRequest<ScannedFood> = ScannedFood.fetchRequest()
        do {
            let results = try  PersistenceHelper.context.fetch(fetchRequest)
            if results.contains(scannedFood) {
                PersistenceHelper.context.delete(scannedFood)
            }
        } catch {
            os_log("Error: %@", log: .default, type: .error, String(describing: error))
        }
    }
    // MARK: - Core Data stack
    // Not saving to IOS cloud right now
    //    // static properties are executed lazily by default
    //    static var persistentContainer: NSPersistentCloudKitContainer = {
    //        /*
    //         The persistent container for the application. This implementation
    //         creates and returns a container, having loaded the store for the
    //         application to it. This property is optional since there are legitimate
    //         error conditions that could cause the creation of the store to fail.
    //        */
    //        let container = NSPersistentCloudKitContainer(name: "smartShopper")
    //        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
    //            if let error = error as NSError? {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate.
    //                // You should not use this function in a shipping application,
    //                // although it may be useful during development.
    //
    //                /*
    //                 Typical reasons for an error here include:
    //                 * The parent directory does not exist, cannot be created, or disallows writing.
    //                 * The persistent store is not accessible,
    //                 * due to permissions or data protection when the device is locked.
    //                 * The device is out of space.
    //                 * The store could not be migrated to the current model version.
    //                 Check the error message to determine what the actual problem was.
    //                 */
    //                fatalError("Unresolved error \(error), \(error.userInfo)")
    //            }
    //        })
    //
    //        return container
    //    }()

    // Saving to local storage
    static public var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "smartShopper")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device
                 * is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    static func saveContext () {
        let context = PersistenceHelper.context
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.
                os_log("Error: %@", log: .default, type: .error, String(describing: error))
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
