//
//  CustomAlertViewController.swift
//  smartShopper
//
//  Created  4/24/21.
//

import UIKit

// MARK: - Start
/// Alert which allows the user to view all `CustomLists`
/// Allows user to add food to a list.
/// Allows Create a new list.
class CustomAlertViewController: UIViewController, UITextFieldDelegate {

    var alertTitle = String()
    var cornerRadius = CGFloat()
    private var customLists: CustomLists?

    // MARK: - IBOutlet
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var customListsTableView: UITableView!
    @IBOutlet weak var newListTitle: UITextField!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        newListTitle.setUpView()
        customListsTableView.delegate = self
        customListsTableView.dataSource = self
        customLists = PersistenceHelper.getCustomLists() ?? CustomLists(context: PersistenceHelper.context)
        customListsTableView.reloadData()

        // This will allow the view to move the alert box up when the keyboard shows up
        NotificationCenter.default.addObserver(self,
                selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.newListTitle.delegate = self

    }

    func setupView() {
        alertTitleLabel.text = "Add to Groceries"
        titleView.roundCorners(corners: [.topLeft, .topRight], radius: cornerRadius)
        alertView.layer.cornerRadius = cornerRadius
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
    @IBAction func createNewList(_ sender: Any) {
        if let customLists: CustomLists = self.customLists,
           newListTitle.text != "",
           let newListTitle: String = newListTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if !customLists.containsList(title: newListTitle) {
                if let customList: CustomList = CustomList(items: [],
                                                         title: newListTitle,
                                                         ofCustomLists: customLists) {
                    customLists.customLists?.adding(customList)
                }
            }
            self.customListsTableView.reloadData()
        }
        self.view.endEditing(true)
    }

    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - Extension Table view
extension CustomAlertViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customLists?.customLists?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customListAlertCell")
        if let customList: CustomList = self.customLists?.customLists?.allObjects[indexPath.item] as? CustomList,
           let title: String = customList.title {
            cell?.textLabel?.text = title
        }
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let customList = self.customLists?.customLists?.allObjects[indexPath.item] as? CustomList
        customList?.items?.append(alertTitle)
        dismiss(animated: true)
    }
}
