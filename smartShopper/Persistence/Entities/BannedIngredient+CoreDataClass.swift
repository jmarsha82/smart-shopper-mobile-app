//
//  BannedIngredient+CoreDataClass.swift
//  smartShopper
//
//  Created on 3/8/21.
//
//

import Foundation
import CoreData

@objc(BannedIngredient)
public class BannedIngredient: NSManagedObject {
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    public convenience init?(name: String, ofFilter filter: Filter) {
        guard let entity = NSEntityDescription.entity(forEntityName: "BannedIngredient",
                                                      in: PersistenceHelper.context) else {
            return nil
        }
        self.init(entity: entity, insertInto: PersistenceHelper.context)
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.ofFilter = filter
        // filter.addToBannedIngredients(self)
    }
}
