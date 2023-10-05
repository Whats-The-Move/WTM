import UIKit
import FirebaseStorage
import Firebase
import FirebaseAuth
class ShowEventViewController: UIViewController {
    // UI Elements
    private let titleLabel = UILabel()
    private let venueNameLabel = UILabel()
    private let startTimeLabel = UILabel()
    private let eventName = UILabel()
    private let addressLabel = UILabel()
    private let descriptionLabel = UILabel()
    var labels : [UIView] = []
    private let deleteEventButton = UIButton()
    let goingButton = UIImageView()
    let gradientLayer = CAGradientLayer()



    // Data Properties
    var selectedItem: Event // Replace YourItemType with your data type

    // Custom initializer to pass data
    init(selectedItem: Event = Event()) {
        self.selectedItem = selectedItem // Initialize with the provided item or a default value
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("printing the event i got")
        print(selectedItem.date ?? "4")
        print(selectedItem.name ?? "4")
        view.backgroundColor = .white
        // Configure UI elements
        configureLabels()
        // Add UI elements to the view
        view.addSubview(titleLabel)
        view.addSubview(venueNameLabel)
        view.addSubview(startTimeLabel)
        view.addSubview(eventName)
        view.addSubview(descriptionLabel)
        view.addSubview(addressLabel)
        view.addSubview(deleteEventButton)
        deleteEventButton.isHidden = true
        if Auth.auth().currentUser?.uid ?? "" == selectedItem.creator{
                deleteEventButton.isHidden = false}
            

        labels = [venueNameLabel, eventName, startTimeLabel, addressLabel, descriptionLabel, goingButton]

        
        addHorizontalLine(belowView: titleLabel, spacing: 10.0)

        // Add constraints
        configureConstraints()
        labels.forEach { label in
            label.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        }
    }

    private func configureLabels() {
        // Configure titleLabel
        titleLabel.font = UIFont(name: "Futura-Medium", size: 40)
        titleLabel.textColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0)
        // Assuming selectedItem.date is of type Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy" // Define the desired date format
        titleLabel.text = dateFormatter.string(from: selectedItem.date)


        // Configure venueNameLabel
        venueNameLabel.font = UIFont(name: "Futura-Medium", size: 20)
        venueNameLabel.textColor = UIColor.black
        venueNameLabel.text = "Who?: " + selectedItem.place // Set the text based on selectedItem's properties

        eventName.font = UIFont(name: "Futura-Medium", size: 20)
        eventName.textColor = UIColor.black
        eventName.text = "What?: " + selectedItem.name // Set the text based on selectedItem's properties

        // Configure startTimeLabel
        startTimeLabel.font = UIFont(name: "Futura-Medium", size: 20)
        startTimeLabel.textColor = UIColor.black
        // Assuming selectedItem.time is a Unix timestamp (TimeInterval)
        dateFormatter.dateFormat = "h:mm a" // Define the desired time format

        let selectedTimeDate = Date(timeIntervalSince1970: Double(selectedItem.time))
        let selectedEndTimeDate = Date(timeIntervalSince1970: Double(selectedItem.time))
        startTimeLabel.text = "When?: " + dateFormatter.string(from: selectedTimeDate) + " to " + dateFormatter.string(from: selectedEndTimeDate)
        
        addressLabel.font = UIFont(name: "Futura-Medium", size: 20)
        addressLabel.textColor = UIColor.black
        addressLabel.text = "Where?: " + selectedItem.location // Set the text based on selectedItem's properties
        
        descriptionLabel.font = UIFont(name: "Futura-Medium", size: 20)
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.text = "Description: " + selectedItem.description // Set the text based on selectedItem's properties
        descriptionLabel.numberOfLines = 0
        
