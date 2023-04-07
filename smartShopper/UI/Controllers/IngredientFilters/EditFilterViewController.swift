//
//  EditFilterViewController.swift
//  smartShopper
//
//  Created on 2/20/21.
//

import UIKit

// MARK: - Start
/// Displayed when the user decided to editing a filter while viewing the `FilterDetialsViewController`
class EditFilterViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var filterNameTextField: UITextField!
    @IBOutlet weak var bannedIngredientsTableView: UITableView!
    @IBOutlet weak var macroSegment: UISegmentedControl!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var percentComparePicker: UISegmentedControl!
    @IBOutlet weak var amountComparePicker: UISegmentedControl!
    @IBOutlet weak var percentText: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var percentTextField: UITextField!

    var filter: Filter?
    var bannedIngredients: [BannedIngredient] = []
    var filters: Filters = PersistenceHelper.getFiltersList() ?? PersistenceHelper.createFiltersList()

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        bannedIngredientsTableView.delegate = self
        bannedIngredientsTableView.dataSource = self
        bannedIngredientsTableView.setupView()
        filterNameTextField.delegate = self
        updateView()
    }

    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }

    func updateView() {
        filterNameTextField.text = filter?.name ?? "Filter Name"
        macroSegment.selectedSegmentIndex = Int(filter?.macro ?? 0)
        if macroSegment.selectedSegmentIndex == 0 {
            amountComparePicker.isEnabled = false
            amountTextField.isEnabled = false
            percentComparePicker.isEnabled = false
            percentTextField.isEnabled = false
        } else {
            if let filter = self.filter {
                if filter.amount != -1 {
                    amountTextField.text = String(filter.amount)
                }
                if filter.percentage != -1 {
                    percentTextField.text = String(filter.percentage)
                }
            }
            amountComparePicker.selectedSegmentIndex = (filter?.amountLessThan ?? true ? 0 : 1)
            percentComparePicker.selectedSegmentIndex = (filter?.percentLessThan ?? true ? 0 : 1)
        }
        bannedIngredientsTableView.reloadData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    // MARK: - IBAction
    @IBAction func changeName(_ sender: Any) {
        filter?.name = filterNameTextField.text
    }

    @IBAction func changeMacro(_ sender: Any) {
        filter?.macro = Int32(macroSegment.selectedSegmentIndex)
        if macroSegment.selectedSegmentIndex == 0 {
            amountComparePicker.isEnabled = false
            amountTextField.isEnabled = false
            percentComparePicker.isEnabled = false
            percentTextField.isEnabled = false
        } else {
            amountComparePicker.isEnabled = true
            amountTextField.isEnabled = true
            percentComparePicker.isEnabled = true
            percentTextField.isEnabled = true
        }
    }

    @IBAction func enterAmount(_ sender: Any) {
        filter?.amount = Float(amountText.text ?? "0") ?? 0
    }

    @IBAction func enterPercent(_ sender: Any) {
        filter?.percentage = Float(percentText.text ?? "0") ?? 0
    }

    @IBAction func switchAmount(_ sender: Any) {
        filter?.amountLessThan = !(filter?.amountLessThan ?? true)
    }

    @IBAction func switchPercent(_ sender: Any) {
        filter?.percentLessThan = !(filter?.percentLessThan ?? true)
    }

    @IBAction func save(_ sender: Any) {
        filter?.name = filterNameTextField.text
        filter?.amount = Float(amountText.text ?? "0") ?? 0
        filter?.percentage = Float(percentText.text ?? "0") ?? 0
        PersistenceHelper.saveContext()
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addBanned() {
        let alertController = UIAlertController(title: "Add a Banned Ingredient", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: ({(_) in
            guard let entries: [UITextField] = alertController.textFields,
                  let entry: String = entries[0].text,
                  let newFilter = Filter(name: "My Filter", ofFilters: self.filters),
                  let bannedEntry = BannedIngredient(name: entry, ofFilter: self.filter ?? newFilter)
            else {
                // print("add ing failed")
                return
            }
            self.filters.removeFromFilters(newFilter)
            self.filter?.addToBannedIngredients(bannedEntry)
            // let indexPaths: [IndexPath] = [IndexPath(row: self.bannedIngredients.count, section: 0)]
            // self.bannedIngredientsTableView.insertRows(at: indexPaths, with: .automatic)
            self.bannedIngredients.append(bannedEntry)
            // print(self.bannedIngredients.count)
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

// MARK: - Extension - UITable
extension EditFilterViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bannedIngredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var bannedIngCell: UITableViewCell
        if let dequeueCell =
            bannedIngredientsTableView.dequeueReusableCell(withIdentifier: "editIngFilterCell") {
            bannedIngCell = dequeueCell
        } else {
            bannedIngCell = UITableViewCell(style: UITableViewCell.CellStyle.default,
                                            reuseIdentifier: "editIngFilterCell")
        }
        bannedIngCell.textLabel!.text = bannedIngredients[indexPath.row].name
        return bannedIngCell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        filter?.removeFromBannedIngredients(bannedIngredients[indexPath.row])
        bannedIngredients.remove(at: indexPath.row)
        bannedIngredientsTableView.reloadData()
    }
}
