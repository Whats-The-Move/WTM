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
import FSCalendar

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FSCalendarDelegate, FSCalendarDataSource {
//    @IBOutlet weak var userbox: UILabel!
    var datesWithPictures: [String] = []
    var currentDateIndex: Int = 0
    var currentImages: [String] = []
    var profBool = true
    var calendar = FSCalendar()
    let imagePickerController = UIImagePickerController()
    let noImagesForDate = "https://firebasestorage.googleapis.com:443/v0/b/whatsthemove-1b3f6.appspot.com/o/partyImages%2FF6680144-0DFE-412B-AF1A-08153AFE1372.jpg?alt=media&token=bb0f479b-3f93-4e33-add6-eb34a36bbdd5"
    let noImages = "https://firebasestorage.googleapis.com:443/v0/b/whatsthemove-1b3f6.appspot.com/o/partyImages%2FD23F9AEA-7F6A-4AF9-9DF8-E051A6F0F11A.jpg?alt=media&token=fa278d02-f1c0-4668-a260-873aac0dd6fc"
    let db = Firestore.firestore()

    @IBOutlet weak var userbox: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editNameImage: UIImageView!

    @IBOutlet weak var bkgdView: UIView!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mainPicture: UIImageView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var badgesButton: UIButton!
    @IBOutlet weak var addFriends: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet weak var imageUploadButton: UIButton!
    
    @IBOutlet weak var creatorPic: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //mainPicture.image = UIImage(named: "default_photo")
        

        mainPicture.isUserInteractionEnabled = true
        let pictapGesture = UITapGestureRecognizer(target: self, action: #selector(mainPictureTapped))
        mainPicture.addGestureRecognizer(pictapGesture)
        //viewDidLayoutSubviews()
        imagePickerController.delegate = self
        calendar.delegate = self // Make sure your view controller conforms to the FSCalendarDelegate protocol
        calendar.dataSource = self // Make sure your view controller conforms to the FSCalendarDataSource protocol
        updateDateLabel()
        calendar.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateLabelTapped))
            dateLabel.addGestureRecognizer(tapGesture)
            dateLabel.isUserInteractionEnabled = true
        
        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data(), let username = data["username"] as? String {
                        // Access the username value
                        
                        self.userbox.text = "username: " + username
                    }
                }
                
            }
        }

        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data(), let name = data["name"] as? String {
                        self.nameLabel.text = name
                        
                        
                    }
                }
                
            }
        }
        let tapGestureName = UITapGestureRecognizer(target: self, action: #selector(nameLabelTapped))
              editNameImage.isUserInteractionEnabled = true
              editNameImage.addGestureRecognizer(tapGestureName)
        
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
    
    @IBAction func imageUploadButtonTapped(_ sender: Any) {
        self.profBool = false
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
                       CameraPermissionManager.checkCameraPermission { granted in
                           if granted {
                               DispatchQueue.main.async {
                                   self.imagePickerController.sourceType = .camera
                                   self.present(self.imagePickerController, animated: true, completion: nil)
                               }
                           } else {
                               // Camera permission not granted, show an alert
                               let alert = UIAlertController(title: "Camera Access Denied", message: "Please enable camera access in Settings to take photos.", preferredStyle: .alert)
                               let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                               alert.addAction(okAction)
                               self.present(alert, animated: true, completion: nil)
                           }
                       }
                   }
                   imagePickerActionSheet.addAction(cameraButton)
               }
               
               let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
               imagePickerActionSheet.addAction(cancelButton)
               
               present(imagePickerActionSheet, animated: true, completion: nil)
         
    }
   
    
    @objc func mainPictureTapped() {
        updateMainPicture(for: dateLabel.text ?? "error")
        guard currentImages.count > 0 else {
            return
        }
        
        
    }
    
    func updateMainPicture(for date: String) {
        print("Date: \(date)")
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self, let document = document else {
                // Handle error or nil self
                return
            }
            
            if let imagesDict = document.data()?["images"] as? [String: [String: String]] {
                // Get the current date in the desired format
                let currentDate = date // Your logic to get the current date in the desired format
                
                if let currentImagesDict = imagesDict[currentDate] {
                    // Convert the dictionary into an array of tuples (URL, UID)
                    let currentImages = Array(currentImagesDict.keys)
                    
                    // Update the currentImages array with the image URLs for the current date
                    //self.currentImages = currentImages
                    self.currentDateIndex = (self.currentDateIndex + 1) % currentImages.count
                    //this needs to go into updatemainpic function?
                    self.loadImage(from: currentImages[self.currentDateIndex], to: self.mainPicture)
                    self.updateCreatorImage(for: self.dateLabel.text ?? "", url: currentImages[self.currentDateIndex])
                    // Print the image URLs
                    print(self.currentImages)
                } else {
                    
                    self.loadImage(from: self.noImagesForDate, to: self.mainPicture)
                    print("No images found for the current date")
                }
            } else {
                print("No images data found")
            }
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userbox.adjustsFontSizeToFitWidth = true
        nameLabel.adjustsFontSizeToFitWidth = true
        //nameLabel.sizeToFit()
        //editNameImage.frame = CGRect(x: nameLabel.frame.origin.x + nameLabel.frame.size.width - nameLabel.frame.size.height, y: nameLabel.frame.origin.y, width: nameLabel.frame.size.height, height: nameLabel.frame.size.height)
        nameLabel.layer.cornerRadius = 5
        addFriends.layer.cornerRadius = 10
        addFriends.setTitle("", for: .normal)
        //addFriends.layer.borderWidth = 2.0 // Set border width
        //addFriends.layer.borderColor = UIColor.black.cgColor // Set border color
        addFriends.layer.cornerRadius = 5
        badgesButton.layer.cornerRadius = 5
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        //mainPicture.layer.cornerRadius = mainPicture.frame.size.width / 2
        mainPicture.clipsToBounds = true
        mainPicture.contentMode = .scaleAspectFill
        calendar.frame = CGRect(x: 50, y: dateLabel.frame.origin.y + 30, width: view.frame.size.width * 3/4, height: view.frame.size.width) // Set the desired frame for the calendar view
        calendar.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.addSubview(calendar)
        //bkgdView.layer.cornerRadius = 10.0
        //bkgdView.layer.masksToBounds = true
        //backButton.setTitle("", for: .normal)
        //forwardButton.setTitle("", for: .normal)
        //dateLabel.text = "hello"
        // Assuming you have outlets for the mainPicture and creatorPic UIImageViews
        // Disable autoresizing mask translation into constraints for all views involved
        let creatorWidthHeight = 50.0
        creatorPic.layer.borderWidth = 2.0
        creatorPic.layer.borderColor = UIColor.white.cgColor
        creatorPic.layer.cornerRadius = CGFloat(creatorWidthHeight) / 2.01
        creatorPic.contentMode = .scaleAspectFill
        creatorPic.clipsToBounds = true
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        creatorPic.translatesAutoresizingMaskIntoConstraints = false

        // Add constraints for backButton
        backButton.leadingAnchor.constraint(equalTo: mainPicture.leadingAnchor).isActive = true
        backButton.topAnchor.constraint(equalTo: mainPicture.topAnchor, constant: -50).isActive = true
        backButton.bottomAnchor.constraint(equalTo: mainPicture.topAnchor, constant: -15)
        backButton.widthAnchor.constraint(equalToConstant: 51).isActive = true
        //backButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // Add constraints for forwardButton
        forwardButton.trailingAnchor.constraint(equalTo: mainPicture.trailingAnchor).isActive = true
        forwardButton.topAnchor.constraint(equalTo: backButton.topAnchor).isActive = true
        forwardButton.bottomAnchor.constraint(equalTo: backButton.bottomAnchor).isActive = true
        forwardButton.widthAnchor.constraint(equalTo: backButton.widthAnchor).isActive = true

        // Add constraints for dateLabel
        dateLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: -10).isActive = true
        dateLabel.topAnchor.constraint(equalTo: backButton.topAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: forwardButton.leadingAnchor, constant: 10).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: backButton.bottomAnchor).isActive = true

        // Add constraints for creatorPic
        creatorPic.trailingAnchor.constraint(equalTo: mainPicture.trailingAnchor).isActive = true
        creatorPic.topAnchor.constraint(equalTo: mainPicture.topAnchor).isActive = true
        creatorPic.widthAnchor.constraint(equalToConstant: creatorWidthHeight).isActive = true
        creatorPic.heightAnchor.constraint(equalToConstant: creatorWidthHeight).isActive = true

