//
//  LoadDataViewController.swift
//  WTM
//
//  Created by Aman Shah on 12/23/23.
//

import UIKit
import FirebaseDatabase

class LoadDataViewController: UIViewController {
    var results: [EventLoad] = [] // List of Event objects

    override func viewDidLoad() {
        super.viewDidLoad()
        var queryFrom = "Events"
        if dbName == "BerkeleyParties" {
            queryFrom = "BerkeleyEvents"
        }
        else if dbName == "ChicagoParties" {
            queryFrom = "ChicagoEvents"
        }
        else {
            queryFrom = "EventsTest"
        }
        loadData(from: queryFrom)
        // Do any additional setup after loading the view.
    }
    
    private func loadData(from queryFrom: String) {
            let ref = Database.database().reference()

            ref.child(queryFrom).observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {
                    print("No data available")
                    return
                }

                for (key, data) in value {
                    if let eventData = data as? [String: Any],
                       let creator = eventData["creator"] as? String,
                       let date = eventData["date"] as? String,
                       let deals = eventData["deals"] as? String,
                       let description = eventData["description"] as? String,
                       let eventName = eventData["eventName"] as? String,
                       let imageURL = eventData["imageURL"] as? String,
                       let isGoing = eventData["isGoing"] as? [String],
                       let location = eventData["location"] as? String,
                       let time = eventData["time"] as? String,
                       let venueName = eventData["venueName"] as? String
                        {
                        let event = EventLoad(creator: creator, date: date, deals: deals, description: description, eventName: eventName, imageURL: imageURL, isGoing: isGoing, location: location, time: time, venueName: venueName)
                        self.results.append(event)
                    }
                }
                // Assuming `results` is an array of EventLoad instances fetched from Firebase
                let sortedByMostGoing = self.results.sorted { $0.isGoing.count > $1.isGoing.count }
                let sortedByLeastGoing = self.results.sorted { $0.isGoing.count < $1.isGoing.count }

                let mostGoingTopFive = Array(sortedByMostGoing.prefix(5))
                let leastGoingTopFive = Array(sortedByLeastGoing.prefix(5))

                // Select any 10 other EventLoad instances and split into two lists
                let otherresults = Array(self.results.shuffled().prefix(10))
                let otherListOne = Array(otherresults.prefix(5))
                let otherListTwo = Array(otherresults.suffix(5))

                // Combine into a list of lists
                let combinedLists = [mostGoingTopFive, leastGoingTopFive, otherListOne, otherListTwo]

                // Initialize NewHomeViewController with combinedLists
                let newHomeVC = NewHomeViewController(events: combinedLists)

                newHomeVC.modalPresentationStyle = .fullScreen

                self.present(newHomeVC, animated: true, completion: nil)
            }) { error in
                print(error.localizedDescription)
            }
        }

}
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

    init(creator: String, date: String, deals: String, description: String, eventName: String, imageURL: String, isGoing: [String], location: String, time: String, venueName: String) {
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
    }

}
