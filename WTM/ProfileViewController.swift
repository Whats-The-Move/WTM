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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mainPicture.image = UIImage(named: "default_photo")

        mainPicture.isUserInteractionEnabled = true
        let pictapGesture = UITapGestureRecognizer(target: self, action: #selector(mainPictureTapped))
        mainPicture.addGestureRecognizer(pictapGesture)
        viewDidLayoutSubviews()
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
        
        currentDateIndex = (currentDateIndex + 1) % currentImages.count
        loadImage(from: currentImages[currentDateIndex], to: mainPicture)
    }
    
    func updateMainPicture(for date: String) {
            print("Date: \(date)")
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }

            let userRef = db.collection("users").document(uid)

            userRef.getDocument { [weak self] (document, error) in
                guard let self = self, let document = document else {
                    // Handle error or nil self
                    return
                }
                
                if let imagesDict = document.data()?["images"] as? [String: [String]] {
                    // Get the current date in the desired format
                    let currentDate = date// Your logic to get the current date in the desired format
                    
                    if let currentImages = imagesDict[currentDate] {
                        // Update the currentImages array with the images for the current date
                        self.currentImages = currentImages
                        
                        // Print the images
                        print(self.currentImages)
                    } else {
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
        updateMainPicture(for: string)
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
                let imagesDict = document.data()?["images"] as? [String: [String]] ?? [:]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd yyyy"
                
                var selectedDateFormatted: Date?
                
                // Convert the selected date string to the desired format if provided
                if let selectedDate = selectedDate {
                    selectedDateFormatted = dateFormatter.date(from: selectedDate)
                }
                
                // Sort the dates in descending order
                let sortedDates = imagesDict.keys.sorted(by: >)
                print(sortedDates)
                self.datesWithPictures = sortedDates
                print(self.datesWithPictures)
                if let firstDate = sortedDates.first {
                    // Set the date string to the label
                    dateLabel.text = dateFormatter.string(from: dateFormatter.date(from: firstDate)!)
                    
                    // Use the imageUrls array from the most recent date
                    if let imageUrls = imagesDict[firstDate], let firstImageUrl = imageUrls.first {
                        // Set the image to your image view
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
                            
                            // Use the imageUrls array as needed
                            // For example, you can display the first image URL in an image view
                            if let firstImageUrl = imageUrls.first {
                                // Set the image to your image view
                                self.loadImage(from: firstImageUrl, to: self.mainPicture)
                            }
                            
                            return
                        }
                    }
                    
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
                        guard let uid = Auth.auth().currentUser?.uid else {
                            print("Error: No user is currently signed in.")
                            return
                        }

                        let userRef = Firestore.firestore().collection("users").document(uid)

                        // Get the current images dictionary from Firestore (if it exists)
                        userRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                // Retrieve the current images dictionary
                                var images = document.data()?["images"] as? [String: [String]] ?? [:]

                                // Add the new image URL with the current timestamp (Unix) as the key
                                let currentTimeStamp = Int(Date().timeIntervalSince1970) - (8 * 3600) // Subtract 5 hours in seconds
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MMM dd yyyy"
                                let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(currentTimeStamp)))
                                
                                var imageList = images[dateString] ?? []
                                imageList.append(downloadURL.absoluteString)
                                images[dateString] = imageList

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
                                let currentTimeStamp = Int(Date().timeIntervalSince1970) - (8 * 3600) // Subtract 12 hours in seconds
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "dd MMM yyyy"
                                let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(currentTimeStamp)))
                                
                                let images = [dateString: [downloadURL.absoluteString]]

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
