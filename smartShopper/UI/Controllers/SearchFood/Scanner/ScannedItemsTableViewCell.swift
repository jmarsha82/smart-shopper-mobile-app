//
//  ScannedItemsTableViewCell.swift
//  smartShopper
//
//  Created  4/4/21.
//

import UIKit

// MARK: - Start
/// This cell supports `ScannedViewController` to display food the user has scanned.
class ScannedItemsTableViewCell: UITableViewCell {

    public let cardViewRadius: CGFloat = 5.0

    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var ingredientsTextView: UITextView!

    public static var cellIdentifier: String = "scannedFoodHistoryTableCell"
    private var scannedFood: ScannedFood?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Cell init
    func setupCell(scannedFood: ScannedFood) {
        self.scannedFood = scannedFood

        if let productName: String = scannedFood.productName {
            productNameLabel.text = productName
        }

        if let imageUrl: String = scannedFood.foodImage {
            foodImageView.download(from: imageUrl, contentMode: .scaleAspectFit)
        }

        if let ingredientsText: String = scannedFood.ingredientsText {
            ingredientsTextView.text = "Ingredients: " + ingredientsText
        }

        // Some investigation into card view
        backgroundCardView.layer.cornerRadius = cardViewRadius
        backgroundCardView.layer.masksToBounds = false

        backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowOpacity = 0.8

    }

}
