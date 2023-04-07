//
//  IngredientFiltersViewController.swift
//  smartShopper
//
//  Created on 2/20/21.
//
// Reference:   for UISearchController

/*
 Tasks: add sorting feature with NSSortDescriptor
        add search feature
*/

import UIKit
import OSLog

// MARK: - Start
/// Main Controller for the `Ingredients Filters` tab.
/// Displays all the filters the user has created in the tab.
class IngredientFiltersViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var filtersTableView: UITableView!

    var filters: Filters?
    var filtersArr: [Filter] = []
    var filteredFilters: [Filter] = []
    // set searchResultsController to new controller in editVC search
    let searchController = UISearchController(searchResultsController: nil)
    var searchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var filterOn: Bool {
        return searchController.isActive && !searchBarEmpty
    }

    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
        filtersTableView.setupView()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Filters"
        // leave true for edit search to obscure background while in diff vc
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        let filtersSet = PersistenceHelper.getFiltersList() ?? PersistenceHelper.createFiltersList()
        filters = filtersSet
        filtersArr = filtersSet.asArray()
        filtersTableView.reloadData()
        PersistenceHelper.saveContext()
    }

    override func viewWillAppear(_ animated: Bool) {
        filtersArr = PersistenceHelper.getFiltersList()?.asArray() ?? []
        // print("filters array size: \(filtersArr.count)")
        filtersTableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        PersistenceHelper.saveContext()
    }

    @IBAction func addFilter(_ sender: Any) {
        // print("add filter")
        // self.performSegue(withIdentifier: "addFilter", sender: nil)
    }

    // MARK: - Search
    func filterContentForSearchQuery(_ searchQuery: String) {
        filteredFilters = filtersArr.filter { (filter: Filter) -> Bool in
            (filter.name?.lowercased().contains(searchQuery.lowercased()) ?? false) }
        filtersTableView.reloadData()
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let filterDetailsVC = segue.destination as? FilterDetailsViewController {
            if let cell = sender as? UITableViewCell {
                let index = filtersTableView.indexPath(for: cell)?.row ?? 0
                filterDetailsVC.filter = (filterOn ? filteredFilters[index] : filtersArr[index])
            }
        } else if segue.destination is AddFilterViewController {
            // print("add filter")
        }
    }
}

// MARK: - Extension UISearchResultsUpdating
extension IngredientFiltersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchQuery(searchBar.text ?? "")
    }
}
// MARK: - Extension Filters Table
extension IngredientFiltersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (filterOn ? filteredFilters.count : filtersArr.count)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var filterCell: UITableViewCell
        if let dequeueCell =
            filtersTableView.dequeueReusableCell(withIdentifier: "ingredientListCell") {
            filterCell = dequeueCell
        } else {
            filterCell = UITableViewCell(style: UITableViewCell.CellStyle.default,
                                            reuseIdentifier: "ingredientListCell")
        }
        let currentFilter = (filterOn ? filteredFilters[indexPath.row] : filtersArr[indexPath.row])
        filterCell.textLabel!.text = currentFilter.name
        return filterCell
    }
    private func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    /// Swipe delete
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Make sure the object get's removed in core data
            guard let filters = self.filters else {
                os_log("Error IngredientFilters delete: %@",
                       log: .default,
                       type: .error, String(describing: "Nil Filters object present. Cannot delete."))
                return
            }
            if (filters.filters?.contains(filtersArr[indexPath.row])) != nil {
                filters.removeFromFilters(filtersArr[indexPath.row])
                filtersArr.remove(at: indexPath.row)
                filtersTableView.reloadData()
            }
        }
    }
}
