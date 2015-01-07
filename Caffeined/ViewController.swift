//
//  ViewController.swift
//  Caffeined
//
//  Created by John Martin on 1/6/15.
//  Copyright (c) 2015 John Martin. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let manager = DatabaseManager.defaultManager()
        manager.getDrinksForCategory(DrinkType.Coffee)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    let healthStore: HKHealthStore = HKHealthStore()
    
    func addCoffee() -> Void {
        var id = HKQuantityTypeIdentifierDietaryCaffeine
        var cafType: HKQuantityType = HKObjectType.quantityTypeForIdentifier(id)
        
        var myCaf: HKQuantity = HKQuantity(unit: HKUnit.gramUnit(), doubleValue: 50.0)
        
        var now = NSDate()
        
        var cafSample: HKQuantitySample = HKQuantitySample(type: cafType, quantity: myCaf, startDate: now, endDate: now)
        
        var error = NSError()
        
        NSLog("HEELLLOO", cafSample.description)
        
        healthStore.saveObject(cafSample, withCompletion: { (success, error) in
            if(success) {
                NSLog("SAVED")
            }
            else {
                NSLog("DIDNT SAVE :  %@", error)
            }
            }
        )
        
        NSLog("NATe")
        
    }

}

