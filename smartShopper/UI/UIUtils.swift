//
//  Utils.swift
//  smartShopper
//
//  Created  2/21/21.
//

import UIKit
import OSLog

// This is a location were any universal item can be added such the one shown bellow
// This was we can all use the methods without have to reimplement them ourselves
// How to Document Code well : https://stackoverflow.com/questions/27715933/how-to-use-swift-documentation-comments

public var honeyYellow: UIColor     = UIColor(named: "Honey Yellow") ?? UIColor.yellow
public var prussianBlue: UIColor    = UIColor(named: "Prussian Blue") ?? UIColor.blue
public var blueGreen: UIColor = UIColor(named: "Blue Green") ?? UIColor.lightGray
public var orange: UIColor = UIColor(named: "Orange") ?? UIColor.orange
public var cornflowerBlue: UIColor = UIColor(named: "Light Cornflower Blue") ?? UIColor.lightGray

// MARK: - Extensions UIViewController
extension UIViewController {

    /// Simple Ok Alert for the user, does not give any feedback
    ///
    /// How to call:
    /// ```
    /// showAlert(title: "My title", message: "My message")
    /// ```
    /// - Parameter title: title of the alert
    /// - Parameter message: The message you would like to present to the user
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .default))
        self.present(alertController, animated: true)

    }

    /// This function allows any one to create an alert dialogue.
    ///
    /// More documentation can be read from here :
    /// https://stackoverflow.com/questions/29633938/swift-displaying-alerts-best-practices
    ///
    /// Example of how to call method:
    /// ```
    /// presentAlertWithTitle(title: "Test", message: "A message", options: "Ok", "Cancel", completion: { (option) in
    ///    print("option:\(option)")
    ///    switch(option) {
    ///    case 0:
    ///       print ("Ok pressed.")
    ///       break
    ///    case 1:
    ///       print ("Cancel Pressed")
    ///       default:
    ///    break
    ///   }
    /// })
    /// ```
    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping(Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (_) in
                completion(index)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }

    /// Goes through the ingredients to see if any of them are in the user banned list
    /// - Returns:
    /// ```True``` if ingredient is banned  |  ```False``` otherwise
    public func banned(ingredient: String, filters: Filters?) -> Bool {
        if ingredient.isEmpty {
            return false
        }

        if let storedFilters: Filters = filters {
            for filter in storedFilters.asArray() {
                let banned = filter.bannedArray()
                    .contains(where: {bannedIngredient in bannedIngredient.name?
                                .trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                                == ingredient.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()})
                if banned {
                    return true
                }
            }
        }
        return false
    }
}

// MARK: - Extensions UIImageView

// credit https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async { [weak self] in
                self?.image = image
            }
        }.resume()
    }

    /// Async download of the image from given link
    /// default content mode is ```scaleAspectFit```
    func download(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

// MARK: - Spinner
private var aView: UIView?

extension UIViewController {

    /// Displays spinner for your view
    /// WIll blur the background
    func showSpinner() {
        aView = UIView(frame: self.view.bounds)

        // Set the blur effect
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = aView!.frame
        aView?.addSubview(blurEffectView)

        // I can force unwrap since i just assigned the variable 2 lines above
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = aView!.center
        activityIndicator.startAnimating()
        aView?.addSubview(activityIndicator)
        self.view.addSubview(aView!)
    }

    /// removes spinner if present
    func removeSpinner() {
        if let view: UIView = aView {
            view.removeFromSuperview()
            aView = nil
        } else {
            os_log("Error: %@",
                   log: .default,
                   type: .error, "Tried to remove Spinner present while not spinner in view.")
        }

    }
}

// MARK: - UIView
extension UIView {
    /// Allows you to decide which corners of the view you would like to round and at what radius
    ///
    /// ```
    /// view.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    /// ```
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

// MARK: - UITableView
extension UITableView {
    /// Sets up a consistent view of the UI Table View throughout the project
    func setupView() {
        let tableViewBorder = cornflowerBlue
        self.layer.borderColor = tableViewBorder.cgColor
        self.layer.cornerRadius = 15.0
        self.layer.borderWidth = 4.0
        self.separatorColor = orange
    }
}

// MARK: - UITextView
extension UITextField {
    /// Sets up a consistent view of the UI Table View throughout the project
    func setUpView() {
        let textBoxBorder = prussianBlue
        self.layer.borderColor = textBoxBorder.cgColor
        self.layer.borderWidth = 2.0
    }
}
