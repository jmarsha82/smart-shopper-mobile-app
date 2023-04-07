//
//  APIManager.swift
//  smartShopper
//


import Foundation
import os.log
import UIKit

// MARK: - Result Enum
enum Result<ResultType> {
    case results(ResultType)
    case error(Error)
}

// MARK: - Start
/// Static class to make restful calls to the ```https://world.openfoodfacts.org/api/v0/product/<barcode>``` database
class APIManager {

    private init() {}

    enum Error: Swift.Error {
        case unknownAPIResponse
        case generic
    }

    /// More information about the data base used can be found here https://world.openfoodfacts.org/data
    /// Api Wiki : https://wiki.openfoodfacts.org/API
    ///  Example Json: https://world.openfoodfacts.org/api/v0/product/737628064502.json
    /// Example call: https://us.openfoodfacts.org/api/v0/product/01223004
    static private let openFoodGetURL = "https://us.openfoodfacts.org/api/v0/product/"
    static private let openFoodGetType = ".json"

    static func constructGetUrl(barcode: String) -> URL? {
        let urlString = openFoodGetURL + barcode + openFoodGetType
        return URL(string: urlString)
    }

    /// Takes in a numerical barcode of  scanned  food and returns a Product object if successful.
    /// If no food found then the APIResponse object will return with an empty Product and 0 as status.
    /// An error will be returned if the look up failed.
    public static func searchFood(for barcode: String, completion: @escaping (Result<APIResult>) -> Void) {

        guard let searchURL = APIManager.constructGetUrl(barcode: barcode) else {
            DispatchQueue.main.async {
                completion(Result.error(URLError(URLError.unknown)))
            }
            return
        }

        /// Creates and initializes a URLRequest with the given URL and cache policy.
        var searchRequest = URLRequest(url: searchURL)
        // Requested by the open food facts to add user-agent header to each api call
        searchRequest.setValue("smartShopper - IOS - Version 1.0", forHTTPHeaderField: "user-agent")

        // UserDefaults.standard.register(defaults: ["UserAgent": "SmartShopper - IOS - Version 1.0 - ClassProject"])
        URLSession.shared.dataTask(with: searchRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            }

            guard
                /// I know I will get a HTTPURLResponse back
                /// URLResponse: Whenever you make an HTTP request, the URLResponse
                /// object you get back is actually an instance of the `HTTPURLResponse` class.
                let response = response as? HTTPURLResponse,
                /// Settings the data
                let data = data
            // Return error if response and data cant be set
            else {
                DispatchQueue.main.async {
                    completion(Result.error(Error.unknownAPIResponse))
                }
                return
            }

            do {
                os_log("HTTPURLResponse: %@", log: .default, type: .default, response)

                // Used : https://www.youtube.com/watch?v=YY3bTxgxWss
                let apiResult = try JSONDecoder().decode(APIResult.self, from: data)

                DispatchQueue.main.async {
                    completion(Result.results(apiResult))
                }
            } catch {
                completion(Result.error(error))
                return
            }
        }.resume()
    }
}
