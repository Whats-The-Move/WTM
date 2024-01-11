import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

class activityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var titleLabel: UILabel!
    var tableView: UITableView!
    var invites: [String: [(String, String)]] = [:]
    var userNames: [String: (String, String)] = [:]
    var eventsDatabaseRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTitleLabel()
        setupTableView()
        fetchInvitesFromFirestore()
        fetchUserNamesFromFirestore()
        setupFirebaseDatabase()
    }

    func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = "Invites"
        titleLabel.font = UIFont(name: "Futura-Medium", size: 24)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Set up constraints for the titleLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Set up constraints for the tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Set the delegate and data source for the table view
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(InviteCellClass.self, forCellReuseIdentifier: "InviteCell")
    }

    func setupFirebaseDatabase() {
        let eventsPath = "\(currCity)Events"
        eventsDatabaseRef = Database.database().reference().child(eventsPath)
        
        eventsDatabaseRef.observe(.childAdded) { [weak self] (snapshot) in
            guard let self = self else { return }

            // Handle the child added event, update your data source, and reload the table view
            self.fetchInvitesFromFirestore()
            self.tableView.reloadData()
        }
    }

    func fetchInvitesFromFirestore() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(currentUserUID)

        userDocRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let document = document, document.exists {
                if let invitesDict = document.data()?["invites"] as? [String: [String]] {
                    var updatedInvites: [String: [(String, String)]] = [:]

                    for (inviterUID, partyIDs) in invitesDict {
                        var inviterInvites: [(String, String)] = []

                        for partyID in partyIDs {
                            let inviteKey = inviterUID
                            inviterInvites.append((partyID, inviteKey))
                        }

                        updatedInvites[inviterUID] = inviterInvites
                    }

                    self.invites = updatedInvites
                    self.tableView.reloadData()
                    print("Invites: \(self.invites)") // Add this line for debugging
                }
            } else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }


    // Inside the fetchUserNamesFromFirestore function
    func fetchUserNamesFromFirestore() {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")

        usersCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching user names: \(error.localizedDescription)")
                return
            }

            for document in querySnapshot!.documents {
                let userID = document.documentID
                let userName = document["name"] as? String ?? ""
                let profileURL = document["profilePic"] as? String ?? ""
                self.userNames[userID] = (userName, profileURL)
            }
            self.tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return invites.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let inviterUIDs = Array(invites.keys)
        
        // Check if the section index is valid
        guard section < inviterUIDs.count else {
            return 0
        }

        let inviterUID = inviterUIDs[section]
        return invites[inviterUID]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "InviteCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InviteCellClass

        let inviterUIDs = Array(invites.keys)

        // Check if the section and row indices are valid
        guard indexPath.section < inviterUIDs.count else {
            return cell
        }

        let inviterUID = inviterUIDs[indexPath.section]

        if let partyIDInfoArray = invites[inviterUID], indexPath.row < partyIDInfoArray.count {
            let partyIDInfo = partyIDInfoArray[indexPath.row]
            let partyID = partyIDInfo.0
            let inviteKey = partyIDInfo.1

            // Configure the cell using partyID and inviteKey
            cell.inviteValue = partyID
            cell.inviteKey = inviteKey
            cell.eventsDatabaseRef = eventsDatabaseRef

            if let userInfo = userNames[inviterUID] {
                let (inviterName, profileURL) = userInfo
                fetchEventName(for: partyID) { (eventName, venueName) in
                    DispatchQueue.main.async {
                        cell.configure(with: inviterName, profileImageURL: profileURL, eventName: eventName, venueName: venueName)
                    }
                }
            } else {
                cell.configure(with: "Unknown user", profileImageURL: "URL_TO_DEFAULT_PROFILE_PIC", eventName: partyID ?? "Unknown Event", venueName: "Unknown Venue")
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // Adjust the value based on your preference
    }

    func fetchEventName(for partyID: String, completion: @escaping (String, String) -> Void) {
        eventsDatabaseRef.observeSingleEvent(of: .value) { (snapshot) in
            // Iterate through all dates
            for dateSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                let date = dateSnapshot.key

                // Check if partyID exists in the current date
                if dateSnapshot.hasChild(partyID) {
                    // Fetch the event name
                    let eventName = dateSnapshot.childSnapshot(forPath: partyID).childSnapshot(forPath: "name").value as? String ?? "Unknown Event"
                    let venueName = dateSnapshot.childSnapshot(forPath: partyID).childSnapshot(forPath: "venueName").value as? String ?? currCity
                    completion(eventName, venueName)
                    return
                }
            }

            // If partyID is not found in any date, return a default value
            completion("Unknown Event", currCity)
        }
    }
}
