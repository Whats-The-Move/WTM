//
//  AppHomeViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 1/21/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import Firebase
import CoreLocation

extension Party: Equatable {
    static func == (lhs: Party, rhs: Party) -> Bool {
        return lhs.name == rhs.name
    }
}

class AppHomeViewController: UIViewController, UITableViewDelegate, CustomCellDelegate, privateCustomCellDelegate, CLLocationManagerDelegate {
    
    func profileClicked(for party: Party) {
        // Create an instance of friendsGoingViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let friendsGoingVC = storyboard.instantiateViewController(withIdentifier: "FriendsGoing") as! friendsGoingViewController
        
        // Pass the selected party object
        friendsGoingVC.selectedParty = party
        
        friendsGoingVC.modalPresentationStyle = .overFullScreen
        
        // Present the friendsGoingVC modally
        present(friendsGoingVC, animated: true, completion: nil)
    }
    
    func profileClicked(for party: privateParty) {
        // Create an instance of friendsGoingViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let friendsGoingVC = storyboard.instantiateViewController(withIdentifier: "FriendsGoing") as! friendsGoingViewController
        
        // Pass the selected party object
        friendsGoingVC.selectedPrivateParty = party
        
        friendsGoingVC.modalPresentationStyle = .overFullScreen
        
        // Present the friendsGoingVC modally
        present(friendsGoingVC, animated: true, completion: nil)
    }
    
    var rank = 0
    var timer: Timer?
    let defaults = UserDefaults.standard

    @IBOutlet weak var partyList: UITableView! {
        didSet {
            partyList.dataSource = self
            partyList.delegate = self
            partyList.register(FirstCustomCellClass.self, forCellReuseIdentifier: "firstPartyCell")
            partyList.register(CustomCellClass.self, forCellReuseIdentifier: "partyCell")
            // Add left and right margins of 16 points each
            

            // Set the content inset to add the margins
            //partyList.contentInset = UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: rightMargin)

        }
    }
    let locationTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    @IBOutlet weak var searchBar: UISearchBar!
    var partyArray = [String]()
    var privatePartyArray = [String]()
    var searching = false
    @IBOutlet weak var friendNotification: UIButton!
    @IBOutlet weak var profileUIImage: UIImageView!
    @IBOutlet var locationLabel: UILabel!
    // Retrieve values from UserDefaults without optional binding
    var locations = UserDefaults.standard.array(forKey: "LocationOptionsKey") as? [String] ?? []
    var pictures = UserDefaults.standard.array(forKey: "PictureOptionsKey") as? [String] ?? []

    @IBOutlet var locationPicture: UIImageView!
    
    var searchParty = [String]()

