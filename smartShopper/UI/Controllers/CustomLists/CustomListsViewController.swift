//
//  CustomListsViewController.swift
//  smartShopper
//
//  Created on 2/20/21.
//

import UIKit
// import TableKit

// MARK: - Start
/// Main controller for the `Custom Lists` Tab
/// Calls both `CustomListViewController` to show all info in the custom List
class CustomListsViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Global Variables
    /// Might be empty if this this the users first time opening the app or if they don't have any custom lists defined
    private var customLists: CustomLists?

    // MARK: - IBOutlet
    @IBOutlet weak var customListsTableView: UITableView!
    @IBOutlet weak var addListUIBarButton: UIBarButtonItem!

    // MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        customListsTableView.delegate = self
        customListsTableView.dataSource = self
        customListsTableView.setupView()
        // Need this for UI test
        addListUIBarButton.accessibilityLabel = "Add List"
        // Getting the stored custom lists if I there're none let's make a empty object
        customLists = PersistenceHelper.getCustomLists() ?? CustomLists(context: PersistenceHelper.context)
        // Do any additional setup after loading the view.
        customListsTableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        PersistenceHelper.saveContext()
    }

    override func viewWillAppear(_ animated: Bool) {
        customListsTableView.reloadData()
    }

    // MARK: - IBAction
    @IBAction func addList(_ sender: Any) {
        let alertController = UIAlertController(title: "Add List", message: "Type...", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: ({(_) in
            // Trying to get the fields from the fields form the alert controller
            guard let fields: [UITextField] = alertController.textFields,
                  let customListTitle: String = fields[0].text,
                  let customLists: CustomLists = self.customLists,
                  let customList: CustomList = CustomList(items: [], title: customListTitle, ofCustomLists: customLists)
            else {
                return
            }
            customLists.customLists?.adding(customList)
            self.customListsTableView.reloadData()
        }))
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Add an Item"
        })
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CustomListViewController.segueIdentifier {
            if let indexPath = customListsTableView.indexPathForSelectedRow {
                guard let customListViewController = segue.destination as? CustomListViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
            customListViewController.customList =
                self.customLists?.customLists?.allObjects[indexPath.item] as? CustomList
            }
        } else {
        }
    }
}

// MARK: - Extension
extension CustomListsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customLists?.customLists?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customListsCell")! as UITableViewCell
        if let customList: CustomList = self.customLists?.customLists?.allObjects[indexPath.item] as? CustomList,
           let title: String = customList.title {
            cell.textLabel?.text = title
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let customList: CustomList = self.customLists?.customLists?.allObjects[indexPath.item] as? CustomList {
                customLists?.removeFromCustomLists(customList)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}
