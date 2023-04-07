//
//  IngredientsHistoryViewController.swift
//  smartShopper
//
//  Created on 4/30/21.
//

import UIKit
import OSLog

// MARK: - Start
/// Displays when the `IngredientHistory` is displayed.
class IngredientsHistoryViewController: UIViewController {

    @IBOutlet weak var ingredientsTableView: UITableView!

    var ingredients: [(ingredient: String, banned: Bool)] = []
    let searchController = UISearchController(searchResultsController: nil)
    var searchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var filterOn: Bool {
        return searchController.isActive && !searchBarEmpty
    }

    fileprivate let alertService = AlertService()

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.setupView()
        searchController.searchResultsUpdater = self

        searchController.searchBar.placeholder = "Search Filters"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    override func viewDidAppear(_ animated: Bool) {
        self.setUpData()
    }

    /// Get's all the ingredients from the scanned food
    /// Tires it's best to alphabetize the list and display it to the user
    private func setUpData () {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        DispatchQueue.global().async {
            let scannedFood = PersistenceHelper.getScannedFood()
            let filters = PersistenceHelper.getFiltersList()
            var setIngredients: Set<String> = []
            for food in scannedFood {
                if let storedIngredients = food.ingredients {
                    for ingredient in storedIngredients {
                        setIngredients.insert(ingredient)
                    }
                }
            }

            self.ingredients.removeAll()
            for ingredient in setIngredients {
                self.ingredients.append((ingredient: ingredient,
                                         banned: self.banned(ingredient: ingredient, filters: filters)))
            }
            self.ingredients = self.ingredients.sorted {
                $0.ingredient.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    < $1.ingredient.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        ingredientsTableView.reloadData()
    }

    // MARK: - Search
    func filterContentForSearchQuery(_ searchQuery: String) {
        ingredientsTableView.reloadData()
    }

    private func banIngredient(ingredient: String?, index: Int, tableCell: IngredientHistoryTableViewCell?) {
        if let banIngredient: String = ingredient, let cell: IngredientHistoryTableViewCell = tableCell {
            if let alertVC = alertService.filterAlert(ingredientToBan: banIngredient, completion: {
                cell.banIngredient()
                self.ingredients[index].banned = true
            }) {
                present(alertVC, animated: true)
            }
        }
    }
}

// MARK: - extension Search
extension IngredientsHistoryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchQuery(searchBar.text ?? "")
    }
}

// MARK: - extension TableView
extension IngredientsHistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: IngredientHistoryTableViewCell.cellIdentifier)
            as? IngredientHistoryTableViewCell {
            cell.setupCell(ingredient: self.ingredients[indexPath.row].ingredient,
                           banned: self.ingredients[indexPath.row].banned)
            return cell
        }
        os_log("Error: %@", log: .default, type: .error,
               "Failed to create \(IngredientHistoryTableViewCell.cellIdentifier)")
        return UITableViewCell()
    }

    private func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Ban Ingredient") { [weak self] (_, _, completionHandler) in
            self?.banIngredient(ingredient: self?.ingredients[indexPath.row].ingredient,
                                index: indexPath.row,
                                tableCell: tableView.cellForRow(at: indexPath) as? IngredientHistoryTableViewCell)

            completionHandler(true)
        }
        action.backgroundColor = prussianBlue
        return UISwipeActionsConfiguration(actions: [action])
    }
}
