//
//  CustomLists+CoreDataProperties.swift
//  smartShopper
//
//  Created  3/20/21.
//
//

import Foundation
import CoreData

extension CustomLists {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomLists> {
        return NSFetchRequest<CustomLists>(entityName: "CustomLists")
    }

    @NSManaged public var customLists: NSSet?
}

// MARK: Generated accessors for customLists
extension CustomLists {

    @objc(addCustomListsObject:)
    @NSManaged public func addToCustomLists(_ value: CustomList)

    @objc(removeCustomListsObject:)
    @NSManaged public func removeFromCustomLists(_ value: CustomList)

    @objc(addCustomLists:)
    @NSManaged public func addToCustomLists(_ values: NSSet)

    @objc(removeCustomLists:)
    @NSManaged public func removeFromCustomLists(_ values: NSSet)

}

extension CustomLists: Identifiable {

}
