import UIKit
import Firebase

class futureEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var eventList: [EventSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = currCity + " Events"
        tableView.delegate = self
        tableView.dataSource = self
        fetchEventData()
    }

    func fetchEventData() {
        let eventsRef = Database.database().reference().child("\(currCity)Events")
        
        eventsRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let eventsData = snapshot.value as? [String: Any] else {
                return
            }
            
            var groupedEvents: [Date: [EventNew]] = [:]
            
            for (eventKey, eventData) in eventsData {
                if let eventData = eventData as? [String: Any],
                   let creator = eventData["creator"] as? String,
                   let dateString = eventData["date"] as? String,
                   let date = self.date(from: dateString),
                   let description = eventData["description"] as? String,
                   let name = eventData["name"] as? String,
                   let time = eventData["time"] as? String {
                    
                    let event = EventNew(eventKey: eventKey,
                                         creator: creator,
                                         date: date,
                                         description: description,
                                         name: name,
                                         time: time)
                    
                    if groupedEvents[date] == nil {
                        groupedEvents[date] = []
                    }
                    
                    groupedEvents[date]?.append(event)
                }
            }
            
            // Create sections from grouped events
            self.eventList = groupedEvents.sorted { $0.key < $1.key }.map { EventSection(date: $0.key, events: $0.value) }
            
            // Reload table view
            self.tableView.reloadData()
        }
    }

    // Helper method to convert date string to Date object
    func date(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.date(from: dateString)
    }

    // MARK: - UITableView DataSource and Delegate methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return eventList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList[section].events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! futureEventCell
        let event = eventList[indexPath.section].events[indexPath.row]
        cell.configure(with: event)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 1, green: 0.0862745098, blue: 0.5803921569, alpha: 1) // #ff1694

        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = DateFormatter.localizedString(from: eventList[section].date, dateStyle: .medium, timeStyle: .none)

        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16)
        ])

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Return the desired height for your cells
        return 80.0 // Adjust the value as needed
    }
}

struct EventSection {
    let date: Date
    let events: [EventNew]
}
