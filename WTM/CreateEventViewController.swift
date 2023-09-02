//
//  CreateEventViewController.swift
//  WTM
//
//  Created by Aman Shah on 6/13/23.
//

import UIKit
import Firebase
import FirebaseAuth

class CreateEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var eventTitle: UITextField!
    
    @IBOutlet weak var dateAndTime: UIDatePicker!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    
    @IBOutlet weak var createButton: UIButton!
    var selectedUsers: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventTitle.delegate = self
        location.delegate = self
        descriptionText.delegate = self
        //inviteesText.delegate = self
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeGesture.direction = .down
        swipeGesture.delegate = self
        descriptionText.addGestureRecognizer(swipeGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        descriptionText.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // Restore the original position of the view
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        // Calculate the height of the keyboard
        let keyboardHeight = keyboardFrame.size.height

        // Check if the text field is hidden by the keyboard
        if eventTitle.isFirstResponder || location.isFirstResponder || descriptionText.isFirstResponder  {
            let maxY = max(eventTitle.frame.maxY, location.frame.maxY, descriptionText.frame.maxY)
            let visibleHeight = view.frame.height - keyboardHeight
            if maxY > visibleHeight {
                // Adjust the view's frame to move the text field above the keyboard
                let offsetY = maxY - visibleHeight + 10 // Add 10 for padding
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -offsetY)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        descriptionText.isEditable = true
        //descriptionText.text = "Description/details"
        descriptionText.textAlignment = .left
        descriptionText.font = UIFont.systemFont(ofSize: 16)
        descriptionText.layer.cornerRadius = 8
        dateAndTime.layer.cornerRadius = 8
    }
    @IBAction func createTapped(_ sender: Any) {
    guard let eventTitle = eventTitle.text,
              let location = location.text,
              let eventDescription = descriptionText.text
            else {
            return
            print("didn't fill it")
        }
        let dateTime = dateAndTime.date

        let currentUserUID = Auth.auth().currentUser?.uid ?? ""
        
        // Get the invitee UIDs as an array
        var inviteeUIDs = selectedUsers.map { $0.uid }
        inviteeUIDs.append(currentUserUID)
        
        // Create a reference to the "Privates" node in Firebase Realtime Database
        let privatesRef = Database.database().reference().child("Events1")
        
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
        
        
        // Display a message
        let alertController = UIAlertController(title: "Congratulations", message: "You have created an event!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
    /*
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
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
