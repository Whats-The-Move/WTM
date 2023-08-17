//
//  plainProfileViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 7/19/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage

class plainProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    var profBool = true
    @IBOutlet weak var profilePic: UIImageView!
    //@IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var badgesButton: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendNotification: UIButton!
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        
        profilePic.isUserInteractionEnabled = true
        let pictapGesture = UITapGestureRecognizer(target: self, action: #selector(profilePicTapped))
        profilePic.addGestureRecognizer(pictapGesture)
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.numberOfLines = 1
        nameLabel.sizeToFit()
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.numberOfLines = 1
        
        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { [weak self] (document, error) in
                guard let self = self, let document = document, document.exists else {
                    // Handle error or nil self
                    print("doesnt exist")
                    return
                }
                
                if let uid = Auth.auth().currentUser?.uid {
                    let userRef = Firestore.firestore().collection("users").document(uid)
                    
                    userRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            if let data = document.data(), let username = data["username"] as? String,
                               let data = document.data(), let name = data["name"] as? String {
                                // Access the username value
                                self.nameLabel.text = name
                                self.usernameLabel.text = username
                            }
                        }
                        
                    }
                }

                
                if let data = document.data(),
                   let pendingFriendRequests = data["pendingFriendRequests"] as? [String] {
                    // Access the username and name values
                    if pendingFriendRequests.isEmpty{
                        self.friendNotification.isHidden = true
                    } else{
                        self.friendNotification.isHidden = false
                        self.friendNotification.setTitle("\(pendingFriendRequests.count)", for: .normal)
                    }
                } else {
                    self.friendNotification.isHidden = true
                }
            }
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else {
                // Handle error or nil self
                return
            }

            if let imageURLString = document.data()?["profilePic"] as? String,
               let imageURL = URL(string: imageURLString) {
                // Load the profile picture using Kingfisher
                self.profilePic.kf.setImage(with: imageURL, placeholder: UIImage(named: "placeholder_image"))
            } else {
                let backupProfile = "https://via.placeholder.com/150/CCCCCC/FFFFFF?text="
                if let backupImageURL = URL(string: backupProfile) {
                    // Load the backup profile picture using Kingfisher
                    self.profilePic.kf.setImage(with: backupImageURL, placeholder: UIImage(named: "placeholder_image"))
                }
            }
        }
        
        //let tapGestureBack = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        let tapGestureBadge = UITapGestureRecognizer(target: self, action: #selector(badgeButtonTapped))
        badgesButton.isUserInteractionEnabled = true
        badgesButton.addGestureRecognizer(tapGestureBadge)
//        backButton.isUserInteractionEnabled = true
//        backButton.addGestureRecognizer(tapGestureBack)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { [weak self] (document, error) in
                guard let self = self, let document = document, document.exists else {
                    // Handle error or nil self
                    return
                }
                
                if let data = document.data(),
                   let pendingFriendRequests = data["pendingFriendRequests"] as? [String] {
                    // Access the username and name values
                    if pendingFriendRequests.isEmpty{
                        self.friendNotification.isHidden = true
                    } else{
                        self.friendNotification.isHidden = false
                        self.friendNotification.setTitle("\(pendingFriendRequests.count)", for: .normal)
                    }
                } else {
                    self.friendNotification.isHidden = true
                }
            }
        }
    }
    
    @IBAction func badgeButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let badgesViewController = storyboard.instantiateViewController(withIdentifier: "badgePopUp") as! BadgesViewController
        present(badgesViewController, animated: true, completion: nil)
    }
    
