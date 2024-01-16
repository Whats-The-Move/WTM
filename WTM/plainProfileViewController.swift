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

class plainProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var profBool = true
    var editLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    //@IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var badgesButton: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    var barStats: UILabel!
    var hours: UILabel!
    @IBOutlet weak var myFriendsButton: UIButton!
    let cities = ["", "Berkeley", "Champaign"]
    var pickerView: UIPickerView!
    var toolbar: UIToolbar!
    
    @IBOutlet weak var addFriendsButton: UIButton!
    //@IBOutlet weak var friendNotification: UIButton!
    
    @IBOutlet weak var changeName: UIButton!
    @IBOutlet weak var changeUsername: UIButton!
    @IBOutlet weak var privacy: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAcct: UIButton!
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isPartyAccount = UserDefaults.standard.bool(forKey: "partyAccount")
        if isPartyAccount {
            showBarProfile()
        }
        else{//show regular acct
            setupConstraints()
            setupStack()
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
            
            pickerView = UIPickerView()
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.backgroundColor = .darkGray

            toolbar = UIToolbar()
            toolbar.sizeToFit()
            toolbar.backgroundColor = .darkGray

            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
            toolbar.setItems([doneButton], animated: true)

            // Add UIPickerView and UIToolbar as subviews
            view.addSubview(pickerView)
            view.addSubview(toolbar)

            // Adjust the frames as needed
            pickerView.frame = CGRect(x: 0, y: view.frame.size.height - pickerView.frame.size.height, width: view.frame.size.width, height: pickerView.frame.size.height)
            toolbar.frame = CGRect(x: 0, y: pickerView.frame.origin.y - toolbar.frame.size.height, width: view.frame.size.width, height: toolbar.frame.size.height)
            pickerView.isHidden = true
            toolbar.isHidden = true
            
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
                            //self.friendNotification.isHidden = true
                        } else{
                            //self.friendNotification.isHidden = false
                            //self.friendNotification.setTitle("\(pendingFriendRequests.count)", for: .normal)
                        }
                    } else {
                        //self.friendNotification.isHidden = true
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

    }
    
    // MARK: - UIPickerViewDataSource and UIPickerViewDelegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cities[row]
    }
    
    @objc func doneButtonTapped() {
        let selectedCity = cities[pickerView.selectedRow(inComponent: 0)]
        if selectedCity != "" {
            currCity = selectedCity
            print(currCity)
            let alert = UIAlertController(title: "City Set", message: "Your current city has been set to \(selectedCity)!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        present(alert, animated: true, completion: nil)
        }

        // Hide UIPickerView and UIToolbar
        UIView.animate(withDuration: 0.3) {
            self.toolbar.frame.origin.y = self.view.frame.size.height
            self.pickerView.frame.origin.y = self.view.frame.size.height
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func addFriendsButton(_ sender: Any) {
        // Show UIPickerView and UIToolbar
        pickerView.isHidden = false
        toolbar.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame.origin.y = self.view.frame.size.height - self.pickerView.frame.size.height
            self.toolbar.frame.origin.y = self.pickerView.frame.origin.y - self.toolbar.frame.size.height
            self.view.layoutIfNeeded()
        }
    }
    
    func setupConstraints() {
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        badgesButton.translatesAutoresizingMaskIntoConstraints = false
        
        editLabel = UILabel()
        editLabel.text = "edit"
        editLabel.font = UIFont(name: "Futura-Medium", size: 16)
        editLabel.textColor = UIColor.gray
        editLabel.translatesAutoresizingMaskIntoConstraints = false
        //addFriendsButton.addSubview(friendNotification)
        view.addSubview(editLabel)
        NSLayoutConstraint.activate([
            // profilePic constraints


            profilePic.widthAnchor.constraint(equalToConstant: 180),
            profilePic.heightAnchor.constraint(equalToConstant: 180),
            profilePic.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profilePic.topAnchor.constraint(equalTo: view.topAnchor, constant: 105),
            profileLabel.widthAnchor.constraint(equalToConstant: 180),
            profileLabel.heightAnchor.constraint(equalToConstant: 50),
            profileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 35),
            // nameLabel constraints
            nameLabel.topAnchor.constraint(equalTo: profilePic.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // usernameLabel constraints
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // badgesButton constraints
            badgesButton.widthAnchor.constraint(equalToConstant: 35),
            badgesButton.heightAnchor.constraint(equalToConstant: 35),
            badgesButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            badgesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            editLabel.centerXAnchor.constraint(equalTo: profilePic.centerXAnchor, constant: 24),
            editLabel.centerYAnchor.constraint(equalTo: profilePic.centerYAnchor),
            editLabel.widthAnchor.constraint(equalToConstant: 80),
            editLabel.heightAnchor.constraint(equalToConstant: 30),
            
//            friendNotification.centerYAnchor.constraint(equalTo: addFriendsButton.centerYAnchor),
//            friendNotification.leadingAnchor.constraint(equalTo: addFriendsButton.trailingAnchor, constant: 0),
//            friendNotification.widthAnchor.constraint(equalToConstant: 35),
//            friendNotification.heightAnchor.constraint(equalToConstant: 35)

            
        
        ])



    }
    func setupStack () {
        let buttons: [UIView] = [myFriendsButton, addFriendsButton, changeName, changeUsername, privacy, logOutButton, deleteAcct]

        // Create a vertical stack view
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        view.addSubview(stackView)

        // Set width constraint for the stack view (400 points, centered)
        stackView.widthAnchor.constraint(equalToConstant: 400).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        // Top constraint for the stack view (50 points above centerY and 20 points from the bottom)
        stackView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 30).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
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
                       // self.friendNotification.isHidden = true
                    } else{
                       // self.friendNotification.isHidden = false
                       // self.friendNotification.setTitle("\(pendingFriendRequests.count)", for: .normal)
                    }
                } else {
                    //self.friendNotification.isHidden = true
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
    
    @IBAction func backButtonTapped(_ sender: Any) {
        // Find the tab bar controller in the view controller hierarchy
        if let tabBarController = self.tabBarController {
            // Switch to the first tab (index 0)
            tabBarController.selectedIndex = 0
        } else if let presentingViewController = self.presentingViewController as? UITabBarController {
            // If presented modally, find the presenting tab bar controller
            presentingViewController.selectedIndex = 0
            self.dismiss(animated: true, completion: nil)
        }
    }
    
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
    
//    @IBAction func addFriendsButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let newViewController = storyboard.instantiateViewController(withIdentifier: "MyFriends") as! MyFriendsViewController
//        newViewController.modalPresentationStyle = .fullScreen
//        present(newViewController, animated: false, completion: nil)
//    }
    
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
        let newViewController = storyboard.instantiateViewController(withIdentifier: "WelcomePage") as! WelcomePageViewController
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
                print("oh no its gonna crash")
                let alertController = UIAlertController(title: "Camera Access Denied", message: "Please allow access to the camera in Settings to use this feature.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            //THIS MEANS YOU ARE EDITING PROFILE IMAGE
        let isPartyAccount = UserDefaults.standard.bool(forKey: "partyAccount")
        var storageBin = ""
        var collectionName = ""
        if isPartyAccount {
            collectionName = "barUsers"
            storageBin = "partyPics/"
        }
        else{
            collectionName = "users"
            storageBin = "profilePics/"
        }
        

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
                let storageRef = Storage.storage().reference().child(storageBin + "\(String(describing: uid)).jpg")
                
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
                            
                            let userRef = Firestore.firestore().collection(collectionName).document(uid)
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
    func showBarProfile () {

        setupConstraints()
        setupStackBarAcct()

        myFriendsButton.isHidden = true
        addFriendsButton.isHidden = true
       // friendNotification.isHidden = true
        badgesButton.isHidden = true
        usernameLabel.isHidden = true
        changeName.isHidden = true
        changeUsername.isHidden = true
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
            print("printing uid" + uid)
            
            let userRef = Firestore.firestore().collection("barUsers").document(uid)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data(), let name = data["venueName"] as? String {
                        // Access the username value
                        print("i found the venue name" + name )
                        self.nameLabel.text = name
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

                
            }
      

        }


        
        //let tapGestureBack = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))

    }
    func setupHours() -> UILabel { //MAYBE I RETURN HOURS LABEL HERE SO I CAN PUT IT INTO BARSTACK????????
        hours = UILabel()
        hours.numberOfLines = 0
        hours.font = UIFont(name: "Futura-Medium", size: 20)
        hours.textColor = UIColor.white
        view.addSubview(hours)
        print("in hours setup")
        // Add a tap gesture recognizer to the label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hoursLabelTapped))
        hours.isUserInteractionEnabled = true
        hours.addGestureRecognizer(tapGesture)

        // Load hours from Firestore and set the label text
        if let currentUserUID = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let userRef = db.collection("barUsers").document(currentUserUID)

            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let hoursText = document["hours"] as? String {
                        DispatchQueue.main.async {
                            self.hours.text = "Hours: " + hoursText
                        }
                    }
                } else {
                    print("Document does not exist in Firestore")
                }
            }
        }
        /*NSLayoutConstraint.activate([
            // profilePic constraints


            hours.widthAnchor.constraint(equalToConstant: 200),
            hours.heightAnchor.constraint(equalToConstant: 80 ),
            hours.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hours.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30)

 
        
        ])
        */
        return hours
    }


    @objc func hoursLabelTapped() {
        print("hours label tapped")
        // Create and show an alert when the label is tapped
        let alert = UIAlertController(title: "Enter Hours", message: "Example: M-F 5pm-11pm, S-S 11am-2am", preferredStyle: .alert)
        
        // Add a text field to the alert for user input
        alert.addTextField { (textField) in
            textField.placeholder = "Enter hours here"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            // Handle the user's input here, e.g., get the entered hours from the text field
            if let textField = alert.textFields?.first, let enteredHours = textField.text {
                // Update the label with the entered hours
                self.hours.text = "Hours: " + enteredHours

                // Update the Firestore database with the entered hours
                if let currentUserUID = Auth.auth().currentUser?.uid {
                    let db = Firestore.firestore()
                    let userRef = db.collection("barUsers").document(currentUserUID)
                    
                    // Merge the changes to avoid overwriting other fields
                    userRef.setData(["hours": enteredHours], merge: true) { error in
                        if let error = error {
                            print("Error updating Firestore: \(error)")
                        } else {
                            print("Hours updated successfully in Firestore")
                        }
                    }
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(submitAction)
        
        self.present(alert, animated: true, completion: nil)
    }


    func setupStackBarAcct () {
        barStats = UILabel()
        barStats.text = "Stats: Coming Soon!"
        barStats.numberOfLines = 0
        barStats.font = UIFont(name: "Futura-Medium", size: 32)
        barStats.textColor = UIColor.white

        view.addSubview(barStats)

        let hoursLabel = setupHours()
        let buttons: [UIView] = [hoursLabel, barStats, myFriendsButton, addFriendsButton, changeName, changeUsername, privacy, logOutButton, deleteAcct]

        // Create a vertical stack view
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        view.addSubview(stackView)

        // Set width constraint for the stack view (400 points, centered)
        stackView.widthAnchor.constraint(equalToConstant: 400).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        // Top constraint for the stack view (50 points above centerY and 20 points from the bottom)
        stackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 60).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
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