/*
        let bkgdWidth = bkgdView.frame.size.width
        let bkgdHeight = bkgdView.frame.size.height
        let bkgdX = bkgdView.frame.origin.x
        let bkgdY = bkgdView.frame.origin.y
        backButton.frame = CGRect(x: bkgdX + 15, y: mainPicture.frame.origin.y - 45, width: 51, height: 40)
        forwardButton.frame = CGRect(x: bkgdX + bkgdWidth - 15 - backButton.frame.size.width, y: backButton.frame.origin.y, width:  backButton.frame.size.width, height:  backButton.frame.size.height)
        dateLabel.frame = CGRect(x: backButton.frame.origin.x + backButton.frame.size.width - 10, y: backButton.frame.origin.y, width: forwardButton.frame.origin.x - (backButton.frame.origin.x + backButton.frame.size.width) + 20, height: backButton.frame.size.height)
        let mainPictureFrame = mainPicture.frame

        let creatorPicOriginX = mainPictureFrame.origin.x + mainPictureFrame.size.width - creatorPic.frame.size.width
        let creatorPicOriginY = mainPictureFrame.origin.y

        let creatorPicFrame = CGRect(x: creatorPicOriginX, y: creatorPicOriginY, width: creatorPic.frame.size.width, height: creatorPic.frame.size.height)
        creatorPic.frame = creatorPicFrame*/

        /*
        mainPicture.addSubview(creatorPic)
        mainPicture.translatesAutoresizingMaskIntoConstraints = false
        creatorPic.translatesAutoresizingMaskIntoConstraints = false
        creatorPic.leadingAnchor.constraint(equalTo: mainPicture.leadingAnchor).isActive = true
        creatorPic.trailingAnchor.constraint(equalTo: mainPicture.trailingAnchor).isActive = true
        creatorPic.topAnchor.constraint(equalTo: mainPicture.topAnchor).isActive = true
        creatorPic.bottomAnchor.constraint(equalTo: mainPicture.bottomAnchor).isActive = true*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Call the function to load and update the data
        // Reload the calendar to reflect the updated data
        
        calendar.reloadData()
    }
    @objc func dateLabelTapped() {
        if self.calendar.isHidden {
            self.calendar.isHidden = false
            calendar.reloadData()
        }
        else{
            self.calendar.isHidden = true
        }
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd YYYY"
        let string = formatter.string(from: date)
        print(string)
        updateDateLabel(selectedDate: string)
        //updateMainPicture(for: string) //should comment out because updatedatelabel alr takes care of it?
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Hide the calendar view
            calendar.isHidden = true
        }
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        
        // Convert the given date to the desired string format
        let dateString = dateFormatter.string(from: date)
        print(datesWithPictures)
        // Check if the dateString is in the datesWithPictures set
        if datesWithPictures.contains(dateString) {
                return 1
            }
            
            return 0    }
    func loadImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        imageView.kf.setImage(with: url)
    }
    /*func loadImage(from urlString: String, to imageView: UIImageView) {
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
    }*/
    func updateDateLabel(selectedDate: String? = nil) {
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
                let imagesDict = document.data()?["images"] as? [String: [String: Any]] ?? [:]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd yyyy"
                
                var selectedDateFormatted: Date?
                
                // Convert the selected date string to the desired format if provided
                if let selectedDate = selectedDate {
                    selectedDateFormatted = dateFormatter.date(from: selectedDate)
                }
                
                // Sort the dates in descending order
                let sortedDates = imagesDict.keys.sorted { (dateString1, dateString2) -> Bool in
                    guard let date1 = dateFormatter.date(from: dateString1),
                          let date2 = dateFormatter.date(from: dateString2) else {
                        // Handle invalid date format
                        return false
                    }
                    
                    return date1 > date2
                }
                
                print(sortedDates)
                self.datesWithPictures = sortedDates
                print(self.datesWithPictures)
                
                if let firstDate = sortedDates.first {
                    // Set the date string to the label
                    dateLabel.text = dateFormatter.string(from: dateFormatter.date(from: firstDate)!)
                    
                    // Use the imageUrls dictionary from the most recent date
                    if let imageUrls = imagesDict[firstDate], let firstImageUrl = imageUrls.keys.first {
                        // Set the image to your image view
                        self.updateCreatorImage(for: firstDate, url: firstImageUrl)
                        self.loadImage(from: firstImageUrl, to: self.mainPicture)
                    }
                } else {
                    print("No images found")
                }
                
                if let selectedDate = selectedDateFormatted {
                    // Iterate through the images dictionary and find the first image under the selected date
                    for (date, imageUrls) in imagesDict {
                        guard let dateFormatted = dateFormatter.date(from: date) else {
                            print("Invalid date format for \(date)")
                            continue
                        }
                        
                        // Compare the selected date with the dates in the dictionary
                        if Calendar.current.isDate(dateFormatted, inSameDayAs: selectedDate) {
                            // Set the date string to the label
                            dateLabel.text = dateFormatter.string(from: dateFormatted)
                            self.updateMainPicture(for: dateLabel.text ?? "error")
                            
                            // Use the imageUrls dictionary as needed
                            // For example, you can display the first image URL in an image view
                            if let firstImageUrl = imageUrls.keys.first {
                                // Set the image to your image view
                                self.loadImage(from: firstImageUrl, to: self.mainPicture)
                            }
                            
                            return
                        }
                    }
                    self.loadImage(from: self.noImagesForDate, to: self.mainPicture)
                    self.creatorPic.isHidden = true
                    dateFormatter.dateFormat = "MMM dd yyyy"
                    let formattedDate = dateFormatter.string(from: selectedDate)
                    dateLabel.text = formattedDate
                    //dateLabel.text = selectedDate
                    print("No image found for the selected date")
                }
            } else {
                print("User document does not exist")
            }
        }
    }

    @objc func nameLabelTapped() {
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

    @IBAction func editProfileClicked(_ sender: Any) {
        
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

            
        //viewDidLoad()
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if self.profBool{
            
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
        else{
            //HERE YOU ARE UPLOADING FOR MAINPICTURE
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                // Upload the image to Firebase Storage
                let storageRef = Storage.storage().reference().child("partyImages/\(UUID().uuidString).jpg")
                //"partyImages/\(UUID().uuidString).jpg"
                guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
                    return
                }
                //DispatchQueue.main.async {}
                    
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
                        //ADD TO FRIENDS HERE
                        //print(self.commonFriends)
                        //self.addImageURLToFriends(url?.absoluteString ?? "", commonFriends: self.commonFriends)
                        guard let uid = Auth.auth().currentUser?.uid else {
                            print("Error: No user is currently signed in.")
                            return
                        }

                        let userRef = Firestore.firestore().collection("users").document(uid)

                        // Get the current images dictionary from Firestore (if it exists)
                        userRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                // Retrieve the current images dictionary
                                var images = document.data()?["images"] as? [String: [String: String]] ?? [:]
                                
                                // Add the new image URL with the current user's UID as the value
                                let currentTimeStamp = Int(Date().timeIntervalSince1970) - (5 * 3600) // Subtract 5 hours in seconds
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MMM dd yyyy"
                                let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(currentTimeStamp)))
                                
                                var imageMap = images[dateString] ?? [:]
                                imageMap[downloadURL.absoluteString] = uid
                                images[dateString] = imageMap
                                
                                // Update the images field in Firestore
                                userRef.updateData(["images": images]) { error in
                                    if let error = error {
                                        // Handle the error
                                        print("Error updating Firestore document: \(error.localizedDescription)")
                                        return
                                    }
                                    // Images updated successfully
                                }
                            } else {
                                // Document doesn't exist, create a new document with the image URL
                                let currentTimeStamp = Int(Date().timeIntervalSince1970) - (5 * 3600) // Subtract 5 hours in seconds
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "dd MMM yyyy"
                                let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(currentTimeStamp)))
                                
                                let imageMap: [String: String] = [downloadURL.absoluteString: uid]
                                let images = [dateString: imageMap]
                                
                                // Set the images field in Firestore
                                userRef.setData(["images": images]) { error in
                                    if let error = error {
                                        // Handle the error
                                        print("Error creating Firestore document: \(error.localizedDescription)")
                                        return
                                    }
                                    // Images created successfully
                                }
                            }
                        }

                        
                    }
                }
            }
            
            dismiss(animated: true, completion: nil)
            picker.dismiss(animated: true, completion: nil)



           
            
            
        }
        
    }
    func updateCreatorImage(for date: String, url: String) {
        self.creatorPic.isHidden = false
        let db = Firestore.firestore()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            return
        }
        
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let images = document.data()?["images"] as? [String: [String: String]] ?? [:]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd yyyy"
                
                if let imageDict = images[date], let creatorUID = imageDict[url] {
                    let creatorRef = db.collection("users").document(creatorUID)
                    
                    creatorRef.getDocument { (creatorDocument, creatorError) in
                        if let creatorDocument = creatorDocument, creatorDocument.exists {
                            if let profileURL = creatorDocument.data()?["profilePic"] as? String {
                                // The profileURL variable now holds the value of the profile picture URL
                                print("Profile URL: \(profileURL)")
                                self.loadImage(from: profileURL, to: self.creatorPic)
                            } else {
                                print("Profile picture URL not found for the creator UID: \(creatorUID)")
                            }
                        } else {
                            print("Error retrieving creator document for UID: \(creatorUID)")
                        }
                    }
                } else {
                    print("URL not found for the given date")
                }
            } else {
                print("Error retrieving user document for UID: \(uid)")
            }
        }
    }


    @IBAction func backButtonTapped(_ sender: Any) {
        if datesWithPictures.count == 0 {
            let alert = UIAlertController(title: "No Pictures Added", message: "You have no pictures added yet.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else {
            let current = dateLabel.text
            var index = 50
            if datesWithPictures.contains(current ?? "") {
                index = datesWithPictures.firstIndex(of: current ?? "") ?? 0
                print(index)
                print(datesWithPictures[index])
            }
            if datesWithPictures.count - 1 == index {
                // do nothing
            } else {
                updateDateLabel(selectedDate: datesWithPictures[index + 1])
            }
        }
    }

    @IBAction func forwardButtonTapped(_ sender: Any) {
        if datesWithPictures.count == 0 {
            let alert = UIAlertController(title: "No Pictures Added", message: "You have no pictures added yet.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else {
            let current = dateLabel.text
            var index = 50
            if datesWithPictures.contains(current ?? "") {
                index = datesWithPictures.firstIndex(of: current ?? "") ?? 0
                print(index)
                print(datesWithPictures[index])
            }
            if index == 0 {
                // do nothing
            } else {
                updateDateLabel(selectedDate: datesWithPictures[index - 1])
            }
        }
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
