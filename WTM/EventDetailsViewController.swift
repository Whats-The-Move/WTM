import UIKit
import FirebaseFirestore

class EventDetailsViewController: UIViewController {
    var eventLoad: EventLoad
    let barImage = UIImageView()
    let nameLabel = UILabel()
    let infoStackView = UIStackView()
    let descriptionLabel = UILabel()
    var profileImageViews: [UIImageView] = []




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

        print(eventLoad.creator)
        // Setup UI and use eventLoad as needed
    }
    override func viewDidLayoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = barImage.bounds // Corrected line
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        gradientLayer.locations = [0.7, 1.0]

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
        let venueLabel = createInfoLabel(text: venueName)
        let dateLabel = createInfoLabel(text: String(eventLoad.date.prefix(eventLoad.date.count - 6)))
        let timeLabel = createInfoLabel(text: eventLoad.time)
        let typeLabel = createInfoLabel(text: eventLoad.type)

        // Add labels to stack view
        infoStackView.addArrangedSubview(venueLabel)
        infoStackView.addArrangedSubview(dateLabel)
        infoStackView.addArrangedSubview(timeLabel)
        infoStackView.addArrangedSubview(typeLabel)

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
        for _ in 0..<maxImageCount {
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
        for i in min(commonFriends.count, maxImageCount)..<maxImageCount {
            profileImageViews[i].image = AppHomeViewController().transImage
            profileImageViews[i].isUserInteractionEnabled = false
            profileImageViews[i].layer.borderWidth = 0
        }

        // Rest of your existing code...
        // ...

        // Update the stack view with the arranged profile image views
        let stackViewSuperview = self.view // Replace this with the superview of your desired location for the stack view
        imageViewsStack.translatesAutoresizingMaskIntoConstraints = false
        stackViewSuperview?.addSubview(imageViewsStack)

        // Add constraints to position the stack view (bottom right corner of the cell)
        let circles = maxImageCount//min(commonFriends.count, 4)
   
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
