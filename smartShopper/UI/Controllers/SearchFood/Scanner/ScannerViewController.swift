//
//  ScannerViewController.swift
//  smartShopper
//
//  Created on 2/20/21.
//

import UIKit
import Vision
import AVFoundation
import BarcodeScanner
import os.log

// MARK: - Start
/// Main controller which is responsible for  the following:
/// Display Scanned food history.
/// Call `BarCodeScanner` to allow the user to Scan Food.
/// Navigate to the scanned food in the `ScannerResultsViewController`.
class ScannerViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var scannedHistoryTableView: UITableView!

    public static var noIngredientsText: String = "N/A"
    public static var containsStr: String = "contains:"
    var barcodeScannerViewController: BarcodeScannerViewController?
    var scannedFood: APIResult?
    var scannedHistory: [ScannedFood] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        scannedHistoryTableView.delegate = self
        scannedHistoryTableView.dataSource = self
        scannedHistoryTableView.rowHeight = UITableView.automaticDimension
        scannedHistoryTableView.setupView()

        scannedHistory = PersistenceHelper.getScannedFood()

        // TODO: Remove before submitting app
        if scannedHistory.count == 0 {
            demoData(barcode: "737628064502")
            demoData(barcode: "01223004")
            demoData(barcode: "079200472146")
            demoData(barcode: "051000025494")
        }

        barcodeScannerViewController = setUpScanner()
        checkPermissions()
    }

    // TODO: Remove before submitting app
    private func demoData(barcode: String) {
        APIManager.searchFood(for: barcode) { apiResults in
            switch apiResults {
            case .error(let error) :
                os_log("Error Searching: %@", log: .default, type: .error, String(describing: error))
            case .results(let results):
                self.scannedFood = results
                /// printing the results for debug info
                os_log("Status Verbose: %@", log: .default, type: .default, String(describing: results.statusVerbose))

                if results.status == 1 {
                    if let apiResults = self.scannedFood, let product = apiResults.product {
                        self.saveScannedFood(apiResults: apiResults, product: product)
                        return
                    }
                }
            }
            return
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        PersistenceHelper.saveContext()
    }

    // Called when the view is actually visible,
    // and can be called multiple times during the lifecycle of a View Controller
    // More on this : https://stackoverflow.com/a/11254744
    override func viewDidAppear(_ animated: Bool) {
        // This is for every time the user enters this view we check for permissions
        checkPermissions()
        self.scannedHistoryTableView.reloadData()
    }

    private func setUpScanner() -> BarcodeScannerViewController {
        let barcodeScannerController = BarcodeScannerViewController()
        barcodeScannerController.codeDelegate = self
        barcodeScannerController.errorDelegate = self
        barcodeScannerController.dismissalDelegate = self
        return barcodeScannerController
    }

    @IBAction func scanFood(_ sender: Any) {
        if let scanner = barcodeScannerViewController {
            scanner.title = "Scann Item"
            // Make sure the scanner has reset
            scanner.reset(animated: false)
            // scanner.navigationItem.hidesBackButton = true
            self.navigationController?.pushViewController(scanner, animated: true)
            // present(scanner, animated: true, completion: nil)
        }
    }

    // MARK: - Check Camera Permissions
    /// Checks to make sure the user has given the app permissions to use the camera
    /// Gotten how to from : https://stackoverflow.com/a/41721013
    /// Also had to add Privacy - Camera Usage Description  to Info.plist
    /// Info.plist :
    /// https://iosdevcenters.blogspot.com/2016/09/infoplist-privacy-settings-in-ios-10.html
    private func checkPermissions() {
        let mediaType = AVMediaType.video
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)

        switch status {
        case .denied, .restricted:
            displayCameraNotAuthorized()
        case .notDetermined:
            // Need to prompt the user for access=
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { response in
                guard response != true else {
                    // The user gave us permission so we can continue with the app
                    return
                }
                // The use did not give us permission
                DispatchQueue.main.async {
                    self.displayCameraNotAuthorized()
                }
            })
        case .authorized:
            break
        default:
            os_log("Error: checkPermissions %@",
                   log: .default,
                   type: .error,
                   String("Invalid statues: '\(status)' returned"))
        }
    }

    private func displayCameraNotAuthorized() {
        presentAlertWithTitle(title: "Camera Authorization",
                              message: "In order to scan foods, the app needs access to your camera." +
                                "Please go to you settings and allow access",
                              options: "Settings",
                              completion: { (option) in
                                switch option {
                                case 0:
                                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(settingsUrl)
                                    } else {
                                        os_log("Failed to open settings ")
                                    }
                                default:
                                    os_log("Error: displayCameraNotAuthorized %@",
                                           log: .default,
                                           type: .error,
                                           String("Invalid option '\(option)' returned"))
                                }

                              })
    }

    // MARK: - Display / Save Food

    /// Pops the view controller of off navigation controller
    /// Begins to so the scanned food results
    private func dismissScanner() {
        // Go back to the controller
        self.navigationController?.popToRootViewController(animated: false)

        if let apiResults = self.scannedFood, let product = apiResults.product {
            // Save the product
            saveScannedFood(apiResults: apiResults, product: product)
            displayProduct(product: product)
        }
    }

    private func saveScannedFood(apiResults: APIResult, product: Product) {
        // Make sure the food hasn't already been stored by comparing all the barcodes
        if !scannedHistory.contains(where: {$0.barcode == apiResults.code}) {
            if let newFood = ScannedFood(barcode: apiResults.code, productName: product.productName) {
                newFood.foodImage = product.getSmallestImage()
                newFood.ingredientsText = product.ingredients ?? ScannerViewController.noIngredientsText
                newFood.ingredients = product.getIngredients()
                newFood.contains = product.getAllergens()
                scannedHistory.append(newFood)
                self.scannedHistoryTableView.reloadData()
            }
        }
    }

    /// Set's up ScannedResultsViewController to display the product the user just scanned or selected from their
    private func displayProduct(product: Product) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        guard let scannedResultsViewController =
                mainStoryboard.instantiateViewController(identifier: ScannerResultsViewController.identifier)
                as? ScannerResultsViewController else {
            os_log("Error instantiating view controller: %@",
                   log: .default,
                   type: .error,
                   String(describing: "Instantiating with identifier \(ScannerResultsViewController.identifier)"))
            return
        }
        scannedResultsViewController.setupViewData(product: product)
        self.navigationController?.pushViewController(scannedResultsViewController, animated: true)
    }

}

