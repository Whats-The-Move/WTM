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


class AppHomeViewController: UIViewController, UITableViewDelegate, CustomCellDelegate {
    
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
    
    var rank = 0
    var timer: Timer?

    @IBOutlet weak var partyList: UITableView! {
        didSet {
            partyList.dataSource = self
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gifImage: UIImageView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var helloWorld: UILabel!
    @IBOutlet weak var Profile: UILabel!
    var partyArray = [String]()
    var searching = false
    var searchParty = [String]()
    
    var databaseRef: DatabaseReference?
    var userDatabaseRef: DatabaseReference?
    public var parties = [Party]()
    public var likeDict = [String : Int]()
    public var dislikeDict = [String : Int]()
    public var overallLikeDict = [String : Double]()
    public var overallDislikeDict = [String : Double]()
    public var addressDict = [String : String]()
    public var userVotes = [String : Int]()
    public var rankDict = [String : Int]()
    public var ratingDict = [String : Double]()
    public var countNum = 34

    override func viewDidLoad() {
        super.viewDidLoad()
        helloWorld.isHidden = false
        helloWorld.text = ""
        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data(), let username = data["username"] as? String {
                        // Access the username value
                        
                        self.helloWorld.text = "Hey " + username + "!"
                    }
                }
                
            }
        }

        partyList.delegate = self

        partyList.rowHeight = 100.0 // Adjust this value as needed
        //partyList.rowHeight = UITableView.automaticDimension

        let user_address1 = UserDefaults.standard.string(forKey: "user_address") ?? "user"
        refreshButton.layer.cornerRadius = 4
        logoutButton.layer.cornerRadius = 4        
        for recognizer in view.gestureRecognizers ?? [] {
            if let swipeRecognizer = recognizer as? UISwipeGestureRecognizer, swipeRecognizer.direction == .down {
                view.removeGestureRecognizer(swipeRecognizer)
            }
        }
        
        gifImage.loadGif(name: "finalillini")
        gifImage.contentMode = .scaleAspectFit
        partyList.overrideUserInterfaceStyle = .dark
        searchBar.overrideUserInterfaceStyle = .dark
        refreshButton.overrideUserInterfaceStyle = .light
        logoutButton.overrideUserInterfaceStyle = .light
        
        partyList.reloadData()
        
