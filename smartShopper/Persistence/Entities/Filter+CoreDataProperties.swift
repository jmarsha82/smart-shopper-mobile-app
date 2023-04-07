//
//  Filter+CoreDataProperties.swift
//  smartShopper
//
//  Created on 3/29/21.
//
//

import Foundation
import CoreData

extension Filter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Filter> {
        return NSFetchRequest<Filter>(entityName: "Filter")
    }

    /// User chosen filter name
    @NSManaged public var name: String?
    /// Indicates with ```Filter.MacroEnum``` the user picked for their filter
    @NSManaged public var macro: Int32
    /// the macro percentage value
    /// ```
    /// defaults to -1
    /// ```
    @NSManaged public var percentage: Float
    /// the macro amount 
    /// ```
    /// defaults to -1
    /// ```
    @NSManaged public var amount: Float
    /// Indicates if the user chose amount value for less than
    @NSManaged public var amountLessThan: Bool
    /// indicates if the user chose percent value less than
    @NSManaged public var percentLessThan: Bool
    /// List of all ingredients the user would like to ban
    @NSManaged public var bannedIngredients: NSSet?
    /// Parent object which holds all user created filters
    @NSManaged public var ofFilters: Filters?

    /// Helpful enum which helps identify which macro the user chose
    public enum MacroEnum: Int {
        case none = 0
        case protein = 1
        case carbs = 2
        case fat = 3

        /// Converts the int value to ```Int32```
        var code: Int32 {
            switch self {
            case .none: return 0
            case .protein: return 1
            case .carbs: return 2
            case .fat: return 3
            }
        }
    }

}

// MARK: Generated accessors for bannedIngredients
extension Filter {

    @objc(addBannedIngredientsObject:)
    @NSManaged public func addToBannedIngredients(_ value: BannedIngredient)

    @objc(removeBannedIngredientsObject:)
    @NSManaged public func removeFromBannedIngredients(_ value: BannedIngredient)

    @objc(addBannedIngredients:)
    @NSManaged public func addToBannedIngredients(_ values: NSSet)

    @objc(removeBannedIngredients:)
    @NSManaged public func removeFromBannedIngredients(_ values: NSSet)

}

extension Filter: Identifiable {

}
