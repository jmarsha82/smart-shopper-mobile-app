//
//  Filters+CoreDataClass.swift
//  smartShopper
//
//  Created on 3/8/21.
//
//

import Foundation
import CoreData

@objc(Filters)
public class Filters: NSManagedObject {
    func asArray() -> [Filter] {
        return filters?.allObjects as? [Filter] ?? []
    }

    /// Checks all stored filters to see if the given filterName already exists 
    public func containsFilter(filterName: String) -> Bool {
        if let filters: NSSet = self.filters {
            for case let filter as Filter in filters where filter.name == filterName {
                return true
            }
        }
        return false
    }
}