// MARK: - Extensions BarcodeScanner

// Used when the barcode is scanned
extension ScannerViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        os_log("Barcode Data: %@", log: .default, type: .default, String(describing: code))
        os_log("Symbology Type: %@", log: .default, type: .default, String(describing: type))

        APIManager.searchFood(for: code) { apiResults in
            switch apiResults {
            case .error(let error) :
                os_log("Error Searching: %@", log: .default, type: .error, String(describing: error))
                controller.resetWithError()
                self.scannedFood = nil
                return
            case .results(let results):
                self.scannedFood = results

                /// printing the results for debug info
                os_log("Status Verbose: %@", log: .default, type: .default, String(describing: results.statusVerbose))

                if results.status == 0 {
                    controller.resetWithError()
                } else {
                    controller.reset(animated: false)
                    controller.dismiss(animated: true, completion: self.dismissScanner)
                }
                return
            }
        }
    }
}

extension ScannerViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        controller.resetWithError(message: "Failed to Scann Barcode")
        os_log("Error: %@", log: .default, type: .error, String(describing: error))
    }
}

// Closing Scanner
extension ScannerViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        os_log("Scanner Dismissed: %@", log: .default, type: .default)
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extensions TableView

extension ScannerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.scannedHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ScannedItemsTableViewCell.cellIdentifier)
            as? ScannedItemsTableViewCell {
            cell.setupCell(scannedFood: self.scannedHistory[indexPath.row])
            return cell
        }
        os_log("Error: %@", log: .default, type: .error, "Failed to create \(ScannedItemsTableViewCell.cellIdentifier)")
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scannedFood = self.scannedHistory[indexPath.row]

        guard let barcode = scannedFood.barcode else {
            self.showAlert(title: "Error", message: "Unable to find food.")
            return
        }

        self.showSpinner()
        APIManager.searchFood(for: barcode) { apiResults in
            switch apiResults {
            case .error(let error) :
                os_log("Error Searching: %@", log: .default, type: .error, String(describing: error))
            case .results(let results):
                self.scannedFood = results
                /// printing the results for debug info
                os_log("Status Verbose: %@", log: .default, type: .default, String(describing: results.statusVerbose))

                if results.status == 1 {
                    if let apiResults = self.scannedFood, let product = apiResults.product {
                        self.removeSpinner()
                        self.displayProduct(product: product)
                        return
                    }
                }
            }

            self.removeSpinner()
            self.scannedFood = nil
            self.showAlert(title: "Error", message: "Unable to find food.")
            return
        }

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
            PersistenceHelper.removeScannedFood(scannedFood: self.scannedHistory[indexPath.row])
            // remove from our row
            scannedHistory.remove(at: indexPath.row)
            self.scannedHistoryTableView.reloadData()

        }
    }

}
