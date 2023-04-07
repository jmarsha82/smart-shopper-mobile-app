//
//  Filters+CoreDataProperties.swift
//  smartShopper
//
//  Created  3/17/21.
//
//

import Foundation
import CoreData

extension Filters {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Filters> {
        return NSFetchRequest<Filters>(entityName: "Filters")
    }

    @NSManaged public var num: Int64
    @NSManaged public var filters: NSSet?

}

// MARK: Generated accessors for filters
extension Filters {

    @objc(addFiltersObject:)
    @NSManaged public func addToFilters(_ value: Filter)

    @objc(removeFiltersObject:)
    @NSManaged public func removeFromFilters(_ value: Filter)

    @objc(addFilters:)
    @NSManaged public func addToFilters(_ values: NSSet)

    @objc(removeFilters:)
    @NSManaged public func removeFromFilters(_ values: NSSet)

}

extension Filters: Identifiable {

}
