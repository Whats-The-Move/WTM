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

        var friends: [User] = []
        var searching = false
        var searchFriends: [User] = []

        var db: Firestore!
        
        override func viewDidLoad() {
            super.viewDidLoad()

            titleText.textColor = .white
            titleText.text = "Friends"
            searchBar.delegate = self
            searchBar.overrideUserInterfaceStyle = .dark
            inviteListTableView.register(addFriendCustomCellClass.self, forCellReuseIdentifier: "friendCell")
            inviteListTableView.overrideUserInterfaceStyle = .dark
            inviteListTableView.delegate = self
            inviteListTableView.dataSource = self

            db = Firestore.firestore()

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
            view.addGestureRecognizer(tapGesture)

            fetchFriends()
        }

        @objc func dismissViewController() {
            self.dismiss(animated: true, completion: nil)
        }

        func fetchFriends() {
            guard let currentUserUID = Auth.auth().currentUser?.uid else {
                print("Error: No user is currently signed in.")
                return
            }
            
            let userRef = Firestore.firestore().collection("users").document(currentUserUID)
            
            userRef.getDocument { [weak self] (document, error) in
                if let error = error {
                    print("Error fetching user document: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, document.exists {
                    if let friends = document.data()?["friends"] as? [String] {
                        self?.fetchFriendDetails(friendUIDs: friends)
                    } else {
                        print("No friends found.")
                    }
                }
            }
        }
        
        func fetchFriendDetails(friendUIDs: [String]) {
            let dispatchGroup = DispatchGroup()
            
            for friendUID in friendUIDs {
                dispatchGroup.enter()
                
                let friendRef = Firestore.firestore().collection("users").document(friendUID)
                
                friendRef.getDocument { [weak self] (friendDocument, friendError) in
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    if let friendError = friendError {
                        print("Error fetching friend document: \(friendError.localizedDescription)")
                        return
                    }
                    
                    if let friendDocument = friendDocument, friendDocument.exists,
                       let friendData = friendDocument.data(),
                       let email = friendData["email"] as? String,
                       let name = friendData["name"] as? String,
                       let username = friendData["username"] as? String,
                       let profilePic = friendData["profilePic"] as? String {
                        let user = User(uid: friendUID, email: email, name: name, username: username, profilePic: profilePic)
                        self?.friends.append(user)
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                self?.inviteListTableView.reloadData()
            }
        }

    }

    extension InviteListViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return searching ? searchFriends.count : friends.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! addFriendCustomCellClass

            let user = searching ? searchFriends[indexPath.row] : friends[indexPath.row]
            cell.configure(with: user)

            return cell
        }
    }

    extension InviteListViewController: UISearchBarDelegate {
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                searching = false
            } else {
                searchFriends = friends.filter { $0.name.lowercased().contains(searchText.lowercased()) }
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
