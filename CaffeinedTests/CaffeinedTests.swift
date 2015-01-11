//
//  CaffeinedTests.swift
//  CaffeinedTests
//
//  Created by John Martin on 1/6/15.
//  Copyright (c) 2015 John Martin. All rights reserved.
//

import UIKit
import XCTest

class CaffeinedTests: XCTestCase {

    override func setUp() {
        super.setUp()
        NSUserDefaults.standardUserDefaults().removeObjectForKey("CaffeinedTests")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFavorites() {
        // This is an example of a functional test case.
        let drink : Drink = Drink(name: "Test", caffeineContent: 120, volume: 5, type: DrinkType.Coffee)
        let manager : DatabaseManager = DatabaseManager()
        manager.saveFavorite(drink)
        XCTAssert(manager.favorites().count == 1, "There is not exactly one drink in the favorites after addition")
        manager.deleteFavorite(drink)
        XCTAssert(manager.favorites().count == 0, "There is a drink in the favorites after deletion")
    }
}
