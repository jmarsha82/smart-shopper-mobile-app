//
//  AddCustomListViewController.swift
//  smartShopper
//
//  Created by Amber Daniels on 3/2/21.
//

import UIKit
import CoreData

// MARK: - Start
/// Displays all items in a `Custom List`.
/// Allows users to reorder or delete items in the list.
class CustomListViewController: UITableViewController {
    /// Identifier used to help segue find this class
    public var customList: CustomList?
    public static let segueIdentifier: String = "ViewCustomList"

    // MARK: - IBOutlet
    @IBOutlet weak var customListTitle: UINavigationItem!
    @IBOutlet weak var customListTableView: UITableView!

    // MARK: - viewDidLoad
    /// Set by CustomListsViewController when the user selects their custom list and it initiates a segue
    override func viewDidLoad() {
        super.viewDidLoad()
        customListTableView.delegate = self
        customListTableView.dataSource = self
        customListTableView.setupView()
        self.customListTableView.isEditing = true
        self.customListTitle.title = customList?.title
        customListTableView.reloadData()
        PersistenceHelper.saveContext()
    }

    override func viewDidDisappear(_ animated: Bool) {
        PersistenceHelper.saveContext()
    }

    @IBAction func addListItem(_ sender: Any) {
        let alertController = UIAlertController(title: "Add to List", message: "Type...", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: ({(_) in
            guard let fields: [UITextField] = alertController.textFields,
                  let field: String = fields[0].text
            else {
                return
            }
            self.customList?.items?.append(field)
            self.customListTableView.reloadData()
        }))
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Add an Item"
        })
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            customListTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            customList?.items?.remove(at: indexPath.row)
            customListTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customList?.items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = customListTableView.dequeueReusableCell(withIdentifier: "customListitemCell")! as UITableViewCell
        cell.textLabel!.text = customList?.items?[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        let movedObject = customList?.items?[sourceIndexPath.row] ?? ""
        customList?.items?.remove(at: sourceIndexPath.row)
        customList?.items?.insert(movedObject, at: destinationIndexPath.row)
    }
}
