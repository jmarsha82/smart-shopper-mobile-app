//
//  FilterAlertViewController.swift
//  smartShopper
//
//  Created  5/1/21.
//

import UIKit
import OSLog

// MARK: - Start
/// Displays all filters to the user in `Alert` format giving them the ability to
/// create new filters or add ingredients to a tapped `Filter`
class FilterAlertViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var filtersTableView: UITableView!
    @IBOutlet weak var filterTitleTextField: UITextField!
    @IBOutlet weak var topView: UIView!

    private var filters: Filters?
    private var ingredient: String?

    var didBanIngredientAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        filtersTableView.delegate = self
        filtersTableView.dataSource = self

        filterTitleTextField.setUpView()

        filters = PersistenceHelper.getFiltersList()

        // This will allow the view to move the alert box up when the keyboard shows up
        NotificationCenter.default.addObserver(self,
                selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.filterTitleTextField.delegate = self
    }

    public func setupAlert(ingredient: String) {
        self.ingredient = ingredient
    }

    override func viewDidDisappear(_ animated: Bool) {
        PersistenceHelper.saveContext()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification
                                .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    // MARK: - IBAction
    @IBAction func createNewFilterTouch(_ sender: Any) {
        if let filterName = filterTitleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           let filters: Filters = self.filters {
            if !filters.containsFilter(filterName: filterName) {
                if let newFilter: Filter = Filter.init(name: filterName, ofFilters: filters) {
                    filters.addToFilters(newFilter)
                    filtersTableView.reloadData()
                }
            }
        }
        // Close the keyboard if open
        self.view.endEditing(true)
    }

    @IBAction func closeBtnTouch(_ sender: Any) {
        dismiss(animated: true)
    }

}

// MARK: - Extension TableView
extension FilterAlertViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.filters?.filters?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = filtersTableView.dequeueReusableCell(withIdentifier: FilterAlertTableViewCell.cellIdentifier)
            as? FilterAlertTableViewCell, let filters: Filters = self.filters {

            cell.setupCell(filter: filters.asArray()[indexPath.row])
            return cell
        }
        os_log("Error: %@", log: .default, type: .error, "Failed to create \(FilterAlertTableViewCell.cellIdentifier)")
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let filters: Filters = self.filters, let ingredient: String = self.ingredient {
            let allFilters: [Filter] = filters.asArray()
            if let bannedIngredient: BannedIngredient
                = BannedIngredient.init(name: ingredient, ofFilter: allFilters[indexPath.row]) {
                allFilters[indexPath.row].bannedIngredients?.adding(bannedIngredient)
            }
        }
        dismiss(animated: true)
        didBanIngredientAction?()
    }
}
