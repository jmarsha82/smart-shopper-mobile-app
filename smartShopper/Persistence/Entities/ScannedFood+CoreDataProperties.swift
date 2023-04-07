//
//  ScannedFood+CoreDataProperties.swift
//  smartShopper
//
//  Created  4/13/21.
//
//

import Foundation
import CoreData

extension ScannedFood {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScannedFood> {
        return NSFetchRequest<ScannedFood>(entityName: "ScannedFood")
    }

    @NSManaged public var barcode: String?
    @NSManaged public var foodImage: String?
    @NSManaged public var productName: String?
    @NSManaged public var ingredients: [String]?
    /// example: "sugar, cocoa processed with alkali, less than 2% of soylecithin, ...."
    @NSManaged public var ingredientsText: String?
    @NSManaged public var contains: String

}

extension ScannedFood: Identifiable {

}
