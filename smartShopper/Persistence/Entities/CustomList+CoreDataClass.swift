//
//  CustomList+CoreDataClass.swift
//  smartShopper
//
//  Created  3/13/21.
//
//

import Foundation
import CoreData
import os.log

@objc(CustomList)
public class CustomList: NSManagedObject, NSSecureCoding {

    /// Required by NSManagedObjects that are 
    public static var supportsSecureCoding: Bool = true

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    convenience init?(items: [String], title: String, ofCustomLists: CustomLists) {
        guard let entity = NSEntityDescription.entity(forEntityName: "CustomList", in: PersistenceHelper.context) else {
            return nil
        }
        self.init(entity: entity, insertInto: PersistenceHelper.context)
        self.items = items
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.ofCustomLists = ofCustomLists
    }

    public required init?(coder: NSCoder) {
        guard
            let items = coder.decodeObject(of: [NSString.self], forKey: "items") as? [String],
            let title = coder.decodeObject(of: [NSString.self], forKey: "title") as? String,
            let ofCustomLists = coder.decodeObject(of: [CustomLists.self], forKey: "ofCustomLists") as? CustomLists,
            let entity = NSEntityDescription.entity(forEntityName: "CustomList", in: PersistenceHelper.context)
        else {
            return nil
        }

        super.init(entity: entity, insertInto: PersistenceHelper.context)

        self.items = items
        self.title = title
        self.ofCustomLists = ofCustomLists
    }

    public func encode(with coder: NSCoder) {
        coder.encode(items, forKey: "items")
        coder.encode(title, forKey: "title")
        coder.encode(ofCustomLists, forKey: "ofCustomLists")
    }

}
