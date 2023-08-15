//
//  allFriendsPopUpViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 6/7/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

class allFriendsPopUpViewController: UIViewController, UITableViewDelegate, AddFriendCellDelegate {
    func showAlertForDeletion(from cell: UITableViewCell) {
        let alert = UIAlertController(title: "Confirm Deletion",
                                      message: "Are you sure you want to remove \(deleteUsername) from your friends?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            // Handle deletion here
            self.deleteFriendAction()
            print("Friend deleted")
            self.dismiss(animated: true) {
                // Dismissal completion block
                self.presentingViewController?.dismiss(animated: false, completion: nil)

            }

            //doesn't work, need to reload the whole page

            //self.friendsTableView.reloadData()
            

            /*
            guard let indexPath = self.friendsTableView.indexPath(for: cell) else {
                return
            }
            //BAZIGLY NUMBER OF ROWS IS GETTING THROWN OFF- NEED TO SOMEHOW JUST RELOAD TABLE DATA MAYBE
            
            self.friendsTableView.beginUpdates()
            self.friendsTableView.deleteRows(at: [indexPath], with: .fade)
            self.friendsTableView.endUpdates()*/
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
    


    
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var friends: [User] = []
    var searching = false
    var searchFriend: [User] = []
    
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleText.textColor = .white
        searchBar.delegate = self
        friendsTableView.register(addFriendCustomCellClass.self, forCellReuseIdentifier: "friendCell")
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.overrideUserInterfaceStyle = .dark
        searchBar.overrideUserInterfaceStyle = .dark
        
        db = Firestore.firestore()
        
        fetchFriends()
    }
    
    func fetchFriends() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("users").document(uid).getDocument { [weak self] (snapshot, error) in
            guard let self = self, let snapshot = snapshot else {
                // Handle error or nil self
                return
            }
            
            if let data = snapshot.data(), let friends = data["friends"] as? [String] {
                self.friends = []
                
                let dispatchGroup = DispatchGroup()
                
                for friendUid in friends {
                    dispatchGroup.enter()
                    
                    self.db.collection("users").document(friendUid).getDocument { (friendSnapshot, error) in
                        defer {
                            dispatchGroup.leave()
                        }
                        
                        if let friendData = friendSnapshot?.data(),
                           let uid = friendSnapshot?.documentID,
                           let email = friendData["email"] as? String,
                           let name = friendData["name"] as? String,
                           let username = friendData["username"] as? String,
                           let profilePic = friendData["profilePic"] as? String {
                            let user = User(uid: uid, email: email, name: name, username: username, profilePic: profilePic)
                            
                            self.friends.append(user)
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.friendsTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    func deleteFriendAction (){

        let currentUsername = deleteUsername
        
        // Get a reference to the Firestore database
        let db = Firestore.firestore()
        
        // Find the user with the given username
        db.collection("users").whereField("username", isEqualTo: currentUsername).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting user documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No user found with the given username.")
                return
            }
            let userDocument = documents.first
            let uid = userDocument?.documentID

            if let currentUserUID = Auth.auth().currentUser?.uid {

                let currentUserDocRef = db.collection("users").document(currentUserUID)

                // Remove the UID from the current user's friends field
                currentUserDocRef.updateData(["friends": FieldValue.arrayRemove([uid])]) { error in
                    if let error = error {
                        print("Error removing friend from current user's friends: \(error)")
                    } else {
                        print("Friend removed successfully.")
                    }
                }
            } else {
                print("Unable to remove friend. Either user document not found or current user not authenticated.")
            }

        }
    }
}

extension allFriendsPopUpViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? searchFriend.count : friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! addFriendCustomCellClass
        cell.delegate = self

        let user = searching ? searchFriend[indexPath.row] : friends[indexPath.row]
        cell.configure(with: user, hasDeleteButton: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userSelectedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userSelectedViewController") as! UserSelectedViewController

        let user = searching ? searchFriend[indexPath.row] : friends[indexPath.row]
        userSelectedVC.uid = user.uid // Set the uid of the selected friend in the UserSelectedViewController
        
        present(userSelectedVC, animated: true, completion: nil)
    }
}

extension allFriendsPopUpViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searching = false
        } else {
            searchFriend = friends.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            searching = true
        }
        
        friendsTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        searching = false
        friendsTableView.reloadData()
    }
}
