import Foundation
import UIKit
import FirebaseAuth
import Firebase
import Kingfisher
protocol CustomCellDelegate: AnyObject {
    func buttonClicked(for party: Party)
    func profileClicked(for party: Party)
}

class CustomCellClass: UITableViewCell {
    weak var delegate: CustomCellDelegate?
    private var party: Party?
    private var profileImageViews: [UIImageView] = []
    private var plusMoreLabel = UILabel()
    private var defaultImageURL = "https://firebasestorage.googleapis.com/v0/b/whatsthemove-1b3f6.appspot.com/o/barProfilePics%2FkamsOutside.jpeg?alt=media&token=ca5e9c08-65bd-4998-9b87-48ea81b78b52"
    var barImageView = UIImageView()
    var partyLabel = UILabel()
    var partyGoersLabel = UILabel()
    var isGoingButton = UIImageView()
    var gradientLayer = CAGradientLayer()

    
    @objc private func profTapped(_ sender: UITapGestureRecognizer) {
        guard let party = party else {
            return
        }
        
        delegate?.profileClicked(for: party)
    }

    @IBAction func buttonClicked(_ sender: UIButton) {
        guard let party = party else {
            return
        }
        delegate?.buttonClicked(for: party)
    }

    func configure(with party: Party, rankDict: [String: Int]) {
        
        createImageView(party: party)
        self.party = party
        
        contentView.addSubview(partyLabel)

        partyLabel.text = party.name
        //partyLabel.adjustsFontSizeToFitWidth = true
        partyLabel.translatesAutoresizingMaskIntoConstraints = false
        partyLabel.leadingAnchor.constraint(equalTo: barImageView.trailingAnchor, constant: 10).isActive = true
        partyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10).isActive = true
        partyLabel.font = UIFont(name: "Futura-Medium", size: 20)
        partyLabel.textColor = .black

        //let ratingLabel = viewWithTag(3) as? UILabel
        //ratingLabel?.text = String(party.rating)
        //ratingLabel?.translatesAutoresizingMaskIntoConstraints = false
        //ratingLabel?.trailingAnchor.constraint(equalTo: partyLabel?.leadingAnchor ?? contentView.leadingAnchor, constant: -15).isActive = true
        //ratingLabel?.centerYAnchor.constraint(equalTo: partyLabel?.centerYAnchor ?? contentView.centerYAnchor, constant: -contentView.bounds.height / 4).isActive = true

        /*let starPic = viewWithTag(12) as? UIImageView
        starPic?.translatesAutoresizingMaskIntoConstraints = false
        starPic?.centerYAnchor.constraint(equalTo: ratingLabel?.centerYAnchor ?? contentView.centerYAnchor).isActive = true
        starPic?.centerXAnchor.constraint(equalTo: ratingLabel?.centerXAnchor ?? contentView.centerXAnchor).isActive = true
*/
        //let subtitleLabel = viewWithTag(2) as? UILabel
        //subtitleLabel?.text = "#" + String(rankDict[party.name] ?? 0)
        //subtitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        //subtitleLabel?.leadingAnchor.constraint(equalTo: ratingLabel?.trailingAnchor ?? contentView.leadingAnchor, constant: 20).isActive = true
        //subtitleLabel?.centerYAnchor.constraint(equalTo: partyLabel?.centerYAnchor ?? contentView.centerYAnchor, constant: -contentView.bounds.height / 4).isActive = true

            

        partyGoersLabel.font = UIFont(name: "Futura-MediumItalic", size: 13)
        partyGoersLabel.textColor = .black
        partyGoersLabel.translatesAutoresizingMaskIntoConstraints = false
        partyGoersLabel.text = "\(party.isGoing.count) partygoers"

        contentView.addSubview(partyGoersLabel)

