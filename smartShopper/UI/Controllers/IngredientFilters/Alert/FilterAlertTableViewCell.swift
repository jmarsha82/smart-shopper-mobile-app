//
//  FilterAlertTableViewCell.swift
//  smartShopper
//
//  Created  5/2/21.
//

import UIKit

/// Table cell for the `FilterAlertViewController` tableView
class FilterAlertTableViewCell: UITableViewCell {

    public static let cellIdentifier: String = "customListAlertCell"

    @IBOutlet weak var filterNameLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(filter: Filter) {
        filterNameLabel.text = filter.name
    }
}
