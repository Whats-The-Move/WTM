//
//  friendPopUpViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 6/2/23.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class friendPopUpViewController: UIViewController{
    var titleText: String = ""
    var nameText: String = ""
    
    @IBOutlet weak var requestFriendPopUpView: UIView!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KeyboardManager.shared.enableTapToDismiss()
        print("Title text: \(titleText)")
        friendName.text = titleText
        friendName.textColor = .black
        displayNameLabel.textColor = .black
        displayNameLabel.text = nameText
        
        profilePicImage.layer.cornerRadius = profilePicImage.frame.size.width / 2
        profilePicImage.backgroundColor = UIColor(red: 1.0, green: 0.41, blue: 0.71, alpha: 1.0)
        profilePicImage.clipsToBounds = true
        profilePicImage.contentMode = .scaleAspectFill
        profilePicImage.layer.borderWidth = 2.0
        profilePicImage.layer.borderColor = UIColor(red: 1.0, green: 0.41, blue: 0.71, alpha: 1.0).cgColor
        profilePicImage.frame = CGRect(x: profilePicImage.frame.origin.x, y: profilePicImage.frame.origin.y, width: 64, height: 64)
        profilePicImage.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addFriendButtonClicked(_ sender: Any) {
        let currentUserUID = Auth.auth().currentUser?.uid
        let personUsername = titleText
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        let query = usersCollection.whereField("username", isEqualTo: personUsername)
        
        self.dismissViewController()
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                // Handle the error
                print("Error fetching person's UID: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot,
                  let document = snapshot.documents.first else {
                // Handle case when the person is not found
                return
            }

            let personUID = document.documentID
            let friendRequestData = ["pendingFriendRequests": FieldValue.arrayUnion([currentUserUID ?? "N/A"])]
            usersCollection.document(personUID).updateData(friendRequestData) { error in
                if let error = error {
                    // Handle the error
                    print("Error adding friend request: \(error.localizedDescription)")
                } else {
                    // Friend request added successfully
                    print("Friend request sent successfully")
                }
            }
        }
    }
    
}
