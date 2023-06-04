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

    var calendar = FSCalendar()
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
        calendar.frame = CGRect(x: 50, y: dateLabel.frame.origin.y + 30, width: view.frame.size.width * 3/4, height: view.frame.size.width) // Set the desired frame for the calendar view
        calendar.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.addSubview(calendar)
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
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    imageView.image = image
                }
            }
        }
    }

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
        let current = dateLabel.text
        var index = 50
        if datesWithPictures.contains(current ?? ""){
            index = datesWithPictures.firstIndex(of: current ?? "") ?? 0
            print(index)
            print(datesWithPictures[index])
            
        }
        if datesWithPictures.count - 1 == index {
            //do nothing
        }
        else{
            updateDateLabel(selectedDate: datesWithPictures[index + 1])
        }
    }
    @IBAction func forwardButtonTapped(_ sender: Any) {
        let current = dateLabel.text
        var index = 50
        if datesWithPictures.contains(current ?? ""){
            index = datesWithPictures.firstIndex(of: current ?? "") ?? 0
            print(index)
            print(datesWithPictures[index])
            
        }
        if index == 0 {
            //do nothing
        }
        else{
            updateDateLabel(selectedDate: datesWithPictures[index - 1])
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
