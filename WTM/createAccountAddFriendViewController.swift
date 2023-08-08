//
//  createAccountAddFriendViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 8/7/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

class createAccountAddFriendViewController: UIViewController, UITableViewDelegate {
    var users: [User] = []
    var allUsers: [User] = []
    var searching = false
    var searchUser: [User] = []
    var pendingFriends: [String] = []
    var friends: [String] = []
    var db: Firestore!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var userList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()
        searchBar.delegate = self
        userList.delegate = self
        userList.dataSource = self
        userList.overrideUserInterfaceStyle = .dark
        userList.register(requestUserCellClass.self, forCellReuseIdentifier: "UserCell")
        searchBar.overrideUserInterfaceStyle = .dark
        
        // Set up Firestore
        db = Firestore.firestore()
        
        fetchUsers()
    }
    
    func fetchUsers() {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")

        usersCollection.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error getting users: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                return
            }

            let allUsers = snapshot.documents.compactMap { document -> User? in
                let data = document.data()
                let uid = document.documentID
                let email = data["email"] as? String
                let name = data["name"] as? String
                let username = data["username"] as? String
                let profilePic = data["profilePic"] as? String
                return User(uid: uid, email: email ?? "N/A", name: name ?? "N/A", username: username ?? "N/A", profilePic: profilePic ?? "")
            }

            // Filter out users who are in pendingFriendRequests or friends array
            let myUid = Auth.auth().currentUser?.uid
            self.allUsers = allUsers.filter { user in
                !self.pendingFriends.contains(user.uid) && !self.friends.contains(user.uid) && user.uid != myUid && user.username != "N/A"
            }

            self.users = self.allUsers
            self.userList.reloadData()
        }
    }
    
    @IBAction func nextButtonPushed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appHomeVC = storyboard.instantiateViewController(identifier: "AppHome")
        appHomeVC.modalPresentationStyle = .overFullScreen
        self.present(appHomeVC, animated: true)
    }
    
}

extension createAccountAddFriendViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? searchUser.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! requestUserCellClass
        
        let user = searching ? searchUser[indexPath.row] : users[indexPath.row]
        cell.configure(with: user)
        return cell
    }
}

extension createAccountAddFriendViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searching = false
            userList.reloadData()
            searchBar.resignFirstResponder() // Dismiss the keyboard
            return
        }

        searchUser = allUsers.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        searching = true
        userList.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        userList.reloadData()
    }
}
