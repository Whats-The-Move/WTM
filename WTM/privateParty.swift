//
//  privateParty.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 6/26/23.
//

import Foundation

class privateParty {
    var id: String
    var creator: String
    var datetime: Int
    var description: String
    var event: String
    var invitees: [String]
    var location: String
    var isGoing: [String]
    
    init(id: String, creator: String, datetime: Int, description: String, event: String, invitees: [String], location : String, isGoing: [String]) {
        self.id = id
        self.creator = creator
        self.datetime = datetime
        self.description = description
        self.invitees = invitees
        self.event = event
        self.location = location
        self.isGoing = isGoing
    }
}
