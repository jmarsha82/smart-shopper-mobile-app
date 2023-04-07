//
//  ScannedFood+CoreDataClass.swift
//  smartShopper
//
//  Created  3/31/21.
//
//

import Foundation
import CoreData

@objc(ScannedFood)
public class ScannedFood: NSManagedObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    convenience init?(barcode: String, productName: String) {
        guard let entity = NSEntityDescription.entity(forEntityName: "ScannedFood",
          in: PersistenceHelper.context) else {
            return nil
        }
        self.init(entity: entity, insertInto: PersistenceHelper.context)
        self.barcode = barcode
        self.productName = productName
        self.ingredients = []
        self.ingredientsText = ScannerViewController.noIngredientsText
    }

    public required init?(coder: NSCoder) {
        guard
            let barcode = coder.decodeObject(of: [NSString.self], forKey: "barcode") as? String,
            let foodImage = coder.decodeObject(of: [NSString.self], forKey: "foodImage") as? String,
            let productName = coder.decodeObject(of: [CustomLists.self], forKey: "productName") as? String,
            let ingredients = coder.decodeObject(of: [NSString.self], forKey: "ingredients") as? [String],
            let ingredientsText = coder.decodeObject(of: [NSString.self], forKey: "ingredientsText") as? String,
            let contains = coder.decodeObject(of: [NSString.self], forKey: "contains") as? String,
            let entity = NSEntityDescription.entity(forEntityName: "CustomList", in: PersistenceHelper.context)
        else {
            return nil
        }

        super.init(entity: entity, insertInto: PersistenceHelper.context)
        self.barcode = barcode
        self.foodImage = foodImage
        self.productName = productName
        self.ingredients = ingredients
        self.ingredientsText = ingredientsText
        self.contains = contains
    }

    public func encode(with coder: NSCoder) {
        coder.encode(barcode, forKey: "barcode")
        coder.encode(foodImage, forKey: "foodImage")
        coder.encode(productName, forKey: "productName")
        coder.encode(ingredients, forKey: "ingredients")
        coder.encode(ingredients, forKey: "ingredientsText")
        coder.encode(contains, forKey: "contains")
    }
}
