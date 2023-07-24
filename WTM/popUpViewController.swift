//
//  popUpViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 1/22/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MapKit
import CoreLocation
import FirebaseStorage
import Firebase
import AVFoundation

class popUpViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var rating = 0.0
    var titleText: String = ""
    var likesLabel: Int = 0
    var dislikesLabel: Int = 0
    var addressLabel: String = ""
    var userGoing = false
    var commonFriends = [String]()
    @IBOutlet weak var popupView: UIView!
    
    var databaseRef: DatabaseReference?
    var parties = [Party]()
    var party = Party(name: "", likes: 0, dislikes: 0, allTimeLikes: 0, allTimeDislikes: 0, address: "", rating: 0, isGoing: [""])
    var pplGoing = 0
    
    
    var bkgdSlider: UIView!


    @IBOutlet weak var bkgdView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var isGoingButton: UIButton!
    @IBOutlet weak var numPeople: UILabel!

    @IBOutlet weak var imageUploadButton: UIButton!
    
    //@IBOutlet weak var bkgdSlider: UIView!
    @IBOutlet weak var slider: UIView!
    @IBOutlet weak var backButton: UIButton!
    //@IBOutlet weak var borderView: UIView!
    var locationManger = CLLocationManager()
    let imagePickerController = UIImagePickerController()

    /*override func viewDidLayoutSubviews() {
        print("fuck")
        print(party.isGoing.count)
        //bkgdSlider.layer.cornerRadius = bkgdSlider.frame.height / 2
        //slider.layer.cornerRadius = slider.frame.height / 2
        //slider.translatesAutoresizingMaskIntoConstraints = false
        //slider.topAnchor.constraint(equalTo: bkgdSlider.topAnchor).isActive = true
        //slider.bottomAnchor.constraint(equalTo: bkgdSlider.bottomAnchor).isActive = true
        //slider.leadingAnchor.constraint(equalTo: bkgdSlider.leadingAnchor).isActive = true
        //numPeople.centerXAnchor.constraint(equalTo: bkgdSlider.centerXAnchor).isActive = true

    }*/
    override func viewDidLoad() {
 
        //numPeople.text
        //self.isModalInPresentation = true

        //assignProfilePictures(commonFriends: commonFriends)
        

        imagePickerController.delegate = self
        print(self.party)
        print(self.rating)
        //borderView.layer.borderWidth = 9
        //borderView.layer.borderColor = UIColor.black.cgColor
        //borderView.layer.cornerRadius = 7
        view.layer.cornerRadius = 10

        bkgdSlider = UIView()
       
        bkgdSlider.backgroundColor = .gray

        // Add the bkgdSlider to the main view
        view.addSubview(bkgdSlider)

        // Set the constraints for the bkgdSlider

        locationManger.delegate = self
        locationManger.requestAlwaysAuthorization()
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        map.overrideUserInterfaceStyle = .dark
        map.delegate = self
        
        //popupView.layer.cornerRadius = 8
        print("titleText: \(titleText)")
        print("likes: \(likesLabel)")
        print("address: \(addressLabel)")
        print(self.rating)

        titleLabel.text = titleText
        //titleLabel.textColor = .black
                
        //create func that checks firebase and changes color of is going, call in the viewdidload and the button clicked

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressLabel) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = (placemark?.location?.coordinate.latitude)!
            let lon = (placemark?.location?.coordinate.longitude)!
            
            //print(lat)
            //print(lon)
            
            let sourceCoordinate = self.locationManger.location?.coordinate ?? CLLocationCoordinate2DMake(0, 0)
            //print(sourceCoordinate)
            
            let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
            let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            
            let sourceItem = MKMapItem(placemark: sourcePlaceMark)
            let destItem = MKMapItem(placemark: destPlaceMark)
            
            let destinationRequest = MKDirections.Request()
            destinationRequest.source = sourceItem
            destinationRequest.destination = destItem
            destinationRequest.transportType = .walking
            
            let directions = MKDirections(request: destinationRequest)
            directions.calculate { (response, error) in
                guard let response = response else {
                    if let error = error {
                        print("Something is wrong.")
                    }
                    return
                }
                let route = response.routes[0]
                self.map.addOverlay(route.polyline)
                self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
            //super.viewDidLoad()
            let grayStackView = self.createStarStackViewGray()
            let stackView = self.createStarStackView()

            self.view.addSubview(grayStackView)
            self.view.addSubview(stackView)

            // Set stack view constraints
            stackView.translatesAutoresizingMaskIntoConstraints = false
            grayStackView.translatesAutoresizingMaskIntoConstraints = false

            
            let distanceBetweenLabels = self.titleLabel.bottomAnchor.constraint(equalTo: self.numPeople.topAnchor, constant: 0)
            let centerYConstraint = stackView.centerYAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: distanceBetweenLabels.constant / 2 + 30)
            let centerYConstraintGray = grayStackView.centerYAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: distanceBetweenLabels.constant / 2 + 30)
            self.bkgdView.translatesAutoresizingMaskIntoConstraints = false
            self.bkgdSlider.translatesAutoresizingMaskIntoConstraints = false
            self.isGoingButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -((30 * 5 + 8 * 4) / 2)),
                centerYConstraint,
                centerYConstraintGray,
                grayStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                self.bkgdSlider.topAnchor.constraint(equalTo: self.bkgdView.topAnchor),
                self.bkgdSlider.leadingAnchor.constraint(equalTo: self.bkgdView.leadingAnchor),
                self.bkgdSlider.widthAnchor.constraint(equalTo: self.bkgdView.widthAnchor),
                self.bkgdSlider.bottomAnchor.constraint(equalTo: self.isGoingButton.topAnchor),
                self.bkgdSlider.heightAnchor.constraint(equalToConstant: 60),
                self.isGoingButton.topAnchor.constraint(equalTo: self.bkgdSlider.bottomAnchor),
                self.isGoingButton.leadingAnchor.constraint(equalTo: self.bkgdSlider.leadingAnchor),
                self.isGoingButton.trailingAnchor.constraint(equalTo: self.bkgdSlider.trailingAnchor),
                self.isGoingButton.heightAnchor.constraint(equalToConstant: 50),
                self.bkgdView.topAnchor.constraint(equalTo: self.numPeople.bottomAnchor, constant: 30),
                self.bkgdView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.bkgdView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.bkgdView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])

        }
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissViewController))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
        
        let mapTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        map.addGestureRecognizer(mapTapGesture)
        
    }
    /*
    func assignProfilePictures(commonFriends: [String]) {
            let imageTags = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] // Update with the appropriate image view tags
            let numberOfImages = min(commonFriends.count, imageTags.count)
            
            let horizontalSpacing: CGFloat = 10 // Adjust the horizontal spacing between images
            let verticalSpacing: CGFloat = 10 // Adjust the vertical spacing between rows
            let imagesPerRow = 5 // Maximum number of images per row
            
            let totalWidth = friendsView.frame.width
            let totalHeight = friendsView.frame.height - 45 // Subtract the top margin
            
            let imageWidth = (totalWidth - CGFloat((imagesPerRow - 1) * Int(horizontalSpacing))) / CGFloat(imagesPerRow)
            let imageHeight = imageWidth
            
            var currentX: CGFloat = 0
            var currentY: CGFloat = 45 // Set the initial Y position with the top margin
            
            for i in 0..<numberOfImages {
                let friendUID = commonFriends[i]
                let tag = imageTags[i]
                
                if let profileImageView = friendsView.viewWithTag(tag) as? UIImageView {
                    // Assign profile picture to the image view
                    profileImageView.clipsToBounds = true
                    profileImageView.contentMode = .scaleAspectFill
                    profileImageView.layer.borderWidth = 2.0
                    profileImageView.layer.borderColor = UIColor.white.cgColor
                    profileImageView.frame = CGRect(x: currentX, y: currentY, width: imageWidth, height: imageHeight)
                    profileImageView.layer.cornerRadius = profileImageView.frame.width / 2 // Set corner radius to half of width
                    
                    // Set the next position for the next image view
                    currentX += imageWidth + horizontalSpacing
                    
                    // Check if the next image view should be placed in the next row
                    if (i + 1) % imagesPerRow == 0 {
                        currentX = 0
                        currentY += imageHeight + verticalSpacing
                    }
                    
                    let userRef = Firestore.firestore().collection("users").document(friendUID)
                    userRef.getDocument { (document, error) in
                        if let error = error {
                            print("Error retrieving profile picture: \(error.localizedDescription)")
                            return
                        }
                        
                        if let document = document, document.exists {
                            if let profilePicURL = document.data()?["profilePic"] as? String {
                                // Assuming you have a function to retrieve the image from the URL
                                self.loadImage(from: profilePicURL, to: profileImageView)
                            } else {
                                print("No profile picture found for friend with UID: \(friendUID)")
                            }
                        }
                    }
                }
            }
        }
    */

    
    func createStarStackViewGray() -> UIStackView {
        // Create a horizontal stack view
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillEqually
       
        // Create star image
        let starImage = UIImage(systemName: "star.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal) // Replace "star" with the name of your star image in the asset catalog

        // Add five star image views to the stack view
        for _ in 1...5 {
            let starView = createStarImageView(image: starImage)
            stackView.addArrangedSubview(starView)
        }

        return stackView
    }
    func createStarStackView() -> UIStackView {
        // Create a horizontal stack view
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillEqually

        // Create star image
        let starImage = UIImage(named: "pink_star_WTM") // Replace "star" with the name of your star image in the asset catalog
        let roundedRating = Int(round(rating))

        // Add five star image views to the stack view
        for _ in 1...roundedRating {
            let starView = createStarImageView(image: starImage)
            stackView.addArrangedSubview(starView)
        }

        return stackView
    }

    func createStarImageView(image: UIImage?) -> UIImageView {
        // Create UIImageView to represent a star
        let starImageView = UIImageView(image: image)
        starImageView.contentMode = .scaleAspectFit
        
        // Set star view size (adjust this as needed)
        let starSize: CGFloat = 30
        starImageView.widthAnchor.constraint(equalToConstant: starSize).isActive = true
        starImageView.heightAnchor.constraint(equalToConstant: starSize).isActive = true

        return starImageView
    }
    func loadImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        imageView.kf.setImage(with: url)
    }
    @objc func handleTap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "AppHome") as! AppHomeViewController
        newViewController.modalPresentationStyle = .fullScreen
        present(newViewController, animated: false, completion: nil)
    }
    
    /*
    func mapThis(destinationCoord : CLLocationCoordinate2D){
        let sourceCoordinate = (locationManger.location?.coordinate)!
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
        let destPlaceMark = MKPlacemark(coordinate: destinationCoord)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destItem = MKMapItem(placemark: destPlaceMark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .walking
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Something is wrong.")
                }
                return
            }
            let route = response.routes[0]
            self.map.addOverlay(route.polyline)
            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
 */
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = UIColor( red: CGFloat(250/255.0), green: CGFloat(17/255.0), blue: CGFloat(242/255.0), alpha: CGFloat(1.0) )
        return render
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch(CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManger.startUpdatingLocation()
        case .denied, .notDetermined, .restricted:
            locationManger.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //print(locations)
    }
    
    @objc func dismissViewController() {
        print("dismissing view controller")
        //self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let TabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        TabBarController.overrideUserInterfaceStyle = .dark
        TabBarController.modalPresentationStyle = .fullScreen
        present(TabBarController, animated: false, completion: nil)
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismissViewController()
    }
    @IBAction func isGoingButtonClicked(_ sender: Any) {
        print(self.rating)

        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        let partyRef = Database.database().reference().child("Parties").child(self.party.name)
        partyRef.child("isGoing").observeSingleEvent(of: .value) { [weak self] snapshot in
            if snapshot.exists() {
                if var attendees = snapshot.value as? [String] {
                    if let index = attendees.firstIndex(of: uid) {
                        attendees.remove(at: index)
                        self?.userGoing = false
                        self!.checkIfUserIsGoing(party: self!.party)

                    } else {
                        attendees.append(uid)
                        let customCell = CustomCellClass()
                        customCell.checkFriendshipStatus(isGoing: attendees) { result in
                            // Call the updateBestFriends function and pass the result as a parameter
                            AppHomeViewController().updateBestFriends(commonFriends: result)
                        }
                        AppHomeViewController().incrementSpotCount(partyName: self?.party.name ?? "")
                        self?.userGoing = true
                        self!.checkIfUserIsGoing(party: self!.party)

                    }
                    partyRef.child("isGoing").setValue(attendees) { error, _ in
                        if let error = error {
                            print("Failed to update party attendance:", error)
                        } else {
                            //print("Successfully updated party attendance1.")
                        }
                    }
                }
            } else {
                partyRef.child("isGoing").setValue([uid]) { error, _ in
                    if let error = error {
                        print("Failed to update party attendance:", error)
                    } else {
                        self?.userGoing = true
                        self!.checkIfUserIsGoing(party: self!.party)

                        //print("Successfully updated party attendance.")
                    }
                }
            }
        }
            

    }
    
    @IBAction func imageUploadButtonTapped(_ sender: Any) {
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
                    print(self.commonFriends)
                    self.addImageURLToFriends(url?.absoluteString ?? "", commonFriends: self.commonFriends)
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

                    var database = Database.database().reference()
                    let partyRef = database.child("Parties").child((self.titleLabel.text)!)

                    partyRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                        if var partyData = currentData.value as? [String: Any] {
                            var images = partyData["images"] as? [String] ?? [] // Get existing images or create empty array
                            images.append(downloadURL.absoluteString) // Append new image URL
                            partyData["images"] = images // Update the images array in the party data
                            
                            // If the images field didn't exist before, add it to the party data
                            if partyData["images"] == nil {
                                partyData["images"] = images
                            }

                            currentData.value = partyData
                            return TransactionResult.success(withValue: currentData)
                        }
                        return TransactionResult.success(withValue: currentData)
                    }) { (error, _, _) in
                        if let error = error {
                            print("Transaction failed with error: \(error.localizedDescription)")
                        } else {
                            print("Transaction successful.")
                        }
                    }
                    
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
        picker.dismiss(animated: true, completion: nil)



       
        
    }

    func addImageURLToFriends(_ downloadURL: String, commonFriends: [String]) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            return
        }
        
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        let dateString = dateFormatter.string(from: Date())

        // Iterate through the commonFriends array
        for friendUID in commonFriends {
            let userRef = db.collection("users").document(friendUID)

            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    var images = document.data()?["images"] as? [String: [String: String]] ?? [:]
                    var imageDict = images[dateString] ?? [:]
                    imageDict[downloadURL] = uid
                    images[dateString] = imageDict

                    userRef.updateData(["images": images]) { error in
                        if let error = error {
                            print("Error updating Firestore document: \(error.localizedDescription)")
                        } else {
                            print("Image URL added to user: \(friendUID)")
                        }
                    }
                } else {
                    print("Error retrieving user document for UID: \(friendUID)")
                }
            }
        }
    }



    @objc func handleMapTap(_ sender: UITapGestureRecognizer) {
        let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(addressLabel) {
                placemarks, error in
                let placemark = placemarks?.first
                let lat = (placemark?.location?.coordinate.latitude)!
                let lon = (placemark?.location?.coordinate.longitude)!
                
                let destinationPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                let destinationItem = MKMapItem(placemark: destinationPlaceMark)
                destinationItem.name = self.titleText
                
                destinationItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
            }
    }
    private func checkIfUserIsGoing(party: Party) -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            return false
        }
        
        print(party.name)
        let partyRef = Database.database().reference().child("Parties").child(titleText)
        
        partyRef.child("isGoing").observeSingleEvent(of: .value) { snapshot in
            var isUserGoing = false
            //HERES THE PROBLEM- not going into fuck again party of code
            if snapshot.exists() {
                if let attendees = snapshot.value as? [String] {
                    isUserGoing = attendees.contains(uid)
                    self.userGoing = isUserGoing
                }
            }
        }
            //completion(isUserGoing)
        let pinkColor = UIColor(red: 215.0/255, green: 113.0/255, blue: 208.0/255, alpha: 0.5)
        let greenColor = UIColor(red: 0.0, green: 185.0/255, blue: 0.0, alpha: 1.0)
        let grayColor = UIColor(red: 128.0/255, green: 128.0/255, blue: 128.0/255, alpha: 0.5)
        
        let backgroundColor = userGoing ? greenColor : grayColor
        self.isGoingButton.backgroundColor = backgroundColor
        let buttonText = userGoing ? "Attending!" : "Not attending"
        // Assuming you have a button instance called 'myButton'
        isGoingButton.setTitle(buttonText, for: .normal)

        return userGoing
    }

    func openInMaps(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Destination"
        mapItem.openInMaps(launchOptions: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reviewSegue" {
            let destinationViewController = segue.destination as! reviewViewController
            print(titleText)
            destinationViewController.titleText = titleText
        }
    }
}
