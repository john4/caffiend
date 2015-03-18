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
        let drink : Drink = Drink(name: "Test", caffeineContent: 120, volume: 5, type: DrinkType.Coffee)
        let manager : DatabaseManager = DatabaseManager()
        manager.saveFavorite(drink)
        XCTAssert(manager.favorites().count == 1, "There is not exactly one drink in the favorites after addition")
        manager.deleteFavorite(drink)
        XCTAssert(manager.favorites().count == 0, "There is a drink in the favorites after deletion")
    }
    
    func testDatabase() {
        var drink : Drink = Drink()
        let manager : DatabaseManager = DatabaseManager()
        var results : Array<Drink> = manager.getDrinksMatchingDrink(drink)
        XCTAssert(results.count == 0, "A default drink did not return 0 results")
        
        drink.type = DrinkType.Coffee
        results = manager.getDrinksMatchingDrink(drink)
        XCTAssert(results.count > 0, "A search for coffee types did not return  >0 results")
        
        // The following tests assume that these values exist in the database, and might be broken
        // when we actually get a database.
        
        drink = Drink()
        drink.name = "Coffee"
        
        results = manager.getDrinksMatchingDrink(drink)
        XCTAssert(results.count > 0, "A search for known name did not return  >0 results")
        
        drink = Drink()
        drink.volume = 8
        results = manager.getDrinksMatchingDrink(drink)
        XCTAssert(results.count > 0, "A search for known volume did not return  >0 results")
        
        drink = Drink()
        drink.caffeineContent = 50
        results = manager.getDrinksMatchingDrink(drink)
        XCTAssert(results.count > 0, "A search for known caffeine content did not return  >0 results")
    }
}
