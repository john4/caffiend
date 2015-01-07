//
//  Caffeined.swift
//  Caffeined
//
//  Created by John Martin on 1/6/15.
//  Copyright (c) 2015 John Martin. All rights reserved.
//

import Foundation
import UIKit


class Drink {
    var name: String
    var volume: Int         // in ounces
    var caffeine: Float     // in grams per ounce (or mL?)
    var image: UIImage? = UIImage(named: "something")
    
    init(name: String, vol: Int, caf: Float) {
        self.name == name
        self.volume == vol
        self.caffeine == caf
    }
}

class Coffee: Drink {
    override var image {
        UIImage(named: "somethding")
    }
    
    init() {
        
    }
}