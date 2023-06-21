//
//  BadgesViewController.swift
//  WTM
//
//  Created by Aman Shah on 6/17/23.
//

import UIKit
import Firebase
import FirebaseAuth
import Kingfisher

class BadgesViewController: UIViewController {

    @IBOutlet weak var bkgdView: UIView!
    @IBOutlet weak var bestFriendsView: UIView!
    @IBOutlet weak var favSpotView: UIView!
    @IBOutlet weak var fratView: UIView!
    
    @IBOutlet weak var bestFriendsLabel: UILabel!
    
    @IBOutlet weak var favSpotLabel: UILabel!
    @IBOutlet weak var favSpotHeader: UILabel!
    @IBOutlet weak var fratPic: UIImageView!
    
    
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
                self.assignProfilePictures(commonFriends: sortedFriendsKeys, friendValues: sortedFriends.map { $0.value })
            } else {
                print("bestFriends field not found or is not a dictionary")
            }
        }
        //continue viewdidload here
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    /*override func viewDidLayoutSubviews() {
        bestFriendsView.layer.cornerRadius = 10
        favSpotView.layer.cornerRadius = 10
        fratView.layer.cornerRadius = 10
        fratPic.layer.cornerRadius = fratPic.frame.width / 2
        favSpotLabel.layer.cornerRadius = 10
        bestFriendsLabel.layer.cornerRadius = 10
        favSpotHeader.layer.cornerRadius = 10

        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let frameWidth = 299.0
        let frameHeight = screenHeight * (2/3) - 100
        
        let frameX = (screenWidth - frameWidth) / 2
        let frameY = screenHeight / 4
        
        bkgdView.frame = CGRect(x: frameX, y: frameY, width: frameWidth, height: frameHeight)
        let headerHeight: CGFloat = 60.0
        let spacing: CGFloat = 15.0
        let horizontalPadding: CGFloat = 15.0
        
        let stackView = UIStackView(arrangedSubviews: [bestFriendsView, favSpotView, fratView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        
        // Calculate the frame for the stack view
        let stackViewWidth = bkgdView.bounds.width - (horizontalPadding * 2)
        let stackViewHeight = bkgdView.bounds.height - headerHeight - (spacing * 2)
        let stackViewX = bkgdView.bounds.origin.x + horizontalPadding
        let stackViewY = headerHeight + spacing
        
        stackView.frame = CGRect(x: stackViewX, y: stackViewY, width: stackViewWidth, height: stackViewHeight)
        
        bkgdView.addSubview(stackView)
    }*/
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
    func assignProfilePictures(commonFriends: [String], friendValues: [Int]) {
        let imageTags = [1,2,3,4,5] // Update with the appropriate image view tags
        
        for i in 0..<min(commonFriends.count, imageTags.count) {
            let friendUID = commonFriends[i]
            let tag = imageTags[i]
            
            if let profileImageView = bestFriendsView.viewWithTag(tag) as? UIImageView {
                // Assign profile picture to the image view
                profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
                profileImageView.clipsToBounds = true
                profileImageView.contentMode = .scaleAspectFill
                profileImageView.layer.borderWidth = 2.0
                let pinkColor = UIColor(red: 255/255, green: 106/255, blue: 245/255, alpha: 1.0)
                profileImageView.layer.borderColor = pinkColor.cgColor
                profileImageView.frame = CGRect(x: profileImageView.frame.origin.x, y: profileImageView.frame.origin.y, width: 50, height: 50)

                            
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
            if let countLabel = bestFriendsView.viewWithTag(tag + 5) as? UILabel{
                countLabel.text = String(friendValues[tag])
                
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
