//
//  CustomLists+CoreDataClass.swift
//  smartShopper
//
//  Created  3/13/21.
//
//

import Foundation
import CoreData

@objc(CustomLists)
public class CustomLists: NSManagedObject, NSSecureCoding {

    public static var supportsSecureCoding: Bool = true

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public required init?(coder: NSCoder) {
        guard
            let customLists = coder.decodeObject(of: [CustomList.self], forKey: "customLists") as? NSSet,
            let entity = NSEntityDescription.entity(forEntityName: "CustomList", in: PersistenceHelper.context)
        else {
            return nil
        }

        super.init(entity: entity, insertInto: PersistenceHelper.context)
        self.customLists = customLists
    }

    public func encode(with coder: NSCoder) {
        coder.encode(customLists, forKey: "customLists")
    }

    /// Using the given title sees if another ```CustomList``` already exists with the same title
    public func containsList(title: String) -> Bool {
        if let lists: NSSet = self.customLists {
            for case let customList as CustomList in lists where customList.title == title {
                return true
            }
        }
        return false
    }
}
