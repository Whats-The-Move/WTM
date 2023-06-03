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
    var imageFromLast = 1
    @IBOutlet weak var userbox: UILabel!
    @IBOutlet weak var emailbox: UILabel!
    let imagePickerController = UIImagePickerController()

    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mainPicture: UIImageView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var forwardButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLayoutSubviews()
        imagePickerController.delegate = self
        updateDateLabel()
        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data(), let username = data["username"] as? String {
                        // Access the username value
                        
                        self.userbox.text = "Hey " + username + "!"
                    }
                }
                
            }
        }

        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data(), let email = data["email"] as? String {
                        // Access the username value
                        
                        self.emailbox.text = "Email: " + email 
                    }
                }
                
            }
        }



        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageURLString = document.data()?["profilePic"] as? String,
                   
                   let imageURL = URL(string: imageURLString) {
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        mainPicture.layer.cornerRadius = mainPicture.frame.size.width / 2
        mainPicture.clipsToBounds = true
        mainPicture.contentMode = .scaleAspectFill
        //backButton.setTitle("", for: .normal)
        //forwardButton.setTitle("", for: .normal)
        //dateLabel.text = "hello"

    }
    func loadImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    imageView.image = image
                }
            }
        }
    }

    func updateDateLabel(selectedIndex: Int = 1) {
        // Assuming you have an outlet for your date label
        guard let dateLabel = dateLabel else {
            return
        }
        
        // Get the current user's UID
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            return
        }
        
        // Reference to the user's document in the "users" collection
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        // Get the "images" field from the user's document
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Retrieve the images dictionary from the document
                let imagesDict = document.data()?["images"] as? [String: [String]] ?? [:]
                
                // Sort the dates in descending order
                let sortedDates = imagesDict.keys.sorted(by: >)
                
                // Check if there are any dates available
                guard sortedDates.count >= selectedIndex else {
                    print("Not enough images found for the selected index")
                    //not enough images, set imagefromlast back to what it was earlier
                    self.imageFromLast -= 1
                    
                    return
                }
                
                // Retrieve the image URLs for the selected date
                let selectedDate = sortedDates[max(selectedIndex - 1, 0)]
                if let imageUrls = imagesDict[selectedDate] {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    
                    // Convert the selected date to the desired string format
                    let dateString = dateFormatter.string(from: dateFormatter.date(from: selectedDate)!)
                    
                    // Set the date string to the label
                    dateLabel.text = dateString
                    
                    // Use the imageUrls array as needed
                    // For example, you can display the first image URL in an image view
                    if let firstImageUrl = imageUrls.first {
                        // Set the image to your image view
                        self.loadImage(from: firstImageUrl, to: self.mainPicture)
                    }
                } else {
                    print("No image URLs found for the selected date")
                }
            } else {
                print("User document does not exist")
            }
        }
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
        viewDidLoad()
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
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.imageFromLast += 1
        updateDateLabel(selectedIndex: self.imageFromLast)
    }
    @IBAction func forwardButtonTapped(_ sender: Any) {
        if self.imageFromLast > 1 {
            self.imageFromLast -= 1
        }
        updateDateLabel(selectedIndex: self.imageFromLast)

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
