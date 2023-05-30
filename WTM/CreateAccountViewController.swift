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

class CreateAccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var uploadPFP: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    let imagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLayoutSubviews()
        username.borderStyle = .line
        name.borderStyle = .line
        username.backgroundColor = UIColor.white // Set the desired background color
        name.backgroundColor = UIColor.white // Set the desired background color
        username.frame = CGRect(x: username.frame.origin.x, y: username.frame.origin.y, width: username.frame.size.width, height: 50)
        name.frame = CGRect(x: name.frame.origin.x, y: name.frame.origin.y, width: name.frame.size.width, height: 50)




        imagePickerController.delegate = self
        username.placeholder = "username"
        name.placeholder = "name"
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
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "CreateAccount") as! ViewController
        newViewController.modalPresentationStyle = .fullScreen
        present(newViewController, animated: false, completion: nil)*/
    }


    @IBAction func doneTapped(_ sender: Any) {
        //check for empty feilds
        //todo: username cant have spaces, uppercases, can't be used by anyone, must have pfp
        
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
        //just checked if pfp existed ^^^
        
        
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
                print("Image uploaded and download URL stored in Firestore!")
            }
        } else {
            // No user is signed in
            print("No user is currently signed in")
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "TabBarController")
                    vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    
    
}