    var dropdownView: UIView!
    var collegeImage: UIImageView!
    var dropdownLabel: UILabel!

    
    var databaseRef: DatabaseReference?
    var userDatabaseRef: DatabaseReference?
    public var parties = [Party]()
    public var partiesCloned = [Party]()
    public var privateParties = [privateParty]()
    public var likeDict = [String : Int]()
    public var dislikeDict = [String : Int]()
    public var overallLikeDict = [String : Double]()
    public var overallDislikeDict = [String : Double]()
    public var addressDict = [String : String]()
    public var privateNameDict = [String : String]()
    public var privateAddressDict = [String : String]()
    public var privateDateTimeDict = [String : Int]()
    public var userVotes = [String : Int]()
    public var rankDict = [String : Int]()
    public var ratingDict = [String : Double]()
    public var countNum = 34
    public var privNum = 0
    public var sortedParties: [(partyID: String, friendsCount: Int)] = []
    public var friendsGoing = [String : [String]]()
    public var transImage = UIImage()
    private let refreshControl = UIRefreshControl()
    var locationManger = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(locationOptions)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDropdown))
        locationLabel.isUserInteractionEnabled = true
        locationLabel.addGestureRecognizer(tapGesture)
        KeyboardManager.shared.enableTapToDismiss()
        locationManger.delegate = self
        locationManger.requestAlwaysAuthorization()
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()

        setupPullToRefresh()
        setDB()
        //cupertino
        setupDropdownView()
        setupDropdownTableView()
        dropdownView.isHidden = true
        if let locationOptions = defaults.array(forKey: "LocationOptionsKey") as? [String] {
            locationLabel.text = locationOptions[0]
        }
        if let pictureOptions = defaults.array(forKey: "PictureOptionsKey") as? [String] {
            locationPicture.image = UIImage(named: pictureOptions[0])

        }
        // Create a transparent UIImage with the desired size
        let imageSize = CGSize(width: 39, height: 39) // Replace with your desired size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        let transparentColor = UIColor.clear
        transparentColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: imageSize))
        transImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        // Set the transparent image to the UIImageView
        dropdownLabel.textColor = .black
        //partyList.sectionHeaderHeight = 8 // 8px vertical spacing between cells
        partyList.separatorStyle = .none
        //let paddingWidth: CGFloat = 10.0
        //partyList.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: paddingWidth)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileUIImage.addGestureRecognizer(tapGestureRecognizer)
        profileUIImage.isUserInteractionEnabled = true
        



        
        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { [weak self] (document, error) in
                guard let self = self, let document = document, document.exists else {
                    // Handle error or nil self
                    return
                }
                
                if let data = document.data(),
                   let pendingFriendRequests = data["pendingFriendRequests"] as? [String] {
                    // Access the username and name values
                    if pendingFriendRequests.isEmpty{
                        self.friendNotification.isHidden = true
                    } else{
                        self.friendNotification.isHidden = false
                        self.friendNotification.setTitle("\(pendingFriendRequests.count)", for: .normal)
                    }
                } else {
                    self.friendNotification.isHidden = true
                }
            }
        }

        partyList.rowHeight = 100.0 // Adjust this value as needed
        //partyList.rowHeight = UITableView.automaticDimension



        let user_address1 = UserDefaults.standard.string(forKey: "user_address") ?? "user"
        for recognizer in view.gestureRecognizers ?? [] {
            if let swipeRecognizer = recognizer as? UISwipeGestureRecognizer, swipeRecognizer.direction == .down {
                view.removeGestureRecognizer(swipeRecognizer)
            }
        }

        partyList.overrideUserInterfaceStyle = .dark
        searchBar.overrideUserInterfaceStyle = .dark

        //partyList.reloadData()
        
        databaseRef = Database.database().reference().child(dbName)
        databaseRef?.queryOrdered(byChild: "Likes").observe(.childAdded) { [weak self] (snapshot) in
            let key = snapshot.key
            guard let value = snapshot.value as? [String : Any] else {return}
            if let address = value["Address"] as? String,
               let rating = value["avgStars"] as? Double,
               let isGoing = value["isGoing"] as? [String] {
                let party = Party(name: key, address: address, rating: rating, isGoing : isGoing)
                if party.isGoing.count > maxPeople {
                    maxPeople = party.isGoing.count
                }
                self?.partiesCloned.insert(party, at: 0)
                self?.partyArray.insert(party.name, at: 0)
                self?.addressDict[party.name] = party.address
                self?.ratingDict[party.name] = party.rating
            }
        }

        calculateFriendsAttending()
    }
    //cupertino
    func setDB (){
        if var locationOptions = defaults.array(forKey: "LocationOptionsKey") as? [String] {

            if locationOptions[0] == "Champaign, IL" {
                dbName = "Parties"
                currCity = "Champaign"
            }
            else if locationOptions[0] == "Chicago, IL" {
                dbName = "ChicagoParties"
                currCity = "Chicago"
                
            }
            else {
                dbName = "BerkeleyParties"
                currCity = "Berkeley"
            }
        }
    }
    //cupertino
    func setupDropdownView() {
        // Create and style dropdownView
        dropdownView = UIView()
        let cornerRadius: CGFloat = 10.0 // Adjust this value as needed
        dropdownView.layer.cornerRadius = cornerRadius
        dropdownView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        dropdownView.clipsToBounds = true
        
        dropdownView.backgroundColor = UIColor.white
        dropdownView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dropdownView)
        
        // Create and style collegeImage
        collegeImage = UIImageView(image: UIImage(named: "calLogo"))
        collegeImage.translatesAutoresizingMaskIntoConstraints = false
        dropdownView.addSubview(collegeImage)
        
        // Create and style dropdownLabel
        dropdownLabel = UILabel()
        //print(locationOptions)
        if let locationOptions = defaults.array(forKey: "LocationOptionsKey") as? [String] {
            dropdownLabel.text = locationOptions[1]
            

        }
        if let pictureOptions = defaults.array(forKey: "PictureOptionsKey") as? [String] {
            collegeImage.image = UIImage(named: pictureOptions[1])


        }

        dropdownLabel.font = UIFont(name: "Future Medium", size: 35)
        //dropdownLabel.textColor = .black
        dropdownLabel.translatesAutoresizingMaskIntoConstraints = false
        dropdownView.addSubview(dropdownLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            dropdownView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor),
            dropdownView.heightAnchor.constraint(equalToConstant: 50),
            dropdownView.leadingAnchor.constraint(equalTo: locationPicture.leadingAnchor),
            dropdownView.trailingAnchor.constraint(equalTo: locationLabel.trailingAnchor),
            
            collegeImage.leadingAnchor.constraint(equalTo: dropdownView.leadingAnchor, constant: 10),
            collegeImage.centerYAnchor.constraint(equalTo: dropdownView.centerYAnchor),
            collegeImage.widthAnchor.constraint(equalToConstant: 20),
            collegeImage.heightAnchor.constraint(equalToConstant: 20),
            
            dropdownLabel.leadingAnchor.constraint(equalTo: collegeImage.trailingAnchor, constant: 10),
            dropdownLabel.centerYAnchor.constraint(equalTo: dropdownView.centerYAnchor)
        ])
        
        // Add tap gesture recognizer to dropdownView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dropdownViewTapped))
        dropdownView.addGestureRecognizer(tapGesture)
    }
    //cupertino
    @objc func dropdownViewTapped() {
        // Toggle locationIndex
        if var locationOptions = defaults.array(forKey: "LocationOptionsKey") as? [String] {
            locationLabel.text = locationOptions[1]
            dropdownLabel.text = locationOptions[0]

            if locationOptions[0] == "Champaign, IL" {
                dbName = "Parties"
            }
            else{
                dbName = "BerkeleyParties"
            }
            locationOptions.reverse()
            defaults.set(locationOptions, forKey: "LocationOptionsKey")


        }
        if var pictureOptions = defaults.array(forKey: "PictureOptionsKey") as? [String] {
            locationPicture.image = UIImage(named: pictureOptions[1])
            collegeImage.image = UIImage(named: pictureOptions[0])

            pictureOptions.reverse()
            defaults.set(pictureOptions, forKey: "PictureOptionsKey")


        }
        //print(locationOptions)
        //print(locationOptions)
        //setupDropdownView()



        dropdownView.isHidden = true
        //partyList.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Replace the below lines with your actual refresh logic
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let AppHomeVC = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            AppHomeVC.overrideUserInterfaceStyle = .dark
            AppHomeVC.modalPresentationStyle = .fullScreen
            self.present(AppHomeVC, animated: false, completion: nil)

            // End the refreshing animation
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func dropdownButtonTapped(_ sender: Any) {
        toggleDropdown()
    }
    @objc func toggleDropdown() {
        locationTableView.isHidden = !locationTableView.isHidden
        let indexPath = IndexPath(row: 0, section: 0)
        locationTableView.scrollToRow(at: indexPath, at: .top, animated: true)

        
    }
    
    private func setupPullToRefresh() {
        // Set the target for the refresh control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        // Set the tint color of the refresh control to hot pink (RGB: 255, 22, 148)
        refreshControl.tintColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0)

        // Add the refresh control to the table view
        partyList.addSubview(refreshControl)
    }

    @objc private func refreshData(_ sender: Any) {
        // Add a delay of 5 milliseconds before refreshing the page
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Replace the below lines with your actual refresh logic
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let AppHomeVC = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            AppHomeVC.overrideUserInterfaceStyle = .dark
            AppHomeVC.modalPresentationStyle = .fullScreen
            self.present(AppHomeVC, animated: false, completion: nil)

            // End the refreshing animation
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { [weak self] (document, error) in
                guard let self = self, let document = document, document.exists else {
                    // Handle error or nil self
                    return
                }
                
                if let data = document.data(),
                   let pendingFriendRequests = data["pendingFriendRequests"] as? [String] {
                    // Access the username and name values
                    if pendingFriendRequests.isEmpty{
                        self.friendNotification.isHidden = true
                    } else{
                        self.friendNotification.isHidden = false
                        self.friendNotification.setTitle("\(pendingFriendRequests.count)", for: .normal)
                    }
                }
            }
        }
    }
    
    @objc func imageTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let badgesViewController = storyboard.instantiateViewController(withIdentifier: "MyFriends") as! MyFriendsViewController
        present(badgesViewController, animated: true, completion: nil)
    }

    func calculateFriendsAttending() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }

        let partiesRef = Database.database().reference().child(dbName)

        // Retrieve the list of parties
        partiesRef.observeSingleEvent(of: .value) { snapshot in
            guard let partiesSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Failed to retrieve parties.")
                return
            }

            var friendsAttendingDict: [String: (friendsCount: Int, isGoingCount: Int)] = [:] // Initialize the friendsAttendingDict dictionary
            let dispatchGroup = DispatchGroup() // Create a dispatch group to wait for all queries to finish

            for partySnapshot in partiesSnapshot {
                let partyID = partySnapshot.key

                guard let attendeesSnapshotArray = partySnapshot.childSnapshot(forPath: "isGoing").value as? [String] else {
                    print("Failed to retrieve attendees for party: \(partyID)")
                    continue
                }

                var friendsCount = 0
                var friendsGoingArray: [String] = []

                for attendeeID in attendeesSnapshotArray {
                    dispatchGroup.enter()

                    let userRef = Firestore.firestore().collection("users").document(currentUserID)

                    userRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            guard let friendList = document.data()?["friends"] as? [String] else {
                                print("Error: No friends list found.")
                                dispatchGroup.leave()
                                return
                            }

                            if friendList.contains(attendeeID) {
                                friendsCount += 1
                                friendsGoingArray.append(attendeeID)
                            }
                        } else {
                            print("Error: Current user document does not exist.")
                        }

                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    friendsAttendingDict[partyID] = (friendsCount: friendsCount, isGoingCount: attendeesSnapshotArray.count)
                    self.friendsGoing[partyID] = friendsGoingArray

                    // Check if all parties have been processed
                    if friendsAttendingDict.count == partiesSnapshot.count {
                        // Sort the parties based on the number of friends attending and the "isGoing" count
                        let sortedParties = friendsAttendingDict
                            .sorted(by: { (entry1, entry2) -> Bool in
                                if entry1.value.friendsCount != entry2.value.friendsCount {
                                    return entry1.value.friendsCount > entry2.value.friendsCount
                                } else {
                                    return entry1.value.isGoingCount > entry2.value.isGoingCount
                                }
                            })
                            .map { (partyID: $0.key, friendsCount: $0.value.friendsCount) }

                        // Now you have the sorted parties and the friendsGoing dictionary populated
                        // You can use them as needed for further processing or displaying data
                        print(sortedParties)
                        print(self.friendsGoing)

                        // Update your UI with the sorted parties and friendsGoing dictionary
                        self.sortedParties = sortedParties
                        self.friendsGoing = self.friendsGoing
                        self.updateUIWithSortedParties()
                    }
                }
            }
        }
    }


    func updateUIWithSortedParties() {
        if publicOrPriv {
            for partyTuple in sortedParties.reversed() {
                let partyID = partyTuple.partyID
                print(partyID)
                // Access the party information directly using the party ID
                if let party = partiesCloned.first(where: { $0.name == partyID }) {
                    print("hello")
                    let address = addressDict[partyID] ?? ""
                    let rating = ratingDict[partyID] ?? 0.0
                    let isGoing = party.isGoing
                    
                    let party = Party(name: party.name, address: address, rating: rating, isGoing: isGoing)
                    
                    self.parties.insert(party, at: 0)
                    self.rankDict[party.name] = self.countNum
                                                        
                    let row = 0 // Insert at the beginning of the section
                    let indexPath = IndexPath(row: 0, section: row)
                    partyList.insertSections([indexPath.section], with: .automatic)
                    self.countNum -= 1

                }
            }
            self.partyList.reloadData()

        } else {
            let uid = Auth.auth().currentUser?.uid
            databaseRef = Database.database().reference().child("Privates")
            databaseRef?.queryOrdered(byChild: "dateTime").queryStarting(atValue: 0).observe(.childAdded) { [weak self] (snapshot) in
                let key = snapshot.key
                guard let value = snapshot.value as? [String: Any] else { return }
                if let datetime = value["dateTime"] as? Int,
                   let creator = value["creator"] as? String,
                   let description = value["description"] as? String,
                   let event = value["event"] as? String,
                   let location = value["location"] as? String,
                   let invitees = value["invitees"] as? [String],
                   let isGoing = value["isGoing"] as? [String] {
                    if invitees.contains(uid ?? "") {
                        let party = privateParty(id: key, creator: creator, datetime: datetime, description: description, event: event, invitees: invitees, location: location, isGoing: isGoing)
                        self?.privateParties.append(party)
                        self?.privatePartyArray.insert(party.event, at: 0)
                        self?.privateNameDict[party.id] = party.event
                        self?.privateAddressDict[party.id] = party.location
                        self?.privateDateTimeDict[party.id] = party.datetime
                        if let row = self?.privateParties.count {
                            let indexPath = IndexPath(row: row - 1, section: 0)
                            self?.partyList.insertRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
                self?.partyList.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        partyList.reloadData()
        super.viewWillAppear(animated)
        
    }
    
//    @IBAction func refreshButtonTapped(_ sender: Any) {
//        /*
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let newViewController = storyboard.instantiateViewController(withIdentifier: "AppHome") as! AppHomeViewController
//        newViewController.modalPresentationStyle = .fullScreen
//        present(newViewController, animated: false, completion: nil)
//        */
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let TabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
//        TabBarController.overrideUserInterfaceStyle = .dark
//        TabBarController.modalPresentationStyle = .fullScreen
//        present(TabBarController, animated: false, completion: nil)
//
//    }
    

    @IBAction func logOutButtonTapped(_ sender: Any) {
        do{
            try FirebaseAuth.Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "authenticated")
            //TAKE THEM TO LOG IN SCREEN
        }
        catch{
            print("error")
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "SignUpPage") as! ViewController
        newViewController.modalPresentationStyle = .fullScreen
        present(newViewController, animated: false, completion: nil)


    }

    
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        partyList.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func buttonClicked(for party: privateParty) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let partyRef = Database.database().reference().child("Privates").child(party.id)
        partyRef.child("isGoing").observeSingleEvent(of: .value) { snapshot   in
            if snapshot.exists() { //if uid is already in the list, take it out (if someone cancels their attendance to a party)
                if var attendees = snapshot.value as? [String] {
                    if let index = attendees.firstIndex(of: uid) {
                        attendees.remove(at: index)
                        partyRef.child("isGoing").setValue(attendees) { error, _ in
                            if let error = error {
                                print("Failed to update party attendance:", error)
                            } else {
                                print("Successfully updated party attendance.")
                            }
                        }
                    } else { //this adds the uid to the list if they say they're going
                        attendees.append(uid)
                        let customCell = privatePartyCellClass()
                        customCell.checkFriendshipStatus(isGoing: attendees) { result in
                            // Call the updateBestFriends function and pass the result as a parameter
                            self.updateBestFriends(commonFriends: result)
                        }
                        
                        partyRef.child("isGoing").setValue(attendees) { error, _ in
                            if let error = error {
                                print("Failed to update party attendance:", error)
                            } else {
                                print("Successfully updated party attendance.")
                            }
                        }
                    }
                }
            } else { //if the node doesn't exist in firebase then create a node and add the uid
                print(" creating node")
                partyRef.child("isGoing").setValue([uid]) { error, _ in
                    if let error = error {
                        print("Failed to update party attendance:", error)
                    } else {
                        print("Successfully updated party attendance.")
                    }
                }
            }
        }
        //reloadlist
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let AppHomeVC = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        AppHomeVC.overrideUserInterfaceStyle = .dark
        AppHomeVC.modalPresentationStyle = .fullScreen
        self.present(AppHomeVC, animated: false, completion: nil)
    }
    
    func buttonClicked(for party: Party) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let partyRef = Database.database().reference().child(dbName).child(party.name)
        partyRef.child("isGoing").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() { //if uid is already in the list, take it out (if someone cancels their attendance to a party)
                if var attendees = snapshot.value as? [String] {
                    if let index = attendees.firstIndex(of: uid) {
                        attendees.remove(at: index)
                        partyRef.child("isGoing").setValue(attendees) { error, _ in
                            if let error = error {
                                print("Failed to update party attendance:", error)
                            } else {
                                print("Successfully updated party attendance.")
                            }
                        }
                    } else { //this adds the uid to the list if they say they're going
                        attendees.append(uid)
                        let customCell = CustomCellClass()
                        customCell.checkFriendshipStatus(isGoing: attendees) { result in
                            // Call the updateBestFriends function and pass the result as a parameter
                            self.updateBestFriends(commonFriends: result)
                        }
                        self.incrementSpotCount(partyName: party.name)

                        partyRef.child("isGoing").setValue(attendees) { error, _ in
                            if let error = error {
                                print("Failed to update party attendance:", error)
                            } else {
                                print("Successfully updated party attendance.")
                            }
                        }
                    }
                }
            } else { //if the node doesn't exist in firebase then create a node and add the uid
                print(" creating node")
                partyRef.child("isGoing").setValue([uid]) { error, _ in
                    if let error = error {
                        print("Failed to update party attendance:", error)
                    } else {
                        print("Successfully updated party attendance.")
                    }
                }
            }
            //reloadlist
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let AppHomeVC = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            AppHomeVC.overrideUserInterfaceStyle = .dark
            AppHomeVC.modalPresentationStyle = .fullScreen
            self.present(AppHomeVC, animated: false, completion: nil)
        }
    }

    func setupDropdownTableView() {
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
        // Remove the separator insets
        locationTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        // Create a custom UIColor with RGB values (255, 22, 148)
        let pinkColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0)

        // Set the separator line color to the custom pink color
        locationTableView.separatorColor = pinkColor




        // Register a custom cell if needed
        // locationTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCellIdentifier")

        // Add the table view to your view hierarchy
        view.addSubview(locationTableView)
        let height = locations.count * 67
        // Set up constraints (adjust these as needed)
        NSLayoutConstraint.activate([
            locationTableView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor),
            locationTableView.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor),
            locationTableView.trailingAnchor.constraint(equalTo: locationLabel.trailingAnchor),
            locationTableView.bottomAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: CGFloat(height))
        ])
        locationTableView.isHidden = true
    }
    
    
    func updateDicts() {
        
        databaseRef = Database.database().reference().child(dbName)
        databaseRef?.observe(.childAdded){ [weak self] (snapshot) in
            let key = snapshot.key
            guard let value = snapshot.value as? [String : Any] else {return}
            if let address = value["Address"] as? String, let rating = value["avgStars"] as? Double, let isGoing = value["isGoing"] as? [String] {
                let party = Party(name: key, address: address, rating: rating, isGoing: isGoing)
                    
                    self?.addressDict[party.name] = party.address
                    self?.ratingDict[party.name] = party.rating
            }
        }
        
        databaseRef = Database.database().reference().child("Privates")
        databaseRef?.queryOrdered(byChild: "dateTime").observe(.childAdded) { [weak self] (snapshot)  in
            let key = snapshot.key
            guard let value = snapshot.value as? [String : Any] else {return}
            if let datetime = value["dateTime"] as? Int,
               let creator = value["creator"] as? String,
               let description = value["description"] as? String,
               let event = value["event"] as? String,
               let location = value["location"] as? String,
               let invitees = value["invitees"] as? [String],
               let isGoing = value["isGoing"] as? [String] {
                let party = privateParty(id: key, creator: creator, datetime: datetime, description: description, event: event, invitees: invitees, location : location, isGoing: isGoing)
                self?.privateParties.insert(party, at: 0)
                self?.privateNameDict[party.id] = party.event
                self?.privateAddressDict[party.id] = party.location
                self?.privateDateTimeDict[party.id] = party.datetime
            }
        }
    }
    
    func incrementSpotCount(partyName: String) {
        let db = Firestore.firestore()

        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }

        // Reference to the user document in Firestore
        let userDocRef = db.collection("users").document(currentUserUID)
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Check if the 'spots' field exists in the document
                if var spots = document.data()?["spots"] as? [String: Int] {
                    // Increment the visit count for the party name
                    if let count = spots[partyName] {
                        spots[partyName] = count + 1
                    } else {
                        spots[partyName] = 1
                    }
                    // Update the 'spots' field in the document
                    userDocRef.updateData(["spots": spots])
                } else {
                    // Create a new 'spots' field with the party name and visit count
                    let spots = [partyName: 1]
                    userDocRef.setData(["spots": spots], merge: true)
                }
            } else {
                // Document doesn't exist, handle the error
                print("User document does not exist.")
            }
        }
    }


    func updateBestFriends(commonFriends: [String]) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let usersCollection = Firestore.firestore().collection("users")
        let userDocument = usersCollection.document(currentUserUID)
        
        userDocument.getDocument { (document, error) in
            if let document = document, document.exists {
                var bestFriends = document.data()?["bestFriends"] as? [String: Int] ?? [:]
                
                for friend in commonFriends {
                    if let count = bestFriends[friend] {
                        // Increment the count if the friend already exists
                        bestFriends[friend] = count + 1
                    } else {
                        // Add the friend with a count of 1 if they don't exist
                        bestFriends[friend] = 1
                    }
                }
                
                // Update the "bestFriends" field in Firestore
                userDocument.setData(["bestFriends": bestFriends], merge: true) { error in
                    if let error = error {
                        print("Error updating best friends: \(error.localizedDescription)")
                    } else {
                        print("Best friends updated successfully!")
                    }
                }
            } else if let error = error {
                print("Error accessing user document: \(error.localizedDescription)")
            } else {
                // Create the "bestFriends" field if it doesn't exist
                userDocument.setData(["bestFriends": [:]]) { error in
                    if let error = error {
                        print("Error creating best friends field: \(error.localizedDescription)")
                    } else {
                        print("Best friends field created successfully!")
                    }
                }
            }
        }
    }
}







