import UIKit
// import TableKit

// MARK: - Start
class AddScannedItemsToListController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Global Variables
    /// Might be empty if this this the users first time opening the app or if they don't have any custom lists defined
    private var customLists: CustomLists?
    @IBOutlet weak var addScannedItemsTableView: UITableView!
    // MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        addScannedItemsTableView.delegate = self
        addScannedItemsTableView.delegate = self
        // Getting the stored custom lists if I there're none let's make a empty object
        customLists = PersistenceHelper.getCustomLists() ?? CustomLists(context: PersistenceHelper.context)
        // Do any additional setup after loading the view.
        addScannedItemsTableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        PersistenceHelper.saveContext()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

// MARK: - Extension
extension AddScannedItemsToListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addScannedItemCell")! as UITableViewCell
        if let customList: CustomList = self.customLists?.customLists?.allObjects[indexPath.item] as? CustomList,
           let title: String = customList.title {
            cell.textLabel?.text = title
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customLists?.customLists?.count ?? 0
    }
}