        deleteEventButton.setTitle(" Delete Event", for: .normal)
        deleteEventButton.setTitleColor(UIColor.red, for: .normal)
        deleteEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16) // Set font as desired

        // Set the image to a system image
        let trashCanImage = UIImage(systemName: "trash.fill")
        deleteEventButton.setImage(trashCanImage, for: .normal)
        deleteEventButton.tintColor = UIColor.red // Set image color as desired

        // Add a tap gesture recognizer to the button
        deleteEventButton.addTarget(self, action: #selector(deleteEventTapped), for: .touchUpInside)

        
        let image = UIImage(named: "clinking-beer-mugs_1f37b")
        goingButton.image = image
                
        // Add a tap gesture recognizer to the button
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(isGoingTapped))
        goingButton.isUserInteractionEnabled = true
        goingButton.addGestureRecognizer(tapGestureRecognizer)
        goingButton.alpha = 0.5
        goingButton.contentMode = .scaleAspectFit

        // Set the frame and position of the UIImageView

        // Create a circular border
        goingButton.layer.cornerRadius = 150 / 2
        goingButton.layer.borderWidth = 2.0
        goingButton.layer.borderColor = UIColor(red: 255/255.0, green: 22/255.0, blue: 148/255.0, alpha: 1.0).cgColor // Border color (RGB values)
        goingButton.clipsToBounds = true

        // Add a drop shadow
        goingButton.layer.shadowColor = UIColor.black.cgColor
        goingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        goingButton.layer.shadowOpacity = 1
        goingButton.layer.shadowRadius = 4.0

        // Add the button to your view
        view.addSubview(goingButton)
        checkColor()

        goingButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Center the button horizontally
        NSLayoutConstraint.activate([
            goingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: view.frame.height / 4), // Adjust the constant to position it vertically
            goingButton.widthAnchor.constraint(equalToConstant: 150),
            goingButton.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        
        view.addSubview(deleteEventButton)

        // Configure constraints for the button
        deleteEventButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteEventButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 300),
            deleteEventButton.widthAnchor.constraint(equalToConstant: 150), // Adjust width as needed
            deleteEventButton.heightAnchor.constraint(equalToConstant: 60) // Adjust height as needed
        ])
    }
    func checkColor(){
        print("going tapped")
        let database = Database.database().reference()
        let currentUserUID = Auth.auth().currentUser?.uid
        
        // Reference to the isGoing field in the selected event
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy" // You can choose your desired date format
        let dateString = dateFormatter.string(from: selectedItem.date)
        
        var queryFrom = "Events"
        if dbName == "BerkeleyParties" {
            queryFrom = "BerkeleyEvents"
        } else if dbName == "ChicagoParties" {
            queryFrom = "ChicagoEvents"
        } else {
            queryFrom = "EventsTest"
        }
        print(dateString)
        let isGoingRef = database.child(queryFrom).child(dateString).child(selectedItem.place).child("isGoing")
        
        isGoingRef.observeSingleEvent(of: .value) { (snapshot) in
            if let isGoingList = snapshot.value as? [String] {
                print("got the snapshot")
                if let currentUserIndex = isGoingList.firstIndex(of: currentUserUID ?? "") {
                    // User is in the list, remove them

                    
                    // Set the alpha to 0.5
                    self.goingButton.alpha = 1.0
                } else {
                    // User is not in the list, add them

                    
                    // Set the alpha to 1.0
                    self.goingButton.alpha = 0.5
                }
            }
        }
    }
    @objc func isGoingTapped() {

        print("going tapped")
        let database = Database.database().reference()
        let currentUserUID = Auth.auth().currentUser?.uid
        
        // Reference to the isGoing field in the selected event
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy" // You can choose your desired date format
        let dateString = dateFormatter.string(from: selectedItem.date)
        
        var queryFrom = "Events"
        if dbName == "BerkeleyParties" {
            queryFrom = "BerkeleyEvents"
        } else if dbName == "ChicagoParties" {
            queryFrom = "ChicagoEvents"
        } else {
            queryFrom = "EventsTest"
        }
        print(dateString)
        let isGoingRef = database.child(queryFrom).child(dateString).child(selectedItem.place).child("isGoing")
        
        isGoingRef.observeSingleEvent(of: .value) { (snapshot) in
            if var isGoingList = snapshot.value as? [String] {
                print("got the snapshot")
                if let currentUserIndex = isGoingList.firstIndex(of: currentUserUID ?? "") {
                    // User is in the list, remove them
                    isGoingList.remove(at: currentUserIndex)
                    
                    // Update the isGoing field in Firebase
                    isGoingRef.setValue(isGoingList)

                    if let sublayers = self.view.layer.sublayers {
                        for layer in sublayers {
                            if layer is CAGradientLayer {
                                layer.removeFromSuperlayer()
                            }
                        }
                    }
                    // Set the alpha to 0.5
                    self.goingButton.alpha = 0.5
                } else {
                    // User is not in the list, add them
                    isGoingList.append(currentUserUID ?? "")
                    
                    // Update the isGoing field in Firebase
                    isGoingRef.setValue(isGoingList)
                    
                    // Set the alpha to 1.0
                    let pinkColor1 = UIColor(red: 231.0/255.0, green: 19.0/255.0, blue: 238.0/255.0, alpha: 1.0).cgColor
                    let pinkColor2 = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor
                    self.gradientLayer.colors = [pinkColor1, pinkColor2]
                    
                    // Set the frame for the gradient layer to cover the entire view
                    self.gradientLayer.frame = self.view.bounds
                    
                    // Add the gradientLayer to the view controller's view
                    self.view.layer.insertSublayer(self.gradientLayer, at: 0)
                    self.goingButton.alpha = 1.0
                }
            }
            else{
                let initialList = [currentUserUID ?? ""]
                isGoingRef.setValue(initialList)
                self.goingButton.alpha = 1.0
            }
        }
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
                        let newEventRef = privatesRef.child(self.titleLabel.text ?? "Sep 1, 2023").child(placeName)
                        
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
    func addHorizontalLine(belowView viewAbove: UIView, spacing: CGFloat = 10.0) {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.gray // Set the line color as needed
        lineView.translatesAutoresizingMaskIntoConstraints = false
        viewAbove.superview?.addSubview(lineView) // Add lineView to the same superview as viewAbove

        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: viewAbove.bottomAnchor, constant: spacing),
            lineView.leadingAnchor.constraint(equalTo: viewAbove.superview!.leadingAnchor), // Use superview's leading
            lineView.trailingAnchor.constraint(equalTo: viewAbove.superview!.trailingAnchor), // Use superview's trailing
            lineView.heightAnchor.constraint(equalToConstant: 1.0) // 1px height

            // Add this constraint to specify the bottom of lineView
        ])
    }

    private func configureConstraints() {
        // Add constraints for titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true

        // Add constraints for venueNameLabel
        venueNameLabel.translatesAutoresizingMaskIntoConstraints = false
        venueNameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 20).isActive = true
        venueNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40).isActive = true

        // Add constraints for startTimeLabel

        
        eventName.translatesAutoresizingMaskIntoConstraints = false
        eventName.leadingAnchor.constraint(equalTo: venueNameLabel.leadingAnchor).isActive = true
        eventName.topAnchor.constraint(equalTo: venueNameLabel.bottomAnchor, constant: 40).isActive = true
        
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        startTimeLabel.leadingAnchor.constraint(equalTo: eventName.leadingAnchor).isActive = true
        startTimeLabel.topAnchor.constraint(equalTo: eventName.bottomAnchor, constant: 40).isActive = true

        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.leadingAnchor.constraint(equalTo: startTimeLabel.leadingAnchor).isActive = true
        addressLabel.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 40).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 40).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Animate labels one after another with a 1-second delay
        for (index, label) in labels.enumerated() {
            UIView.animate(withDuration: 0.5, delay: Double(index) * 0.3, options: .curveEaseInOut, animations: {
                label.transform = .identity // Reset the label's position
            }, completion: nil)
        }
    }

}
