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
    case EnergyDrink = "energy_soda"
    case Other = "other"
}

class Drink {
    var name : String = ""
    var caffeineContent : Double = 0 //mg per floz?
    var volume : Int = 0 // floz?
    var type : DrinkType = DrinkType.Other
    
    init(name: String, caffeineContent : Double, volume : Int, type : DrinkType) {
        self.name = name
        self.caffeineContent = caffeineContent
        self.volume = volume
        self.type = type
    }
    
    convenience init(decoder : NSCoder) {
        let name : String = decoder.decodeObjectForKey("name") as String
        let caffeineContent : Double = decoder.decodeObjectForKey("caffeineContent") as Double
        let volume : Int = decoder.decodeObjectForKey("volume") as Int
        let type : DrinkType = DrinkType(rawValue: decoder.decodeObjectForKey("type") as String)!
        self.init(name: name,caffeineContent: caffeineContent,volume: volume,type: type)
    }
    
    func encodeWithEncoder(encoder : NSCoder) {
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeObject(caffeineContent, forKey: "caffeineContent")
        encoder.encodeObject(volume, forKey: "volume")
        encoder.encodeObject(type.rawValue, forKey: "type")
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
        default:
            path = "pathToOther"
        }
        
        return UIImage(named: path)
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