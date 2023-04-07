//
//  FilterDetailsViewController.swift
//  smartShopper
//
//  Created on 2/20/21.
//

import UIKit

// MARK: - Start
/// Gets called when the user selects a filter that they had created from the `Ingredient Filters Tab`
class FilterDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - IBOutlet
    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet weak var bannedIngredientsTableView: UITableView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var macroLabel: UILabel!
    @IBOutlet weak var amountCompareLabel: UILabel!
    @IBOutlet weak var percentCompareLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationItem!

    var filter: Filter?
    var bannedIngredients: [BannedIngredient] = []
    var macro: Filter.MacroEnum = .none
    var percent = 0.0
    var amount = 0.0

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        bannedIngredientsTableView.delegate = self
        bannedIngredientsTableView.dataSource = self
        bannedIngredientsTableView.setupView()
        updateView()
    }

    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        PersistenceHelper.saveContext()
    }

    func updateView() {
        navBar.title = "\(filter?.name ?? "Filter") Details"
        filterNameLabel.text = filter?.name ?? ""
        filterNameLabel.adjustsFontSizeToFitWidth = true
        switch filter?.macro ?? 0 {
        case Filter.MacroEnum.fat.code:
            macro = .fat
        case Filter.MacroEnum.protein.code:
            macro = .protein
        case Filter.MacroEnum.carbs.code:
            macro = .carbs
        default:
            macro = .none
        }
        if macro.rawValue > Filter.MacroEnum.none.code {
            hideMacroOutlets(false)
            switch macro {
            case .protein:
                macroLabel.text = "Protein:"
            case .carbs:
                macroLabel.text = "Carbs:"
            case .fat:
                macroLabel.text = "Fat:"
            default:
                break
            }
            amountLabel.text = "\(round((filter?.amount ?? 0.0) * 10) / 10)g"
            percentLabel.text = "\(round((filter?.percentage ?? 0.0) * 10) / 10)%"
            amountCompareLabel.text = (filter?.amountLessThan ?? true ? "<" : ">")
            percentCompareLabel.text = (filter?.percentLessThan ?? true ? "<" : ">")
        } else {
            hideMacroOutlets(true)
        }
        bannedIngredients = filter?.bannedArray() ?? []
        bannedIngredientsTableView.reloadData()
    }

    func hideMacroOutlets(_ hide: Bool) {
        macroLabel.isHidden = hide
        amountLabel.isHidden = hide
        percentLabel.isHidden = hide
        amountCompareLabel.isHidden = hide
        percentCompareLabel.isHidden = hide
    }

    // MARK: - IBAction
    @IBAction func editFilter(_ sender: Any) {
    }

    @IBAction func deleteFilter(_ sender: Any) {
        // filter?.removeFromFilters(filter)
        guard let filters: Filters = PersistenceHelper.getFiltersList() else {
            navigationController?.popViewController(animated: true)
            return
        }
        guard let tempFilter: Filter = filter else {
            navigationController?.popViewController(animated: true)
            return
        }
        filters.removeFromFilters(filter ?? tempFilter)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editFilterVC = segue.destination as? EditFilterViewController
        editFilterVC?.filter = filter
        editFilterVC?.bannedIngredients = bannedIngredients
    }
}

// MARK: - extension Table
extension FilterDetailsViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bannedIngredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var bannedIngCell: UITableViewCell
        if let dequeueCell =
            bannedIngredientsTableView.dequeueReusableCell(withIdentifier: "filterDetailCell") {
            bannedIngCell = dequeueCell
        } else {
            bannedIngCell = UITableViewCell(style: UITableViewCell.CellStyle.default,
                                            reuseIdentifier: "filterDetailCell")
        }
        bannedIngCell.textLabel!.text = bannedIngredients[indexPath.row].name
        return bannedIngCell
    }
}
