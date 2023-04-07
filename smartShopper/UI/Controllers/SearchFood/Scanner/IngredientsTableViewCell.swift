//
//  IngredientsTableViewCell.swift
//  smartShopper
//
//  Created  4/14/21.
//

import UIKit

// MARK: - Start
/// Used by the `ScannedResultsViewController` to display ingredients for a `Product` the user scanned.
class IngredientsTableViewCell: UITableViewCell {

    public static let cellIdentifier: String = "ingredientsCell"

    // MARK: - IBOutlet
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var cautionImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func setupCell(ingredient: String, banned: Bool) {
        ingredientLabel.text = ingredient
        cautionImageView.alpha = banned ? 1 : 0
    }

    /// Displays the image to indicate the ingredient is banned
    public func banIngredient() {
        cautionImageView.alpha = 1
    }

}
