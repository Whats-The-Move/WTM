import Foundation
import UIKit
import FirebaseAuth
import Firebase
protocol CustomCellDelegate: AnyObject {
    func buttonClicked(for party: Party)
}

class CustomCellClass: UITableViewCell {
    weak var delegate: CustomCellDelegate?
    private var party: Party?
    

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
                    let label = isGoingBool ? "See you there" : "Yeah I'll Be There"
                    titleLabel.text = label
                    titleLabel.textColor = UIColor.white
                    titleLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
                }
                let pinkColor = UIColor(red: 215.0/255, green: 113.0/255, blue: 208.0/255, alpha: 1.0)
                let greenColor = UIColor(red: 0.0, green: 200.0/255, blue: 0.0, alpha: 1.0)

                let backgroundColor = isGoingBool ? greenColor : pinkColor
                //print(backgroundColor)
                goingButton.backgroundColor = backgroundColor
                goingButton.layer.cornerRadius = 8.0
                goingButton.layer.masksToBounds = true

               
               
            }
            goingButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            
            


            // let backgroundColor = isGoing ? UIColor.green : UIColor.systemPink
            // goingButton.backgroundColor = backgroundColor
        }

        checkFriendshipStatus(isGoing: party.isGoing) { commonFriends in
            // Handle the commonFriends array here
            print("Common friends from the completion handler:")
            print(commonFriends)
            var friendUID = "jSp9XTx1e7aeVCmL1EtrgjLJk2g2"
            var friendsnum = commonFriends.count
            if let firstFriendUID = commonFriends.first{
                friendUID = firstFriendUID
            }

            
            if let profile1 = self.viewWithTag(5) as? UIImageView {
                //print("accessed tag 5")
                profile1.layer.cornerRadius = profile1.frame.size.width / 2
                profile1.clipsToBounds = true
                profile1.contentMode = .scaleAspectFill
                let userRef = Firestore.firestore().collection("users").document(friendUID)
                    
                    userRef.getDocument { (document, error) in
                        if let error = error {
                            print("Error retrieving profile picture: \(error.localizedDescription)")
                            return
                        }
                        
                        if let document = document, document.exists {
                            if let profilePicURL = document.data()?["profilePic"] as? String {
                                // Assuming you have a function to retrieve the image from the URL
                                self.loadImage(from: profilePicURL, to: profile1)
                                }
                            else{
                                print("no prof pic found")
                            }
                        }
                    }
                        
             }
        }

        //print("common friends")
        //print(commonFriends)
        //print(commonFriends)

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

                completion(commonFriends)
            } else {
                print("Error: Current user document does not exist.")
                completion([])
            }
        }
    }


    
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
    }
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
