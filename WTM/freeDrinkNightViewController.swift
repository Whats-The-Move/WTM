//
//  freeDrinkNightViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 9/3/23.
//

import UIKit
import Firebase
import CoreGraphics

class freeDrinkNightViewController: UIViewController {
/*
    @IBOutlet weak var swipeDownButton: UIButton!
    @IBOutlet weak var showScreenLabel: UILabel!
    @IBOutlet weak var clickOnceLabel: UILabel!
    @IBOutlet weak var receivedButton: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!*/
    var swipeDownButton: UIButton!
    var showScreenLabel: UILabel!
    var clickOnceLabel: UILabel!
    var receivedButton: UIImageView!
    var titleLabel: UILabel!
    private let deleteEventButton = UIButton()

    let gradientLayer = CAGradientLayer()
    var creator = ""
    var selectedPlace: String?
    var date: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupComponents()
        configureConstraints()
       

        // Add constraints for centering the titleLabel


        
        let databaseReference = Database.database().reference()
        
        if let selectedPlace = selectedPlace {
            // Assuming fcmToken is the token you want to add to the array
            let fcmToken = userFcmToken
            
            // Construct the path to the location where you want to update the data
            let databasePath = "Events/\(date ?? "N/A")/\(selectedPlace)/fcmTokenList"
            
            // Update the database with the new FCM token
            databaseReference.child(databasePath).observeSingleEvent(of: .value, with: { (snapshot) in
                var tokenList = snapshot.value as? [String] ?? []
                if !tokenList.contains(fcmToken){
                    self.receivedButton.alpha = 0.2 //
                } else{
                    self.receivedButton.alpha = 1.0
                    let pinkColor1 = UIColor(red: 231.0/255.0, green: 19.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor
                    let pinkColor2 = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor
                    self.gradientLayer.colors = [pinkColor1, pinkColor2]
                    
                    // Set the frame for the gradient layer to cover the entire view
                    self.gradientLayer.frame = self.view.bounds
                    
                    // Add the gradientLayer to the view controller's view
                    self.view.layer.insertSublayer(self.gradientLayer, at: 0)
                    self.swipeDownButton.tintColor = .white
                    self.showScreenLabel.text = "Enjoy your free drink!"
                    self.clickOnceLabel.text = "Free Drink Redeemed."
                }
            })
            
        }
        
        // Add the button to your view

        // Configure constraints for the button
        

        
    }
    func setupComponents(){


        titleLabel = UILabel()
        titleLabel.text = "Free Drink Night at " + (selectedPlace ?? "N/A") + "!"
        titleLabel.font = UIFont(name: "Futura-Medium", size: 25)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center

  

        swipeDownButton = UIButton()
        if let arrowImage = UIImage(systemName: "arrow.down") {
            let pinkTintedImage = arrowImage.withTintColor(UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0), renderingMode: .alwaysOriginal)
            swipeDownButton.setImage(pinkTintedImage, for: .normal)
        }
        swipeDownButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)

        showScreenLabel = UILabel()
        showScreenLabel.text = "Show this screen to a bartender to claim your free drink!"
        showScreenLabel.font = UIFont(name: "Futura-Medium", size: 20)
        showScreenLabel.textColor = .black
        showScreenLabel.textAlignment = .center
        showScreenLabel.numberOfLines = 0

        
        clickOnceLabel = UILabel()
        clickOnceLabel.text = "DO NOT TAP\nThis can only be clicked once,\nand it must be clicked by an employee of the bar!"

        clickOnceLabel.font = UIFont(name: "Futura-Medium", size: 15)
        clickOnceLabel.textColor = .black
        clickOnceLabel.textAlignment = .center
        clickOnceLabel.numberOfLines = 0

        
        receivedButton = UIImageView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(receivedButtonTapped))
            
        // Add the UITapGestureRecognizer to the receivedButton
        receivedButton.isUserInteractionEnabled = true
        receivedButton.image = UIImage(named: "clinking-beer-mugs_1f37b")

        receivedButton.addGestureRecognizer(tapGesture)
        
        deleteEventButton.isHidden = true
        if Auth.auth().currentUser?.uid ?? "" == self.creator {
                deleteEventButton.isHidden = false}
          
        deleteEventButton.setTitle(" Delete Event", for: .normal)
        deleteEventButton.setTitleColor(UIColor.red, for: .normal)
        deleteEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16) // Set font as desired

        // Set the image to a system image
        let trashCanImage = UIImage(systemName: "trash.fill")
        deleteEventButton.setImage(trashCanImage, for: .normal)
        deleteEventButton.tintColor = UIColor.red // Set image color as desired

        // Add a tap gesture recognizer to the button
        deleteEventButton.addTarget(self, action: #selector(deleteEventTapped), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(swipeDownButton)
        view.addSubview(showScreenLabel)
        view.addSubview(clickOnceLabel)
        view.addSubview(receivedButton)
        view.addSubview(deleteEventButton)

    }
    func configureConstraints(){
        // Assuming you have references to these views
        swipeDownButton.translatesAutoresizingMaskIntoConstraints = false
        showScreenLabel.translatesAutoresizingMaskIntoConstraints = false
        clickOnceLabel.translatesAutoresizingMaskIntoConstraints = false
        receivedButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Define the constraints
        NSLayoutConstraint.activate([
            // Center swipeDownButton horizontally and set 20px from the top of the screen
            swipeDownButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            swipeDownButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),

            // Center showScreenLabel horizontally and set 40px below swipeDownButton


            // Center titleLabel horizontally and set 40px below showScreenLabel
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: swipeDownButton.bottomAnchor, constant: 40),

            // Center receivedButton horizontally, set its width and height to 200x200, and set 40px below titleLabel
            receivedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            receivedButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            receivedButton.widthAnchor.constraint(equalToConstant: 200),
            receivedButton.heightAnchor.constraint(equalToConstant: 200),
            
            showScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showScreenLabel.topAnchor.constraint(equalTo: receivedButton.bottomAnchor, constant: 40),
            showScreenLabel.heightAnchor.constraint(equalToConstant: 90),
            showScreenLabel.widthAnchor.constraint(equalToConstant: 220),

            // Center clickOnceLabel horizontally and set 50px below receivedButton
            clickOnceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clickOnceLabel.topAnchor.constraint(equalTo: showScreenLabel.bottomAnchor, constant: 50),
            clickOnceLabel.heightAnchor.constraint(equalToConstant: 90),
            clickOnceLabel.widthAnchor.constraint(equalToConstant: 220),
        ])

        deleteEventButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteEventButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 300),
            deleteEventButton.widthAnchor.constraint(equalToConstant: 150), // Adjust width as needed
            deleteEventButton.heightAnchor.constraint(equalToConstant: 60) // Adjust height as needed
        ])
        
    }
    @objc func deleteEventTapped() {
        // Show an alert when the button is tapped
        let alertController = UIAlertController(
            title: "Delete Event",
            message: "Are you sure you want to delete this event?",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            let currentUserUID = Auth.auth().currentUser?.uid ?? ""
            var barLocation = ""
            let db = Firestore.firestore()
            let userRef = db.collection("barUsers").document(currentUserUID)
            var placeName = "testParty"
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let venueName = document["venueName"] as? String, let creatorLocation = document["location"] as? String {
                        // Successfully fetched the venueName
                        barLocation = creatorLocation
                        print("Venue Name: \(venueName)")
                        placeName = venueName
                        let privatesRef = Database.database().reference().child("\(barLocation)Events")
                        let newEventRef = privatesRef.child(self.date ?? "Sep 1, 2023").child(placeName)
                        
                        // Delete the node
                        newEventRef.removeValue { error, _ in
                            if let error = error {
                                print("Error deleting event: \(error.localizedDescription)")
                            } else {
                                print("Event deleted successfully!")
                                // TODO: Perform any additional actions after event deletion
                            }
                        }
                    } else {
                        // The "venueName" field does not exist or is not a String
                        print("Venue Name not found or is not a String")
                    }
                } else {
                    // Document does not exist or there was an error
                    print("Document does not exist or an error occurred")
                }
            }

            
        })

        present(alertController, animated: true, completion: nil)
    }
    @objc func receivedButtonTapped() {
        // Change the image when the button is tapped
        receivedButton.alpha = 1.0
        updateFirebaseDatabase()
        let pinkColor1 = UIColor(red: 231.0/255.0, green: 19.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor
        let pinkColor2 = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor
        gradientLayer.colors = [pinkColor1, pinkColor2]
        
        // Set the frame for the gradient layer to cover the entire view
        gradientLayer.frame = view.bounds
        
        // Add the gradientLayer to the view controller's view
        view.layer.insertSublayer(gradientLayer, at: 0)
        swipeDownButton.tintColor = .white
        showScreenLabel.text = "Enjoy your free drink!"
        self.clickOnceLabel.text = "Free Drink Redeemed."
    }
    
    func updateFirebaseDatabase() {
        // Get a reference to the Firebase Realtime Database
        let databaseReference = Database.database().reference()
        
        if let selectedPlace = selectedPlace {
            // Assuming fcmToken is the token you want to add to the array
            let fcmToken = userFcmToken
            
            // Construct the path to the location where you want to update the data
            let databasePath = "Events/\(date ?? "N/A")/\(selectedPlace)/fcmTokenList"
            
            // Update the database with the new FCM token
            databaseReference.child(databasePath).observeSingleEvent(of: .value, with: { (snapshot) in
                var tokenList = snapshot.value as? [String] ?? []
                if !tokenList.contains(fcmToken){
                    tokenList.append(fcmToken)
                    
                    // Update the value in the database
                    databaseReference.child(databasePath).setValue(tokenList)
                }
            })
        }
    }
    
    @objc func dismissVC(_ sender: Any) {
        dismiss(animated: true)
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
