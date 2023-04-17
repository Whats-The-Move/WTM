//
//  PartyAcctViewController.swift
//  WTM
//
//  Created by Aman Shah on 4/5/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class PartyAcctViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
 
    @IBOutlet weak var partyName: UITextField!
    @IBOutlet weak var venueAddress: UITextField!
    @IBOutlet weak var personName: UITextField!
    @IBOutlet weak var contactEmail: UITextField!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var certificateUpload: UIButton!
    @IBOutlet weak var success: UILabel!
    
    @IBOutlet weak var borderView: UIView!
    let imagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLayoutSubviews()
        
        imagePickerController.delegate = self



        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        borderView.layer.cornerRadius = 6
        borderView.layer.borderWidth = 8
        borderView.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 10

        partyName.placeholder = "Name of Frat/Bar/Party"
        personName.placeholder = "Name of Person who is point of contact"
        contactEmail.placeholder = "Email address of primary contact"
        venueAddress.placeholder = "Address of Frat/Bar/Party"
        uploadLabel.text = "Upon submission, upload photo proof that you are a legitimate Bar/Frat/Club (business registration, liquor license, etc). Don't waste our fucking time with genitalia (balls, tits, etc)"
        uploadLabel.numberOfLines = 0
        uploadLabel.lineBreakMode = .byWordWrapping
        uploadLabel.textAlignment = .center
        success.isHidden = true
        success.frame = CGRect(x: 20,
                                  y: certificateUpload.frame.origin.y + certificateUpload.frame.size.height + 10,
                                  width: view.frame.size.width - 40,
                                  height: 50)
        partyName.frame = CGRect(x: 20,
                                  y: certificateUpload.frame.origin.y + certificateUpload.frame.size.height ,
                                  width: view.frame.size.width - 40,
                                  height: 50)
        
       
    }

    @IBAction func certificateUploadTapped(_ sender: Any) {
        guard let partyName = partyName.text, !partyName.isEmpty,
                let personName = personName.text, !personName.isEmpty,
                let contactEmail = contactEmail.text, !contactEmail.isEmpty,
                let venueAddress = venueAddress.text, !venueAddress.isEmpty
        else{
            let alert = UIAlertController(title: "Alert", message: "missing field data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
            print("missing field data")
            return
        }
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
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                // Upload the image to Firebase Storage
            let storageRef = Storage.storage().reference().child("partyImages/\(String(describing: self.partyName.text)).jpg")
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
                        let userRef = Firestore.firestore().collection("pendingParty").document()
                        let data: [String: Any] = [
                           
                            "imageUrl": downloadURL.absoluteString,
                            "venueName": self.partyName.text,
                            "venueAddress": self.venueAddress.text,
                            "email": self.contactEmail.text,
                            "personName" : self.personName.text
                            // Add other fields as needed
                        ]
                        userRef.setData(data) { error in
                            if let error = error {
                                // Handle the error
                                print("Error creating Firestore document: \(error.localizedDescription)")
                                return
                            }
                            
                            // Success!
                            self.success.isHidden = false
                            print("Image uploaded and download URL stored in Firestore!")
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
