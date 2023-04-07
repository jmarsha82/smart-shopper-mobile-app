//
//  Utils.swift
//  smartShopper
//
//  Created  4/17/21.
//

import Foundation

// This file contains all utility methods used throughout the project

// MARK: - Extension Double
extension Double {

    /// Will give you the ratio from the given total
    /// if ```self``` or ```total``` are 0 then 0 is returned
    ///  Does multiply by 100
    /// Returns: Ex. return ``79``
    func getRatio(total: Double, roundTo: Int) -> String {
        if total == 0  || self == 0 {
            return "0"
        }
        return (((self / total) * 100) as Double).roundTo(decimalPlaces: roundTo)
    }

    /// Will round to given decimal place
    func roundTo(decimalPlaces: Int) -> String {
        return NSString(format: "%.\(decimalPlaces)f" as NSString, self) as String
    }
}

// MARK: - Extension String

extension String {
    /// Replaces any occurrence of the ```en:``` string
    /// Returns: cleaned string without any ```en:```
    func removeEn() -> String {
        return self.replacingOccurrences(of: "en:", with: "")
    }

    /// Replaces all ```.``` with empty string
    /// Returns: period free string
    func removePeriod() -> String {
        return self.replacingOccurrences(of: ".", with: "")
    }
}
