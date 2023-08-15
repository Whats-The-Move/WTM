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
    var selectedIndexPaths: [IndexPath] = []
    var selectedUsers: [User] = []
    var didSelectUsers: (([User]) -> Void)?


    var friends: [User] = []
    var searching = false
    var searchFriends: [User] = []
    weak var createEventViewController: CreateEventViewController?

    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleText.textColor = .white
        titleText.text = "Invite"
        searchBar.delegate = self
        searchBar.overrideUserInterfaceStyle = .dark
        inviteListTableView.register(addFriendCustomCellClass.self, forCellReuseIdentifier: "friendCell")
        inviteListTableView.overrideUserInterfaceStyle = .dark
        inviteListTableView.delegate = self
        inviteListTableView.dataSource = self

        db = Firestore.firestore()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        //view.addGestureRecognizer(tapGesture)

        fetchFriends()
    }

    @IBAction func doneButton(_ sender: Any) {
        didSelectUsers?(selectedUsers)
        dismiss(animated: true, completion: nil)
    }
    @objc func dismissViewController(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)

        if !inviteListTableView.frame.contains(location) {
            self.dismiss(animated: true, completion: nil)
        }
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

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = searching ? searchFriends[indexPath.row] : friends[indexPath.row]
        
        if selectedUsers.contains(where: { $0.uid == selectedUser.uid }) {
            // Deselect the cell and remove the selectedUser from the array
            if let index = selectedUsers.firstIndex(where: { $0.uid == selectedUser.uid }) {
                selectedUsers.remove(at: index)
            }
        } else {
            // Select the cell and add the selectedUser to the array
            selectedUsers.append(selectedUser)
        }
        
        tableView.reloadData()
        
        print("Selected User UID: \(selectedUser.uid)")
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! addFriendCustomCellClass

        let user = searching ? searchFriends[indexPath.row] : friends[indexPath.row]
        cell.configure(with: user, hasDeleteButton: false)
        
        if selectedUsers.contains(where: { $0.uid == user.uid }) {
            cell.backgroundColor = .systemPink
        } else {
            cell.backgroundColor = .clear
        }

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
