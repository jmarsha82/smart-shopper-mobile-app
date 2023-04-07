//
//  AlertService.swift
//  smartShopper
//
//  Created  4/24/21.
//

import UIKit

// MARK: - Start
/// Gives any `ViewController` the ability to create the custom alerts we've created for the app.
class AlertService {

    /// Creates the Custom Alert for use
    /// Returns view controller or nil if failed to initialize
    func customListAlert(title: String, cornerRadius: CGFloat = 10) -> CustomAlertViewController? {
        let storyBoard = UIStoryboard(name: "CustomAlert", bundle: .main)

        if let alertVC = storyBoard.instantiateViewController(withIdentifier: "AlertVC") as? CustomAlertViewController {
            alertVC.alertTitle = title
            alertVC.cornerRadius = cornerRadius
            return alertVC
        }
        return nil
    }

    /// Creates a alert which will display all filters and the closure will be
    /// called if the user has picked a filter to add an ingredient to.
    /// Otherwise the alert will close without calling the closure.
    func filterAlert(ingredientToBan: String,
                     cornerRadius: CGFloat = 10, completion: @escaping () -> Void) -> FilterAlertViewController? {
        let storyBoard = UIStoryboard(name: "FilterAlert", bundle: .main)

        if let alertVC = storyBoard.instantiateViewController(identifier: "FilterAlert") as? FilterAlertViewController {
            alertVC.setupAlert(ingredient: ingredientToBan)
            alertVC.didBanIngredientAction = completion
            return alertVC
        }
        return nil
    }
}