        NSLayoutConstraint.activate([
            partyGoersLabel.leadingAnchor.constraint(equalTo: barImageView.trailingAnchor, constant: 8),
            partyGoersLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5)
        ])
        
        /*
        if let bkgdSlider = viewWithTag(11) {
            //print("getting here?")
            let corner = bkgdSlider.frame.height / 2
            bkgdSlider.layer.cornerRadius = corner
            
            if let slider = viewWithTag(12) {
                //print("inside of inner slider")
                slider.layer.cornerRadius = corner
                print(party.name)
                print(party.isGoing.count)
                var fillPercent = 0.0
                fillPercent = CGFloat(party.isGoing.count) / Double(maxPeople) - 0.000001
                //let numGoing = party.isGoing.count
                slider.translatesAutoresizingMaskIntoConstraints = false
                slider.leadingAnchor.constraint(equalTo: bkgdSlider.leadingAnchor).isActive = true
                slider.topAnchor.constraint(equalTo: bkgdSlider.topAnchor).isActive = true
                slider.bottomAnchor.constraint(equalTo: bkgdSlider.bottomAnchor).isActive = true

                
                slider.widthAnchor.constraint(equalTo: bkgdSlider.widthAnchor, multiplier: fillPercent).isActive = true
            }
        }

*/
        setupIsGoing(party: party)
        
        //self.assignProfilePictures(commonFriends: [])
        checkFriendshipStatus(isGoing: party.isGoing) { commonFriends in
            self.assignProfilePictures(commonFriends: commonFriends)
            //print(commonFriends)
        }
    }
    func setupIsGoingColor(isGoing: Bool) {
        if isGoing {
            let pinkColor1 = UIColor(red: 231.0/255.0, green: 19.0/255.0, blue: 238.0/255.0, alpha: 1.0)
            var pinkColor2 = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 100.0/255.0, alpha: 1.0)
            

            gradientLayer.colors = [pinkColor2.cgColor, pinkColor1.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.2)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.frame = contentView.bounds

            // Remove any previous gradient layer to avoid adding multiple layers
            if let sublayers = contentView.layer.sublayers {
                for layer in sublayers {
                    if layer is CAGradientLayer {
                        layer.removeFromSuperlayer()
                        print("removing layer")
                    }
                }
            }

            contentView.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            let whiteColor = UIColor.white
            contentView.backgroundColor = whiteColor
            
            // Remove any previous gradient layer to avoid adding multiple layers
            if let sublayers = contentView.layer.sublayers {
                for layer in sublayers {
                    if layer is CAGradientLayer {
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
    }

    func setupIsGoing(party: Party) {
        // Create an image view for the isGoing button (party emoji)
        isGoingButton.image = UIImage(named: "partyemoji")
        isGoingButton.contentMode = .scaleAspectFit
        isGoingButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(isGoingButton)
        isGoingButton.layer.shadowColor = UIColor.black.cgColor // Shadow color
        isGoingButton.layer.shadowOpacity = 0.7 // Shadow opacity (0.0 to 1.0)
        isGoingButton.layer.shadowRadius = 4.0 // Shadow blur radius
        isGoingButton.layer.shadowOffset = CGSize(width: 5.0, height: 5.0) // Shadow offset (x, y)
        isGoingButton.layer.masksToBounds = false

        // Set up constraints for the isGoing button (party emoji) image view
        NSLayoutConstraint.activate([
            isGoingButton.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70),
            isGoingButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            isGoingButton.widthAnchor.constraint(equalToConstant: 60),
            isGoingButton.heightAnchor.constraint(equalTo: isGoingButton.widthAnchor)
        ])

        // Update the isGoing button (party emoji) image view's alpha based on isGoingBool
        var isGoingBool = false
        checkIfUserIsGoing(party: party) { isUserGoing in
            isGoingBool = isUserGoing
            self.isGoingButton.alpha = isGoingBool ? 1.0 : 0.2
            //let pinkColor = UIColor(red: 255.0/255.0, green: 22.0/255.0, blue: 142.0/255.0, alpha: 1.0)
            
            self.setupIsGoingColor(isGoing: isGoingBool)
        }

        // Add tap gesture recognizer to the isGoing button (party emoji) image view

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonClicked(_:)))
        isGoingButton.isUserInteractionEnabled = true
        isGoingButton.addGestureRecognizer(tapGesture)    }

    func checkFriendshipStatus(isGoing: [String], completion: @escaping ([String]) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently signed in.")
            completion([])
            return
        }

        let userRef = Firestore.firestore().collection("users").document(currentUserUID)

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let friendList = document.data()?["friends"] as? [String] else {
                    print("Error: No friends list found.")
                    completion([])
                    return
                }

                let commonFriends = friendList.filter { isGoing.contains($0) }
                print(commonFriends)
                completion(commonFriends)
            } else {
                print("Error: Current user document does not exist.")
                completion([])
            }
        }
    }

    func assignProfilePictures(commonFriends: [String]) {
            let imageViewsStack = UIStackView()
            imageViewsStack.axis = .horizontal
            imageViewsStack.alignment = .fill
            imageViewsStack.distribution = .fill
            imageViewsStack.spacing = -10 // Adjust the spacing between image views as needed
            let maxImageCount = 4 // Maximum number of profile pictures to show

            // Remove existing profile image views from the stack view and clear the array
            for profileImageView in profileImageViews {
                imageViewsStack.removeArrangedSubview(profileImageView)
                profileImageView.removeFromSuperview()
            }
            profileImageViews.removeAll()

            // Create 4 image views and add them to the stack view
            for _ in 0..<maxImageCount {
                let profileImageView = UIImageView()
                profileImageViews.append(profileImageView)

                // Set up properties and constraints for the profileImageView (same as before)
                profileImageView.layer.cornerRadius = 35.0 / 2
                profileImageView.clipsToBounds = true
                profileImageView.contentMode = .scaleAspectFill
                profileImageView.layer.borderWidth = 1.0
                profileImageView.layer.borderColor = UIColor.black.cgColor
                profileImageView.isUserInteractionEnabled = true
                profileImageView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
                profileImageView.translatesAutoresizingMaskIntoConstraints = false
                profileImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
                profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profTapped(_:)))
                profileImageView.addGestureRecognizer(tapGesture)

                // Add the profile image view to the stack view
                imageViewsStack.addArrangedSubview(profileImageView)
            }

            // Assign profile pictures to the image views
            for i in 0..<commonFriends.count {
                if i >= maxImageCount {
                    break // Break out of the loop if we have filled all 4 image views
                }

                let friendUID = commonFriends[i]
                let profileImageView = profileImageViews[i]

                // Load the profile picture from commonFriends
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
                            profileImageView.image = AppHomeViewController().transImage
                            profileImageView.layer.borderWidth = 0
                        }
                    }
                }
            }

            // Hide the remaining image views with transparent image
            for i in min(commonFriends.count, 4)..<maxImageCount {
                profileImageViews[i].image = AppHomeViewController().transImage
                profileImageViews[i].layer.borderWidth = 0
            }

            // Rest of your existing code...
            // ...

            // Update the stack view with the arranged profile image views
            let stackViewSuperview = contentView // Replace this with the superview of your desired location for the stack view
            imageViewsStack.translatesAutoresizingMaskIntoConstraints = false
            stackViewSuperview.addSubview(imageViewsStack)

            // Add constraints to position the stack view (bottom right corner of the cell)
            let circles = 4//min(commonFriends.count, 4)
            NSLayoutConstraint.activate([
                imageViewsStack.leadingAnchor.constraint(equalTo: barImageView.trailingAnchor, constant: 8), // Adjust the right margin as needed
                imageViewsStack.bottomAnchor.constraint(equalTo: stackViewSuperview.bottomAnchor, constant: -8), // Adjust the bottom margin as needed
                imageViewsStack.widthAnchor.constraint(equalToConstant: CGFloat(circles) * 35.0 - CGFloat(circles - 1) * 10.0), // Adjust the width of the stack view based on the number of image views and the spacing
                imageViewsStack.heightAnchor.constraint(equalToConstant: 35.0)
            ])

            // Show the appropriate number of image views in the stack view
            /*for i in 0..<min(commonFriends.count, maxImageCount) {
                print("adding profile")
                if let profileImageView = imageViewsStack.arrangedSubviews[i] as? UIImageView {
                    profileImageView.isHidden = false
                }
            }*/

            // If there are more than 4 common friends, show the "plus more" label
            // Create the plusMoreLabel
            //let plusMoreLabel = UILabel()
            plusMoreLabel.font = UIFont(name: "Futura-Medium", size: 15)
            plusMoreLabel.textColor = .black
            plusMoreLabel.translatesAutoresizingMaskIntoConstraints = false

            // Add the plusMoreLabel to the cell's contentView
            contentView.addSubview(plusMoreLabel)

            // Set up constraints for the plusMoreLabel
            NSLayoutConstraint.activate([
                plusMoreLabel.leadingAnchor.constraint(equalTo: imageViewsStack.trailingAnchor, constant: 8),
                plusMoreLabel.topAnchor.constraint(equalTo: imageViewsStack.topAnchor),
                plusMoreLabel.bottomAnchor.constraint(equalTo: imageViewsStack.bottomAnchor),
                // Optionally, you can add a width constraint for the label if needed:
                // plusMoreLabel.widthAnchor.constraint(equalToConstant: 100)
            ])

            // Update the plusMoreLabel text based on commonFriends count and maxImageCount
            if commonFriends.count > maxImageCount {
                plusMoreLabel.text = "+" + String(commonFriends.count - maxImageCount)
            } else {
                plusMoreLabel.text = ""
            }
        }
    func createImageView(party: Party) -> UIImageView {

        barImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(barImageView)

        // Add constraints
        NSLayoutConstraint.activate([
            barImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            barImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            barImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            barImageView.widthAnchor.constraint(equalTo: barImageView.heightAnchor),
        ])

        // Apply rounded edges
        barImageView.layer.cornerRadius = 8.0
        barImageView.clipsToBounds = true

        // Get the imageURL from Firebase
        print(party.name)
        let database = Database.database().reference().child("Parties").child(party.name )
        database.observeSingleEvent(of: .value) { snapshot, error in
            if let error = error {
                print("Error fetching imageURL from Firebase:")

                self.loadImage(from: self.defaultImageURL, to: self.barImageView)
                return
            }

            if let value = snapshot.value as? [String: Any],
               let imageURL = value["profileURL"] as? String {
                print("INSIDE PROFILE URL")
                self.loadImage(from: imageURL, to: self.barImageView)
            } else {
                print("couldn't find profile url")
                self.loadImage(from: self.defaultImageURL, to: self.barImageView)
            }
        }

        return barImageView
    }
    func loadImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        imageView.kf.setImage(with: url)
    }
    /*
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
    }*/   
    private func checkIfUserIsGoing(party: Party, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let partyRef = Database.database().reference().child("Parties").child(party.name)
        
        partyRef.child("isGoing").observeSingleEvent(of: .value) { snapshot in
            var isUserGoing = false
            
            if snapshot.exists() {
                if let attendees = snapshot.value as? [String] {
                    isUserGoing = attendees.contains(uid)
                }
            }
            
            completion(isUserGoing)
        }
    }









}
extension UIColor {
    static func gradientColor(from startColor: UIColor, to endColor: UIColor, size: CGSize) -> UIColor {
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return startColor
        }

        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]

        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations) {
            let startPoint = CGPoint.zero
            let endPoint = CGPoint(x: size.width, y: size.height)
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }

        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return UIColor(patternImage: gradientImage ?? UIImage())
    }
}
