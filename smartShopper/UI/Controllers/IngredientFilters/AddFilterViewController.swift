//
//  AddFilterViewController.swift
//  smartShopper
//
//  Created on 3/31/21.
//

import UIKit

// MARK: - Start
/// This get's called when the user decided to call `Add Filter` while in the `Ingredients Filters` tab.
/// The Controller allows the user to create a filter, empty or full of restrictions.
class AddFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var filterNameTextField: UITextField!
    @IBOutlet weak var bannedIngredientsTableView: UITableView!
    @IBOutlet weak var macroSegment: UISegmentedControl!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var percentComparePicker: UISegmentedControl!
    @IBOutlet weak var amountComparePicker: UISegmentedControl!
    @IBOutlet weak var percentText: UITextField!

    public var filter: Filter?
    var bannedIngredients: [String] = []
    var macro: Int32 = 0
    var amount: Float = 0.0
    var percentage: Float = 0.0
    var amountLessThan = true
    var percentLessThan = true
    var filters: Filters = PersistenceHelper.getFiltersList() ?? PersistenceHelper.createFiltersList()

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        bannedIngredientsTableView.delegate = self
        bannedIngredientsTableView.dataSource = self
        bannedIngredientsTableView.setupView()
        filterNameTextField.delegate = self
        macroSegment.selectedSegmentIndex = 0
        // filters = PersistenceHelper.getFiltersList() ?? PersistenceHelper.createFiltersList()
        bannedIngredientsTableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        PersistenceHelper.saveContext()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    // MARK: - IBActions
    @IBAction func changeName(_ sender: Any) {
        filter?.name = filterNameTextField.text
    }

    @IBAction func changeMacro(_ sender: Any) {
        macro = Int32(macroSegment.selectedSegmentIndex)
    }

    @IBAction func enterAmount(_ sender: Any) {
        amount = Float(amountText.text ?? "0") ?? 0
    }

    @IBAction func enterPercent(_ sender: Any) {
        percentage = Float(percentText.text ?? "0") ?? 0
    }

    @IBAction func switchAmount(_ sender: Any) {
        amountLessThan = !(filter?.amountLessThan ?? true)
    }

    @IBAction func switchPercent(_ sender: Any) {
        percentLessThan = !(filter?.percentLessThan ?? true)
    }

    @IBAction func save(_ sender: Any) {
        if let name = filterNameTextField.text {
            var found = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if !found {
                for filter in filters.asArray() where filter.name == name {
                    found = true
                }
            }
            if !found {
                if let filterNew = Filter(name: name, ofFilters: filters) {
                    filter = filterNew
                    filters.addToFilters(filterNew)
                    filterNew.macro = macro
                    filterNew.amount = Float(amountText.text ?? "0") ?? 0
                    filterNew.percentage = Float(percentText.text ?? "0") ?? 0
                    filterNew.amountLessThan = amountLessThan
                    filterNew.percentLessThan = percentLessThan
                    for bannedName in bannedIngredients {
                        if let banned = BannedIngredient(name: bannedName, ofFilter: filterNew) {
                            filterNew.addToBannedIngredients(banned)
                        }
                    }
                }
            }
        }
        PersistenceHelper.saveContext()
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addBannedIngredient(_ sender: Any) {
        let alertController = UIAlertController(title: "Add a Banned Ingredient", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: ({(_) in
            guard let entries: [UITextField] = alertController.textFields,
                  let entry: String = entries[0].text,
                  !entry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                return
            }
            self.bannedIngredients.append(entry)
            self.bannedIngredientsTableView.reloadData()
        }))
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Add an Ingredient"
        })
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Extension Table View
extension AddFilterViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bannedIngredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var bannedIngCell: UITableViewCell
        if let dequeueCell =
            bannedIngredientsTableView.dequeueReusableCell(withIdentifier: "addFilterCell") {
            bannedIngCell = dequeueCell
        } else {
            bannedIngCell = UITableViewCell(style: UITableViewCell.CellStyle.default,
                                            reuseIdentifier: "addFilterCell")
        }
        bannedIngCell.textLabel!.text = bannedIngredients[indexPath.row]
        return bannedIngCell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        bannedIngredients.remove(at: indexPath.row)
        bannedIngredientsTableView.reloadData()
    }
}
