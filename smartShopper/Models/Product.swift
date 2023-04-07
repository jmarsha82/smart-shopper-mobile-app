//
//  APIResult.swift
//  smartShopper
//
//  Created  3/13/21.
//

import UIKit

// Helpful link about Decoding : https://stackoverflow.com/a/53569685

// MARK: - Product
/// Actual food information which will be displayed to the user
class Product: Codable {
    var productName: String
    var ingredients: String?
    var imageUrl: String?
    var servingSize: String?
    let selectedImages: SelectedImages?
    var allergens: String?
    var allergensFromIngredients: String?
    var nutriments: Nutriments

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case ingredients = "ingredients_text"
        case imageUrl = "image_url"
        case servingSize = "serving_size"
        case nutriments = "nutriments"
        case selectedImages = "selected_images"
        case allergens = "allergens"
        case allergensFromIngredients = "allergens_from_ingredients"
    }

    /// Tries to strip the string from ```,``` and gives back a list ordered from most used ingredient to least
    /// Will remove the ```contains:``` and everything after
    /// Returns: If no ingredients then an empty list is returned
    public func getIngredients() -> [String] {
        if var ingredientsText: String = ingredients {
            if let containsRange = ingredientsText.range(of: ScannerViewController.containsStr) {
                ingredientsText.removeSubrange(containsRange.lowerBound..<ingredientsText.endIndex)
            }

            return (ingredientsText.removePeriod().components(separatedBy: ","))
                .map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        }
        return []
    }

    /// Tries to get the allergen info from the product if present,
    /// Will combine ```allergens``` and ```allergensFromIngredients```
    /// if both present. If they're not present then this will try to parse ```ingredients```
    /// and see if that has information.
    /// Will try to get the ```Contains: ....``` from the ingredients if present is not then ```N/A``` is returned
    public func getAllergens() -> String {

        var returnString: String = ScannerViewController.noIngredientsText

        if let allergen: String = self.allergens {
            if !allergen.isEmpty {
                returnString = allergen.removeEn()
            }
        }

        returnString += allergensFromIngredients ?? ""

        if returnString != ScannerViewController.noIngredientsText {
            return returnString.removeEn()
        }

        if let ingredientsText: String = ingredients {
            if ingredientsText.range(of: ScannerViewController.containsStr) != nil {
                var subString: String = ""
                if subString.contains(":") {
                    subString.remove(at: subString.startIndex)
                }
                return subString
            }

        }
        return returnString.removeEn()
    }

    /// Will try to get the smallest Image possible stored in the ```SelectedImages```
    public func getSmallestImage() -> String? {
        if let images = selectedImages {
            if let front = images.front {

                if let thumb = front.thumb, let image = thumb.en {
                    return image
                }

                if let small = front.small, let image = small.en {
                    return image
                }

                if let display = front.display, let image = display.en {
                    return image
                }
            }
        }
        return nil
    }
}

// MARK: - Nutriments
class Nutriments: Codable {
    let carbohydratesServing: Double?
    let fatUnit: String?
    let fat: Double?
    let sodium: Double?
    let energyUnit: String?
    let carbohydrates: Double?
    let saturatedFatValue: Double?
    let sodiumUnit: String?
    let nutritionScoreFr100G, fat100G: Double?
    let sodium100G, sugars100G, salt: Double?
    let carbohydratesValue, sugarsValue: Double?
    let sodiumValue: Double?
    let saturatedFat100G: Double?
    let sodiumServing: Double?
    let energyKcal, proteins: Double?
    let saltServing: Double?
    let saturatedFat, fiberValue: Double?
    let fiberServing: Double?
    let fiberUnit: String?
    let fatServing: Double?
    let carbohydratesUnit: String?
    let saturatedFatServing: Double?
    let saturatedFatUnit: String?
    let energy: Double?
    let sugars: Double?
    let fatValue, saltValue: Double?
    let sugarsUnit: String?
    let sugarsServing: Double?
    let carbohydrates100G: Double?
    let saltUnit: String?
    let fiber: Double?
    let proteinsUnit: String?
    let fiber100G: Double?

    enum CodingKeys: String, CodingKey {
        case carbohydratesServing = "carbohydrates_serving"
        case fatUnit = "fat_unit"
        case fat
        case sodium
        case energyUnit = "energy_unit"
        case carbohydrates
        case saturatedFatValue = "saturated-fat_value"
        case sodiumUnit = "sodium_unit"
        case nutritionScoreFr100G = "nutrition-score-fr_100g"
        case fat100G = "fat_100g"
        case sodium100G = "sodium_100g"
        case sugars100G = "sugars_100g"
        case salt
        case carbohydratesValue = "carbohydrates_value"
        case sugarsValue = "sugars_value"
        case sodiumValue = "sodium_value"
        case saturatedFat100G = "saturated-fat_100g"
        case sodiumServing = "sodium_serving"
        case energyKcal = "energy-kcal"
        case proteins
        case saltServing = "salt_serving"
        case saturatedFat = "saturated-fat"
        case fiberValue = "fiber_value"
        case fiberServing = "fiber_serving"
        case fiberUnit = "fiber_unit"
        case fatServing = "fat_serving"
        case carbohydratesUnit = "carbohydrates_unit"
        case saturatedFatServing = "saturated-fat_serving"
        case saturatedFatUnit = "saturated-fat_unit"
        case energy
        case sugars
        case fatValue = "fat_value"
        case saltValue = "salt_value"
        case sugarsUnit = "sugars_unit"
        case sugarsServing = "sugars_serving"
        case carbohydrates100G = "carbohydrates_100g"
        case saltUnit = "salt_unit"
        case fiber
        case proteinsUnit = "proteins_unit"
        case fiber100G = "fiber_100g"
    }
}

// MARK: - SelectedImages
class SelectedImages: Codable {
    let nutrition, ingredients, front: Front?

    init(nutrition: Front?, ingredients: Front?, front: Front?) {
        self.nutrition = nutrition
        self.ingredients = ingredients
        self.front = front
    }
}

// MARK: - Front
class Front: Codable {
    let display, thumb, small: Display?

    init(display: Display?, thumb: Display?, small: Display?) {
        self.display = display
        self.thumb = thumb
        self.small = small
    }
}

// MARK: - Display
class Display: Codable {
    // swiftlint:disable identifier_name
    let en: String?
}
