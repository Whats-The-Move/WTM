import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore


class MyEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let titleLabel = UILabel()
    let upcomingEventsButton = UIButton()
    let pastEventsButton = UIButton()
    let myEventsTableView = UITableView()
    
    var pastEvents: [EventLoad] = []
    var upcomingEvents: [EventLoad] = []
    var pastBool = false

    override func viewDidLoad() {
        super.viewDidLoad()
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
                for event in matchedEvents {
                    if let eventDate = DateFormatter.yyyyMMdd.date(from: event.date), eventDate < currentDate {
                        self.pastEvents.append(event)
                    } else {
                        self.upcomingEvents.append(event)
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
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)
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

        // Setup myEventsTableView
        myEventsTableView.delegate = self
        myEventsTableView.dataSource = self
        myEventsTableView.backgroundColor = .darkGray
        myEventsTableView.register(MyEventsCell.self, forCellReuseIdentifier: "MyEventsCell")
        myEventsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myEventsTableView)

        NSLayoutConstraint.activate([
            myEventsTableView.topAnchor.constraint(equalTo: upcomingEventsButton.bottomAnchor, constant: 20),
            myEventsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            myEventsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            myEventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
                    print("eventsGoing field does not exist")
                    completion(nil)
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
                       let location = eventDataDict["location"] as? String,
                       let time = eventDataDict["time"] as? String,
                       let venueName = eventDataDict["venueName"] as? String,
                       let type = eventDataDict["type"] as? String {
                        
                        let event = EventLoad(creator: creator, date: dateString, deals: deals, description: description, eventName: eventName, imageURL: imageURL, isGoing: [], location: location, time: time, venueName: venueName, type: type, eventKey: eventKey)
                        matchedEvents.append(event)
                    }
                }
            }

            completion(matchedEvents)
        }) { error in
            print(error.localizedDescription)
            completion([])
        }
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
        cell.backgroundColor = .clear
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150 // Set cell height to 200px
    }

}
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// Assuming you have a 'MyEventsCell' class
class MyEventsCell: UITableViewCell {
    let eventNameLabel = UILabel()
    let eventDateLabel = UILabel()
    let eventImageView = UIImageView()
    let ticketImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Adding subviews
        addSubview(eventNameLabel)
        addSubview(eventDateLabel)
        addSubview(eventImageView)
        addSubview(ticketImageView)

        // Disable autoresizing masks for all subviews
        [eventNameLabel, eventDateLabel, eventImageView, ticketImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Constraints for ticketImageView
        NSLayoutConstraint.activate([
            ticketImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            ticketImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ticketImageView.widthAnchor.constraint(equalToConstant: 30),
            ticketImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        ticketImageView.image = UIImage(systemName: "ticket")
        ticketImageView.tintColor = .systemPink

        // Constraints for eventNameLabel
        NSLayoutConstraint.activate([
            eventNameLabel.leadingAnchor.constraint(equalTo: ticketImageView.trailingAnchor, constant: 10),
            eventNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
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
            eventImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            eventImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            eventImageView.widthAnchor.constraint(equalToConstant: 150),
            eventImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
        eventImageView.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithEvent(event: EventLoad) {
        eventNameLabel.text = event.eventName
        eventDateLabel.text = event.date
        HorizontalCollectionViewCell().loadImage(from: event.imageURL, to: eventImageView)
        

    }
}

