//
//  DatabaseManager.swift
//  Caffeined
//
//  Created by Stefan Rajkovic on 6/1/15.
//  Copyright (c) 2015 John Martin. All rights reserved.
//

import Foundation

/* Private Class Properites
 * 
 * These don't need to be visible to anyone else and are constant across all instances
 * of this class, so they live up here.
 *
 */
private let _defaultManager = DatabaseManager()

private let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
    .UserDomainMask, true)[0] as String

private let databasePath = documentsFolder.stringByAppendingPathComponent("drinkDatabase.sqlite")

private func copyDatabaseFile() {
    if !NSFileManager.defaultManager().fileExistsAtPath(databasePath) {
        NSFileManager.defaultManager().copyItemAtPath(NSBundle.mainBundle().pathForResource(
            "drinkDatabase", ofType: "sqlite")!, toPath: databasePath, error: nil)
    }
}

class DatabaseManager : NSObject {
    
    private var drinkDatabase : FMDatabase?
    
    class func defaultManager() -> DatabaseManager {
        return _defaultManager
    }
    
    override init() {
        super.init()
        
        copyDatabaseFile()
    }
    
    private func initializeDatabase() {
        
        self.drinkDatabase = FMDatabase(path: databasePath)
        
        if !self.drinkDatabase!.open() {
            NSLog("Shit, we couldn't open the database, better copy it back and try again")
            self.drinkDatabase = nil;
            
            NSFileManager.defaultManager().removeItemAtPath(databasePath, error: nil)
            copyDatabaseFile()
            
            self.drinkDatabase = FMDatabase(path: databasePath)
            self.drinkDatabase!.open()
            
            return
        }
    }
    // here we could have an else if we have multiple versions of this DB
    // floating around, like if we added a column later but that's unnecessary right now
    
    func getDrinksForCategory(drinkTypeLookup : DrinkType) -> Array<DrinkBlank> {
        
        var drinks : Array<DrinkBlank> = []
        
        let results : FMResultSet = self.drinkDatabase!.executeQuery(
            "SELECT * FROM drinks WHERE type = ?",
            withArgumentsInArray: [drinkTypeLookup.rawValue])
        
        while results.next() {
            let newDrink = DrinkBlank(name: results.stringForColumn("name"),
                caffeineContent : results.doubleForColumn("caffeine"),
                // SQLite does not have support for arrays, so we split a comma separated string
                commonSizes : split(results.stringForColumn("sizes"),{$0 == ","},
                    allowEmptySlices:false).map({$0.toInt()!}),
                type : DrinkType(rawValue: results.stringForColumn("type"))!)
            
            drinks.append(newDrink)
        }
        return drinks
    }
    
    
}
