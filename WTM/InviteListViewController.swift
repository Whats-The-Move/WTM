//
//  InviteListViewController.swift
//  WTM
//
//  Created by Aman Shah on 6/13/23.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth
import Kingfisher


class InviteListViewController: UIViewController, UITableViewDelegate{

    @IBOutlet weak var inviteListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleText: UILabel!
    
    var selectedParty: Party?

    var partyID = ""

    var friendsGoing: [User] = []
    var searching = false
    var searchFriend: [User] = []

    var db: Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        partyID = selectedParty?.name ?? ""
        print(partyID)

        titleText.textColor = .white
        titleText.text = partyID
        searchBar.delegate = self
        searchBar.overrideUserInterfaceStyle = .dark
        inviteListTableView.register(addFriendCustomCellClass.self, forCellReuseIdentifier: "friendCell")
        inviteListTableView.overrideUserInterfaceStyle = .dark
        inviteListTableView.delegate = self
        inviteListTableView.dataSource = self

        db = Firestore.firestore()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        view.addGestureRecognizer(tapGesture)

        fetchFriendsGoing()
    }
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }

    func fetchFriendsGoing() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            return
        }
        
        let partyRef = Database.database().reference().child("Parties").child(partyID)
        
        partyRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard snapshot.exists() else {
                print("No party found.")
                return
            }
            
            guard let partyDict = snapshot.value as? [String: Any],
                  let isGoing = partyDict["isGoing"] as? [String] else {
                print("Error: Invalid party data.")
                return
            }
            
            let userRef = Firestore.firestore().collection("users").document(currentUserUID)
            
            userRef.getDocument { [weak self] (document, error) in
                if let error = error {
                    print("Error fetching user document: \(error.localizedDescription)")
                    return
                }
                
                guard let document = document, document.exists,
                      let friendList = document.data()?["friends"] as? [String] else {
                    print("Error: No friends list found.")
                    return
                }
                
                let commonFriendsUIDs = friendList.filter { isGoing.contains($0) }
                
                let dispatchGroup = DispatchGroup()
                var commonFriends: [User] = []
                
                for friendUID in commonFriendsUIDs {
                    dispatchGroup.enter()
                    
                    let friendRef = Firestore.firestore().collection("users").document(friendUID)
                    
                    friendRef.getDocument { (friendDocument, friendError) in
                        defer {
                            dispatchGroup.leave()
                        }
                        
                        if let friendError = friendError {
                            print("Error fetching friend document: \(friendError.localizedDescription)")
                            return
                        }
                        
                        guard let friendDocument = friendDocument, friendDocument.exists,
                              let friendData = friendDocument.data(),
                              let email = friendData["email"] as? String,
                              let name = friendData["name"] as? String,
                              let username = friendData["username"] as? String,
                              let profilePic = friendData["profilePic"] as? String else {
                            return
                        }
                        
                        let user = User(uid: friendUID, email: email, name: name, username: username, profilePic: profilePic)
                        commonFriends.append(user)
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self?.friendsGoing = commonFriends
                    self?.inviteListTableView.reloadData()
                }
            }
        }
    }

    func checkFriendshipStatus(isGoing: [String], completion: @escaping ([User]) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            completion([])
            return
        }
        
        let userCollectionRef = Firestore.firestore().collection("users")
        let currentUserRef = userCollectionRef.document(currentUserUID)
        
        currentUserRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let document = document, document.exists,
                  let friendList = document.data()?["friends"] as? [String] else {
                print("Error: No friends list found.")
                completion([])
                return
            }
            
            let commonFriendsUIDs = friendList.filter { isGoing.contains($0) }
            let uniqueFriendIDs = Set(commonFriendsUIDs)
            
            let dispatchGroup = DispatchGroup()
            var commonFriends: [User] = []
            
            for friendUID in uniqueFriendIDs {
                dispatchGroup.enter()
                
                let friendRef = userCollectionRef.document(friendUID)
                
                friendRef.getDocument { (friendDocument, friendError) in
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    if let friendError = friendError {
                        print("Error fetching friend document: \(friendError.localizedDescription)")
                        return
                    }
                    
                    guard let friendDocument = friendDocument, friendDocument.exists,
                          let friendData = friendDocument.data(),
                          let email = friendData["email"] as? String,
                          let name = friendData["name"] as? String,
                          let username = friendData["username"] as? String,
                          let profilePic = friendData["profilePic"] as? String else {
                        return
                    }
                    
                    let user = User(uid: friendUID, email: email, name: name, username: username, profilePic: profilePic)
                    commonFriends.append(user)
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(commonFriends)
            }
        }
    }

}

extension InviteListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? searchFriend.count : friendsGoing.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! addFriendCustomCellClass

        let user = searching ? searchFriend[indexPath.row] : friendsGoing[indexPath.row]
        cell.configure(with: user)

        return cell
    }
}

extension InviteListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searching = false
        } else {
            searchFriend = friendsGoing.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            searching = true
        }

        inviteListTableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()

        searching = false
        inviteListTableView.reloadData()
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


