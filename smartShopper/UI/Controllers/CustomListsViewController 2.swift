//
//  CustomListsViewController.swift
//  smartShopper
//
//  Created on 2/20/21.
//

import UIKit
import TableKit

class CustomListsViewController: UIViewController {
    @IBAction func addList(_ sender: Any) {
    }
    @IBOutlet weak var customTableView: UITableView! {
        didSet {
            let row1 = TableRow<StringTableViewCell>(item: "Groceries")
            let section = TableSection(rows: [row1])
            tableDirector = TableDirector(tableView: customTableView)
            tableDirector += section
        }
    }
    var tableDirector: TableDirector!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom Lists"
//        self.navigationItem.rightBarButtonItem =
//        UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: nil)
        // Do any additional setup after loading the view.
    }
    func addItem() {
        print("We be adding something")
    }
}

class StringTableViewCell: UITableViewCell, ConfigurableCell {
    func configure(with string: String) {
        textLabel?.text = string
    }
}
