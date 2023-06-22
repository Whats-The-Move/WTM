import Foundation
import UIKit
import FirebaseAuth
import Firebase
import Kingfisher
protocol CustomCellDelegate: AnyObject {
    func buttonClicked(for party: Party)
    func profileClicked(for party: Party)
}

class CustomCellClass: UITableViewCell {
    weak var delegate: CustomCellDelegate?
    private var party: Party?
    
    @objc private func profTapped(_ sender: UITapGestureRecognizer) {
        guard let party = party else {
            return
        }
        
        delegate?.profileClicked(for: party)
    }

    @IBAction func buttonClicked(_ sender: UIButton) {
        guard let party = party else {
            return
        }
        delegate?.buttonClicked(for: party)
    }

    func configure(with party: Party, rankDict: [String: Int]) {
        self.party = party
        if let partyLabel = viewWithTag(1) as? UILabel {
            partyLabel.text = party.name
        }
        if let subtitleLabel = viewWithTag(2) as? UILabel {
            subtitleLabel.text = "#" + String(rankDict[party.name] ?? 0)
        }
        if let ratingLabel = viewWithTag(3) as? UILabel {
            ratingLabel.text = String(party.rating)
        }


        if let goingButton = viewWithTag(4) as? UIButton {
            var isGoingBool = false
            checkIfUserIsGoing(party: party) { isUserGoing in
                //print("isUserGoing: \(isUserGoing)")
                // Use the value of isUserGoing to update the button's appearance or perform any other action
                isGoingBool = isUserGoing
                if let titleLabel = goingButton.titleLabel {
                    let label = isGoingBool ? "I'm Going!" : "Not going"
                    titleLabel.text = label
                    titleLabel.textColor = UIColor.white
                    titleLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
                }
                let pinkColor = UIColor(red: 215.0/255, green: 113.0/255, blue: 208.0/255, alpha: 0.5)
                let greenColor = UIColor(red: 0.0, green: 185.0/255, blue: 0.0, alpha: 1.0)

                let backgroundColor = isGoingBool ? greenColor : pinkColor
                //print(backgroundColor)
                goingButton.backgroundColor = backgroundColor
                goingButton.layer.cornerRadius = 8.0
                goingButton.layer.masksToBounds = true
               
            }
            goingButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)

        }
        //self.assignProfilePictures(commonFriends: [])
        checkFriendshipStatus(isGoing: party.isGoing) { commonFriends in
            self.assignProfilePictures(commonFriends: commonFriends)
            //print(commonFriends)
        }
    }
    
    func checkFriendshipStatus(isGoing: [String], completion: @escaping ([String]) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            completion([])
            return
        }

        let userRef = Firestore.firestore().collection("users").document(currentUserUID)

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let friendList = document.data()?["friends"] as? [String] else {
                    print("Error: No friends list found.")
                    completion([])
                    return
                }

                let commonFriends = friendList.filter { isGoing.contains($0) }
                print(commonFriends)
                completion(commonFriends)
            } else {
                print("Error: Current user document does not exist.")
                completion([])
            }
        }
    }

    func assignProfilePictures(commonFriends: [String]) {
        let imageTags = [5, 6, 7, 8] // Update with the appropriate image view tags
        for tag in imageTags {
                if let profileImageView = self.viewWithTag(tag) as? UIImageView {
                    profileImageView.isHidden = true
                }
            }
        if commonFriends.count - 4 > 0 {
            if let plusMore = viewWithTag(10) as? UILabel {
                plusMore.text = "+" + String(commonFriends.count - 4) 
            }
        }
        else{
            if let plusMore = viewWithTag(10) as? UILabel {
                plusMore.text = ""
            }
        }
        
        for i in 0..<min(commonFriends.count, imageTags.count) {
            let friendUID = commonFriends[i]
            let tag = imageTags[i]
            
            if let profileImageView = self.viewWithTag(tag) as? UIImageView {
                // Assign profile picture to the image view
                profileImageView.isHidden = false

                profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
                profileImageView.clipsToBounds = true
                profileImageView.contentMode = .scaleAspectFill
                profileImageView.layer.borderWidth = 2.0
                profileImageView.layer.borderColor = UIColor.white.cgColor
                profileImageView.frame = CGRect(x: profileImageView.frame.origin.x, y: profileImageView.frame.origin.y, width: 39, height: 39)
                profileImageView.isUserInteractionEnabled = true
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profTapped(_:)))
                            profileImageView.addGestureRecognizer(tapGesture)
                            
                let userRef = Firestore.firestore().collection("users").document(friendUID)
                userRef.getDocument { (document, error) in
                    if let error = error {
                        print("Error retrieving profile picture: \(error.localizedDescription)")
                        return
                    }
                    
                    if let document = document, document.exists {
                        if let profilePicURL = document.data()?["profilePic"] as? String {
                            // Assuming you have a function to retrieve the image from the URL
                            self.loadImage(from: profilePicURL, to: profileImageView)
                        } else {
                            print("No profile picture found for friend with UID: \(friendUID)")
                        }
                    }
                }
            }
        }
    }

    func loadImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        imageView.kf.setImage(with: url)
    }
    /*
    func loadImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    imageView.image = image
                }
            }
        }
    }*/   
    private func checkIfUserIsGoing(party: Party, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let partyRef = Database.database().reference().child("Parties").child(party.name)
        
        partyRef.child("isGoing").observeSingleEvent(of: .value) { snapshot in
            var isUserGoing = false
            
            if snapshot.exists() {
                if let attendees = snapshot.value as? [String] {
                    isUserGoing = attendees.contains(uid)
                }
            }
            
            completion(isUserGoing)
        }
    }









}
