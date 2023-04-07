//
//  Filter+CoreDataClass.swift
//  smartShopper
//
//  Created on 3/29/21.
//
//

import Foundation
import CoreData

@objc(Filter)
public class Filter: NSManagedObject {
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    public convenience init?(name: String, ofFilters filters: Filters) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Filter", in: PersistenceHelper.context) else {
            return nil
        }
        self.init(entity: entity, insertInto: PersistenceHelper.context)
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.ofFilters = filters
        self.macro = 0
        self.percentage = -1
        self.amount = -1
        self.amountLessThan = true
        self.percentLessThan = true
        let bannedIngArr: [BannedIngredient] = []
        self.bannedIngredients = NSSet(array: bannedIngArr)
        // filters.addToFilters(self)
    }
    func bannedArray() -> [BannedIngredient] {
        return bannedIngredients?.allObjects as? [BannedIngredient] ?? []
    }
}
