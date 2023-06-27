//
//  CreateEventViewController.swift
//  WTM
//
//  Created by Aman Shah on 6/13/23.
//

import UIKit
import Firebase
import FirebaseAuth

class CreateEventViewController: UIViewController {
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var bkgdView: UIView!
    
    @IBOutlet weak var dateAndTime: UIDatePicker!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var inviteesText: UITextView!
    var selectedUsers: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(inviteesTapped))
             inviteesText.addGestureRecognizer(tapGestureRecognizer)
             inviteesText.isUserInteractionEnabled = true
        let selectedUserNames = selectedUsers.map { $0.name }
           inviteesText.text = selectedUserNames.joined(separator: ", ")
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        descriptionText.isEditable = true
        //descriptionText.text = "Description/details"
        descriptionText.textAlignment = .left
        descriptionText.font = UIFont.systemFont(ofSize: 16)
        descriptionText.layer.cornerRadius = 8
        bkgdView.layer.cornerRadius = 8
        dateAndTime.layer.cornerRadius = 8
    }
    @IBAction func createTapped(_ sender: Any) {
    guard let eventTitle = eventTitle.text,
              let location = location.text,
              let eventDescription = descriptionText.text,
              let inviteesText = inviteesText.text else {
            return
        }
        let dateTime = dateAndTime.date

        let currentUserUID = Auth.auth().currentUser?.uid ?? ""
        
        // Get the invitee UIDs as an array
        var inviteeUIDs = selectedUsers.map { $0.uid }
        inviteeUIDs.append(currentUserUID)
        
        // Create a reference to the "Privates" node in Firebase Realtime Database
        let privatesRef = Database.database().reference().child("Privates")
        
        // Create a new child node under "Privates" and generate a unique key
        let newEventRef = privatesRef.childByAutoId()
        
        // Create a dictionary with the event information
        let eventInfo: [String: Any] = [
            "event": eventTitle,
            "dateTime": dateTime.timeIntervalSince1970,
            "location": location,
            "description": eventDescription,
            "invitees": inviteeUIDs,
            "isGoing": [currentUserUID],
            "creator": currentUserUID
        ]
        
        // Set the event information under the new child node
        newEventRef.setValue(eventInfo) { error, _ in
            if let error = error {
                print("Error creating event: \(error.localizedDescription)")
            } else {
                print("Event created successfully!")
                // TODO: Perform any additional actions after event creation
            }
        }
        
        self.eventTitle.text = ""
        self.location.text = ""
        descriptionText.text = ""
        self.inviteesText.text = ""
        
        // Display a message
        let alertController = UIAlertController(title: "Congratulations", message: "You have created an event!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
    @objc func inviteesTapped() {
        let inviteListVC = storyboard?.instantiateViewController(withIdentifier: "InviteList") as! InviteListViewController
            inviteListVC.selectedUsers = selectedUsers  // Pass the selectedUsers array to InviteListViewController
            inviteListVC.didSelectUsers = { [weak self] users in
                // Update inviteesText with the names of the selected users
                let names = users.map { $0.name }
                self?.inviteesText.text = names.joined(separator: ", ")
                self?.selectedUsers = users  // Update the selectedUsers array with the newly selected users
            }
            present(inviteListVC, animated: true, completion: nil)
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
