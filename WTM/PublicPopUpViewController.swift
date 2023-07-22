//
//  PublicPopUpViewController.swift
//  WTM
//
//  Created by Aman Shah on 7/21/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MapKit
import CoreLocation
import FirebaseStorage
import Firebase
import AVFoundation

class PublicPopUpViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UINavigationControllerDelegate {
    var rating = 0.0
    var titleText: String = "Joes"
    var likesLabel: Int = 0
    var dislikesLabel: Int = 0
    var addressLabel: String = ""
    var userGoing = false
    var commonFriends = [String]()    
    var databaseRef: DatabaseReference?
    var parties = [Party]()
    var party = Party(name: "", likes: 0, dislikes: 0, allTimeLikes: 0, allTimeDislikes: 0, address: "", rating: 0, isGoing: [""])
    var pplGoing = 0
    var locationManger = CLLocationManager()

    
    
    var bkgdView: UIView!
    var titleLabel: UILabel!
    var numPeople: UILabel!
    var bkgdSlider: UIView! // New view for the slider
    var slider: UIView!
    var isGoingButton: UIButton! // New button
    var reviewLabel: UILabel! // New label
    var backButton: UIButton! // New button




        override func viewDidLoad() {
            super.viewDidLoad()

            // Call the setupBkgdView() function to set up the background view and its constraints
            setupBkgdView()
            setupTitleLabel(titleText: titleText)
            setupNumPeople(pplGoing: 5)
            setupStars(rating: 3)
            //setupBkgdSlider()
            //setupSlider()
            setupIsGoingButton()
            setupReviewLabel()
            setupBackButton()



        }

