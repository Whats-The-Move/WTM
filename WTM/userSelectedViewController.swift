import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage
import Kingfisher

class UserSelectedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var favSpotLabel: UILabel!
    @IBOutlet weak var sharedFriendTable: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!

    var sharedFriends: [User] = [] // Update the data type to User
    var uid = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        sharedFriendTable.delegate = self
        sharedFriendTable.dataSource = self

        let userRef = Firestore.firestore().collection("users").document(uid)

        userRef.getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else {
                // Handle error or nil self
                return
            }

            if let imageURLString = document.data()?["profilePic"] as? String {
                if let imageURL = URL(string: imageURLString) {
                    DispatchQueue.global().async {
                        if let imageData = try? Data(contentsOf: imageURL) {
                            DispatchQueue.main.async {
                                let image = UIImage(data: imageData)
                                self.profilePic.image = image
                            }
                        }
                    }
                }
            } else {
                // Handle the case where the profilePic data is empty or nonexistent
                self.profilePic.image = UIImage(named: "default_profile_pic") // Set a default profile picture
            }

            if let name = document.data()?["name"] as? String {
                self.nameLabel.text = name
            } else {
                // Handle the case where the name data is empty or nonexistent
                self.nameLabel.text = "Name not available"
            }

            if let username = document.data()?["username"] as? String {
                self.usernameLabel.text = username
            } else {
                // Handle the case where the username data is empty or nonexistent
                self.usernameLabel.text = "Username not available"
            }

            if let spots = document.data()?["spots"] as? [String: Int] {
                // Get the party with the largest occurrence (maximum value) from the spots map
                if let maxSpot = spots.max(by: { $0.value < $1.value }) {
                    self.favSpotLabel.text = "Favorite Spot: \(maxSpot.key)"
                } else {
                    self.favSpotLabel.text = "No favorite spot found"
                }
            }

            // Fetch the friends for the current user and the selected user
            self.fetchCurrentUserFriends { currentUserFriends in
                self.fetchSelectedUserFriends { selectedUserFriends in
                    // Find the shared friends between the current user and the selected user
                    let sharedFriends = currentUserFriends.filter { selectedUserFriends.contains($0.uid) }
                    // Set the sharedFriends array
                    self.sharedFriends = sharedFriends
                    self.sharedFriendTable.reloadData()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedFriends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! addFriendCustomCellClass

        // Load data for each friend and set the cell's properties
        let user = sharedFriends[indexPath.row]
        cell.configure(with: user) // Use User data to configure the cell

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userSelectedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userSelectedViewController") as! UserSelectedViewController

        let user = sharedFriends[indexPath.row]
        userSelectedVC.uid = user.uid // Set the uid of the selected friend in the UserSelectedViewController
        
        present(userSelectedVC, animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    // Function to fetch friends for the current user
    private func fetchCurrentUserFriends(completion: @escaping ([User]) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        Firestore.firestore().collection("users").document(currentUserUID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching current user document: \(error)")
                completion([])
                return
            }

            if let data = snapshot?.data(), let friends = data["friends"] as? [String] {
                // Fetch the User objects for the friends
                let dispatchGroup = DispatchGroup()
                var userArray: [User] = []
                for friendUID in friends {
                    dispatchGroup.enter()
                    Firestore.firestore().collection("users").document(friendUID).getDocument { snapshot, error in
                        defer {
                            dispatchGroup.leave()
                        }
                        if let error = error {
                            print("Error fetching friend's document: \(error)")
                            return
                        }

                        if let data = snapshot?.data(),
                           let uid = data["uid"] as? String,
                           let email = data["email"] as? String,
                           let name = data["name"] as? String,
                           let username = data["username"] as? String,
                           let profilePic = data["profilePic"] as? String {
                            let user = User(uid: uid, email: email, name: name, username: username, profilePic: profilePic)
                            userArray.append(user)
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    completion(userArray)
                }
            } else {
                completion([])
            }
        }
    }

    // Function to fetch friends for the selected user
    private func fetchSelectedUserFriends(completion: @escaping ([String]) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching selected user document: \(error)")
                completion([])
                return
            }

            if let data = snapshot?.data(), let friends = data["friends"] as? [String] {
                completion(friends)
            } else {
                completion([])
            }
        }
    }
}
