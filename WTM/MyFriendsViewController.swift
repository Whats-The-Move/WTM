import UIKit
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

struct User {
    let uid: String
    let email: String
    let name: String
    let username: String
    let profilePic: String
}

class MyFriendsViewController: UIViewController, UITableViewDelegate {
    var users: [User] = []
    var allUsers: [User] = []
    var searching = false
    var searchUser: [User] = []
    var pendingFriends: [String] = []
    var friends: [String] = []
    var db: Firestore!

    @IBOutlet weak var pendingFriendList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var userList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        pendingFriendList.delegate = self
        pendingFriendList.dataSource = self
        pendingFriendList.overrideUserInterfaceStyle = .dark
        pendingFriendList.register(FriendRequestCellClass.self, forCellReuseIdentifier: "pendingCell")
        searchBar.delegate = self
        userList.delegate = self
        userList.dataSource = self
        userList.overrideUserInterfaceStyle = .dark
        userList.register(addFriendCustomCellClass.self, forCellReuseIdentifier: "UserCell")
        searchBar.overrideUserInterfaceStyle = .dark
        
        // Set up Firestore
        db = Firestore.firestore()
        
        fetchPendingFriends()
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
    
    func fetchPendingFriends() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("users").document(uid).getDocument { [weak self] (snapshot, error) in
            guard let self = self, let snapshot = snapshot else {
                // Handle error or nil self
                return
            }
            
            if let data = snapshot.data(), let friends = data["friends"] as? [String] {
                self.friends = friends
            }
            
            if let data = snapshot.data(), let pendingFriends = data["pendingFriendRequests"] as? [String] {
                // Update the pendingFriends array
                self.pendingFriends = pendingFriends
                
                self.fetchUsers()
                
                // Reload the table view
                self.pendingFriendList.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == userList{
            print("Row selected at index: \(indexPath.row)")
            let selectedCell = userList.cellForRow(at: indexPath)
            performSegue(withIdentifier: "friendPopUpSegue", sender: selectedCell)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendPopUpSegue" {
            let destinationVC = segue.destination as! friendPopUpViewController
            if let cell = sender as? addFriendCustomCellClass {
                let titleText = cell.nameLabel.text ?? "error"
                print("Title text to be passed: \(titleText)")
                destinationVC.titleText = titleText
            }
        }
    }

    @IBAction func backButtonPushed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MyFriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == userList{
            return searching ? searchUser.count : users.count
        } else {
            return pendingFriends.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == userList{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! addFriendCustomCellClass
            
            let user = searching ? searchUser[indexPath.row] : users[indexPath.row]
            cell.configure(with: user)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pendingCell", for: indexPath) as! FriendRequestCellClass
            
            let friendUID = pendingFriends[indexPath.row]
            
            // Fetch friend's email from Firestore
            db.collection("users").document(friendUID).getDocument { (snapshot, error) in
                if let error = error {
                    // Handle the error
                    print("Error fetching friend's email: \(error.localizedDescription)")
                    return
                }
                
                if let data = snapshot?.data(), let friendEmail = data["email"] as? String {
                    // Configure the cell with the friend's email
                    cell.configure(with: friendEmail, index: indexPath.row)
                    cell.delegate = self
                }
            }
            
            return cell
        }
    }
}

extension MyFriendsViewController: UISearchBarDelegate {
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

extension MyFriendsViewController: FriendRequestCellDelegate {
    func didTapAcceptButton(at index: Int) {
        let friendUID = pendingFriends[index]
        let currentUserUID = Auth.auth().currentUser?.uid ?? ""
        
        // Update the current user's "friends" array
        db.collection("users").document(currentUserUID).updateData([
            "friends": FieldValue.arrayUnion([friendUID])
        ]) { [weak self] error in
            if let error = error {
                // Handle the error
                print("Error accepting friend request: \(error.localizedDescription)")
                return
            }
            
            // Remove the friendUID from the current user's "pendingFriendRequests" array
            self?.db.collection("users").document(currentUserUID).updateData([
                "pendingFriendRequests": FieldValue.arrayRemove([friendUID])
            ]) { [weak self] error in
                if let error = error {
                    // Handle the error
                    print("Error removing friend request from pending: \(error.localizedDescription)")
                    return
                }
                
                // Remove the friendUID from the local pendingFriends array
                self?.pendingFriends.remove(at: index)
                
                // Reload the table view
                self?.pendingFriendList.reloadData()
            }
        }
    }
    
    func didTapDenyButton(at index: Int) {
        let friendUID = pendingFriends[index]
        let currentUserUID = Auth.auth().currentUser?.uid ?? ""
        
        // Remove the friendUID from the current user's "pendingFriendRequests" array
        db.collection("users").document(currentUserUID).updateData([
            "pendingFriendRequests": FieldValue.arrayRemove([friendUID])
        ]) { [weak self] error in
            if let error = error {
                // Handle the error
                print("Error removing friend request from pending: \(error.localizedDescription)")
                return
            }
            
            // Remove the friendUID from the local pendingFriends array
            self?.pendingFriends.remove(at: index)
            
            // Reload the table view
            self?.pendingFriendList.reloadData()
        }
    }
}
