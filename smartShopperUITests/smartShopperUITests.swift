//
//  smartShopperUITests.swift
//  smartShopperUITests
//

//

import XCTest

class SmartShopperUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation
        //      - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    func testCustomListNavButton() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()

        let addListButton = app.navigationBars.buttons["Add List"]
        XCTAssert(addListButton.exists)

        // app.launch()
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testAddListButton() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        // let tabButton = app.tabButton.buttons["Custom List"]
        // XCTAssert(tabButton.exists)
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testEditFilterButton() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        let editFilterButton = app.buttons["EditFilter"]
        XCTAssert(editFilterButton.exists)
    }

    func testDeleteFilterButton() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        let deleteFilterButton = app.buttons["DeleteFilter"]
        XCTAssert(deleteFilterButton.exists)
    }

    // 1 minute

}