//
//  LoadDataViewController.swift
//  WTM
//
//  Created by Aman Shah on 12/23/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore

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
        queryFrom = "ChampaignEvents"
        loadData(from: queryFrom)
        // Do any additional setup after loading the view.
    }
    func checkFriendshipStatus(isGoing: [String]) async -> [String] {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            return []
        }

        let userRef = Firestore.firestore().collection("users").document(currentUserUID)

        do {
            let document = try await userRef.getDocument()
            if document.exists {
                guard let friendList = document.data()?["friends"] as? [String] else {
                    print("Error: No friends list found.")
                    return []
                }

                let commonFriends = friendList.filter { isGoing.contains($0) }
                print(commonFriends)
                return commonFriends
            } else {
                print("Error: Current user document does not exist.")
                return []
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return []
        }
    }
/*
    private func loadData(from queryFrom: String, with dates: [String]) {
        let ref = Database.database().reference()

        // Initialize a group to manage multiple async requests
        let dispatchGroup = DispatchGroup()

        // This will store all the events from the specified dates

        for date in dates {
            dispatchGroup.enter()
            ref.child(queryFrom).child(date).observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {
                    print("No data available for date \(date)")
                    dispatchGroup.leave()
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
                dispatchGroup.leave()
            }) { error in
                print(error.localizedDescription)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            Task {
                var friendsDict =   [Int: [String]] ()
                var counter = 0
                for item in self.results {
                    let commonFriends = await self.checkFriendshipStatus(isGoing: item.isGoing)
                    friendsDict[counter] = commonFriends
                    counter += 1
                    
                }
                var topFriends: [EventLoad] = []
                let sortedKeys = friendsDict.keys.sorted {
                    (friendsDict[$0]?.count ?? 0) > (friendsDict[$1]?.count ?? 0)
                }
                for item in sortedKeys {
                    topFriends.append(self.results[item])
                }
                //TOP FRIENDS DONE
                
                
                //MOST POPULAR
                let sortedByMostGoing = self.results.sorted { $0.isGoing.count > $1.isGoing.count }
                let mostGoingTopFive = Array(sortedByMostGoing.prefix(5))
                

                // DEALS
                let sortedByDeals = self.results.filter { $0.deals != "" }

               
                //NUMBER 4
                let otherresults = Array(self.results.shuffled().prefix(5))


                
                let combinedLists = [mostGoingTopFive, topFriends, sortedByDeals, otherresults]

                // Initialize NewHomeViewController with combinedLists
                let newHomeVC = NewHomeViewController(events: combinedLists)

                newHomeVC.modalPresentationStyle = .fullScreen

                self.present(newHomeVC, animated: true, completion: nil)
            }
        }
    }
*/

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

                Task {
                    //TOP FRIENDS START
                    var friendsDict =   [Int: [String]] ()
                    var counter = 0
                    for item in self.results {
                        let commonFriends = await self.checkFriendshipStatus(isGoing: item.isGoing)
                        friendsDict[counter] = commonFriends
                        counter += 1
                        
                    }
                    var topFriends: [EventLoad] = []
                    let sortedKeys = friendsDict.keys.sorted {
                        (friendsDict[$0]?.count ?? 0) > (friendsDict[$1]?.count ?? 0)
                    }
                    for item in sortedKeys {
                        topFriends.append(self.results[item])
                    }
                    //TOP FRIENDS DONE
                    
                    
                    //MOST POPULAR
                    let sortedByMostGoing = self.results.sorted { $0.isGoing.count > $1.isGoing.count }
                    let mostGoingTopFive = Array(sortedByMostGoing.prefix(5))
                    

                    // DEALS
                    let sortedByDeals = self.results.filter { $0.deals != "" }

                   
                    //NUMBER 4
                    let otherresults = Array(self.results.shuffled().prefix(5))


                    
                    let combinedLists = [mostGoingTopFive, topFriends, sortedByDeals, otherresults]

                    // Initialize NewHomeViewController with combinedLists
                    let newHomeVC = NewHomeViewController(events: combinedLists)

                    newHomeVC.modalPresentationStyle = .fullScreen

                    self.present(newHomeVC, animated: true, completion: nil)

                }

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
