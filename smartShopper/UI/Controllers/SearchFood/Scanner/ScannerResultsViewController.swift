//
//  ScannerResultsViewController.swift
//  smartShopper
//
//  Created on 2/20/21.
//

import UIKit
import PieCharts
import OSLog

// MARK: - Start
/// Displays the food information form the food the user either scanned or select from their history
/// Also evaluates all filters to indicate if the food contains anything in the filters.
class ScannerResultsViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!

    @IBOutlet weak var carbsPrecentLabel: UILabel!
    @IBOutlet weak var fatPrecentLabel: UILabel!
    @IBOutlet weak var proteinPrecentLabel: UILabel!

    @IBOutlet weak var carbsWarningImage: UIImageView!
    @IBOutlet weak var fatWarningImage: UIImageView!
    @IBOutlet weak var proteinWarningLabel: UIImageView!

    @IBOutlet weak var pieChart: PieChart!
    @IBOutlet weak var servingSize: UILabel!
    @IBOutlet weak var allergiesLabel: UILabel!
    @IBOutlet weak var ingredientsTableView: UITableView!

    public static var identifier = "ScannerResultsViewController"

    private var showingProduct: Product?
    private var ingredients: [String] = []
    private var filters: Filters?

    private var viewDisappeared: Bool = false

    fileprivate let alertService = AlertService()

    // MARK: - ViewDid Load
    override func viewDidLoad() {
        super.viewDidLoad()

        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.setupView()

        // Do any additional setup after loading the view.
        // Test change
        guard let product = self.showingProduct else {
            return
        }
        self.setupView(product: product)

        // Set up the Custom list button
        // create a new button
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        // set image for button
        button.setImage(UIImage(named: "addlist"), for: .normal)
        // add function for button
        button.addTarget(self, action: #selector(addToCustomList), for: UIControl.Event.touchUpInside)
        // Setting the right button bar item
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: button)
    }

    // MARK: - Controller Methods
    override func viewDidDisappear(_ animated: Bool) {
        self.viewDisappeared = true
    }

    override func viewWillAppear(_ animated: Bool) {
        if let product = self.showingProduct {
            // IF the user comes back to the view we will reload data to make sure the users filters get re applied
            if viewDisappeared {
                filters = PersistenceHelper.getFiltersList()
                let carbs: Double = product.nutriments.carbohydrates ?? 0
                let fat: Double = product.nutriments.fatValue ?? product.nutriments.fat100G ?? 0
                let protein: Double = product.nutriments.proteins ?? 0
                let total = carbs + fat + protein
                DispatchQueue.global().async {
                    self.evaluateFilters(carb: carbs, fat: fat, protein: protein, total: total)
                }
                ingredientsTableView.reloadData()
            }
        }
        viewDisappeared = false
    }

    /// Call back for the add to custom list button
    @objc private func addToCustomList() {
        guard let product = self.showingProduct else {
            return
        }
        if let alertVC = alertService.customListAlert(title: product.productName) {
            present(alertVC, animated: true)
        }
    }

    /// Set's up the view for the given product
    public func setupViewData(product: Product) {
        self.title = product.productName
        self.showingProduct = product
        filters = PersistenceHelper.getFiltersList()
    }

    private func setupView(product: Product) {
        ingredients = product.getIngredients()
        if let calories: Double = product.nutriments.energyKcal {
            caloriesLabel.text = String(calories)
        } else {
            if let calories: Double = product.nutriments.energy {
                caloriesLabel.text = String(calories)
            }
        }

        let carbs: Double = product.nutriments.carbohydrates ?? 0
        let fat: Double = product.nutriments.fatValue ?? product.nutriments.fat100G ?? 0
        let protein: Double = product.nutriments.proteins ?? 0
        let total = carbs + fat + protein

        pieChart.models = [
            PieSliceModel(value: carbs, color: prussianBlue),
            PieSliceModel(value: fat, color: honeyYellow),
            PieSliceModel(value: protein, color: blueGreen)
        ]

        carbsLabel.text = String(carbs.roundTo(decimalPlaces: 0)) + " " + (product.nutriments.carbohydratesUnit ?? "g")
        carbsLabel.textColor = prussianBlue
        fatLabel.text = String(fat) +  " " + (product.nutriments.fatUnit ?? "g")
        fatLabel.textColor = honeyYellow
        proteinLabel.text = String(protein) +  " " + (product.nutriments.proteinsUnit ?? "g")
        proteinLabel.textColor = blueGreen

        carbsPrecentLabel.text = carbs.getRatio(total: total, roundTo: 0) + " %"
        carbsPrecentLabel.textColor = prussianBlue
        proteinPrecentLabel.text = protein.getRatio(total: total, roundTo: 0) + " %"
        proteinPrecentLabel.textColor = blueGreen
        fatPrecentLabel.text = fat.getRatio(total: total, roundTo: 0) + " %"
        fatPrecentLabel.textColor = honeyYellow

        servingSize.text = product.servingSize ?? ScannerViewController.noIngredientsText
        allergiesLabel.text = product.getAllergens()

        DispatchQueue.global().async {
            self.evaluateFilters(carb: carbs, fat: fat, protein: protein, total: total)
        }
    }

    // MARK: - Filters Eval
    /// evaluates filters to see if the carbs protein or fat are out of filter limits
    private func evaluateFilters(carb: Double, fat: Double, protein: Double, total: Double) {

        proteinWarningLabel.alpha = 0
        carbsWarningImage.alpha = 0
        fatWarningImage.alpha = 0

        guard let storedFilters: Filters = self.filters else {
            return
        }

        let carbRatio: Float = Float(carb.getRatio(total: total, roundTo: 0)) ?? 0
        let proteinRatio: Float = Float(protein.getRatio(total: total, roundTo: 0)) ?? 0
        let fatRatio: Float = Float(fat.getRatio(total: total, roundTo: 0)) ?? 0

        for filter in storedFilters.asArray() {
            if filter.macro == Filter.MacroEnum.protein.code {
                setWarningLabel(filter: filter,
                                macro: Float(protein),
                                macroPrecent: proteinRatio,
                                warningImage: proteinWarningLabel)
            } else if filter.macro == Filter.MacroEnum.fat.code {
                setWarningLabel(filter: filter,
                                macro: Float(fat),
                                macroPrecent: fatRatio,
                                warningImage: fatWarningImage)
            } else if filter.macro == Filter.MacroEnum.carbs.code {
                setWarningLabel(filter: filter,
                                macro: Float(carb),
                                macroPrecent: carbRatio,
                                warningImage: carbsWarningImage)
            }
        }
    }

    private func setWarningLabel(filter: Filter, macro: Float, macroPrecent: Float, warningImage: UIImageView) {

        if filter.amount != -1 {
            if filter.amountLessThan && macro < filter.amount {
                warningImage.alpha = 1
            } else if macroPrecent > filter.amount {
                warningImage.alpha = 1
            }
        }

        if filter.percentage != -1 {
            if filter.percentLessThan && macro < filter.percentage {
                warningImage.alpha = 1
            } else if macroPrecent > filter.percentage {
                warningImage.alpha = 1
            }
        }
    }

    private func banIngredient(ingredient: String?, tableCell: IngredientsTableViewCell?) {
        if let banIngredient: String = ingredient, let cell: IngredientsTableViewCell = tableCell {
            if let alertVC = alertService.filterAlert(ingredientToBan: banIngredient, completion: {
                cell.banIngredient()
            }) {
                present(alertVC, animated: true)
            }
        }
    }

    @objc func ingredientBanned() {

    }
}

// MARK: - Extension
extension ScannerResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: IngredientsTableViewCell.cellIdentifier)
            as? IngredientsTableViewCell {
            cell.setupCell(ingredient: ingredients[indexPath.row],
                           banned: banned(ingredient: ingredients[indexPath.row], filters: self.filters))
            return cell
        }
        os_log("Error: %@", log: .default, type: .error, "Failed to create \(IngredientsTableViewCell.cellIdentifier)")
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Ban Ingredient") { [weak self] (_, _, completionHandler) in
            self?.banIngredient(ingredient: self?.ingredients[indexPath.row],
                                tableCell: tableView.cellForRow(at: indexPath) as? IngredientsTableViewCell)
            completionHandler(true)
        }
        action.backgroundColor = prussianBlue
        return UISwipeActionsConfiguration(actions: [action])
    }
}
