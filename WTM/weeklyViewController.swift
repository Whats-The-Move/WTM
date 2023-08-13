import UIKit
import FirebaseDatabase

class weeklyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedDate = Date()
    var totalSquares = [Date]()
    
    var eventsList: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCellsView()
        setWeekView()
        fetchEventData()
    }
    
    func fetchEventData() {
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
    
    func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
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
        return selectedDateEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! EventCell

        let selectedDateEvents = eventsList.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }

        if indexPath.section < selectedDateEvents.count {
            let event = selectedDateEvents[indexPath.section]
            cell.placeLabel.text = event.place
            cell.nameLabel.text = event.name
            cell.timeLabel.text = event.time
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