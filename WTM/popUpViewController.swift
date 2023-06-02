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

class popUpViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var titleText: String = ""
    var likesLabel: Int = 0
    var dislikesLabel: Int = 0
    var addressLabel: String = ""
    @IBOutlet weak var popupView: UIView!
    
    var databaseRef: DatabaseReference?
    var parties = [Party]()
    
    
    @IBOutlet weak var votesLeftLabel: UILabel!
    @IBOutlet weak var wasItTheMoveLabel: UILabel!
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var upvoteLabel: UILabel!
    @IBOutlet weak var downvoteLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var reviewButon: UIButton!
    @IBOutlet weak var user_name: UILabel!
    //@IBOutlet weak var hoursLabel: UILabel!
    //@IBOutlet weak var coverLabel: UILabel!
    //@IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var imageUploadButton: UIButton!
    
    @IBOutlet weak var borderView: UIView!
    var locationManger = CLLocationManager()
    let imagePickerController = UIImagePickerController()

    
    override func viewDidLoad() {
        imagePickerController.delegate = self

        borderView.layer.borderWidth = 9
        borderView.layer.borderColor = UIColor.black.cgColor
        borderView.layer.cornerRadius = 7
        view.layer.cornerRadius = 10


        upvoteButton.imageView?.contentMode = .scaleAspectFit
        downvoteButton.imageView?.contentMode = .scaleAspectFit
        
        locationManger.delegate = self
        locationManger.requestAlwaysAuthorization()
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        map.overrideUserInterfaceStyle = .dark
        map.delegate = self
        
        popupView.layer.cornerRadius = 8
        print("titleText: \(titleText)")
        print("likes: \(likesLabel)")
        print("address: \(addressLabel)")
        titleLabel.text = titleText
        titleLabel.textColor = .black
        upvoteLabel.text = String(likesLabel)
        upvoteLabel.textColor = .black
        downvoteLabel.text = String(dislikesLabel)
        downvoteLabel.textColor = .black
        num.text = String(UserDefaults.standard.integer(forKey: "votesLabel"))
        num.textColor = .black
        votesLeftLabel.textColor = .black
        wasItTheMoveLabel.textColor = .black
        

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
            
            super.viewDidLoad()
            
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
        
        let mapTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        map.addGestureRecognizer(mapTapGesture)
        
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
        self.dismiss(animated: true, completion: nil)
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
            let storageRef = Storage.storage().reference().child("partyImages/\(UUID().uuidString).jpg")
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
                    guard let uid = Auth.auth().currentUser?.uid else {
                        print("Error: No user is currently signed in.")
                        return
                    }
                    print("uid")
                    print(uid)
                    // Store the download URL in Firestore
                    
                    let userRef = Firestore.firestore().collection("users").document(uid)
                    
                    // Get the current images array from Firestore (if it exists)
                    userRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            // Retrieve the current images array
                            var images = document.data()?["images"] as? [String] ?? []
                            
                            // Add the new image URL to the array
                            images.append(downloadURL.absoluteString)
                            
                            // Update the images field in Firestore
                            userRef.updateData(["images": images]) { error in
                                if let error = error {
                                    // Handle the error
                                    print("Error updating Firestore document: \(error.localizedDescription)")
                                    return
                                }
                                
                                // Success!
                                print("Image uploaded and download URL stored in Firestore!")
                            }
                        } else {
                            // Handle the error
                            //if the images array doesn't exist
                            let images = [downloadURL.absoluteString]
                            
                            // Set the images field in Firestore
                            userRef.updateData(["images": images]) { error in
                                if let error = error {
                                    // Handle the error
                                    print("Error creating Firestore document: \(error.localizedDescription)")
                                    return
                                }
                                
                                // Success!
                                print("Image uploaded and download URL stored in Firestore!")
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
                    }}
            }
        }
        
        dismiss(animated: true, completion: nil)
        


       
        
    }

    @IBAction func likeButtonTapped(_ sender: Any) {
        //print(titleText)
        //print("liked")
        if(UserDefaults.standard.integer(forKey: "votesLabel") > 0){
            let database = Database.database().reference()
            database.child("Parties").child((titleLabel.text)!).updateChildValues(["Likes" : ServerValue.increment(1)])
            database.child("Parties").child((titleLabel.text)!).updateChildValues(["allTimeLikes" : ServerValue.increment(1)])
            let number = Int(upvoteLabel.text!)
            likesLabel = number! + 1
            let votesNumber = Int(num.text!)
            let votesB = votesNumber! - 1
            UserDefaults.standard.setValue(votesB, forKey: "votesLabel")
        } else {
            let alert = UIAlertController(title: "Alert", message: "No votes left!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
        }
        viewDidLoad()
    }

    @IBAction func dislikeButtonTapped(_ sender: Any) {
        //print(titleText)
        //print("disliked")
        if(UserDefaults.standard.integer(forKey: "votesLabel") > 0){
            let database = Database.database().reference()
            database.child("Parties").child((titleLabel.text)!).updateChildValues(["Dislikes" : ServerValue.increment(1)])
            database.child("Parties").child((titleLabel.text)!).updateChildValues(["allTimeDislikes" : ServerValue.increment(1)])
            let number = Int(downvoteLabel.text!)
            dislikesLabel = number! + 1
            let votesNumber = Int(num.text!)
            let votesB = votesNumber! - 1
            UserDefaults.standard.setValue(votesB, forKey: "votesLabel")
        } else {
            let alert = UIAlertController(title: "Alert", message: "No votes left!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
        }
        viewDidLoad()
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
    
    func openInMaps(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Destination"
        mapItem.openInMaps(launchOptions: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reviewSegue" {
            let destinationViewController = segue.destination as! reviewViewController
            destinationViewController.titleText = titleText
        }
    }
}
