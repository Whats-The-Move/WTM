import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

class EventDetailsViewController: UIViewController {
    var eventLoad: EventLoad
    let barImage = UIImageView()
    let nameLabel = UILabel()
    let infoStackView = UIStackView()
    let descriptionLabel = UILabel()
    var profileImageViews: [UIImageView] = []
    var grayBkgd: UIView!
    var bkgdLabel: UILabel!
    var goingButton: UIButton!
    var isUserGoing = false
    var pplGoing: UIStackView!




    init(eventLoad: EventLoad) {
        self.eventLoad = eventLoad
        super.init(nibName: nil, bundle: nil)
        // Additional setup if needed
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Call the setupBarImage function
        setupBarImage()
        addBackButton()
        addNameLabel()
        addInfoStackView()
        //configureProfileImageStackView(with: ["00NOZzy9prZdbWpLdE61dgZIEj83", "01sdNvA3ksgQn7ivXWEve9wpnQ83"])
        assignProfilePictures(commonFriends: ["00NOZzy9prZdbWpLdE61dgZIEj83", "01sdNvA3ksgQn7ivXWEve9wpnQ83"])
        addDescriptionLabel()
        setupGrayBkgd()
        setupBkgdLabel()
        setupGoingButton()

        print(eventLoad.creator)
        // Setup UI and use eventLoad as needed
    }
    override func viewDidLayoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = barImage.bounds // Corrected line
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.0).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        gradientLayer.locations = [0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.6)

        // Add gradient layer as an overlay to barImage
        barImage.layer.addSublayer(gradientLayer)
    }

    func setupBarImage() {
        // Configure barImage
        barImage.translatesAutoresizingMaskIntoConstraints = false
        barImage.contentMode = .scaleAspectFill
        barImage.clipsToBounds = true
        loadImage(from: eventLoad.imageURL, to: barImage)
        // Add barImage to the view
        view.addSubview(barImage)

        // Setup constraints for barImage to span the top half of the screen
        NSLayoutConstraint.activate([
            barImage.topAnchor.constraint(equalTo: view.topAnchor),
            barImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            barImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            barImage.heightAnchor.constraint(equalTo: view.widthAnchor)
        ])

        // Set an example image (replace with your own logic to load an image)

        // Add gradient layer

    }
    func addBackButton() {
            let backButton = UIButton(type: .system)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
            backButton.tintColor = .white
            backButton.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
            backButton.layer.cornerRadius = 15 // Half of the button's height for a circular button
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

            view.addSubview(backButton)

            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                backButton.widthAnchor.constraint(equalToConstant: 30),
                backButton.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
    func addNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.text = eventLoad.eventName
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5 // Adjust as needed
        nameLabel.textAlignment = .center

        view.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: barImage.bottomAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 300),
            nameLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    func addInfoStackView() {
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.axis = .horizontal
        infoStackView.spacing = 0 // No spacing between labels and separators
        infoStackView.alignment = .center

        // Create labels
        let venueName = eventLoad.venueName + "   "
        var going = String(eventLoad.isGoing.count)
        if going == "1" {
            going = "1 person"
        }
        else{
            going = going + " people"
        }
        let dateLabel = createInfoLabel(text: String(eventLoad.date.prefix(eventLoad.date.count - 6)))
        let timeLabel = createInfoLabel(text: eventLoad.time)
        let venueLabel = createInfoLabel(text: venueName)
        pplGoing = createInfoLabel(text: going)

        // Add labels to stack view
        infoStackView.addArrangedSubview(dateLabel)
        infoStackView.addArrangedSubview(timeLabel)
        infoStackView.addArrangedSubview(venueLabel)

        infoStackView.addArrangedSubview(pplGoing)

        // Add stack view to the view
        view.addSubview(infoStackView)

        // Set up constraints for the infoStackView
        NSLayoutConstraint.activate([
            infoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 25),
            infoStackView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }

    func createInfoLabel(text: String) -> UIStackView {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)

        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5 // Adjust as needed
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        // Add thin line separator to the right
        let separatorView = UIView()
        separatorView.backgroundColor = .gray
        NSLayoutConstraint.activate([
            separatorView.widthAnchor.constraint(equalToConstant: 1),
            separatorView.heightAnchor.constraint(equalToConstant: 30),
            label.widthAnchor.constraint(equalToConstant: 74)
        ])
 


        // Set equal width for label and separator

        // Create a horizontal stack view to combine label and separator
        let labelStackView = UIStackView(arrangedSubviews: [label, separatorView])
        labelStackView.axis = .horizontal
        labelStackView.alignment = .fill
        labelStackView.spacing = 0

        return labelStackView
    }
    func addDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = eventLoad.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)

        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0 // Allow multiple lines for description

        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            descriptionLabel.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 70),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    func assignProfilePictures(commonFriends: [String]) {
        let imageViewsStack = UIStackView()

        imageViewsStack.axis = .horizontal
        imageViewsStack.alignment = .fill
        imageViewsStack.distribution = .fill
        imageViewsStack.spacing = 0 // Adjust the spacing between image views as needed
        let maxImageCount = 6 // Maximum number of profile pictures to show

        // Create 4 image views and add them to the stack view
        for i in 0..<min(maxImageCount, commonFriends.count) {
            let profileImageView = UIImageView()

            // Set up properties and constraints for the profileImageView (same as before)
            profileImageView.layer.cornerRadius = 45.0 / 2
            profileImageView.clipsToBounds = true
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.layer.borderWidth = 1.0
            profileImageView.layer.borderColor = UIColor.white.cgColor
            profileImageView.isUserInteractionEnabled = true
            profileImageView.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            profileImageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profTapped(_:)))
            profileImageView.addGestureRecognizer(tapGesture)

            // Add the profile image view to the stack view
            imageViewsStack.addArrangedSubview(profileImageView)
            profileImageViews.append(profileImageView)//del
            
            let friendUID = commonFriends[i]
            //let profileImageView = profileImageViews[i]

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



        // Rest of your existing code...
        // ...

        // Update the stack view with the arranged profile image views
         // Replace this with the superview of your desired location for the stack view
        imageViewsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageViewsStack)

        // Add constraints to position the stack view (bottom right corner of the cell)
        let circles = min(maxImageCount, commonFriends.count)//min(commonFriends.count, 4)
   
        NSLayoutConstraint.activate([
            imageViewsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Adjust the right margin as needed
            imageViewsStack.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 15), // Adjust the bottom margin as needed
            imageViewsStack.widthAnchor.constraint(equalToConstant: CGFloat(circles) * 45.0 - CGFloat(circles - 1) * 0.0), // Adjust the width of the stack view based on the number of image views and the spacing
            imageViewsStack.heightAnchor.constraint(equalToConstant: 45.0)
        ])
     

    /*
        // Add the plusMoreLabel and background to the cell's contentView
        let plusMoreLabel = UILabel()
        let plusMoreBkgd = UIView()

        plusMoreLabel.font = UIFont(name: "Futura-Medium", size: 15)
        plusMoreLabel.textColor = .black
        plusMoreLabel.translatesAutoresizingMaskIntoConstraints = false

        plusMoreBkgd.translatesAutoresizingMaskIntoConstraints = false
        plusMoreBkgd.backgroundColor = UIColor.gray.withAlphaComponent(1.0)
        plusMoreBkgd.layer.cornerRadius = 17.5 // Half of 45px
        plusMoreBkgd.layer.borderWidth = 1

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profTapped(_:)))
        plusMoreBkgd.addGestureRecognizer(tapGesture)

        stackViewSuperview?.addSubview(plusMoreBkgd)

        // Set up constraints for the circular background view
        NSLayoutConstraint.activate([
            plusMoreBkgd.widthAnchor.constraint(equalToConstant: 45),
            plusMoreBkgd.heightAnchor.constraint(equalToConstant: 45),
            plusMoreBkgd.leadingAnchor.constraint(equalTo: imageViewsStack.trailingAnchor, constant: -10),
            plusMoreBkgd.topAnchor.constraint(equalTo: imageViewsStack.topAnchor)
        ])

        // Add the plusMoreLabel to the circular background view
        stackViewSuperview?.addSubview(plusMoreLabel)

        // Set up constraints for the plusMoreLabel within the circular background view
        NSLayoutConstraint.activate([
            plusMoreLabel.centerXAnchor.constraint(equalTo: plusMoreBkgd.centerXAnchor),
            plusMoreLabel.centerYAnchor.constraint(equalTo: plusMoreBkgd.centerYAnchor)
        ])

        // Update the plusMoreLabel text based on commonFriends count and maxImageCount
        if commonFriends.count > maxImageCount {
            plusMoreBkgd.isHidden = false
            plusMoreLabel.text = "+" + String(commonFriends.count - maxImageCount)
        } else {
            plusMoreLabel.text = ""
        }
*/
        // Adjust the contentView of the view controller as needed
        // Replace the following line with the actual background color you want for the view controller
    }
    func profileClicked(for party: Party) {
        // Create an instance of friendsGoingViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let friendsGoingVC = storyboard.instantiateViewController(withIdentifier: "FriendsGoing") as! friendsGoingViewController
        
        // Pass the selected party object
        friendsGoingVC.selectedParty = party
        
        friendsGoingVC.modalPresentationStyle = .overFullScreen
        
        // Present the friendsGoingVC modally
        present(friendsGoingVC, animated: true, completion: nil)
    }
    
    @objc func profTapped(_ sender: UITapGestureRecognizer) {
        // Handle the profile image tap event (e.g., show a profile view)
        if let tappedImageView = sender.view as? UIImageView {
            // Perform the action based on the tappedImageView
            print("Profile image tapped!")
            //CALL PROFILE CLICKED ABOVE^^
            
        }
    }

    func setupGrayBkgd() {
            grayBkgd = UIView()
        grayBkgd.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.9)
            grayBkgd.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(grayBkgd)

            NSLayoutConstraint.activate([
                grayBkgd.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                grayBkgd.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                grayBkgd.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                grayBkgd.heightAnchor.constraint(equalToConstant: 100)
            ])
        }

    func setupBkgdLabel() {
        bkgdLabel = UILabel()
        bkgdLabel.text = "Are you..."
        bkgdLabel.textColor = .white
        bkgdLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        bkgdLabel.translatesAutoresizingMaskIntoConstraints = false
        grayBkgd.addSubview(bkgdLabel)

        NSLayoutConstraint.activate([
            bkgdLabel.leadingAnchor.constraint(equalTo: grayBkgd.leadingAnchor, constant: 50),
            bkgdLabel.centerYAnchor.constraint(equalTo: grayBkgd.centerYAnchor, constant: -10)
        ])
    }

    func setupGoingButton() {
        goingButton = UIButton()
        goingButton.setTitle("Going?", for: .normal)
        goingButton.setTitleColor(.white, for: .normal)
        goingButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        let eventref = Database.database().reference().child(currCity + "Events").child(eventLoad.date).child(eventLoad.eventKey)
        //                            var isUserGoing = false
        eventref.child("isGoing").observeSingleEvent(of: .value) { snapshot in
            
            
            print("segue before it goes in")
            if snapshot.exists() {
                if let attendees = snapshot.value as? [String] {
                    let uid = Auth.auth().currentUser?.uid
                    var isUserGoing = attendees.contains(uid ?? "zzzzzneverwillbefound")
                    print("is user going: \(isUserGoing)")
                    self.isUserGoing = isUserGoing
                    if isUserGoing {
                        self.goingButton.backgroundColor = UIColor(red: 255/255, green: 28/255, blue: 142/255, alpha: 1.0)
                        self.goingButton.layer.shadowColor = UIColor.black.cgColor
                        self.goingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
                        self.goingButton.layer.shadowOpacity = 0.5

                    }
                    else{
                        self.goingButton.backgroundColor = UIColor(red: 255/255, green: 28/255, blue: 142/255, alpha: 0.5)

                    }
    
                }
            }
            
        }

        goingButton.layer.cornerRadius = 8
       
        goingButton.addTarget(self, action: #selector(goingTapped), for: .touchUpInside)
        goingButton.translatesAutoresizingMaskIntoConstraints = false
        grayBkgd.addSubview(goingButton)

        NSLayoutConstraint.activate([
            goingButton.trailingAnchor.constraint(equalTo: grayBkgd.trailingAnchor, constant: -16),
            goingButton.centerYAnchor.constraint(equalTo: bkgdLabel.centerYAnchor),
            goingButton.widthAnchor.constraint(equalToConstant: 140),
            goingButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        goingButton.addTarget(self, action: #selector(buttonClickAnimation), for: .touchDown)
        goingButton.addTarget(self, action: #selector(buttonReleaseAnimation), for: [.touchUpInside, .touchUpOutside])
    }

    @objc func goingTapped() {
        isUserGoing = !isUserGoing
        print("Going button tapped!")
        print(eventLoad.eventKey)

        // Assuming you have a reference to your Firebase Realtime Database
        let database = Database.database()

        // Get the current user's UID
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        // Replace "yourCurrCity" with the actual value for currCity
        let eventsRef = database.reference(withPath: currCity + "Events")

        // Access the specific event's data in the database
        let eventRef = eventsRef.child(eventLoad.date).child(eventLoad.eventKey) // Replace with your actual path

        // Use observeSingleEvent to fetch data once
        eventRef.observeSingleEvent(of: .value) { (snapshot) in
            guard var event = snapshot.value as? [String: Any] else {
                print("Missing or malformed event data")
                return
            }

            // Check if the "isGoing" field exists
            if var isGoingList = event["isGoing"] as? [String] {
                // Check if the user is already in the list
                if isGoingList.contains(currentUserUID) {
                    // User is already in the list, remove them
                    isGoingList.removeAll { $0 == currentUserUID }
                    print("Removing user from isGoing")
                    self.locallyDecrement()
                    
                } else {
                    // User is not in the list, add them
                    isGoingList.append(currentUserUID)
                    print("Adding user to isGoing")
                    self.locallyIncrement()
                }

                // Update the "isGoing" field in the event data
                event["isGoing"] = isGoingList

                // Set the updated event data
                eventRef.setValue(event)

                print("Updated event data: \(event)")
            } else {
                print("Missing or malformed 'isGoing' field")
            }
        }
    }
    func locallyIncrement (){
        self.goingButton.backgroundColor = UIColor(red: 255/255, green: 28/255, blue: 142/255, alpha: 1.0)
        self.goingButton.layer.shadowColor = UIColor.black.cgColor
        self.goingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.goingButton.layer.shadowOpacity = 0.5
        self.updatePeopleGoingLabel(up: true)
        
    }
    func locallyDecrement (){
        self.goingButton.backgroundColor = UIColor(red: 255/255, green: 28/255, blue: 142/255, alpha: 0.5)

        self.updatePeopleGoingLabel(up: false)
        
    }
    func updatePeopleGoingLabel(up: Bool) {
        // Assuming infoStackView is your UIStackView
        guard let pplGoingLabel = pplGoing.arrangedSubviews[0] as? UILabel else {
            print("Error accessing pplGoing label")
            return
        }

        // Extract the numeric value from the label text using regular expression
        let regex = try! NSRegularExpression(pattern: "^(\\S+)", options: [])
        let matches = regex.matches(in: pplGoingLabel.text!, options: [], range: NSRange(location: 0, length: pplGoingLabel.text!.count))

        if let match = matches.first, let range = Range(match.range, in: pplGoingLabel.text!) {
            let currentText = pplGoingLabel.text![range]
            if var currentNumber = Int(currentText) {
                // Update the number based on the 'up' parameter
                currentNumber = up ? currentNumber + 1 : max(0, currentNumber - 1)

                // Update the label text with proper grammar
                if currentNumber == 0 {
                    pplGoingLabel.text = "0 people"
                } else if currentNumber == 1 {
                    pplGoingLabel.text = "1 person"
                } else {
                    pplGoingLabel.text = "\(currentNumber) people"
                }
            } else {
                print("Error converting current text to Int")
            }
        } else {
            print("Error extracting text from pplGoing label text")
        }
    }





    @objc func buttonClickAnimation() {
        UIView.animate(withDuration: 0.1) {
            self.goingButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    @objc func buttonReleaseAnimation() {
        UIView.animate(withDuration: 0.1) {
            self.goingButton.transform = CGAffineTransform.identity
        }
    }


    @objc func backButtonTapped() {
        // Dismiss the current view controller
        self.dismiss(animated: true, completion: nil)
    }
    func loadImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        imageView.kf.setImage(with: url)
    }
}