//    @IBAction func backButtonTapped(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func nameLabelTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Edit Name", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter your name"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            if let newName = alertController.textFields?.first?.text {
                self.saveName(newName)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func saveName(_ name: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.setData(["name": name], merge: true) { error in
            if let error = error {
                // Handle the error
                print("Error updating user's name in Firestore: \(error.localizedDescription)")
                return
            }
            // Name updated successfully
            print("Name updated in Firestore.")
            self.nameLabel.text = name
            
            // Update the UI or perform any other necessary actions after saving the name
        }
    }
    
    @IBAction func addFriendsButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "MyFriends") as! MyFriendsViewController
        newViewController.modalPresentationStyle = .fullScreen
        present(newViewController, animated: false, completion: nil)
    }
    
    @IBAction func privacyButtonTapped(_ sender: Any) {
        if let url = URL(string: "https://sites.google.com/view/wtmwhatsthemove/privacy-policy?authuser=0") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
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
                        self.saveUsername(newUsername)
                        self.usernameLabel.text = newUsername
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
    
    func saveUsername(_ username: String) {
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
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        do{
            
            // Remove FCM token from Firestore
            if let currentUser = Auth.auth().currentUser {
                print(currentUser.uid)
                let uid = currentUser.uid
                let userRef = Firestore.firestore().collection("users").document(uid)
                let data: [String: Any] = [
                    "fcmToken": "null"
                ]
                
                userRef.updateData(data) { error in
                    if let error = error {
                        print("Error removing FCM token from Firestore: \(error.localizedDescription)")
                    } else {
                        print("FCM token removed from Firestore.")
                    }
                }
            }
            
            try FirebaseAuth.Auth.auth().signOut()
            
            UserDefaults.standard.set(false, forKey: "authenticated")
            //TAKE THEM TO LOG IN SCREEN
        }
        catch{
            print("error")
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "SignUpPage") as! ViewController
        newViewController.modalPresentationStyle = .fullScreen
        present(newViewController, animated: false, completion: nil)
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
    
    func deleteAccount() {
        // Get the currently signed-in user
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in")
            return
        }
        
        // Delete the user account from Firebase Authentication
        currentUser.delete { error in
            if let error = error {
                let alert = UIAlertController(title: "Log Out and Log Back In", message: "Log out then log back in again to confirm your account deletion.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
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
    
    @objc func profilePicTapped() {
        // Check camera permission
        self.profBool = true
        let permissionManager = CameraPermissionManager()
        CameraPermissionManager.checkCameraPermission { granted in
            if granted {
                DispatchQueue.main.async {
                    
                    // Camera permission granted, show image picker
                    let imagePickerActionSheet = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
                    
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        let libraryButton = UIAlertAction(title: "Choose from Library", style: .default) { (action) in
                            self.imagePickerController.sourceType = .photoLibrary
                            self.present(self.imagePickerController, animated: true, completion: nil)
                            
                        }
                        imagePickerActionSheet.addAction(libraryButton)
                    }
                    
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        let cameraButton = UIAlertAction(title: "Take Photo", style: .default) { (action) in
                            
                            self.imagePickerController.sourceType = .camera
                            self.present(self.imagePickerController, animated: true, completion: nil)
                            
                        }
                        imagePickerActionSheet.addAction(cameraButton)
                    }
                    
                    let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    imagePickerActionSheet.addAction(cancelButton)
                    
                    self.present(imagePickerActionSheet, animated: true, completion: nil)
                }
                
            } else {
                // Camera permission not granted, show an alert or take appropriate action
                let alertController = UIAlertController(title: "Camera Access Denied", message: "Please allow access to the camera in Settings to use this feature.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            //THIS MEANS YOU ARE EDITING PROFILE IMAGE
            var uid = ""
            if let currentUser = Auth.auth().currentUser {
                // User is signed in
                uid = currentUser.uid
                // Now you can use the `uid` variable to perform any necessary operations
                print("User UID: \(uid)")
            } else {
                // No user is signed in
                print("No user is currently signed in")
            }
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                // Update the profile picture locally
                profilePic.image = selectedImage
                
                // Upload the image to Firebase Storage
                let storageRef = Storage.storage().reference().child("profilePics/\(String(describing: uid)).jpg")
                
                guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
                    return
                }
                
                storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        // Handle the error
                        print("Error uploading image: \(error.localizedDescription)")
                        return
                    }
                    
                    // Once the image is uploaded, get its download URL and store it in Firestore
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Handle the error
                            print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        // Store the download URL in Firestore
                        
                        if let currentUser = Auth.auth().currentUser {
                            // User is signed in
                            let uid = currentUser.uid
                            
                            let userRef = Firestore.firestore().collection("users").document(uid)
                            let data: [String: Any] = [
                                "profilePic": downloadURL.absoluteString,
                            ]
                            
                            userRef.setData(data, merge: true) { error in
                                if let error = error {
                                    // Handle the error
                                    print("Error creating Firestore document: \(error.localizedDescription)")
                                    return
                                }
                                
                                // Success!
                                print("Image uploaded and download URL stored in Firestore!")
                                
                            }
                        } else {
                            // No user is signed in
                            print("No user is currently signed in")
                        }
                    }
                }
            }
            
            dismiss(animated: true, completion: nil)
    }
    
    @IBAction func myFriendsButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "allFriends") as! allFriendsPopUpViewController
        newViewController.modalPresentationStyle = .fullScreen
        present(newViewController, animated: false, completion: nil)
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
