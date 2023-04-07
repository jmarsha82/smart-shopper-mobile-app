//
//  smartShopperTests.swift
//  smartShopperTests
//

//

import XCTest
import CoreData
@testable import smartShopper

class SmartShopperTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testCustomList() {

        let customList: CustomList = CustomList(context: PersistenceHelper.context)
        customList.title = "New Title"
        XCTAssertEqual(customList.title, "New Title")
        customList.items = []
        customList.items?.append("Item1")
        customList.items?.append("item2")
        customList.items?.append("item3")

        XCTAssertEqual(customList.items?.count, 3)
        XCTAssertEqual(customList.items![2], "item3")
    }

    func testCustomLists() {
        let customLists: CustomLists = CustomLists(context: PersistenceHelper.context)
        let customList: CustomList = CustomList(context: PersistenceHelper.context)
        customList.title = "Stored List"
        customLists.addToCustomLists(customList)
        XCTAssertEqual(customLists.containsList(title: "Stored List"), true)
    }

    func testFilters() {
        let filters: Filters = Filters(context: PersistenceHelper.context)
        filters.num = 1
        XCTAssertEqual(filters.num, 1)

        let filter: Filter = Filter(context: PersistenceHelper.context)

        filter.name = "name"
        XCTAssertEqual(filter.name, "name")

        let bannedIngredient = BannedIngredient(context: PersistenceHelper.context)
        bannedIngredient.name = "New Ingredient"

        filter.addToBannedIngredients(bannedIngredient)
        XCTAssertEqual(filter.bannedIngredients?.count, 1)

        filter.ofFilters = filters
        XCTAssertFalse(filter.ofFilters == nil)

    }

    func testBannedIngredient() {
        let bannedIngredient = BannedIngredient(context: PersistenceHelper.context)
        bannedIngredient.name = "New Ingredient"

        XCTAssertEqual(bannedIngredient.name, "New Ingredient")

        bannedIngredient.ofFilter = Filter(context: PersistenceHelper.context)

        XCTAssertFalse(bannedIngredient.ofFilter == nil)
    }

}
