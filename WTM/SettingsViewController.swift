//
//  SettingsViewController.swift
//  WTM
//
//  Created by Aman Shah on 6/27/23.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var deleteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? This cannot be undone.", preferredStyle: .alert)

           alertController.addTextField { textField in
               textField.placeholder = "Type 'delete'"
               textField.isSecureTextEntry = true
           }

           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           alertController.addAction(cancelAction)

           let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
               guard let textField = alertController.textFields?.first, let userInput = textField.text else {
                   return
               }

               if userInput == "delete" {
                   self.deleteAccount()
               } else {
                   print("Invalid input")
               }
           }
           alertController.addAction(confirmAction)

           present(alertController, animated: true, completion: nil)
    }

    @IBAction func changeUsernameTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Edit username", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter new username"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            if let newUsername = alertController.textFields?.first?.text {
                // Perform username availability check
                self.checkUsernameAvailability(newUsername) { (isAvailable) in
                    if isAvailable {
                        // Username is available, save it
                        self.saveName(newUsername)
                    } else {
                        // Username is already taken, display alert
                        let alert = UIAlertController(title: "Username is taken", message: "Please choose a different username.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func checkUsernameAvailability(_ username: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        
        // Query Firestore to check if the username is already taken
        usersCollection.whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking username availability: \(error.localizedDescription)")
                completion(false) // Assume username is not available in case of error
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No matching documents found")
                completion(true) // Username is available if no documents are found
                return
            }
            
            // If any documents are found, the username is already taken
            completion(documents.isEmpty)
        }
    }

    func deleteAccount() {
        // Get the currently signed-in user
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in")
            return
        }
        
        // Delete the user account from Firebase Authentication
        currentUser.delete { error in
            if let error = error {
                print("Error deleting user account: \(error.localizedDescription)")
                return
            }
            
            // User account deleted successfully
            
            // Access the Firestore instance
            let firestore = Firestore.firestore()
            
            // Define the path to the user's document using their UID
            let userDocRef = firestore.collection("users").document(currentUser.uid)
            
            // Delete the user's document from Firestore
            userDocRef.delete { error in
                if let error = error {
                    print("Error deleting user document: \(error.localizedDescription)")
                    return
                }
                
                // User document deleted successfully
                
                // Remove the current user's UID from friends field of other user documents
                let usersCollectionRef = firestore.collection("users")
                usersCollectionRef.getDocuments { snapshot, error in
                    if let error = error {
                        print("Error getting user documents: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("No user documents found")
                        return
                    }
                    
                    // Iterate over each user document
                    for document in documents {
                        let userDocRef = usersCollectionRef.document(document.documentID)
                        
                        // Update the friends array of the user document
                        userDocRef.updateData(["friends": FieldValue.arrayRemove([currentUser.uid])]) { error in
                            if let error = error {
                                print("Error updating friends array: \(error.localizedDescription)")
                            }
                        }
                        
                        userDocRef.updateData(["pendingFriendRequests" : FieldValue.arrayRemove([currentUser.uid])]) { error in
                            if let error = error {
                                print("Error updating friends array: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    print("User account, document, and friend references deleted successfully, now kicking them to signup")
               
                        //try FirebaseAuth.Auth.auth().signOut()
                    UserDefaults.standard.set(false, forKey: "authenticated")
                        //TAKE THEM TO LOG IN SCREEN
                 
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyboard.instantiateViewController(withIdentifier: "SignUpPage") as! ViewController
                    newViewController.modalPresentationStyle = .fullScreen
                    self.present(newViewController, animated: false, completion: nil)

                    // TODO: Handle any additional cleanup or navigation
                }
            }
        }
    }


    func saveName(_ username: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.setData(["username": username], merge: true) { error in
            if let error = error {
                // Handle the error
                print("Error updating user's name in Firestore: \(error.localizedDescription)")
                return
            }
            // Name updated successfully
            print("Name updated in Firestore.")
            //self.nameLabel.text = name
            
            // Update the UI or perform any other necessary actions after saving the name
        }
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
