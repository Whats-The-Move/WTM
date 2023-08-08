//
//  CreateAccountViewController.swift
//  WTM
//
//  Created by Aman Shah on 5/30/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseMessaging

class CreateAccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {


    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var uploadPFP: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    let imagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        username.delegate = self
        name.delegate = self
        
        viewDidLayoutSubviews()
        username.borderStyle = .line
        name.borderStyle = .line
        username.backgroundColor = UIColor.white // Set the desired background color
        name.backgroundColor = UIColor.white // Set the desired background color
        name.textColor = .black
        username.textColor = .black
        username.autocapitalizationType = .none
        imagePickerController.delegate = self
        let usernamePlaceholder = "Create username"
        let namePlaceholder = "Create display name"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray,  // Set the desired color here
        ]
        let attributedUsernamePlaceholder = NSAttributedString(string: usernamePlaceholder, attributes: attributes)
        let attributedNamePlaceholder = NSAttributedString(string: namePlaceholder, attributes: attributes)
        
        // Set the attributed string as the placeholder of the text field
        username.attributedPlaceholder = attributedUsernamePlaceholder
        name.attributedPlaceholder = attributedNamePlaceholder
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.updateData([
            "profilePic":  "https://firebasestorage.googleapis.com:443/v0/b/whatsthemove-1b3f6.appspot.com/o/profilePics%2FmiI524oOPzV36XHg4pBq8cro6RN2.jpg?alt=media&token=95861ebb-a7ce-4c7d-90ff-5e017e910e40"
        ])
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("doc exists")
                if let imageURLString = document.data()?["profilePic"] as? String,
                   
                   let imageURL = URL(string: imageURLString) {
                    print(imageURLString)
                    DispatchQueue.global().async {
                        if let imageData = try? Data(contentsOf: imageURL) {
                            DispatchQueue.main.async {
                                let image = UIImage(data: imageData)
                                self.profilePic.image = image
                            }
                        }
                    }
                }
                else{
                    let backupProfile = "https://via.placeholder.com/150/CCCCCC/FFFFFF?text="
                    if let backupImageURL = URL(string: backupProfile) {
                        DispatchQueue.global().async {
                            if let imageData = try? Data(contentsOf: backupImageURL) {
                                DispatchQueue.main.async {
                                    let image = UIImage(data: imageData)
                                    self.profilePic.image = image
                                }
                            }
                        }
                    }
                }
            } else {
                print("User document not found")
            }
        }


        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let minDimension = min(profilePic.frame.size.width, profilePic.frame.size.height)
            profilePic.layer.cornerRadius = minDimension / 2
            profilePic.clipsToBounds = true
            profilePic.contentMode = .scaleAspectFill

        username.borderStyle = .line
        name.borderStyle = .line
        username.backgroundColor = UIColor.white // Set the desired background color
        name.backgroundColor = UIColor.white // Set the desired background color
        profilePic.frame = CGRect(x: profilePic.frame.origin.x, y: profilePic.frame.origin.y, width: 150, height: 150)
        uploadPFP.frame = CGRect(x: profilePic.frame.origin.x, y: profilePic.frame.origin.y + 167, width: 150, height: 30)
        username.frame = CGRect(x: username.frame.origin.x, y: uploadPFP.frame.origin.y + 60, width: username.frame.size.width, height: 40)
        name.frame = CGRect(x: name.frame.origin.x, y: username.frame.origin.y + 55, width: name.frame.size.width, height: 40)
        doneButton.frame = CGRect(x: uploadPFP.frame.origin.x, y: name.frame.origin.y + 60, width: uploadPFP.frame.size.width, height: 30)

    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        // Calculate the height of the keyboard
        let keyboardHeight = keyboardFrame.size.height

        // Check if the text field is hidden by the keyboard
        if username.isFirstResponder || name.isFirstResponder {
            let maxY = max(username.frame.maxY, name.frame.maxY)
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

    @objc func keyboardWillHide(notification: Notification) {
        // Restore the original position of the view
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }

    @IBAction func uploadPFPclicked(_ sender: Any) {
        print("edit clicked")
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
        
        present(imagePickerActionSheet, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
            // Upload the image to Firebase Storage
            let storageRef = Storage.storage().reference().child("profilePics/\(String(describing: uid)).jpg")
            //"partyImages/\(UUID().uuidString).jpg"
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
                            //update profilePic here
                            let userRef = Firestore.firestore().collection("users").document(uid)
                            
                            userRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    print("doc exists")
                                    if let imageURLString = document.data()?["profilePic"] as? String,
                                       
                                       let imageURL = URL(string: imageURLString) {
                                        print(imageURLString)
                                        DispatchQueue.global().async {
                                            if let imageData = try? Data(contentsOf: imageURL) {
                                                DispatchQueue.main.async {
                                                    let image = UIImage(data: imageData)
                                                    self.profilePic.image = image
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        let backupProfile = "https://via.placeholder.com/150/CCCCCC/FFFFFF?text="
                                        if let backupImageURL = URL(string: backupProfile) {
                                            DispatchQueue.global().async {
                                                if let imageData = try? Data(contentsOf: backupImageURL) {
                                                    DispatchQueue.main.async {
                                                        let image = UIImage(data: imageData)
                                                        self.profilePic.image = image
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    print("User document not found")
                                }
                            }
                            
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func checkUsernameAvailability(username: String, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        
        let query = usersCollection.whereField("username", isEqualTo: username)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle the error
                completion(false, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                // No documents found, username is available
                completion(true, nil)
                return
            }
            
            // If any documents are found, the username is already taken
            let isTaken = !documents.isEmpty
            completion(!isTaken, nil)
        }
    }
    @IBAction func doneTapped(_ sender: Any) {
        //check for empty feilds
        //todo: username cant have spaces, uppercases, can't be used by anyone, must have pfp
//check for empty
        guard let username = username.text, !username.isEmpty,
              let name = name.text, !name.isEmpty
        else{
            print("missing field data")
            let alert = UIAlertController(title: "Alert", message: "Fill the blanks", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sorry I won't do it again", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
            return
        }
        //check for spaces
        if username.contains(" ") {
            print("Username contains spaces")
            let alert = UIAlertController(title: "Alert", message: "Username should not contain spaces", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Firestore.firestore().collection("users").document(uid)
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data(), data["profilePic"] != nil {
                        // Profile picture exists
                        // Proceed with further actions
                        print("profilePic exists in this user")
                    } else {
                        // Profile picture doesn't exist
                        let alert = UIAlertController(title: "Alert", message: "Profile picture doesn't exist", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                } else {
                    print("Document does not exist")
                    let alert = UIAlertController(title: "Alert", message: "User document not found", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        //just checked if pfp was submitted ^^^
        checkUsernameAvailability(username: username) { isAvailable, error in
            if let error = error {
                // Handle the error
                print("Error checking username availability: \(error.localizedDescription)")
                return
            }
            if isAvailable {
                // Username is available
                print("Username is available")
                if let currentUser = Auth.auth().currentUser {
                    // User is signed in
                    let uid = currentUser.uid
                    
                    let userRef = Firestore.firestore().collection("users").document(uid)
                    let data: [String: Any] = [
                        "username": username ,
                        "name": name
                    ]
                    userRef.setData(data, merge: true) { error in
                        if let error = error {
                            // Handle the error
                            print("Error creating Firestore document: \(error.localizedDescription)")
                            return
                        }
                        // Success!
                        print("added username and name")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let appHomeVC = storyboard.instantiateViewController(identifier: "createAddFriend")
                        appHomeVC.modalPresentationStyle = .overFullScreen
                        self.present(appHomeVC, animated: true)
                    }
                } else {
                    // No user is signed in
                    print("No user is currently signed in")
                }
            } else {
                // Username is already taken
                print("Username is already taken")
                let alert = UIAlertController(title: "Alert", message: "Username taken", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return // Exit the entire function
            }
        }
    }
}
