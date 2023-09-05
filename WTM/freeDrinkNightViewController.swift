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

    @IBOutlet weak var swipeDownButton: UIButton!
    @IBOutlet weak var showScreenLabel: UILabel!
    @IBOutlet weak var clickOnceLabel: UILabel!
    @IBOutlet weak var receivedButton: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    let gradientLayer = CAGradientLayer()
    
    var selectedPlace: String?
    var date: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Free Drink Night at " + (selectedPlace ?? "N/A") + "!"
        
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(receivedButtonTapped))
            
        // Add the UITapGestureRecognizer to the receivedButton
        receivedButton.isUserInteractionEnabled = true
        receivedButton.addGestureRecognizer(tapGesture)
        
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
    
    @IBAction func dismissVC(_ sender: Any) {
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