        databaseRef = Database.database().reference().child("Parties")
        databaseRef?.queryOrdered(byChild: "Likes").observe(.childAdded) { [weak self] (snapshot) in
            let key = snapshot.key
            guard let value = snapshot.value as? [String : Any] else {return}
            if let likes = value["Likes"] as? Int,
                let dislikes = value["Dislikes"] as? Int,
                let allTimeLikes = value["allTimeLikes"] as? Double,
                let allTimeDislikes = value["allTimeDislikes"] as? Double,
                let address = value["Address"] as? String,
                let rating = value["avgStars"] as? Double,
                let isGoing = value["isGoing"] as? [String] {
                let party = Party(name: key, likes: likes, dislikes: dislikes, allTimeLikes: allTimeLikes, allTimeDislikes: allTimeDislikes, address: address, rating: rating, isGoing : isGoing)
                self?.parties.insert(party, at: 0)
                self?.likeDict[party.name] = party.likes
                self?.dislikeDict[party.name] = party.dislikes
                self?.overallLikeDict[party.name] = party.allTimeLikes
                self?.overallDislikeDict[party.name] = party.allTimeDislikes
                self?.addressDict[party.name] = party.address
                self?.rankDict[party.name] = self?.countNum
                self?.partyArray.insert(party.name, at: 0)
                self?.ratingDict[party.name] = party.rating
                if let row = self?.parties.count {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self?.partyList.insertRows(at: [indexPath], with: .automatic)
                    self?.countNum -= 1
                    //if((self?.parties.count)! <= 58){
                      //  self?.partyList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    //} else {
                    /*
                        self?.partyList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            self?.scrollToTop()
                            print("scrolled to top")
                     
                        }
                     */
                    //}
                }
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        partyList.reloadData()
        super.viewWillAppear(animated)
        
    }
        /*
        databaseRef = Database.database().reference().child("Parties")
        databaseRef?.queryOrdered(byChild: "Likes").observe(.childAdded) { [weak self] (snapshot) in
            let key = snapshot.key
            guard let value = snapshot.value as? [String : Any] else {return}
            if let likes = value["Likes"] as? Int, let dislikes = value["Dislikes"] as? Int, let allTimeLikes = value["allTimeLikes"] as? Double, let allTimeDislikes = value["allTimeDislikes"] as? Double, let address = value["Address"] as? String {
                let party = Party(name: key, likes: likes, dislikes: dislikes, allTimeLikes: allTimeLikes, allTimeDislikes: allTimeDislikes, address: address)
                self?.parties.append(party)
                self?.likeDict[party.name] = party.likes
                self?.dislikeDict[party.name] = party.dislikes
                self?.overallLikeDict[party.name] = party.allTimeLikes
                self?.overallDislikeDict[party.name] = party.allTimeDislikes
                self?.addressDict[party.name] = party.address
                self?.partyArray.append(party.name)
                if let row = self?.parties.count {
                    let indexPath = IndexPath(row: row - 1, section: 0)
                    self?.partyList.insertRows(at: [indexPath], with: .automatic)
                    //if((self?.parties.count)! <= 58){
                      //  self?.partyList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    //} else {
                        self?.partyList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            self?.scrollToTop()
                            print("scrolled to top")
                        }
                    //}
                }
            }
        }
        partyList.reloadData()
         
    }*/
   
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "AppHome") as! AppHomeViewController
        newViewController.modalPresentationStyle = .fullScreen
        present(newViewController, animated: false, completion: nil)
        */
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let TabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        TabBarController.overrideUserInterfaceStyle = .dark
        TabBarController.modalPresentationStyle = .fullScreen
        present(TabBarController, animated: false, completion: nil)
        
    }
    

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
    func buttonClicked(for party: Party) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let partyRef = Database.database().reference().child("Parties").child(party.name)
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
                        incrementSpotCount(partyName: party.name)

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
    let TabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
    TabBarController.overrideUserInterfaceStyle = .dark
    TabBarController.modalPresentationStyle = .fullScreen
    present(TabBarController, animated: false, completion: nil)
    }

    
    
    
    func updateDicts() {
        
        databaseRef = Database.database().reference().child("Parties")
        databaseRef?.observe(.childAdded){ [weak self] (snapshot) in
            let key = snapshot.key
            guard let value = snapshot.value as? [String : Any] else {return}
            if let likes = value["Likes"] as? Int, let dislikes = value["Dislikes"] as? Int, let allTimeLikes = value["allTimeLikes"] as? Double, let allTimeDislikes = value["allTimeDislikes"] as? Double, let address = value["Address"] as? String, let rating = value["avgStars"] as? Double, let isGoing = value["isGoing"] as? [String] {
                let party = Party(name: key, likes: likes, dislikes: dislikes, allTimeLikes: allTimeLikes, allTimeDislikes: allTimeDislikes, address: address, rating: rating, isGoing: isGoing)
                    self?.likeDict[party.name] = party.likes
                    self?.dislikeDict[party.name] = party.dislikes
                    self?.overallLikeDict[party.name] = party.allTimeLikes
                    self?.overallDislikeDict[party.name] = party.allTimeDislikes
                    self?.addressDict[party.name] = party.address
                    self?.ratingDict[party.name] = party.rating
            }
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








extension AppHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchParty.count
        }
        return parties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "partyCell", for: indexPath) as! CustomCellClass

        cell.delegate = self // Set the view controller as the delegate for the cell
        
        let party: Party
        if searching {
            party = parties.first { $0.name == searchParty[indexPath.row] }!
        } else {
            party = parties[indexPath.row]
        }
        
        cell.configure(with: party, rankDict: rankDict)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedParty = parties[indexPath.row]
        performSegue(withIdentifier: "popupSegue", sender: selectedParty)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateDicts()
        let date = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        var newDate : NSDate?
        cal.range(of: .day, start: &newDate, interval: nil, for: date as Date)

        
        if segue.identifier == "popupSegue" {
                print("going into popup")
                let destinationVC = segue.destination as! popUpViewController
                if let cell = sender as? UITableViewCell {
                    if let label = cell.viewWithTag(1) as? UILabel {
                        let uid = Auth.auth().currentUser?.uid ?? ""
      
                        let partyRef = Database.database().reference().child("Parties").child(label.text ?? "")
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
                                    destinationVC.isGoingButton.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
                                    destinationVC.isGoingButton.setTitleColor(UIColor.white, for: .normal)

                                    // Assuming you have a button instance called 'myButton'
                                    destinationVC.isGoingButton.setTitle(buttonText, for: .normal)
                                    destinationVC.isGoingButton.layer.cornerRadius = 8
                                }
                            }
                        }

                        
            

                        databaseRef = Database.database().reference().child("Parties").child(label.text ?? "")
                        
                        databaseRef?.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                            if let value = snapshot.value as? [String: Any] {

                                let key = snapshot.key
                                print("Party Key: \(key)")
                                
                                if let likes = value["Likes"] as? Int,
                                   let dislikes = value["Dislikes"] as? Int,
                                   let allTimeLikes = value["allTimeLikes"] as? Double,
                                   let allTimeDislikes = value["allTimeDislikes"] as? Double,
                                   let address = value["Address"] as? String,
                                   let rating = value["avgStars"] as? Double,
                                   let isGoing = value["isGoing"] as? [String] {
                                let party = Party(name: key, likes: likes, dislikes: dislikes, allTimeLikes: allTimeLikes, allTimeDislikes: allTimeDislikes, address: address, rating: rating, isGoing: isGoing)
                                    destinationVC.party = party
                                    destinationVC.assignProfilePictures(commonFriends: party.isGoing)
                                    
                                    destinationVC.numPeople.text = String(party.isGoing.count) + " people attending total"
                                    destinationVC.numPeople.textColor = UIColor.black
                                    destinationVC.numPeople.font = UIFont.systemFont(ofSize: 15.0)

                               
                                }
                            }
                        }
                        
                        destinationVC.titleText = (label.text)!
                        destinationVC.likesLabel = likeDict[(label.text)!]!
                        destinationVC.dislikesLabel = dislikeDict[(label.text)!]!
                        destinationVC.addressLabel = addressDict[(label.text)!]!
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
        if searchBar.text?.isEmpty ?? true {
            searching = false
            searchBar.resignFirstResponder()
            partyList.reloadData()
            return
        }
        searchParty = partyArray.filter({$0.lowercased().contains(searchText.lowercased())})
        searching = true
        partyList.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        partyList.reloadData()
    }
}
