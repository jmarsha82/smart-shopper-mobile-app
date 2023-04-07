//
//  IngredientHistoryTableViewCell.swift
//  smartShopper
//
//  Created  5/3/21.
//

import UIKit

// MARK: - Start
/// Cell to support `IngredientHistoryViewController` table view.
class IngredientHistoryTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var bannedUIImage: UIImageView!

    public static let cellIdentifier: String = "ingredientHistoryTableCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setupCell(ingredient: String, banned: Bool) {
        ingredientLabel.text = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
        bannedUIImage.alpha = banned ? 1 : 0
    }

    /// Displays the image to indicate the ingredient is banned
    public func banIngredient() {
        bannedUIImage.alpha = 1
    }

}
