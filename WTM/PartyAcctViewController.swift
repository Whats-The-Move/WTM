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

class PartyAcctViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var partyName: UITextField!
    
    var personName: UITextField!
    
    var contactEmail: UITextField!
    
    var venueAddress: UITextField!
    
    var uploadLabel: UILabel!
    
    var certificateUpload: UIButton!
    
    var success: UILabel!
    var fail: UILabel!

    
    var borderView: UIView!
    
    var backButton: UIButton!
    
    let imagePickerController = UIImagePickerController()
    
    var lineView: UIView!
    
    var barLoginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPartyName()

        setupBackButton()
        
        setupVenueAddress()
        setupPersonName()
        setupContactEmail()
        setupUploadLabel()
        setupCertificateUploadButton()
        setupSuccess()
        success.isHidden = true
        setupFail()
        fail.isHidden = true
        setupLineView()
        setupBarLoginButton()
        imagePickerController.delegate = self
        certificateUpload.addTarget(self, action: #selector(certificateUploadTapped), for: .touchUpInside)

    }
    
    func setupBackButton() {
        backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the button image and tint color to black
        backButton.setImage(UIImage(systemName: "chevron.backward.circle"), for: .normal)
        backButton.tintColor = .black
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Enable user interaction for the button
        backButton.isUserInteractionEnabled = true
        
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func backButtonTapped() {
        // Handle the button tap event here, e.g., dismiss the view controller
        self.dismiss(animated: true, completion: nil)
    }

    func setupPartyName() {
        partyName = UITextField()
        partyName.borderStyle = .roundedRect
        partyName.clipsToBounds = true

        partyName.placeholder = "Name of Frat/Bar/Party"
        partyName.backgroundColor = .white // Set background color to white
        partyName.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size
        partyName.layer.cornerRadius = 10 // Add rounded corners
        partyName.layer.borderWidth = 1.0 // Add border
        partyName.layer.borderColor = UIColor.black.cgColor // Set border color to black
        partyName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(partyName)

        NSLayoutConstraint.activate([
            partyName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            partyName.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -160),
            partyName.widthAnchor.constraint(equalToConstant: 300), // Set width to 300
            partyName.heightAnchor.constraint(equalToConstant: 35) // Set height to 35
        ])
    }
    

    func setupVenueAddress() {
        venueAddress = UITextField()
        venueAddress.borderStyle = .roundedRect
        venueAddress.clipsToBounds = true

        venueAddress.placeholder = "Address of Frat/Bar/Party"
        venueAddress.backgroundColor = .white // Set background color to white
        venueAddress.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size
        venueAddress.layer.cornerRadius = 10 // Add rounded corners
        venueAddress.layer.borderWidth = 1.0 // Add border
        venueAddress.layer.borderColor = UIColor.black.cgColor // Set border color to black
        venueAddress.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(venueAddress)

        NSLayoutConstraint.activate([
            venueAddress.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            venueAddress.topAnchor.constraint(equalTo: partyName.bottomAnchor, constant: 20),
            venueAddress.widthAnchor.constraint(equalToConstant: 300), // Set width to 300
            venueAddress.heightAnchor.constraint(equalToConstant: 35) // Set height to 35
        ])
    }

    func setupPersonName() {
        personName = UITextField()
        personName.borderStyle = .roundedRect
        personName.clipsToBounds = true

        personName.placeholder = "Name of Person who is point of contact"
        personName.backgroundColor = .white // Set background color to white
        personName.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size
        personName.layer.cornerRadius = 10 // Add rounded corners
        personName.layer.borderWidth = 1.0 // Add border
        personName.layer.borderColor = UIColor.black.cgColor // Set border color to black
        personName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(personName)

        NSLayoutConstraint.activate([
            personName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            personName.topAnchor.constraint(equalTo: venueAddress.bottomAnchor, constant: 20),
            personName.widthAnchor.constraint(equalToConstant: 300), // Set width to 300
            personName.heightAnchor.constraint(equalToConstant: 35) // Set height to 35
        ])
    }

    func setupContactEmail() {
        contactEmail = UITextField()
        contactEmail.borderStyle = .roundedRect
        contactEmail.clipsToBounds = true
        contactEmail.placeholder = "Email address of primary contact"
        contactEmail.backgroundColor = .white // Set background color to white
        contactEmail.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size

        contactEmail.layer.cornerRadius = 10 // Add rounded corners
        contactEmail.layer.borderWidth = 1.0 // Add border

        contactEmail.layer.borderColor = UIColor.black.cgColor // Set border color to black
        contactEmail.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contactEmail)

        NSLayoutConstraint.activate([
            contactEmail.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contactEmail.topAnchor.constraint(equalTo: personName.bottomAnchor, constant: 20),
            contactEmail.widthAnchor.constraint(equalToConstant: 300), // Set width to 300
            contactEmail.heightAnchor.constraint(equalToConstant: 35) // Set height to 35
        ])
    }
    func setupUploadLabel() {
        uploadLabel = UILabel()
        uploadLabel.text = "Upon clicking submit below, you'll have to submit proof that you are a registered organization (liquor license, frat registration, etc.)"
        uploadLabel.textColor = .black // Set text color to black
        uploadLabel.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size
        uploadLabel.numberOfLines = 0 // Allow multiple lines for long text
        uploadLabel.textAlignment = .center // Center-align the text
        uploadLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uploadLabel)

        NSLayoutConstraint.activate([
            uploadLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadLabel.topAnchor.constraint(equalTo: contactEmail.bottomAnchor, constant: 20), // 20px below contactEmail
            uploadLabel.widthAnchor.constraint(equalToConstant: 300), // 20px below contactEmail

        ])
    }


    func setupCertificateUploadButton() {
        certificateUpload = UIButton()

        certificateUpload.setTitle("Upload and Submit", for: .normal)
        certificateUpload.setTitleColor(.white, for: .normal) // Set text color to white

        certificateUpload.backgroundColor = .black // Set background fill color to white
        certificateUpload.layer.cornerRadius = 10 // Add rounded corners
        certificateUpload.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(certificateUpload)

        NSLayoutConstraint.activate([
            certificateUpload.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            certificateUpload.topAnchor.constraint(equalTo: uploadLabel.bottomAnchor, constant: 20),
            certificateUpload.widthAnchor.constraint(equalToConstant: 300), // Set width to 300
            certificateUpload.heightAnchor.constraint(equalToConstant: 35) // Set height to 35
        ])
    }
    
    func setupSuccess() {
        success = UILabel()
        success.text = "Application submitted successfully"
        success.textColor = .black // Set text color to black
        success.font = UIFont(name: "Futura-Medium", size: 16) // Set font style and size
        success.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(success)

        NSLayoutConstraint.activate([
            success.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            success.topAnchor.constraint(equalTo: certificateUpload.bottomAnchor, constant: 20), // 20px under certificateUpload button
        ])
    }
    func setupFail() {
        fail = UILabel()
        fail.numberOfLines = 0 // Allow text to wrap to multiple lines

        fail.text = "That didn't work. Try again later or email support @ aman04shah@gmail.com"
        fail.textColor = .black // Set text color to black
        fail.font = UIFont(name: "Futura-Medium", size: 16) // Set font style and size
        fail.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fail)

        NSLayoutConstraint.activate([
            fail.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fail.topAnchor.constraint(equalTo: certificateUpload.bottomAnchor, constant: 20), // 20px under certificateUpload button
            fail.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20)
        ])
    }
    func setupLineView() {
        lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .white
        // Set the button image and tint color to black

        
 
        
        // Enable user interaction for the button
        
        view.addSubview(lineView)

        NSLayoutConstraint.activate([
            lineView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lineView.topAnchor.constraint(equalTo: fail.bottomAnchor, constant: 20),
            lineView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    func setupBarLoginButton() {
        barLoginButton = UIButton()
        barLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the button title and styling
        barLoginButton.setTitle("Already been approved? Sign in instead", for: .normal)
        barLoginButton.setTitleColor(.black, for: .normal)
        barLoginButton.backgroundColor = .white
        barLoginButton.layer.borderWidth = 2.0
        barLoginButton.layer.borderColor = UIColor.black.cgColor
        barLoginButton.titleLabel?.adjustsFontSizeToFitWidth = true
        barLoginButton.titleLabel?.minimumScaleFactor = 0.5 // You can adjust this value as needed.
        barLoginButton.layer.cornerRadius = 8
        barLoginButton.clipsToBounds = true
        barLoginButton.addTarget(self, action: #selector(barLoginTapped), for: .touchUpInside)
        
        // Enable user interaction for the button
        barLoginButton.isUserInteractionEnabled = true
        
        view.addSubview(barLoginButton)
        
        NSLayoutConstraint.activate([
            barLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            barLoginButton.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 20),
            barLoginButton.widthAnchor.constraint(equalToConstant: 370),
            barLoginButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }


    @objc func barLoginTapped() {
        // Handle the button tap event here, e.g., dismiss the view controller
        //take to bar login screen
    }


  @objc func certificateUploadTapped(_ sender: Any) {
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
            let storageRef = Storage.storage().reference().child("pendingParties/\(String(describing: self.partyName.text)).jpg")
            //"partyImages/\(UUID().uuidString).jpg"
                guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
                    return
                }
                storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        // Handle the error
                        print("Error uploading image: \(error.localizedDescription)")
                        self.fail.isHidden = false

                        return
                    }
                    
                    // Once the image is uploaded, get its download URL and store it in Firestore
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Handle the error
                            print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                            self.fail.isHidden = false

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
                                self.fail.isHidden = false

                                return
                            }
                            
                            // Success!
                            self.success.isHidden = false
                            self.fail.isHidden = true
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
