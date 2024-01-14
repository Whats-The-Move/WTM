import UIKit
import FirebaseDatabase
import FirebaseAuth


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
        fetchEvents { pastEvents, upcomingEvents in
            // This code block will be executed after the events are fetched
            // Setup your UI using pastEvents and upcomingEvents
            self.pastEvents = pastEvents
            self.upcomingEvents = upcomingEvents
            DispatchQueue.main.async {
                // Make sure to update the UI on the main thread
                self.setupUI()

                // For example:
                // self.updateTableView(with: pastEvents, upcomingEvents)
            }
        }

    }

    private func setupUI() {
        // Setup titleLabel
        titleLabel.font = UIFont(name: "Futura-Medium", size: 34)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
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
            myEventsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myEventsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            myEventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupButton(_ button: UIButton, title: String) {
        print("setting up buton")
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(toggleEventView(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
    }

    @objc func toggleEventView(_ sender: UIButton) {
        // Reverse the pastBool value
        pastBool = !pastBool

        // Update the button styles based on the value of pastBool
        if pastBool {
            // When pastBool is true, highlight the pastEventsButton and disable upcomingEventsButton
            pastEventsButton.setTitleColor(.white, for: .normal)
            pastEventsButton.isUserInteractionEnabled = false

            upcomingEventsButton.setTitleColor(.gray, for: .normal)
            upcomingEventsButton.isUserInteractionEnabled = true
        } else {
            // When pastBool is false, highlight the upcomingEventsButton and disable pastEventsButton
            upcomingEventsButton.setTitleColor(.white, for: .normal)
            upcomingEventsButton.isUserInteractionEnabled = false

            pastEventsButton.setTitleColor(.gray, for: .normal)
            pastEventsButton.isUserInteractionEnabled = true
        }

        // You might want to reload your table view or perform other UI updates here
        // tableView.reloadData() for example

        print("Button pressed. PastBool is now \(pastBool)")
    }


    private func updateButtonStyles() {
        let buttons = [upcomingEventsButton, pastEventsButton]
        buttons.forEach { button in
            button.setTitleColor(button == upcomingEventsButton ? .white : .gray, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            // Additional style updates, e.g., underline
        }
    }

    // MARK: - TableView Delegate & DataSource Methods


    func fetchEvents(completion: @escaping ([EventLoad], [EventLoad]) -> Void) {
        let ref = Database.database().reference()
        let currCityRef = ref.child(currCity + "Events")  // Replace 'currCity' with your current city variable
        let currentUserUID = Auth.auth().currentUser?.uid ?? ""
        let currentDate = Date()

        currCityRef.observeSingleEvent(of: .value, with: { snapshot in
            var pastEvents: [EventLoad] = []
            var upcomingEvents: [EventLoad] = []

            guard let cityData = snapshot.value as? [String: Any] else {
                completion([], [])
                return
            }

            for (dateString, dateNodes) in cityData {
                guard let dateData = dateNodes as? [String: Any],
                      let date = DateFormatter.yyyyMMdd.date(from: dateString) else { continue }

                for (key, eventData) in dateData {
                    if let eventDataDict = eventData as? [String: Any],
                       let isGoing = eventDataDict["isGoing"] as? [String],
                       isGoing.contains(currentUserUID),
                       let creator = eventDataDict["creator"] as? String,
                       let deals = eventDataDict["deals"] as? String,
                       let description = eventDataDict["description"] as? String,
                       let eventName = eventDataDict["eventName"] as? String,
                       let imageURL = eventDataDict["imageURL"] as? String,
                       let location = eventDataDict["location"] as? String,
                       let time = eventDataDict["time"] as? String,
                       let venueName = eventDataDict["venueName"] as? String,
                       let type = eventDataDict["type"] as? String {
                        
                        let event = EventLoad(creator: creator, date: dateString, deals: deals, description: description, eventName: eventName, imageURL: imageURL, isGoing: isGoing, location: location, time: time, venueName: venueName, type: type, eventKey: key)
                        print("event created")
                        if date < currentDate {
                            pastEvents.append(event)
                        } else {
                            upcomingEvents.append(event)
                        }
                    }
                    else{
                        print("missing event data")
                    }
                }
            }

            completion(pastEvents, upcomingEvents)
        }) { error in
            print(error.localizedDescription)
            completion([], [])
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

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 // Set cell height to 200px
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

        // Constraints for eventDateLabel
        NSLayoutConstraint.activate([
            eventDateLabel.leadingAnchor.constraint(equalTo: eventNameLabel.leadingAnchor),
            eventDateLabel.topAnchor.constraint(equalTo: eventNameLabel.bottomAnchor, constant: 5),
            eventDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: eventImageView.leadingAnchor, constant: -10)
        ])

        // Constraints for eventImageView
        NSLayoutConstraint.activate([
            eventImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            eventImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            eventImageView.widthAnchor.constraint(equalToConstant: 60),
            eventImageView.heightAnchor.constraint(equalToConstant: 60)
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

