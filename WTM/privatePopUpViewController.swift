//
//  privatePopUpViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 6/27/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MapKit
import CoreLocation
import FirebaseStorage
import Firebase
import AVFoundation

class privatePopUpViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var titleText: String = ""
    var locationText: String = ""
    var dateText: String = ""
    var timeText: String = ""
    var descriptionText: String = ""
    var userGoing = false
    var commonFriends = [String]()
    
    @IBOutlet weak var popupView: UIView!
    
    var databaseRef: DatabaseReference?
    var parties = [privateParty]()
    var party = privateParty(id: "", creator: "", datetime: 0, description: "", event: "", invitees: [""], location : "", isGoing: [""])
    
    @IBOutlet weak var friendsView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numPeople: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var creatorProfilePic: UIImageView!
    @IBOutlet weak var isGoingButton: UIButton!
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(party.isGoing)
        self.isModalInPresentation = true
        
        assignProfilePictures(commonFriends: commonFriends)
        
        creatorProfilePic.layer.cornerRadius = creatorProfilePic.frame.size.width / 2
        creatorProfilePic.clipsToBounds = true
        creatorProfilePic.contentMode = .scaleAspectFill
        creatorProfilePic.layer.borderWidth = 2.0
        let hotPinkColor = UIColor(red: 255/255, green: 105/255, blue: 180/255, alpha: 1.0)
        creatorProfilePic.layer.borderColor = hotPinkColor.cgColor
        creatorProfilePic.frame = CGRect(x: creatorProfilePic.frame.origin.x, y: creatorProfilePic.frame.origin.y, width: 39, height: 39)
        creatorProfilePic.isUserInteractionEnabled = true
        
        imagePickerController.delegate = self
        print(self.party)
        view.layer.cornerRadius = 10
        
        popupView.layer.cornerRadius = 8
        titleLabel.textColor = .black
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissViewController() {
        print("dismissing view controller")
        //self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let TabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        TabBarController.overrideUserInterfaceStyle = .dark
        TabBarController.modalPresentationStyle = .fullScreen
        present(TabBarController, animated: false, completion: nil)
        
    }
    
    func assignProfilePictures(commonFriends: [String]) {
        let imageTags = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] // Update with the appropriate image view tags
        if commonFriends.count - 10 > 0 {
            if let plusMore = friendsView.viewWithTag(10) as? UILabel {
                plusMore.text = "+" + String(commonFriends.count - 10)
            }
        }
        else{
            if let plusMore = friendsView.viewWithTag(10) as? UILabel {
                plusMore.text = ""
            }
        }
        for i in 0..<min(commonFriends.count, imageTags.count) {
            let friendUID = commonFriends[i]
            let tag = imageTags[i]
            
            if let profileImageView = friendsView.viewWithTag(tag) as? UIImageView {
                // Assign profile picture to the image view
                profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
                profileImageView.clipsToBounds = true
                profileImageView.contentMode = .scaleAspectFill
                profileImageView.layer.borderWidth = 2.0
                profileImageView.layer.borderColor = UIColor.white.cgColor
                profileImageView.frame = CGRect(x: profileImageView.frame.origin.x, y: profileImageView.frame.origin.y, width: 39, height: 39)
                profileImageView.isUserInteractionEnabled = true
                            //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profTapped(_:)))
                            //profileImageView.addGestureRecognizer(tapGesture)
                            
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
    
    @IBAction func isGoingButtonClicked(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let partyRef = Database.database().reference().child("Privates").child(self.party.id)
        partyRef.child("isGoing").observeSingleEvent(of: .value) { [weak self] snapshot in
            if snapshot.exists() {
                if var attendees = snapshot.value as? [String] {
                    if let index = attendees.firstIndex(of: uid) {
                        attendees.remove(at: index)
                        self?.userGoing = false
                        self!.checkIfUserIsGoing(party: self!.party)

                    } else {
                        attendees.append(uid)
                        let customCell = CustomCellClass()
                        customCell.checkFriendshipStatus(isGoing: attendees) { result in
                            // Call the updateBestFriends function and pass the result as a parameter
                            AppHomeViewController().updateBestFriends(commonFriends: result)
                        }
                        self?.userGoing = true
                        self!.checkIfUserIsGoing(party: self!.party)

                    }
                    partyRef.child("isGoing").setValue(attendees) { error, _ in
                        if let error = error {
                            print("Failed to update party attendance:", error)
                        } else {
                            //print("Successfully updated party attendance1.")
                        }
                    }
                }
            } else {
                partyRef.child("isGoing").setValue([uid]) { error, _ in
                    if let error = error {
                        print("Failed to update party attendance:", error)
                    } else {
                        self?.userGoing = true
                        self!.checkIfUserIsGoing(party: self!.party)

                        //print("Successfully updated party attendance.")
                    }
                }
            }
        }
    }
    
    private func checkIfUserIsGoing(party: privateParty) -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            return false
        }
        
        let partyRef = Database.database().reference().child("Privates").child(party.id)
        
        partyRef.child("isGoing").observeSingleEvent(of: .value) { snapshot in
            var isUserGoing = false
            //HERES THE PROBLEM- not going into fuck again party of code
            if snapshot.exists() {
                if let attendees = snapshot.value as? [String] {
                    isUserGoing = attendees.contains(uid)
                    self.userGoing = isUserGoing
                }
            }
        }
            //completion(isUserGoing)
        let pinkColor = UIColor(red: 215.0/255, green: 113.0/255, blue: 208.0/255, alpha: 0.5)
        let greenColor = UIColor(red: 0.0, green: 185.0/255, blue: 0.0, alpha: 1.0)
        
        let backgroundColor = userGoing ? greenColor : pinkColor
        self.isGoingButton.backgroundColor = backgroundColor
        let buttonText = userGoing ? "I'm Going!" : "Not going"
        // Assuming you have a button instance called 'myButton'
        isGoingButton.setTitle(buttonText, for: .normal)

        return userGoing
    }
        
}
