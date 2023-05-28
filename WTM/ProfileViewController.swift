//
//  ProfileViewController.swift
//  WTM
//
//  Created by Aman Shah on 2/26/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    @IBOutlet weak var userbox: UILabel!
    @IBOutlet weak var userbox: UILabel!
    @IBOutlet weak var emailbox: UILabel!
    let imagePickerController = UIImagePickerController()

    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLayoutSubviews()
        imagePickerController.delegate = self

        let user_address1 = UserDefaults.standard.string(forKey: "user_address") ?? "none"
        userbox.text =  "username: " + user_address1
        let email_address1 = user_address1 + "@illinois.edu"
        emailbox.text =  "email: " + email_address1



        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
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
                    let backupProfile = "https://via.placeholder.com/150/CCCCCC/FFFFFF?text=Profile"
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
    }

    
    @IBAction func editProfileClicked(_ sender: Any) {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
