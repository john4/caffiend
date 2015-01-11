//
//  DatabaseManager.swift
//  Caffeined
//
//  Created by Stefan Rajkovic on 6/1/15.
//  Copyright (c) 2015 John Martin. All rights reserved.
//

import Foundation

/* Private Class Properties
 * 
 * These don't need to be visible to anyone else and are constant across all instances
 * of this class, so they live up here.
 *
 */
private let _defaultManager = DatabaseManager()

private let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
    .UserDomainMask, true)[0] as String

private let databasePath = documentsFolder.stringByAppendingPathComponent("drinkDatabase.sqlite")

private let userDefaultsKey = "CaffeinedFavorites"

class DatabaseManager : NSObject {
    
    private var drinkDatabase : FMDatabase?
    
    /**
        Return the shared DatabaseManager
    
        :returns: The shared DatabaseManager
    */
    class func defaultManager() -> DatabaseManager {
        return _defaultManager
    }
    
    override init() {
        super.init()
        
        copyDatabaseFile()
        
        self.initializeDatabase()
    }
    
    private func initializeDatabase() {
        
        self.drinkDatabase = FMDatabase(path: databasePath)
        
        if (self.drinkDatabase != nil && !self.drinkDatabase!.open()) {
            NSLog("Shit, we couldn't open the database, better copy it back and try again")
            self.drinkDatabase = nil;
            
            NSFileManager.defaultManager().removeItemAtPath(databasePath, error: nil)
            copyDatabaseFile()
            
            self.drinkDatabase = FMDatabase(path: databasePath)
            self.drinkDatabase!.open()
        
        }
        
        return
    }
    
    private func copyDatabaseFile() {
        if !NSFileManager.defaultManager().fileExistsAtPath(databasePath) {
            NSFileManager.defaultManager().copyItemAtPath(NSBundle.mainBundle().pathForResource(
                "drinkDatabase", ofType: "sqlite")!, toPath: databasePath, error: nil)
        }
    }
    // here we could have an else if we have multiple versions of this DB
    // floating around, like if we added a column later but that's unnecessary right now
    
    /**
        Save a drink to favorites
    
        :param: drinkTypeLookup The DrinkType for which to return drinks.
    
        :returns: An array of Drink objects, all with type DrinkTypeLookup.
    */
    func getDrinksForCategory(drinkTypeLookup : DrinkType) -> Array<Drink> {
        
        var drinks : Array<Drink> = []
        
        let results : FMResultSet = self.drinkDatabase!.executeQuery(
            "SELECT * FROM drinks WHERE type = ?",
            withArgumentsInArray: [drinkTypeLookup.rawValue])
        
        while results.next() {
            let newDrink = Drink(name: results.stringForColumn("name"),
                caffeineContent : results.doubleForColumn("caffeine"),
                volume : Int(results.intForColumn("volume")),
                type : DrinkType(rawValue: results.stringForColumn("type"))!)
            drinks.append(newDrink)
        }
        return drinks
    }
    
    /** 
        Save a drink to favorites
    
        :param: favorite The drink to be saved to favorites.
     */
    func saveFavorite(favorite: Drink) -> Void {
        let archiveData : NSData = NSKeyedArchiver.archivedDataWithRootObject(favorite)
        var favorites_array : Array<NSData>? = NSUserDefaults.standardUserDefaults().valueForKey(userDefaultsKey) as Array<NSData>?
        if (favorites_array != nil) {
            favorites_array!.append(archiveData)
        }
        else {
            favorites_array = [archiveData]
        }
        NSUserDefaults.standardUserDefaults().setObject(favorites_array!, forKey: userDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /**
        Remove a drink from the favorites. If the drink is not a favorite, do nothing.
    
        :param: favorite The drink to be removed from the favorites
    */
    func deleteFavorite(favorite: Drink) -> Void {
        let archiveData : NSData = NSKeyedArchiver.archivedDataWithRootObject(favorite)
        var favoritesArray : Array<NSData>? = NSUserDefaults.standardUserDefaults().valueForKey(userDefaultsKey) as Array<NSData>?
        if favoritesArray != nil {
            if let index : Int? = find(favoritesArray!, archiveData) {
                favoritesArray!.removeAtIndex(index!)
                NSUserDefaults.standardUserDefaults().setValue(favoritesArray!, forKey: userDefaultsKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    /**
        Return an array of the user's favorites.
    
        :returns: An array of the user's favorites
    */
    func favorites() -> Array<Drink> {
        let favoritesArray : Array<NSData>? = NSUserDefaults.standardUserDefaults().valueForKey(userDefaultsKey) as Array<NSData>?
        var favoriteDrinksArray : Array<Drink> = []
        if (favoritesArray != nil) {
            for favorite in favoritesArray! {
                favoriteDrinksArray.append(NSKeyedUnarchiver.unarchiveObjectWithData(favorite) as Drink)
            }
        }
        return favoriteDrinksArray
    }
}
