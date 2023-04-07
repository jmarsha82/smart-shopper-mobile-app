//
//  BannedIngredient+CoreDataProperties.swift
//  smartShopper
//
//  Created  3/17/21.
//
//

import Foundation
import CoreData

extension BannedIngredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BannedIngredient> {
        return NSFetchRequest<BannedIngredient>(entityName: "BannedIngredient")
    }

    @NSManaged public var name: String?
    @NSManaged public var ofFilter: Filter?

}

extension BannedIngredient: Identifiable {

}
