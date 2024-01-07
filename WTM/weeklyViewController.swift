import UIKit
import FirebaseDatabase
import FirebaseAuth

class weeklyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    var myEventsButton: UIButton!

    var noDealsLabel: UILabel!

    var selectedDate = Date()
    var totalSquares = [Date]()
    var eventsList: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCellsView()
        setWeekView()
        fetchEventData()
        setupNoDealsLabel()
        setupMyEventsButton()
        print("viewdidload")
    }
    
    func fetchEventData() {
        print("fetchevent")
        var queryFrom = "Events"
        if dbName == "BerkeleyParties" {
            queryFrom = "BerkeleyEvents"
        }
        else if dbName == "ChicagoParties" {
            queryFrom = "ChicagoEvents"
        }
        else {
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






    func setupMyEventsButton() {
        // Create the button
        myEventsButton = UIButton()
        myEventsButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Set button title and style
        myEventsButton.setTitle("My Events", for: .normal)
        myEventsButton.titleLabel?.font = UIFont(name: "Futura-Medium", size: 30)
        myEventsButton.backgroundColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0)
        myEventsButton.setTitleColor(.white, for: .normal)
        myEventsButton.layer.cornerRadius = 10
        myEventsButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Add button target
        myEventsButton.addTarget(self, action: #selector(myEventsButtonTapped), for: .touchUpInside)
        
        // Add button to the view
        view.addSubview(myEventsButton)
        
        // Define constraints
        NSLayoutConstraint.activate([
            myEventsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myEventsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            myEventsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            myEventsButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        // Retrieve the value of partyAccount from UserDefaults
        let partyAccount = UserDefaults.standard.bool(forKey: "partyAccount")
        myEventsButton.isHidden = true
        if partyAccount {
    
            print("party account true: partyaccount is:")
            print(partyAccount)
            myEventsButton.isHidden = false
        }

    }

    @objc func myEventsButtonTapped() {
        print("my events clicked")

        let createEventVC = CreateEventViewController()
        createEventVC.modalPresentationStyle = .fullScreen // Optional: Present full screen
        present(createEventVC, animated: true, completion: nil)
    }

    

    
    func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
        
        let screen = UIScreen.main.bounds
        
        if screen.size.width > 400 { // iPhone 14 Pro Max
            flowLayout.minimumInteritemSpacing = 10
        } else if screen.size.width < 400 { // iPhone 14
            flowLayout.minimumInteritemSpacing = 2
        } else {
            // Set a default value here if needed
            flowLayout.minimumInteritemSpacing = 4
        }
    }
    
    func setWeekView()
    {
        totalSquares.removeAll()
        
        var current = CalendarHelper().sundayForDate(date: selectedDate)
        let nextSunday = CalendarHelper().addDays(date: current, days: 7)
        
        while (current < nextSunday)
        {
            totalSquares.append(current)
            current = CalendarHelper().addDays(date: current, days: 1)
        }
        
        monthLabel.text = CalendarHelper().monthString(date: selectedDate)
            + " " + CalendarHelper().yearString(date: selectedDate)
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("collectionviewcellforitemat")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! calendarCell
            
        let date = totalSquares[indexPath.item]
        cell.dayOfMonth.text = String(CalendarHelper().dayOfMonth(date: date))
        
        if(date == selectedDate)
        {
            cell.backgroundColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1)
            cell.layer.cornerRadius = cell.frame.height / 2
        }
        else
        {
            cell.backgroundColor = UIColor.clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectedDate = totalSquares[indexPath.item]
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    @IBAction func previousWeek(_ sender: Any) {
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: -7)
        setWeekView()
    }
    
    @IBAction func nextWeek(_ sender: Any) {
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: 7)
        setWeekView()
    }
    
    override open var shouldAutorotate: Bool
    {
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let selectedDateEvents = eventsList.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }

        if let label = noDealsLabel {
            print("nodealslabel exists")
            label.isHidden = !selectedDateEvents.isEmpty
        }
        return selectedDateEvents.count
        print("numberofsections")
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        

        let selectedDateEvents = eventsList.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! EventCell
        
        let event = selectedDateEvents[indexPath.section]
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
        
        /*if selectedCell?.creator == Auth.auth().currentUser?.uid {
                //let selectedDateEvents = eventsList.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
                //let selectedItem = selectedDateEvents[indexPath.row]

            print("my events clicked")

            // Replace "YourStoryboardName" with the actual name of your storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createEvent = storyboard.instantiateViewController(withIdentifier: "CreateEvent") as! CreateEventViewController
            present(createEvent, animated: true, completion: nil)
            }
        */

        if selectedCell?.eventType == "Free Drink" {
            performSegue(withIdentifier: "freeDrinkNightSegue", sender: self)
        }

        else{
            //let selectedItem = yourDataSource[indexPath.row]
            //let selectedItem = yourDataSource[indexPath.row]
           
            // Create an instance of the destination view controller
            let selectedDateEvents = eventsList.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            let selectedItem = selectedDateEvents[indexPath.row]
            //how does this work... how does it know waht destinationViewController is
            // Create an instance of the DestinationViewController and pass the selectedItem
            let destinationVC = ShowEventViewController(selectedItem: selectedItem)

            // Present the destination view controller modally
            present(destinationVC, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "freeDrinkNightSegue",
           let selectedIndexPath = tableView.indexPathForSelectedRow,
           let destinationViewController = segue.destination as? freeDrinkNightViewController,
           let selectedCell = tableView.cellForRow(at: selectedIndexPath) as? EventCell {
            destinationViewController.selectedPlace = selectedCell.placeLabel.text
            destinationViewController.creator = selectedCell.creator
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy" // Use the desired date format

            let dateString = dateFormatter.string(from: selectedDate)

            destinationViewController.date = dateString

        }
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}
