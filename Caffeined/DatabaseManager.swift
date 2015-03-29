//
//  DatabaseManager.swift
//  Caffeined
//
//  Created by Stefan Rajkovic on 6/1/15.
//  Copyright (c) 2015 John Martin. All rights reserved.
//

import Foundation
import HealthKit

/* Private Class Properties
 * 
 * These don't need to be visible to anyone else and are constant across all instances
 * of this class, so they live up here.
 *
 */
private let _defaultManager = DatabaseManager()
private let _defaultHealthStore = HKHealthStore()

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
    
    /**
    Return the shared HKHealthStore
    
    :returns: The shared HKHealthStore
    */
    class func defaultHealthStore() -> HKHealthStore {
        return _defaultHealthStore
    }
    
    override init() {
        saveToHealth = _defaultHealthStore.authorizationStatusForType(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCaffeine))
        super.init()
        
        copyDatabaseFile()
        self.initializeDatabase()
    }
    
    var saveToHealth : HKAuthorizationStatus
    
    private func initializeDatabase() {
        
        self.drinkDatabase = FMDatabase(path: databasePath)
        
        if (self.drinkDatabase != nil && !self.drinkDatabase!.open()) {
            // We might want to be able to tell people their DB failed here?
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
        Get drinks matching the given template
    
        :param: drinkLookup A Drink object containing the desired values in the
    
        :returns: An array of Drink objects, where each field matches the corresponding field in drinkLookup
    */
    func getDrinksMatchingDrink(drinkLookup : Drink) -> Array<Drink> {
        
        // if the drink is a default drink, do nothing
        if drinkLookup == Drink() {
            return []
        }
        
        var drinks : Array<Drink> = []
        var queryString : String = "SELECT * FROM drinks WHERE"
        var includeAnd : Bool = false
        var arguments : NSMutableArray = []
        var index = 0
        
        if drinkLookup.name != "" {
            queryString += " name = ?"
            includeAnd = true
            arguments.insertObject(drinkLookup.name, atIndex: index++)
        }
        
        if drinkLookup.caffeineContent != 0 {
            if includeAnd {
                queryString += " AND"
            }
            else {
                includeAnd = true
            }

            queryString += " caffeine = ?"
            arguments.insertObject(drinkLookup.caffeineContent, atIndex: index++)
        }
        
        if drinkLookup.volume != 0 {
            if includeAnd {
                queryString += " AND"
            }
            else {
                includeAnd = true
            }

            queryString += " volume = ?"
            arguments.insertObject(drinkLookup.volume, atIndex: index++)
        }
        
        if drinkLookup.type != DrinkType.Default {
            if includeAnd {
                queryString += " AND"
            }
            else {
                includeAnd = true
            }
            queryString += " type = ?"
            arguments.insertObject(drinkLookup.type.rawValue, atIndex: index++)
        }
        
        let results : FMResultSet = self.drinkDatabase!.executeQuery(
            queryString,
            withArgumentsInArray: arguments)
        
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
        if (favoritesArray != nil) {
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
    
    /**
        Save a drink to Health.
    
        :param: healthDrink The drink to save to health
        :param: date The time at which it was drank
        :param: completion block to run on completion of the save
    */
    func writeToHealth(healthDrink : Drink, date : NSDate, completion: ((Bool, NSError!) -> Void)!) {
        let healthStore = _defaultHealthStore
        
        let id = HKQuantityTypeIdentifierDietaryCaffeine
        let cafType : HKQuantityType = HKObjectType.quantityTypeForIdentifier(id)
        let caffeineValue : Double = healthDrink.caffeineContent * Double(healthDrink.volume)
        let cafQuantity : HKQuantity = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: caffeineValue)

        let cafSample : HKQuantitySample = HKQuantitySample(type: cafType, quantity: cafQuantity, startDate: date, endDate: date)
        var error = NSError()
        
        NSLog("Description of sample %@", cafSample.description)
        
        _defaultHealthStore.saveObject(cafSample, withCompletion:completion)
    }
    
    /**
        Save a drink to Health.
    
        :param: healthDrink The drink to save to health
        :param: date The time at which it was drank
    */
    func writeToHealth(healthDrink : Drink, date : NSDate) {
        writeToHealth(healthDrink, date: date, completion: { _ in })
    }
    
    /**
        Ask for permissions from HK

        :param: completion block to run on completion of the request
    */
    func askForHealthPermissions(completion : ((Bool, NSError!) -> Void)!) {
        let readingTypes = NSSet(array:[
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth),
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
            ])
        let writingTypes = NSSet(array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCaffeine)
            ])
        
        _defaultHealthStore.requestAuthorizationToShareTypes(writingTypes, readTypes: readingTypes, completion: completion)
        
        saveToHealth = _defaultHealthStore.authorizationStatusForType(HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryCaffeine))
    }
    
    /**
        Ask for permissions from HK
    */
    func askForHealthPermissions() {
        askForHealthPermissions({ _ in })
    }
    
    /**
        Get age from HK
    
        :return: age in seconds or nil
    */
    func getHKAge() -> NSTimeInterval? {
        let dob = _defaultHealthStore.dateOfBirthWithError(nil)
        if (dob != nil) {
            return NSDate().timeIntervalSince1970 - dob.timeIntervalSince1970
        }
        return nil
    }
    
    /**
        Get biological sex from HK
    
        :return: HKBiologicalSex enum (Male | Female | NotSet | Other)
    */
    func getHKSex() -> HKBiologicalSex {
        return _defaultHealthStore.biologicalSexWithError(nil).biologicalSex
    }

    /**
        Get weight from HK

        :param: completion block to execute on completion. Second value is only valid if first is true.
    */
    func getHKWeight(completion : (Bool, Double) -> Void) -> Void {
        let weightType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(NSDate(timeIntervalSince1970: 0), endDate:NSDate(), options: .None)
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let weight_query = HKSampleQuery(sampleType: weightType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (sample, results, error) -> Void in
            if (results != nil && 1 == results.count) {
                let weight = results.first as HKQuantitySample
                let user_weight = weight.quantity.doubleValueForUnit(HKUnit.poundUnit())
                completion(true, user_weight) as Void
            }
            else {
                completion(false,-1)
            }
        }
        _defaultHealthStore.executeQuery(weight_query)
    }
    
    /**
    Get height from HK
    
    :param: completion block to execute on completion. Second value is only valid if first is true.
    */
    func getHKHeight(completion : (Bool, Double) -> Void) -> Void {
        let heightType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(NSDate(timeIntervalSince1970: 0), endDate:NSDate(), options: .None)
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let height_query = HKSampleQuery(sampleType: heightType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (sample, results, error) -> Void in
            if (results != nil && 1 == results.count) {
                let height = results.first as HKQuantitySample
                let user_height = height.quantity.doubleValueForUnit(HKUnit.inchUnit())
                completion(true, user_height) as Void
            }
            else {
                completion(false,-1)
            }
        }
        _defaultHealthStore.executeQuery(height_query)
    }
}
