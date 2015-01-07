//
//  Caffeined.swift
//  Caffeined
//
//  Created by John Martin on 1/6/15.
//  Copyright (c) 2015 John Martin. All rights reserved.
//

import Foundation
import UIKit

enum DrinkType: String {
    case Tea = "tea"
    case Coffee = "coffee"
    case EnergyDrink = "energy"
    case Soda = "soda"
    case Other = "other"
}

class DrinkBlank {
    var name : String = ""
    var caffeineContent : Double = 0
    var commonSizes : Array<Int> = []
    var type : DrinkType = DrinkType.Other
    
    init(name: String, caffeineContent : Double, commonSizes : Array<Int>, type : DrinkType) {
        self.name = name
        self.caffeineContent = caffeineContent
        self.commonSizes = commonSizes
        self.type = type
    }
    
    func getImage() -> UIImage? {
        var path : String
        
        switch self.type {
        case .Tea:
            path = "pathToTeaTimage"
        case .Coffee:
            path = "pathToCoffeeImage"
        case .EnergyDrink:
            path = "pathToEnergyDrink"
        case .Soda:
            path = "pathToEnergySoda"
        default:
            path = "pathToOther"
        }
        
        return UIImage(named: path)
    }
}


class Drink {
    var name: String
    var volume: Int         // in ounces
    var caffeine: Float     // in grams per ounce (or mL?)
    var image: UIImage? = UIImage(named: "something")
    
    init(name: String, vol: Int, caf: Float) {
        self.name = name
        self.volume = vol
        self.caffeine = caf
    }
}

//class Coffee: Drink {
//    override var image : {
//        UIImage(named: "somethding")
//    }
//    
//    init() {
//        
//    }
//}