extension AppHomeViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == partyList {
            print("table view is main")
            if searching {
                return searchParty.count
            } else {
                return parties.count
            }
        }
        else { //will change this to dropdown later
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == partyList {
                return 1
            }
        else {
            return self.locations.count //location.count
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == partyList{
            return 0.1
            
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == partyList {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
            
        }
        else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == partyList{
            if indexPath.section != 0{
                
                print("mmmmmm")
                print(indexPath.section)
                let cell = tableView.dequeueReusableCell(withIdentifier: "partyCell", for: indexPath) as! CustomCellClass

                cell.delegate = self // Set the view controller as the delegate for the cell
                cell.contentView.layoutMargins = .init(top: 0.0, left: 23.5, bottom: 0.0, right: 23.5)
                cell.layer.cornerRadius = 10
                cell.layer.borderWidth = 2
                let pinkColor = UIColor(red: 255.0/255.0, green: 22.0/255.0, blue: 142.0/255.0, alpha: 1.0).cgColor
                cell.layer.borderColor = UIColor.white.cgColor
                cell.backgroundColor = UIColor.white

                
                let party: Party
                if searching {
                    party = parties.first { $0.name == searchParty[indexPath.section] }!
                } else {
                    
                    print("bbbbbbb")
                    print(indexPath.section)
                    party = parties[indexPath.section]
                }
                
                cell.configure(with: party, rankDict: rankDict, at: indexPath)
                return cell

                
            } else{

                print("nnnnnnnn")
                print(indexPath.section)

                // Dequeue the first cell prototype
                let cell = tableView.dequeueReusableCell(withIdentifier: "firstPartyCell", for: indexPath) as! FirstCustomCellClass
                
                cell.delegate = self // Set the view controller as the delegate for the cell
                cell.layer.cornerRadius = 10
                cell.layer.borderWidth = 2
                let pinkColor = UIColor(red: 255.0/255.0, green: 22.0/255.0, blue: 142.0/255.0, alpha: 1.0).cgColor
                cell.layer.borderColor = UIColor.white.cgColor
                cell.backgroundColor = UIColor.white
                // Configure the first cell with the desired layout
                // ...
                
                
                let party: Party
                if searching {
                    party = parties.first { $0.name == searchParty[indexPath.section] }!
                } else {
                    print("pppppp")
                    print(indexPath.section)

                    party = parties[indexPath.section]
                    print(party.name)
                }
                
                cell.configureFirst(with: party, rankDict: rankDict, at: indexPath)
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
            cell.textLabel?.text = locations[indexPath.row]
            cell.textLabel?.font = UIFont(name: "Futura-Medium", size: 18)

            return cell
        }
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Check if it's the first cell
        if tableView == partyList{
            if indexPath.section == 0 {
                // Return the desired height for the first cell
                return 250 // Change this value to the height you want for the first cell
            } else {
                // Return the default height for other cells
                return partyList.rowHeight // Change this value to the default height for other cells
            }
        }
        else {
            return 67
        }

    }

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == partyList {
           //do nothing for now

            var destinationVC = PublicPopUpViewController(selectedParty: parties[indexPath.section])

            // Create an instance of the DestinationViewController and pass the selectedItem
            if searching {
                if let foundParty = parties.first(where: { $0.name == searchParty[indexPath.section] }) {
                    destinationVC = PublicPopUpViewController(selectedParty:foundParty)
                }


            }
            

            // Present the destination view controller modally
            present(destinationVC, animated: true, completion: nil)
        }
        else {
            if let cell = tableView.cellForRow(at: indexPath) {
                // Access the text label of the selected cell
                if let titleLabel = cell.textLabel {
                    // Access the text of the title label
                    let title = titleLabel.text
                    // Do something with the title
                    //locationLabel.text = title
                    if title == "Champaign, IL" {
                        dbName = "Parties"
                        locationPicture.image = UIImage(named: "illinoisLogo")
                        if let index = pictures.firstIndex(of: "illinoisLogo") {
                            // Remove the title from its current position
                            pictures.remove(at: index)
                            // Insert it at the beginning of the array
                            pictures.insert("illinoisLogo", at: 0)
                            print("Found first index")
                            print(pictures)
                            defaults.set(pictures, forKey: "PictureOptionsKey")

                        }
                    }
                    else if title == "Chicago, IL" {
                        dbName = "ChicagoParties"
                        locationPicture.image = UIImage(named: "chicago_flag")
                        if let index = pictures.firstIndex(of: "chicago_flag") {
                            // Remove the title from its current position
                            pictures.remove(at: index)
                            // Insert it at the beginning of the array
                            pictures.insert("chicago_flag", at: 0)
                            defaults.set(pictures, forKey: "PictureOptionsKey")
                            
                        }

                    }
                    else {
                        dbName = "BerkeleyParties"
                        locationPicture.image = UIImage(named: "calLogo")
                        if let index = pictures.firstIndex(of: "calLogo") {
                            // Remove the title from its current position
                            pictures.remove(at: index)
                            // Insert it at the beginning of the array
                            pictures.insert("calLogo", at: 0)
                            defaults.set(pictures, forKey: "PictureOptionsKey")
                            
                        }

                    }
                    if let index = locations.firstIndex(of: title ?? "Champaign, IL") {
                        // Remove the title from its current position
                        locations.remove(at: index)
                        // Insert it at the beginning of the array
                        locations.insert(title ?? "Champaign, IL", at: 0)
                        // Reload the table view to reflect the updated data

                    }
                    defaults.set(locations, forKey: "LocationOptionsKey")

                }
            }

            locationTableView.isHidden = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Replace the below lines with your actual refresh logic
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let AppHomeVC = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            //AppHomeVC.overrideUserInterfaceStyle = .dark
            AppHomeVC.modalPresentationStyle = .fullScreen
            self.present(AppHomeVC, animated: false, completion: nil)

            // End the refreshing animation
            self.refreshControl.endRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if publicOrPriv {
//            updateDicts()
//            let date = NSDate()
//            let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
//            var newDate : NSDate?
//            cal.range(of: .day, start: &newDate, interval: nil, for: date as Date)
//
//
//            if segue.identifier == "popupSegue" {
//                    print("going into popup")
//                    let destinationVC = segue.destination as! PublicPopUpViewController
//                //destinationVC.isModalInPresentation = true
//                //destinationVC.modalPresentationStyle = .fullScreen
//
//                    if let cell = sender as? UITableViewCell {
//                        if let label = cell.viewWithTag(1) as? UILabel {
//                            let uid = Auth.auth().currentUser?.uid ?? ""
//
//                            let partyRef = Database.database().reference().child("Parties").child(label.text ?? "")
//                            var isUserGoing = false
//                            partyRef.child("isGoing").observeSingleEvent(of: .value) { snapshot in
//
//
//                                print("segue before it goes in")
//                                if snapshot.exists() {
//                                    if let attendees = snapshot.value as? [String] {
//                                        isUserGoing = attendees.contains(uid)
//                                        print("is user going: \(isUserGoing)")
//                                        destinationVC.userGoing = isUserGoing
//                                        let pinkColor = UIColor(red: 215.0/255, green: 113.0/255, blue: 208.0/255, alpha: 0.5)
//                                        let greenColor = UIColor(red: 0.0, green: 185.0/255, blue: 0.0, alpha: 1.0)
//                                        let grayColor = UIColor(red: 128.0/255, green: 128.0/255, blue: 128.0/255, alpha: 0.5)
//                                        let backgroundColor = isUserGoing ? greenColor : grayColor
//                                        print(backgroundColor)
//                                        destinationVC.isGoingButton.backgroundColor = backgroundColor
//                                        let buttonText = isUserGoing ? "Attending!" : "Not attending"
//                                        //destinationVC.isGoingButton.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
//                                        destinationVC.isGoingButton.setTitleColor(UIColor.white, for: .normal)
//
//                                        // Assuming you have a button instance called 'myButton'
//                                        destinationVC.isGoingButton.setTitle(buttonText, for: .normal)
//
//
//                                    }
//                                }
//                            }
//
//
//
//
//                            databaseRef = Database.database().reference().child("Parties").child(label.text ?? "")
//
//                            databaseRef?.observeSingleEvent(of: .value) { [weak self] (snapshot) in
//                                if let value = snapshot.value as? [String: Any] {
//
//                                    let key = snapshot.key
//                                    print("Party Key: \(key)")
//
//                                    if let likes = value["Likes"] as? Int,
//                                       let dislikes = value["Dislikes"] as? Int,
//                                       let allTimeLikes = value["allTimeLikes"] as? Double,
//                                       let allTimeDislikes = value["allTimeDislikes"] as? Double,
//                                       let address = value["Address"] as? String,
//                                       let rating = value["avgStars"] as? Double,
//                                       let isGoing = value["isGoing"] as? [String] {
//                                    let party = Party(name: key, likes: likes, dislikes: dislikes, allTimeLikes: allTimeLikes, allTimeDislikes: allTimeDislikes, address: address, rating: rating, isGoing: isGoing)
//                                        let widthMult = Double(party.isGoing.count) / Double(maxPeople)
//
//                                        destinationVC.party = party
//
//                                        //destinationVC.assignProfilePictures(commonFriends: self?.friendsGoing[party.name] ?? party.isGoing)
//
//                                        destinationVC.numPeople.text = String(party.isGoing.count) + " people attending"
//                                        destinationVC.rating = self?.ratingDict[party.name] ?? 0.0
//                                        //destinationVC.numPeople.textColor = UIColor.black
//                                        //destinationVC.numPeople.font = UIFont.systemFont(ofSize: 15.0)
//
//                                        destinationVC.commonFriends = self?.friendsGoing[party.name] ?? party.isGoing
//                                        //destinationVC.slider.widthAnchor.constraint(equalTo: destinationVC.bkgdSlider.widthAnchor, multiplier: widthMult).isActive = true
//
//
//
//                                    }
//                                }
//                            }
//
//                            destinationVC.titleText = (label.text?.lowercased())!
//                            destinationVC.likesLabel = likeDict[(label.text)!]!
//                            destinationVC.dislikesLabel = dislikeDict[(label.text)!]!
//                            destinationVC.addressLabel = addressDict[(label.text)!]!
//                        }
//
//                    }
//                }
        } else {
            updateDicts()
            
            if segue.identifier == "privatePopUpSegue" {
                    print("going into private popup")
                    let destinationVC = segue.destination as! privatePopUpViewController
                    if let cell = sender as? UITableViewCell {
                        if let label = cell.viewWithTag(11) as? UILabel {
                            let uid = Auth.auth().currentUser?.uid ?? ""
          
                            let partyRef = Database.database().reference().child("Privates").child(label.text ?? "")
                            var isUserGoing = false
                            partyRef.child("isGoing").observeSingleEvent(of: .value) { snapshot in
                                
                                //HERES THE PROBLEM- not going into fuck again party of code
                                print("segue before it goes in")
                                if snapshot.exists() {
                                    if let attendees = snapshot.value as? [String] {
                                        isUserGoing = attendees.contains(uid)
                                        print("is user going: \(isUserGoing)")
                                        destinationVC.userGoing = isUserGoing
                                        let pinkColor = UIColor(red: 215.0/255, green: 113.0/255, blue: 208.0/255, alpha: 0.5)
                                        let greenColor = UIColor(red: 0.0, green: 185.0/255, blue: 0.0, alpha: 1.0)
                                        
                                        let backgroundColor = isUserGoing ? greenColor : pinkColor
                                        print(backgroundColor)
                                        destinationVC.isGoingButton.backgroundColor = backgroundColor
                                        let buttonText = isUserGoing ? "I'm Going!" : "Not going"
                                        //destinationVC.isGoingButton.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
                                        destinationVC.isGoingButton.setTitleColor(UIColor.white, for: .normal)

                                        // Assuming you have a button instance called 'myButton'
                                        destinationVC.isGoingButton.setTitle(buttonText, for: .normal)
                                        destinationVC.isGoingButton.layer.cornerRadius = 8
                                    }
                                }
                            }

                            
                

                            databaseRef = Database.database().reference().child("Privates").child(label.text ?? "")
                            
                            databaseRef?.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                                if let value = snapshot.value as? [String: Any] {

                                    let key = snapshot.key
                                    print("Party Key: \(key)")
                                    
                                    if let datetime = value["dateTime"] as? Int,
                                       let location = value["location"] as? String,
                                       let creator = value["creator"] as? String,
                                       let description = value["description"] as? String,
                                       let event = value["event"] as? String,
                                       let invitees = value["invitees"] as? [String],
                                       let isGoing = value["isGoing"] as? [String] {
                                        let party = privateParty(id: key, creator: creator, datetime: datetime, description: description, event: event, invitees: invitees, location: location, isGoing: isGoing)
                                        destinationVC.party = party
                                        destinationVC.assignProfilePictures(commonFriends: party.isGoing)
                                        
                                        destinationVC.numPeople.text = String(party.isGoing.count) + " partygoers tonight"
                                        //destinationVC.numPeople.textColor = UIColor.black
                                        //destinationVC.numPeople.font = UIFont.systemFont(ofSize: 15.0)
                                        
                                        let timestamp: TimeInterval = TimeInterval(party.datetime) // Replace with your actual timestamp
                                        let date = Date(timeIntervalSince1970: timestamp)

                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "MMMM d" // Use 'MMMM d' for the date format like "June 6"

                                        let timeFormatter = DateFormatter()
                                        timeFormatter.dateFormat = "hh:mm a" // Use 'hh:mm a' for 12-hour format with AM/PM

                                        let formattedDate = dateFormatter.string(from: date)
                                        var formattedTime = timeFormatter.string(from: date)

                                        if formattedTime.hasPrefix("0") {
                                            formattedTime = String(formattedTime.dropFirst())
                                        }
                                        
                                        let usersCollection = Firestore.firestore().collection("users")
                                        let userUID = party.creator
                                        
                                        usersCollection.document(userUID).getDocument { snapshot, error in
                                            if let error = error {
                                                print("Error fetching user document: \(error)")
                                                return
                                            }
                                            
                                            guard let document = snapshot, document.exists else {
                                                print("User document does not exist")
                                                return
                                            }
                                            
                                            if let userName = document.data()?["name"] as? String {
                                                destinationVC.creatorLabel.text = userName
                                            } else {
                                                print("User name not found in the document")
                                            }
                                            
                                            if let profilePictureURL = document.data()?["profilePic"] as? String,
                                               let url = URL(string: profilePictureURL) {
                                                let imageView = UIImageView()
                                                imageView.kf.setImage(with: url)
                                                destinationVC.creatorProfilePic.image = imageView.image
                                            } else {
                                                print("Profile picture URL not found in the document")
                                            }
                                        }
                                        
                                        destinationVC.titleLabel.text = party.event
                                        destinationVC.locationLabel.text = "Location: " + party.location
                                        destinationVC.dateLabel.text = "Date: " + formattedDate
                                        destinationVC.timeLabel.text = "Time: " + formattedTime
                                        
                                        let descriptionText = "Description: " + party.description
                                        let attributedText = NSMutableAttributedString(string: descriptionText)

                                        let fontSize: CGFloat = 14.0 // The desired font size for party.description

                                        let range = (descriptionText as NSString).range(of: party.description)
                                        let font = UIFont.systemFont(ofSize: fontSize)

                                        attributedText.addAttribute(.font, value: font, range: range)

                                        destinationVC.descriptionLabel.attributedText = attributedText

                                    }
                                }
                            }
                        }
                        
                    }
                }
        }
    }
    
}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

extension AppHomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if publicOrPriv {
            if searchBar.text?.isEmpty ?? true {
                searching = false
                searchBar.resignFirstResponder()
                partyList.reloadData()
                return
            }
            searchParty = partyArray.filter({$0.lowercased().contains(searchText.lowercased())})
            searching = true
            partyList.reloadData()
        } else {
            if searchBar.text?.isEmpty ?? true {
                searching = false
                searchBar.resignFirstResponder()
                partyList.reloadData()
                return
            }
            searchParty = privatePartyArray.filter({$0.lowercased().contains(searchText.lowercased())})
            searching = true
            partyList.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        partyList.reloadData()
    }
}

