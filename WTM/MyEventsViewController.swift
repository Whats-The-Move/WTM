import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore


class MyEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MyEventsCellDelegate {

    let titleLabel = UILabel()
    let upcomingEventsButton = UIButton()
    let pastEventsButton = UIButton()
    let myEventsTableView = UITableView()
    let bgView = UIView()
    let createButton = UIButton()
    
    var pastEvents: [EventLoad] = []
    var upcomingEvents: [EventLoad] = []
    var pastBool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        createButton.isHidden = true
        view.backgroundColor = .black
        fetchUserEventsGoing { eventsGoingList in
            guard let eventsGoingList = eventsGoingList else {
                print("No events or error fetching eventsGoing list.")
                return
            }
            print("eventsgoinglist")
            print(eventsGoingList)

            // Now fetch the corresponding events from Realtime Database
            self.fetchEventsMatchingEventsGoing(currCity: currCity + "Events", eventsGoing: eventsGoingList) { matchedEvents in
                // Process the matched events
                //var pastEvents: [EventLoad] = []
                //var upcomingEvents: [EventLoad] = []
                let currentDate = Date()
                print(matchedEvents)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                for event in matchedEvents {
                    print(event.date)
                    if let eventDate = dateFormatter.date(from: event.date), eventDate < currentDate {
                        self.pastEvents.append(event)
                        print("adding to past events")
                    } else {
                        self.upcomingEvents.append(event)
                        print("adding to upcoming events")

                    }
                }
                self.setupUI()

                // Here, pastEvents and upcomingEvents are populated with the relevant events
                // You can now use these arrays to update your UI, etc.
            }
        }

    }

    private func setupUI() {
        // Setup titleLabel
        titleLabel.font = UIFont(name: "Futura-Medium", size: 34)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        titleLabel.text = "My Events"
        createButton.setImage(UIImage(systemName: "plus.app.fill"), for: .normal)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.tintColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
        createButton.addTarget(self, action: #selector(createButtonClicked), for: .touchUpInside)
        let isPartyAccount = UserDefaults.standard.bool(forKey: "partyAccount")
        print("party account: ", isPartyAccount)
        if isPartyAccount{
            createButton.isHidden = false
        } else {
            createButton.isHidden = true
        }
        
        view.addSubview(titleLabel)
        view.addSubview(createButton)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            createButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            createButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 120),
            createButton.heightAnchor.constraint(equalToConstant: 120)
        ])

        // Setup buttons
        setupButton(upcomingEventsButton, title: "Upcoming Events")
        setupButton(pastEventsButton, title: "Past Events")

        // Position the buttons
        NSLayoutConstraint.activate([
            upcomingEventsButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            upcomingEventsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pastEventsButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            pastEventsButton.leadingAnchor.constraint(equalTo: upcomingEventsButton.trailingAnchor, constant: 20)
        ])

        updateButtonStyles()
        
        
        
        bgView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        view.addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: upcomingEventsButton.bottomAnchor, constant: 20),
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        

        // Setup myEventsTableView
        myEventsTableView.delegate = self
        myEventsTableView.dataSource = self
        myEventsTableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        myEventsTableView.register(MyEventsCell.self, forCellReuseIdentifier: "MyEventsCell")
        myEventsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myEventsTableView)

        NSLayoutConstraint.activate([
            myEventsTableView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 5),
            myEventsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            myEventsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            myEventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func createButtonClicked(){
        let createEventVC = CreateEventViewController()
        createEventVC.modalPresentationStyle = .fullScreen // Optional: Present full screen
        present(createEventVC, animated: true, completion: nil)
    }

    private func setupButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)

        button.addTarget(self, action: #selector(toggleEventView(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
    }

    private func updateButtonStyles() {
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Futura-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Futura-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        ]

        if pastBool {
            pastEventsButton.setAttributedTitle(NSAttributedString(string: pastEventsButton.currentTitle ?? "", attributes: underlineAttributes), for: .normal)
            pastEventsButton.setTitleColor(.white, for: .normal)
            pastEventsButton.isUserInteractionEnabled = false

            upcomingEventsButton.setAttributedTitle(NSAttributedString(string: upcomingEventsButton.currentTitle ?? "", attributes: normalAttributes), for: .normal)
            upcomingEventsButton.setTitleColor(.gray, for: .normal)
            upcomingEventsButton.isUserInteractionEnabled = true
        } else {
            upcomingEventsButton.setAttributedTitle(NSAttributedString(string: upcomingEventsButton.currentTitle ?? "", attributes: underlineAttributes), for: .normal)
            upcomingEventsButton.setTitleColor(.white, for: .normal)
            upcomingEventsButton.isUserInteractionEnabled = false

            pastEventsButton.setAttributedTitle(NSAttributedString(string: pastEventsButton.currentTitle ?? "", attributes: normalAttributes), for: .normal)
            pastEventsButton.setTitleColor(.gray, for: .normal)
            pastEventsButton.isUserInteractionEnabled = true
        }
    }


    @objc func toggleEventView(_ sender: UIButton) {
        pastBool = !pastBool
        myEventsTableView.reloadData()
        updateButtonStyles()
        // Reload your table view or perform other UI updates here
        // tableView.reloadData()
        print("Button pressed. PastBool is now \(pastBool)")
    }





    // MARK: - TableView Delegate & DataSource Methods

    func fetchUserEventsGoing(completion: @escaping ([String]?) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(nil)
            return
        }

        let userRef = Firestore.firestore().collection("users").document(currentUserUID)

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let eventsGoing = document.get("eventsGoing") as? [String] {
                    // Successfully retrieved the list
                    completion(eventsGoing)
                } else {
                    userRef.updateData(["eventsGoing": []]) { error in
                        if let error = error {
                            print("Error updating user document: \(error)")
                            completion(nil)
                        } else {
                            completion([])
                        }
                    }
                }
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "")")
                completion(nil)
            }
        }
    }


    func fetchEventsMatchingEventsGoing(currCity: String, eventsGoing: [String], completion: @escaping ([EventLoad]) -> Void) {
        let ref = Database.database().reference()
        let currCityRef = ref.child(currCity)

        currCityRef.observeSingleEvent(of: .value, with: { snapshot in
            var matchedEvents: [EventLoad] = []

            guard let cityData = snapshot.value as? [String: Any] else {
                completion([])
                return
            }

            for (dateString, dateNodes) in cityData {
                guard let dateData = dateNodes as? [String: Any] else { continue }

                for (eventKey, eventData) in dateData {
                    if eventsGoing.contains(eventKey),
                       let eventDataDict = eventData as? [String: Any],
                       let creator = eventDataDict["creator"] as? String,
                       let deals = eventDataDict["deals"] as? String,
                       let description = eventDataDict["description"] as? String,
                       let eventName = eventDataDict["eventName"] as? String,
                       let imageURL = eventDataDict["imageURL"] as? String,
                       let isGoing = eventDataDict["isGoing"] as? [String],
                       let location = eventDataDict["location"] as? String,
                       let time = eventDataDict["time"] as? String,
                       let venueName = eventDataDict["venueName"] as? String,
                       let type = eventDataDict["type"] as? String {
                        
                        let event = EventLoad(creator: creator, date: dateString, deals: deals, description: description, eventName: eventName, imageURL: imageURL, isGoing: isGoing, location: location, time: time, venueName: venueName, type: type, eventKey: eventKey)
                        matchedEvents.append(event)
                        print("printing isgoing for event")
                        print(event.isGoing)
                    }
                }
            }

            completion(matchedEvents)
        }) { error in
            print(error.localizedDescription)
            completion([])
        }
    }
    func pplGoingButtonTapped(cell: MyEventsCell, event: EventLoad) {
        // Present your new view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let friendsGoingVC = storyboard.instantiateViewController(withIdentifier: "FriendsGoing") as! friendsGoingViewController
        
        // Pass the selected party object
        let userIDs = event.isGoing
        fetchUsersWithUID(fromUserIDs: userIDs) { users in
            // Handle the list of users
            friendsGoingVC.friendsGoing = users
            friendsGoingVC.eventName = event.eventName
            
            friendsGoingVC.modalPresentationStyle = .overFullScreen
            
            // Present the friendsGoingVC modally
            self.present(friendsGoingVC, animated: true, completion: nil)

        }

    }
    func fetchUsersWithUID(fromUserIDs userIDs: [String], completion: @escaping ([User]) -> Void) {
        var users: [User] = []
        let group = DispatchGroup()

        for userID in userIDs {
            group.enter()
            let userRef = Firestore.firestore().collection("users").document(userID)
            userRef.getDocument { (document, error) in
                defer { group.leave() }
                
                if let error = error {
                    print("Error retrieving user data: \(error.localizedDescription)")
                    return
                }

                if let document = document, document.exists {
                    if let profilePicURL = document.data()?["profilePic"] as? String,
                       let usersName = document.data()?["name"] as? String,
                       let usersEmail = document.data()?["email"] as? String,
                       let usersUsername = document.data()?["username"] as? String {
                        let user = User(uid: userID, email: usersEmail, name: usersName, username: usersUsername, profilePic: profilePicURL)
                        users.append(user)
                    } else {
                        print("Field data missing for user with uid: \(userID)")
                    }
                } else {
                    print("Document does not exist for user with uid: \(userID)")
                }
            }
        }

        group.notify(queue: .main) {
            completion(users)
        }
    }
    func editButtonTapped(cell: MyEventsCell, event: EventLoad){
        
        let createEventVC = CreateEventViewController()
        createEventVC.modalPresentationStyle = .fullScreen // Optional: Present full screen
        createEventVC.eventToEdit = event

        present(createEventVC, animated: true, completion: nil)
        
        

        // Pass the selected party object

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastBool ? pastEvents.count : upcomingEvents.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyEventsCell", for: indexPath) as? MyEventsCell else {
            fatalError("Unable to dequeue MyEventsCell")
        }

        let event = pastBool ? pastEvents[indexPath.row] : upcomingEvents[indexPath.row]
        cell.configureWithEvent(event: event)
        //cell.backgroundColor = .clear
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        cell.delegate = self
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pastBool{
            let event = pastEvents[indexPath.row]
            let detailsVC = EventDetailsViewController(eventLoad: event)
            present(detailsVC, animated: true, completion: nil)
        }
        else{
            let event = upcomingEvents[indexPath.row]
            let detailsVC = EventDetailsViewController(eventLoad: event)
            present(detailsVC, animated: true, completion: nil)
        }
        

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115  // Set cell height to 200px
    }

}


