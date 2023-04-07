//
//  APIResult.swift
//  smartShopper
//
//  Created  3/13/21.
//

import Foundation

// MARK: - Start
/// Holds the parent ```JSON``` information after a call is made to the food database
class APIResult: Codable {
    /// 0 - No product found, 1 - Product found
    let status: Int
    /// verbose way of indicating if a product is found or not
    let statusVerbose: String
    /// The product information which the user is looking for
    let product: Product?
    /// The code the user scanned
    let code: String

    enum CodingKeys: String, CodingKey {
        case status
        case statusVerbose = "status_verbose"
        case product, code
    }

    init(status: Int, statusVerbose: String, product: Product, code: String) {
        self.status = status
        self.statusVerbose = statusVerbose
        self.product = product
        self.code = code
    }
}
