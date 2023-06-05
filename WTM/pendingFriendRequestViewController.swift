import UIKit
import FirebaseFirestore
import FirebaseAuth

class pendingFriendRequestViewController: UIViewController {
    
    @IBOutlet weak var friendRequestsTableView: UITableView!
    
    var pendingFriends: [String] = []
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Firestore
        db = Firestore.firestore()
        
        // Set the delegate and data source for the table view
        friendRequestsTableView.delegate = self
        friendRequestsTableView.dataSource = self
        
        // Register the custom cell class
        friendRequestsTableView.register(FriendRequestCellClass.self, forCellReuseIdentifier: "pendingCell")
        
        // Fetch pending friends based on your UID
        fetchPendingFriends()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
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
            
            if let data = snapshot.data(), let pendingFriends = data["pendingFriendRequests"] as? [String] {
                // Update the pendingFriends array
                self.pendingFriends = pendingFriends
                
                // Reload the table view
                self.friendRequestsTableView.reloadData()
            }
        }
    }
}

extension pendingFriendRequestViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

extension pendingFriendRequestViewController: FriendRequestCellDelegate {
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
                self?.friendRequestsTableView.reloadData()
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
            self?.friendRequestsTableView.reloadData()
        }
    }
}
