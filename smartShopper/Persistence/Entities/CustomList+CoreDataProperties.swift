//
//  CustomList+CoreDataProperties.swift
//  smartShopper
//
//  Created  3/17/21.
//
//

import Foundation
import CoreData

extension CustomList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomList> {
        return NSFetchRequest<CustomList>(entityName: "CustomList")
    }

    @NSManaged public var items: [String]?
    @NSManaged public var title: String?
    @NSManaged public var ofCustomLists: CustomLists?

}

extension CustomList: Identifiable {

}