extension AppHomeViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get the most recent location
        guard let userLocation = locations.last?.coordinate else { return }
        
        // Iterate through party addresses and check if user's location matches any address
        for (partyName, address) in addressDict {
            getLocation(from: address) { partyLocation in
                // Create CLLocation objects for user and party locations
                let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                let partyCLLocation = CLLocation(latitude: partyLocation.latitude, longitude: partyLocation.longitude)
                
                // Calculate distance between user and party
                let distance = userCLLocation.distance(from: partyCLLocation)
                
                // Assuming that the party location is within a certain radius of the user's location (adjust this threshold as needed)
                let thresholdDistance: CLLocationDistance = 100 // 1000 meters
                if distance <= thresholdDistance {
                    // The user is near the party at the given address
                    print("User is near party:", partyName)
                    
                    // Add the user's UID to the party's isGoing array
                    if let currentUserUID = Auth.auth().currentUser?.uid {
                        let partyRef = self.databaseRef?.child(partyName)
                        
                        partyRef?.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                            if var partyDetails = snapshot.value as? [String: Any], var isGoing = partyDetails["isGoing"] as? [String] {
                                if !isGoing.contains(currentUserUID) {
                                    isGoing.append(currentUserUID)
                                    partyDetails["isGoing"] = isGoing
                                    
                                    // Update the party's isGoing array in the Realtime Database
                                    partyRef?.setValue(partyDetails) { error, _ in
                                        if let error = error {
                                            print("Error updating party's isGoing array:", error.localizedDescription)
                                        } else {
                                            print("User added to party's isGoing array.")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getLocation(from address: String, completion: @escaping (CLLocationCoordinate2D) -> Void) {
        // Convert address to coordinates using geocoding
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                let partyLocation = location.coordinate
                completion(partyLocation)
            }
        }
    }
}