// Assuming you have a 'MyEventsCell' class
class MyEventsCell: UITableViewCell {
    
    weak var delegate: MyEventsCellDelegate?

    
    let eventNameLabel = UILabel()
    let eventDateLabel = UILabel()
    let eventImageView = UIImageView()
    let ticketImageView = UIImageView()
    let editButton = UIButton()
    let pplGoing = UIButton()
    var eventPassed: EventLoad?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .darkGray
        
        let isPartyAccount = UserDefaults.standard.bool(forKey: "partyAccount")

        if !isPartyAccount {
            editButton.isHidden = true
            pplGoing.isHidden = true
        }
        // Adding subviews
        contentView.addSubview(eventNameLabel)
        contentView.addSubview(eventDateLabel)
        contentView.addSubview(eventImageView)
        contentView.addSubview(ticketImageView)
        contentView.addSubview(editButton)
        contentView.addSubview(pplGoing)


        // Disable autoresizing masks for all subviews
        [eventNameLabel, eventDateLabel, eventImageView, ticketImageView, editButton, pplGoing].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Constraints for ticketImageView
        NSLayoutConstraint.activate([
            ticketImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            ticketImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            ticketImageView.widthAnchor.constraint(equalToConstant: 45),
            ticketImageView.heightAnchor.constraint(equalToConstant: 45)
        ])
        ticketImageView.image = UIImage(named: "ticketStraight")
        ticketImageView.tintColor = .systemPink

