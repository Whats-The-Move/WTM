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
    
    @IBOutlet weak var requestFriendPopUpView: UIView!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var friendName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Title text: \(titleText)")
        friendName.text = titleText
        friendName.text = .black
        
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
        let query = usersCollection.whereField("email", isEqualTo: personUsername)
        
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
            let friendRequestData = ["pendingFriendRequests": FieldValue.arrayUnion([currentUserUID])]
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
