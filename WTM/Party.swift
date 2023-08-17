//
//  Party.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 1/21/23.
//

import Foundation

class Party {
    var name: String

    var address: String
    var rating : Double
    var isGoing: [String]
    
    init(name: String, address: String, rating: Double, isGoing: [String]) {
        self.name = name

        self.address = address
        self.rating = rating
        self.isGoing = isGoing
        
    }
}