        // Constraints for eventNameLabel
        NSLayoutConstraint.activate([
            eventNameLabel.leadingAnchor.constraint(equalTo: ticketImageView.trailingAnchor, constant: 10),
            eventNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            eventNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: eventImageView.leadingAnchor, constant: -10)
        ])
        eventNameLabel.font = UIFont(name: "Futura-Medium", size: 20)
        eventNameLabel.textColor = .white

        // Constraints for eventDateLabel
        NSLayoutConstraint.activate([
            eventDateLabel.leadingAnchor.constraint(equalTo: eventNameLabel.leadingAnchor),
            eventDateLabel.topAnchor.constraint(equalTo: eventNameLabel.bottomAnchor, constant: 5),
            eventDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: eventImageView.leadingAnchor, constant: -10)
        ])
        eventDateLabel.font = UIFont(name: "Futura-Medium", size: 16)
        eventDateLabel.textColor = .white

        // Constraints for eventImageView
        NSLayoutConstraint.activate([
            // Anchor the right side of the image to the right side of the cell
            eventImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            // Center the image vertically within the cell
            eventImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            // Set the height of the image equal to the cell's height
            eventImageView.heightAnchor.constraint(equalTo: heightAnchor),
            // Maintain a 1:1 aspect ratio
            eventImageView.widthAnchor.constraint(equalTo: heightAnchor)
        ])
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.clipsToBounds = true
        
        // Set the button title and image

        pplGoing.titleLabel?.font = UIFont(name: "Futura-Medium", size: 14)
        pplGoing.backgroundColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1)
        pplGoing.layer.cornerRadius = 8
        pplGoing.clipsToBounds = true
        pplGoing.layer.shadowColor = UIColor.black.cgColor
        pplGoing.layer.shadowOpacity = 0.5
        pplGoing.layer.shadowOffset = CGSize(width: 0, height: 4)
        pplGoing.layer.shadowRadius = 5
        pplGoing.layer.masksToBounds = false
        pplGoing.tintColor = .white
        pplGoing.setTitleColor(.white, for: .normal)
        pplGoing.titleLabel?.adjustsFontSizeToFitWidth = true

        // Adjust the image position
        pplGoing.semanticContentAttribute = .forceRightToLeft
        pplGoing.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5)
        pplGoing.isUserInteractionEnabled = true


        // Set constraints
        NSLayoutConstraint.activate([
            pplGoing.leadingAnchor.constraint(equalTo: eventDateLabel.leadingAnchor),
            pplGoing.topAnchor.constraint(equalTo: eventDateLabel.bottomAnchor, constant: 10),
            pplGoing.trailingAnchor.constraint(equalTo: eventDateLabel.trailingAnchor), // Adjust as needed
            pplGoing.heightAnchor.constraint(equalToConstant: 30)
        ])
        pplGoing.translatesAutoresizingMaskIntoConstraints = false

        // Add target action
        pplGoing.addTarget(self, action: #selector(pplGoingClicked), for: .touchUpInside)
        
        
        
        // Set the button title and image
        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.textColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1)
        editButton.titleLabel?.font = UIFont(name: "Futura-Medium", size: 14)
        editButton.isUserInteractionEnabled = true
        editButton.titleLabel?.adjustsFontSizeToFitWidth = true
        //editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.tintColor = .white
        editButton.setTitleColor(.white, for: .normal)

        // Adjust the image position
        editButton.semanticContentAttribute = .forceRightToLeft
        editButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5)

        // Set constraints
        NSLayoutConstraint.activate([
            editButton.centerXAnchor.constraint(equalTo: ticketImageView.centerXAnchor),
            editButton.centerYAnchor.constraint(equalTo: pplGoing.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 50), // Adjust as needed
            editButton.heightAnchor.constraint(equalToConstant: 25)
        ])
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.isUserInteractionEnabled = true

        // Add target action
        editButton.addTarget(self, action: #selector(editClicked), for: .touchUpInside)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithEvent(event: EventLoad) {
        self.eventPassed = event
        pplGoing.setTitle(String(event.isGoing.count) + " Attendees", for: .normal)
        eventNameLabel.text = event.eventName
        eventDateLabel.text = event.date
        loadImage(from: event.imageURL, to: eventImageView)
        

    }
    func loadImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        imageView.kf.setImage(with: url)
    }



    @objc func editClicked() {
        // Implement the action for the edit button
        print("Edit button clicked")
        delegate?.editButtonTapped(cell: self, event: eventPassed!)

    }
    @objc func pplGoingClicked() {
        // Implement the action for the edit button
        print("pplgoing button clicked")
        delegate?.pplGoingButtonTapped(cell: self, event: eventPassed!)

    }
}


protocol MyEventsCellDelegate: AnyObject {
    func pplGoingButtonTapped(cell: MyEventsCell, event: EventLoad)
    func editButtonTapped(cell: MyEventsCell, event: EventLoad)
}
