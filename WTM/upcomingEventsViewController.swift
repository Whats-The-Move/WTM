//
//  upcomingEventsViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 9/28/23.
//
import UIKit
import Firebase
import FirebaseAuth
class upcomingEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    var eventsList: [Event] = []
    var noDealsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // Set the background color to black
        setupTitleLabel()
        setupTableView()
        fetchEventData()
        setupNoDealsLabel()
        // Register the cell class
        tableView.register(EventCell.self, forCellReuseIdentifier: "cellID")
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Upcoming Events"
        titleLabel.textColor = .white // Set the text color to white
        titleLabel.font = UIFont(name: "Futura", size: 24) // Set the Futura font and size
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black // Set the background color of the table view to black
        tableView.separatorStyle = .none // Remove cell separators
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func fetchEventData() {
        var queryFrom = "Events"
        if dbName == "BerkeleyParties" {
            queryFrom = "BerkeleyEvents"
        } else if dbName == "ChicagoParties" {
            queryFrom = "ChicagoEvents"
        } else {
            queryFrom = "EventsTest"
        }
        let ref = Database.database().reference().child(queryFrom)
        ref.observe(.childAdded) { [weak self] (snapshot) in
            let dateKey = snapshot.key
            print("printing date key " + dateKey)
            guard let placeDict = snapshot.value as? [String: Any] else { return }
            for (eventPlaceName, placeInfo) in placeDict {
                print("Event Place Name:", eventPlaceName)
                print("Place Info:", placeInfo)
                guard let eventInfo = placeInfo as? [String: Any],
                      let eventName = eventInfo["title"] as? String,
                      let start = eventInfo["start"] as? Int,
                      let eventEnd = eventInfo["end"] as? Int,
                      let eventLocation = eventInfo["location"] as? String,
                      let eventType = eventInfo["eventType"] as? String,
                      let creator = eventInfo["creator"] as? String,
                      let eventDescription = eventInfo["description"] as? String else {
                        print("didnt work")
                        continue
                    }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy"
                if let eventDate = dateFormatter.date(from: dateKey) {
                    let event = Event()
                    print("I am going to pull event")
                    event.place = eventPlaceName
                    event.name = eventName
                    event.time = start
                    event.date = eventDate
                    event.description = eventDescription
                    event.endTime = eventEnd
                    event.location = eventLocation
                    event.type = eventType
                    event.creator = creator
                    self?.eventsList.append(event)
                }
            }
            self?.tableView.reloadData()
        }
    }
    
    func setupNoDealsLabel() {
        noDealsLabel = UILabel()
        noDealsLabel.text = "No events or deals today :("
        noDealsLabel.textColor = UIColor.gray
        noDealsLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        noDealsLabel.textAlignment = .center
        noDealsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDealsLabel)
        NSLayoutConstraint.activate([
            noDealsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDealsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        noDealsLabel.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! EventCell
        let event = eventsList[indexPath.section]
        if let eventCell = cell as? EventCell {
            eventCell.placeLabel.text = event.place
            eventCell.nameLabel.text = event.name
            let unixTimestamp = event.time ?? 0 // Replace this with your Unix timestamp
            let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a" // Set the format to display time in 12-hour format with AM/PM
            let timeString = dateFormatter.string(from: date)
            let endUnixTimestamp = event.endTime ?? 0 // Replace this with your Unix timestamp
            let endDate = Date(timeIntervalSince1970: TimeInterval(endUnixTimestamp))
            let endTimeString = dateFormatter.string(from: endDate)
            eventCell.timeLabel.text = timeString + " to " + endTimeString
            eventCell.eventType = event.type
            eventCell.creator = event.creator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0 // Adjust the spacing as needed
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView() // Empty view to create the spacing
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as? EventCell
        
        if selectedCell?.eventType == "Free Drink" {
            let freeDrinkVC = freeDrinkNightViewController() // Initialize the view controller
            // You can add more properties from selectedEvent if needed
            present(freeDrinkVC, animated: true, completion: nil)
        } else {
            let selectedEvent = eventsList[indexPath.section]
            let destinationVC = ShowEventViewController(selectedItem: selectedEvent)
            present(destinationVC, animated: true, completion: nil)
        }
    }
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}

