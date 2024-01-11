//
//  EventLoad.swift
//  WTM
//
//  Created by Aman Shah on 1/11/24.
//

import Foundation

class EventLoad {
    var creator: String
    var date: String
    var deals: String
    var description: String
    var eventName: String
    var imageURL: String
    var isGoing: [String]
    var location: String
    var time: String
    var venueName: String
    var type: String
    var eventKey: String

    init(creator: String, date: String, deals: String, description: String, eventName: String, imageURL: String, isGoing: [String], location: String, time: String, venueName: String, type: String, eventKey: String) {
        self.creator = creator
        self.date = date
        self.deals = deals
        self.description = description
        self.eventName = eventName
        self.imageURL = imageURL
        self.isGoing = isGoing
        self.location = location
        self.time = time
        self.venueName = venueName
        self.type = type
        self.eventKey = eventKey
    }

}
