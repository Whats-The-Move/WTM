import UIKit
import FirebaseDatabase

class weeklyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
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
        print("viewdidload")
    }
    
    func fetchEventData() {
        print("fetchevent")

        let ref = Database.database().reference().child("Events")
        ref.observe(.childAdded) { [weak self] (snapshot) in
            let dateKey = snapshot.key
            guard let placeDict = snapshot.value as? [String: Any] else { return }

            for (eventPlaceName, placeInfo) in placeDict {
                guard let eventInfo = placeInfo as? [String: Any],
                      let eventName = eventInfo["Event Name"] as? String,
                      let eventTime = eventInfo["Time"] as? String else {
                          continue
                      }

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy"
                if let eventDate = dateFormatter.date(from: dateKey) {
                    let event = Event()
                    event.place = eventPlaceName
                    event.name = eventName
                    event.time = eventTime
                    event.date = eventDate
                    self?.eventsList.append(event)
                }
            }

            self?.tableView.reloadData()

        }
    }
    func setupNoDealsLabel() {
        noDealsLabel = UILabel()
        noDealsLabel.text = "No drink deals today :("
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! EventCell
        print("cellforrowat")

        return selectedDateEvents.isEmpty ? 1 : selectedDateEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        

        let selectedDateEvents = eventsList.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }

        if selectedDateEvents.isEmpty {
            // Display the "No events for today" cell
            cell = tableView.dequeueReusableCell(withIdentifier: "noEventsCell", for: indexPath) as! NoEventsCell
        } else {
            // Display the regular event cell
            cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! EventCell
            
            let event = selectedDateEvents[indexPath.section]
            if let eventCell = cell as? EventCell {
                eventCell.placeLabel.text = event.place
                eventCell.nameLabel.text = event.name
                eventCell.timeLabel.text = event.time
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0 // Adjust the spacing as needed
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView() // Empty view to create the spacing
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}
