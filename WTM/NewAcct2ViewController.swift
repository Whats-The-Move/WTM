//
//  NewAcct2ViewController.swift
//  WTM
//
//  Created by Aman Shah on 1/12/24.
//

import UIKit
import FirebaseStorage

class NewAcct2ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imageURL = ""
    var backButton: UIButton!
    var descriptionLabel: UILabel!
    //var profilePic: UIImageView!

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    
    
    let imagePickerController = UIImagePickerController()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self

        
        let vc = NewAcctLandingViewController()
        backButton = vc.createBackButton()
        view.addSubview(backButton)
        descriptionLabel = vc.createLabel(text: "Upload your profile picture", fontSize: 36)
        view.addSubview(descriptionLabel)
        
        setupProfilePic()

        setupConstraints()
        // Do any additional setup after loading the view.
    }
    func setupConstraints(){
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16), // Adjust as needed
            descriptionLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10), // Adjust as needed
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 120),
        ])

        
    }
    func setupProfilePic (){
        //profilePic = UIImageView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(_:)))
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(tapGesture)
        profilePic.layer.cornerRadius = profilePic.frame.width / 2
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        profilePic.image = UIImage(named: "pinkPFP")
        view.addSubview(profilePic)
    }
    @IBAction func continueTapped(_ sender: Any) {
        
              
            

        if self.imageURL == "" {
            print("missing field data")
            let alert = UIAlertController(title: "Alert", message: "Upload your profile picture (it can be changed later)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sorry I won't do it again", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
            return
        }
        
        createImageURL = self.imageURL
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CreateAccount3")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
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
                    self.profilePic.image = selectedImage

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