        func setupBkgdView() {
            // Calculate the height for the white rectangle (80% of the screen height)
            let screenHeight = view.bounds.height
            let whiteRectangleHeight = screenHeight * 0.75

            // Create and add the white rectangle view (background view)
            bkgdView = UIView()
            bkgdView.translatesAutoresizingMaskIntoConstraints = false
            bkgdView.backgroundColor = .white
            view.addSubview(bkgdView)

            // Set the constraints for the background view
            NSLayoutConstraint.activate([
                bkgdView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                bkgdView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                bkgdView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                bkgdView.heightAnchor.constraint(equalToConstant: whiteRectangleHeight)
            ])
        }
        func setupTitleLabel(titleText: String) {
            // Create the titleLabel
            titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = titleText // Set the titleLabel text using the parameter
            titleLabel.textColor = .white
            titleLabel.font = UIFont(name: "Futura-Medium", size: 26)
            titleLabel.textAlignment = .center
            view.addSubview(titleLabel)

            // Set the constraints for the titleLabel
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50)
            ])
        }
        func setupNumPeople(pplGoing: Int) {
                // Create the numPeople label
                numPeople = UILabel()
                numPeople.translatesAutoresizingMaskIntoConstraints = false
                numPeople.text = "\(pplGoing) people going" // Set the numPeople label text using the parameter
                numPeople.textColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0) // RGB(255, 22, 148)
                numPeople.font = UIFont(name: "Futura-Medium", size: 20)
                numPeople.textAlignment = .center
                view.addSubview(numPeople)

                // Set the constraints for the numPeople label
                NSLayoutConstraint.activate([
                    numPeople.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    numPeople.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 70)
                ])
            }
        func setupStars(rating: Int){
            //super.viewDidLoad()
            let grayStackView = self.createStarStackViewGray()
            let stackView = self.createStarStackView(rating:rating)

            self.view.addSubview(grayStackView)
            self.view.addSubview(stackView)

            // Set stack view constraints
            stackView.translatesAutoresizingMaskIntoConstraints = false
            grayStackView.translatesAutoresizingMaskIntoConstraints = false

            let distanceBetweenLabels = self.titleLabel.bottomAnchor.constraint(equalTo: self.numPeople.topAnchor, constant: 0)
            let centerYConstraint = stackView.centerYAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: distanceBetweenLabels.constant / 2 + 30)
            let centerYConstraintGray = grayStackView.centerYAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: distanceBetweenLabels.constant / 2 + 30)
            
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -((30 * 5 + 8 * 4) / 2)),
                centerYConstraint,
                centerYConstraintGray,
                grayStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
                ])
        }
        func setupBkgdSlider() {
            // Create the bkgdSlider view
            bkgdSlider = UIView()
            bkgdSlider.translatesAutoresizingMaskIntoConstraints = false
            bkgdSlider.backgroundColor = .gray // Set the background color to gray
            view.addSubview(bkgdSlider)

            // Set the constraints for the bkgdSlider
            NSLayoutConstraint.activate([
                bkgdSlider.topAnchor.constraint(equalTo: bkgdView.topAnchor),
                bkgdSlider.leadingAnchor.constraint(equalTo: bkgdView.leadingAnchor),
                bkgdSlider.trailingAnchor.constraint(equalTo: bkgdView.trailingAnchor),
                bkgdSlider.bottomAnchor.constraint(equalTo: bkgdView.topAnchor, constant: 25)
            ])
        }
        func setupSlider() {
            // Create the slider view
            slider = UIView()
            slider.translatesAutoresizingMaskIntoConstraints = false
            //slider.backgroundColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0) // RGB(255, 22, 148)
            slider.backgroundColor = UIColor(red: 0.0, green: 185.0/255, blue: 0.0, alpha: 1.0)
            view.addSubview(slider)

            // Set the constraints for the slider
            NSLayoutConstraint.activate([
                slider.leadingAnchor.constraint(equalTo: bkgdView.leadingAnchor),
                slider.topAnchor.constraint(equalTo: bkgdSlider.topAnchor),
                slider.bottomAnchor.constraint(equalTo: bkgdSlider.bottomAnchor),
                slider.widthAnchor.constraint(equalToConstant: 150)
            ])

            // Apply corner radius to the top right and bottom right corners
            slider.layer.cornerRadius = 8
            slider.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
        func setupIsGoingButton() {
            // Create the "Is Going" button
            isGoingButton = UIButton()
            isGoingButton.translatesAutoresizingMaskIntoConstraints = false
            isGoingButton.setTitle("Not Attending", for: .normal)
            isGoingButton.backgroundColor = UIColor(red: 255/255, green: 22/255, blue: 142/255, alpha: 0.5) // Dull pink with alpha 0.5
            isGoingButton.addTarget(self, action: #selector(isGoingButtonTapped), for: .touchUpInside)
            view.addSubview(isGoingButton)

            // Set the constraints for the "Is Going" button
            NSLayoutConstraint.activate([
                isGoingButton.leadingAnchor.constraint(equalTo: bkgdView.leadingAnchor),
                isGoingButton.topAnchor.constraint(equalTo: bkgdView.topAnchor),
                isGoingButton.trailingAnchor.constraint(equalTo: bkgdView.trailingAnchor),
                isGoingButton.heightAnchor.constraint(equalToConstant: 50) // Set the height to 50 pixels
            ])

            // Apply corner radius to the bottom left and bottom right corners
            isGoingButton.layer.cornerRadius = 10
            isGoingButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        func setupReviewLabel() {
            // Create the "Reviews" label
            reviewLabel = UILabel()
            reviewLabel.translatesAutoresizingMaskIntoConstraints = false
            reviewLabel.text = "Reviews:"
            reviewLabel.font = UIFont(name: "Futura-Medium", size: 20.0)
            reviewLabel.textColor = UIColor(red: 255/255, green: 22/255, blue: 142/255, alpha: 1.0)
            view.addSubview(reviewLabel)

            // Set the constraints for the "Reviews" label
            NSLayoutConstraint.activate([
                reviewLabel.leadingAnchor.constraint(equalTo: bkgdView.leadingAnchor, constant: 40),
                reviewLabel.topAnchor.constraint(equalTo: isGoingButton.bottomAnchor, constant: 20),
                reviewLabel.trailingAnchor.constraint(equalTo: bkgdView.trailingAnchor)
            ])
        }
        func setupBackButton() {
            // Create the back button as an image
            backButton = UIButton()
            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.setImage(UIImage(systemName: "chevron.backward.circle"), for: .normal)
            backButton.tintColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0)
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            view.addSubview(backButton)

            // Set the constraints for the back button
            NSLayoutConstraint.activate([
                backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
                backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                backButton.widthAnchor.constraint(equalToConstant: 50),
                backButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        @objc func backButtonTapped() {
               // Function to be called when the back button is tapped
               // Add your desired actions here
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyboard.instantiateViewController(withIdentifier: "AppHome") as! AppHomeViewController
            newViewController.modalPresentationStyle = .fullScreen
            present(newViewController, animated: false, completion: nil)
        }
       

        @objc func isGoingButtonTapped() {
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
                

            // Function to be called when the "Is Going" button is tapped
            // Add your desired actions here
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
        func createStarStackView(rating: Int) -> UIStackView {
            // Create a horizontal stack view
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.alignment = .center
            stackView.distribution = .fillEqually

            // Create star image
            let starImage = UIImage(named: "pink_star_WTM") // Replace "star" with the name of your star image in the asset catalog

            // Add five star image views to the stack view
            for _ in 1...rating {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
