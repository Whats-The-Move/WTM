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
    
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var uploadPFP: UIButton!
    
    var email: UITextField!
    var password: UITextField!
    var phone: UITextField!
    var username: UITextField!
    var name: UITextField!
    var interests: UITextField!
    var imageURL = ""
    
    
    
    @IBOutlet weak var doneButton: UIButton!
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [email, password, phone, username, name, interests, doneButton])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        //stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    let imagePickerController = UIImagePickerController()
    var backButton: UIButton = {
        let button = UIButton()
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysTemplate)
        button.setImage(backImage, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15 // half of the desired height
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Button Actions
    
    @objc func backButtonTapped() {
        // Handle back button tap
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        email = createTextField(placeholder: "Email")
        password = createTextField(placeholder: "Password", isSecure: true)
        password.isSecureTextEntry = true
        phone = createTextField(placeholder: "Phone Number")
        username = createTextField(placeholder: "Username")
        name = createTextField(placeholder: "Display Name")
        interests = createTextField(placeholder: "List 3 Interests")
        
        setupConstraints()
        setupShowPasswordButton()
        
        
        username.delegate = self
        name.delegate = self
        email.delegate = self
        password.delegate = self
        phone.delegate = self
        interests.delegate = self
        imagePickerController.delegate = self
        
        
        // Add the backButton to your view hierarchy, then apply these constraints
        
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupUI()
        
        
        // Do any additional setup after loading the view.
    }
    private func setupConstraints() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            stackView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
            // Adjust centerYAnchor based on your layout requirements
        ])
        NSLayoutConstraint.activate([
            profilePic.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            profilePic.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15),
            profilePic.heightAnchor.constraint(equalToConstant: 150),
            profilePic.widthAnchor.constraint(equalToConstant: 150)
            // Adjust centerYAnchor based on your layout requirements
        ])
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            doneButton.widthAnchor.constraint(equalToConstant: 200)
            // Adjust centerYAnchor based on your layout requirements
        ])
    }
    func createTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        //textField.isSecureTextEntry = isSecure
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 8.0 // You can adjust the radius value as needed
        textField.clipsToBounds = true // Add this line
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Set background color and border color
        textField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Light gray
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1.0
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.widthAnchor.constraint(equalToConstant: 200),
            // Adjust centerYAnchor based on your layout requirements
        ])
        
        return textField
    }
    
    func setupUI(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(_:)))
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(tapGesture)
        
        name.textColor = .black
        username.textColor = .black
        username.autocapitalizationType = .none
        password.autocapitalizationType = .none
        email.autocapitalizationType = .none
        profilePic.layer.cornerRadius = 75
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        phone.keyboardType = .phonePad

        


        
        
        //profilePic.image = UIImage(named: "profileIcon")
        /*guard let uid = Auth.auth().currentUser?.uid else {
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
         
         let placeholderImage = UIImage(named: "placeholder") // Replace "placeholder" with your default placeholder image name
         
         self.profilePic.kf.setImage(with: imageURL, placeholder: placeholderImage) { result in
         switch result {
         case .success(let value):
         print("Image downloaded: \(value.source.url?.absoluteString ?? "")")
         case .failure(let error):
         print("Image download failed: \(error.localizedDescription)")
         }
         }
         } else {
         let backupProfile = "https://via.placeholder.com/150/CCCCCC/FFFFFF?text="
         if let backupImageURL = URL(string: backupProfile) {
         let placeholderImage = UIImage(named: "placeholder") // Replace "placeholder" with your default placeholder image name
         
         self.profilePic.kf.setImage(with: backupImageURL, placeholder: placeholderImage) { result in
         switch result {
         case .success(let value):
         print("Backup image downloaded: \(value.source.url?.absoluteString ?? "")")
         case .failure(let error):
         print("Backup image download failed: \(error.localizedDescription)")
         }
         }
         }
         }
         } else {
         print("User document not found")
         }
         }*/
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
    
    @objc func profileImageTapped(_ sender: Any) {
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

        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Upload the image to Firebase Storage
            profilePic.image = selectedImage
            let storageRef = Storage.storage().reference().child("profilePics/\(UUID().uuidString).jpg")
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
                    self.imageURL = downloadURL.absoluteString
                    
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
    func setupBackButton(){
        view.addSubview(backButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
    }
    private func setupShowPasswordButton() {
        let showPasswordButton = UIButton(type: .custom)
        showPasswordButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        showPasswordButton.tintColor = .black
        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        showPasswordButton.addTarget(self, action: #selector(showPassword), for: .touchUpInside)
        view.addSubview(showPasswordButton)
        
        NSLayoutConstraint.activate([
            showPasswordButton.widthAnchor.constraint(equalToConstant: 20),
            showPasswordButton.heightAnchor.constraint(equalToConstant: 20),
            showPasswordButton.centerYAnchor.constraint(equalTo: password.centerYAnchor),
            showPasswordButton.trailingAnchor.constraint(equalTo: password.trailingAnchor, constant: -10)
        ])
    }
    
    // Function to toggle the visibility of the password text field
    @objc private func showPassword() {
        password.isSecureTextEntry = !password.isSecureTextEntry
    }
    @IBAction func doneTapped(_ sender: Any) {
        //check for empty feilds
        //todo: username cant have spaces, uppercases, can't be used by anyone, must have pfp
        //check for empty
        
        // Check for empty fields
        guard let username = username.text, !username.isEmpty,
              let name = name.text, !name.isEmpty,
              let email = email.text, !email.isEmpty,
              let password = password.text, !password.isEmpty,
              let phone = phone.text, !phone.isEmpty,
              let interests = interests.text, !interests.isEmpty,
              self.imageURL != ""
        else {
            print("Missing field data")
            let alert = UIAlertController(title: "Alert", message: "Fill in all the fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        if email.contains(".edu") == false {
            print("it says use SCHOOL email")
            let alert = UIAlertController(title: "Alert", message: "Please use your school (.edu) email.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sorry, I won't do it again.", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
            
        return
        }
        // Check for spaces in the username
        if username.contains(" ") {
            print("Username contains spaces")
            let alert = UIAlertController(title: "Alert", message: "Username should not contain spaces", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        checkUsernameAvailability(username: username) { isAvailable, error in
            if let error = error {
                // Handle the error
                print("Error checking username availability: \(error.localizedDescription)")
                return
            }
          
            if isAvailable {
                // Create a new user with email and password
                Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                    if let error = error {
                        // Handle the error
                        print("Error creating user: \(error.localizedDescription)")
                        let alert = UIAlertController(title: "Alert", message: "Error creating user", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    // User successfully created, proceed with adding data to Firestore
                    if let authResult = authResult {
                        let uid = authResult.user.uid
                        let userRef = Firestore.firestore().collection("users").document(uid)
                        
                        let data: [String: Any] = [
                            "email": email,
                            "username": username,
                            "name": name,
                            "phone": phone,
                            "interests": interests,
                            "profilePic": self.imageURL,
                            "uid": uid,
                            "images": [],
                            "bestFriends": [],
                            "friends": [],
                            "fcmToken": userFcmToken,
                            "pendingFriendRequests": [],
                            "spots": []
                        ]
                        
                        userRef.setData(data, merge: true) { error in
                            if let error = error {
                                // Handle the error
                                print("Error creating Firestore document: \(error.localizedDescription)")
                                let alert = UIAlertController(title: "Alert", message: "Error creating Firestore document", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                            
                            // Success!
                            UserDefaults.standard.set(true, forKey: "authenticated")

                            print("Added username, name, phone, and interests")
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let appHomeVC = storyboard.instantiateViewController(identifier: "createAddFriend")
                            appHomeVC.modalPresentationStyle = .overFullScreen
                            self.present(appHomeVC, animated: true)
                        }
                    }
                }
          
            }
            else{
                // Username is already taken
                print("Username is already taken")
                let alert = UIAlertController(title: "Alert", message: "Username taken", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return // Exit the entire function
            }
        }
        // Check if the username is valid (add your validation logic here)

        
      
    }
}
/*
 guard let username = username.text, !username.isEmpty,
       let name = name.text, !name.isEmpty,
       let email = email.text, !email.isEmpty,
       let password = password.text, !password.isEmpty,
       let phone = phone.text, !phone.isEmpty,
       let interests = interests.text, !interests.isEmpty

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
 */
