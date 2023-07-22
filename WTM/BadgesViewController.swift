import UIKit
import Firebase
import FirebaseAuth
import Kingfisher

class BadgesViewController: UIViewController {

    @IBOutlet weak var friendName1: UILabel!
    @IBOutlet weak var friendPic1: UIImageView!
    @IBOutlet weak var friendName2: UILabel!
    @IBOutlet weak var friendPic2: UIImageView!
    @IBOutlet weak var friendName3: UILabel!
    @IBOutlet weak var friendPic3: UIImageView!
    @IBOutlet weak var friendName4: UILabel!
    @IBOutlet weak var friendPic4: UIImageView!
    @IBOutlet weak var friendName5: UILabel!
    @IBOutlet weak var friendPic5: UIImageView!
    @IBOutlet weak var favSpotLabel: UILabel!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findMostVisitedParty()
        let uid = Auth.auth().currentUser?.uid ?? ""
        let userRef = Firestore.firestore().collection("users").document(uid)
        // Retrieve the bestFriends field from Firestore
        userRef.getDocument { (snapshot, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }
            guard let document = snapshot, document.exists else {
                print("User document does not exist")
                return
            }
            // Retrieve the bestFriends field as a dictionary
            if let bestFriendsDict = document.data()?["bestFriends"] as? [String: Int] {
                // Sort the bestFriends dictionary by frequency in descending order
                let sortedFriends = bestFriendsDict.sorted(by: { $0.value > $1.value })

                // Extract the keys (UIDs) from the sortedFriends dictionary
                let sortedFriendsKeys = sortedFriends.map { $0.key }

                // Call the assignProfilePictures function with the sortedFriendsKeys array
                print("going to assign now")
                self.assignProfilePictures(commonFriends: sortedFriendsKeys)
            } else {
                print("bestFriends field not found or is not a dictionary")
            }
        }
 
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func findMostVisitedParty() {
        let currentUserUID = Auth.auth().currentUser?.uid ?? ""
        
        let usersCollection = Firestore.firestore().collection("users")
        let userDocument = usersCollection.document(currentUserUID)
        
        userDocument.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let spots = data?["spots"] as? [String: Int] {
                    // Find the spot with the highest value
                    let mostVisitedSpot = spots.max { $0.value < $1.value }
                    let mostVisitedPartyName = mostVisitedSpot?.key
                    
                    DispatchQueue.main.async {
                        // Set the favSpotLabel with the most visited party name
                        self.favSpotLabel.text = mostVisitedPartyName
                    }
                } else {
                    DispatchQueue.main.async {
                        // Handle the case when the spots field is not found or is empty
                        self.favSpotLabel.text = "No favorite spot"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    // Handle the case when the document is not found or there is an error
                    self.favSpotLabel.text = "Error retrieving data"
                }
            }
        }
    }
    
    func assignProfilePictures(commonFriends: [String]) {
        let imageViews = [friendPic1, friendPic2, friendPic3, friendPic4, friendPic5]
        
        for (index, friendUID) in commonFriends.prefix(imageViews.count).enumerated() {
            let imageView = imageViews[index]
            imageView?.layer.cornerRadius = 40
            imageView?.clipsToBounds = true
            imageView?.contentMode = .scaleAspectFill
            imageView?.layer.borderWidth = 2.0
            let pinkColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0)
            imageView?.layer.borderColor = pinkColor.cgColor
            imageView?.frame = CGRect(x: imageView?.frame.origin.x ?? 0.0, y: imageView?.frame.origin.y ?? 0.0, width: 50, height: 50)

            let userRef = Firestore.firestore().collection("users").document(friendUID)
            userRef.getDocument { (document, error) in
                if let error = error {
                    print("Error retrieving profile picture: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, document.exists {
                    if let profilePicURL = document.data()?["profilePic"] as? String {
                        // Assuming you have a function to retrieve the image from the URL
                        self.loadImage(from: profilePicURL, to: imageView)
                    } else {
                        print("No profile picture found for friend with UID: \(friendUID)")
                    }
                }
            }
            
            fetchUserName(for: friendUID) { name in
                let labelIndex = index + 1 // Assuming the labels are ordered similarly to the image views
                let friendNameLabel = self.friendNameLabel(for: labelIndex)
                friendNameLabel?.text = name ?? "Unknown" // Set the name or a default value if not found
            }
        }
    }
    
    func loadImage(from urlString: String, to imageView: UIImageView?) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        imageView?.kf.setImage(with: url)
    }
    
    func fetchUserName(for uid: String, completion: @escaping (String?) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error retrieving user data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let document = document, let name = document.data()?["name"] as? String {
                completion(name)
            } else {
                completion(nil)
            }
        }
    }
    
    private func friendNameLabel(for index: Int) -> UILabel? {
        switch index {
        case 1: return friendName1
        case 2: return friendName2
        case 3: return friendName3
        case 4: return friendName4
        case 5: return friendName5
        default: return nil
        }
    }
}
