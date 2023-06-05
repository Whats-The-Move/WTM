import UIKit
import FirebaseFirestore

struct User {
    let uid: String
    let email: String
}

class MyFriendsViewController: UIViewController, UITableViewDelegate {
    var users: [User] = []
    var allUsers: [User] = []
    var searching = false
    var searchUser: [User] = []

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        userList.delegate = self
        userList.dataSource = self
        userList.overrideUserInterfaceStyle = .dark
        userList.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        searchBar.overrideUserInterfaceStyle = .dark

        fetchUsers()
    }

    func fetchUsers() {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")

        usersCollection.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting users: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                return
            }

            self.allUsers = snapshot.documents.compactMap { document in
                let data = document.data()
                let uid = document.documentID
                let email = data["email"] as? String
                return User(uid: uid, email: email ?? "N/A")
            }

            self.users = self.allUsers
            self.userList.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at index: \(indexPath.row)")
        let selectedCell = userList.cellForRow(at: indexPath)
        performSegue(withIdentifier: "friendPopUpSegue", sender: selectedCell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendPopUpSegue" {
            let destinationVC = segue.destination as! friendPopUpViewController
            if let cell = sender as? UITableViewCell {
                let titleText = cell.textLabel?.text ?? "error"
                print("Title text to be passed: \(titleText)")
                destinationVC.titleText = titleText
            }
        }
    }

}

extension MyFriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? searchUser.count : users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = searching ? searchUser[indexPath.row] : users[indexPath.row]
        cell.textLabel?.text = user.email
        return cell
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

        searchUser = allUsers.filter { $0.email.lowercased().contains(searchText.lowercased()) }
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
