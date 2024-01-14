import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase


class NewHomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIScrollViewDelegate, TopGalleryCollectionViewCellDelegate {
    
    
    
    
    
    var verticalCollectionView: UICollectionView!
    let filters = ["Trending Now", "Friend's Choice", "Rush Events", "Bars/Clubs", "Best Deals"]
    var events: [EventLoad] = []
    var rushList: [EventLoad] = []
    var barList: [EventLoad] = []
    var friendSortedList: [EventLoad] = []
    
    //let searchBar = UISearchBar()
    //let dropdownButton = UIButton(type: .system)
    let dates = ["This Week", "Tomorrow", "Today"]
    //let optionsStackView = UIStackView()
    let titleLabel = UILabel()
    
    private let ticketButton = UIButton(type: .system)
    private let addFriendsButton = UIButton(type: .system)
    private let refreshControl = UIRefreshControl()
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupGradientBackground()
        view.backgroundColor = .black
        //setupSearchBar()
        setupTitleLabel()
        
        //setupDropdownButton()
        //setupOptionsStackView()
        setupTicketButton()
        setupAddFriendsButton()
        
        
        
        
        let datelist = getDatesBasedOnCurrentOption()
        /*Task {
         await loadAndPrepareData()
         }*/
        loadData(queryFrom: currCity + "Events", dateStrings: datelist) { [weak self] loadedEvents in
            self?.events = loadedEvents
            self?.events.sort { $0.isGoing.count > $1.isGoing.count }
            
            // Use a Task to call the asynchronous function
            self?.prepareRushData()
            self?.prepareBarClubData()
            Task {
                // Make sure to capture self weakly to avoid retain cycles
                guard let strongSelf = self else { return }
                let friendSortedEvents = await strongSelf.getEventsSortedByFriends()
                
                // Dispatch back to the main thread for any UI updates
                DispatchQueue.main.async {
                    strongSelf.friendSortedList = friendSortedEvents
                    strongSelf.setupVerticalCollectionView()
                    strongSelf.setupPullToRefresh()
                    
                    // Any other UI updates
                }
            }
            
            
            
        }
        
        
        
        
        
        
        
    }
    
    
    private func setupTicketButton() {
        ticketButton.setImage(UIImage(systemName: "ticket"), for: .normal)
        ticketButton.tintColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1)
        ticketButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ticketButton)
        
        NSLayoutConstraint.activate([
            ticketButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            ticketButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            ticketButton.heightAnchor.constraint(equalToConstant: 30),
            ticketButton.widthAnchor.constraint(equalToConstant: 30)
            
            
        ])
    }
    private func setupAddFriendsButton() {
        addFriendsButton.setImage(UIImage(systemName: "person.crop.circle.badge.plus"), for: .normal)
        addFriendsButton.tintColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1)
        addFriendsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addFriendsButton)
        
        NSLayoutConstraint.activate([
            addFriendsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addFriendsButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addFriendsButton.heightAnchor.constraint(equalToConstant: 30),
            addFriendsButton.widthAnchor.constraint(equalToConstant: 30)
            
            
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //view.bringSubviewToFront(optionsStackView)
        
    }
    func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        titleLabel.text = "WTM"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
    /*
     func setupOptionsStackView() {
     view.addSubview(optionsStackView)
     optionsStackView.axis = .horizontal
     optionsStackView.distribution = .fillEqually
     optionsStackView.alignment = .fill
     optionsStackView.spacing = 5
     optionsStackView.isHidden = true  // Initially hidden
     optionsStackView.isUserInteractionEnabled = true
     
     
     // Create and add buttons
     let todayButton = createButtonWithTitle("Today")
     let tomorrowButton = createButtonWithTitle("Tomorrow")
     let thisWeekButton = createButtonWithTitle("This Week")
     
     optionsStackView.addArrangedSubview(todayButton)
     optionsStackView.addArrangedSubview(tomorrowButton)
     optionsStackView.addArrangedSubview(thisWeekButton)
     
     optionsStackView.translatesAutoresizingMaskIntoConstraints = false
     NSLayoutConstraint.activate([
     optionsStackView.topAnchor.constraint(equalTo: dropdownButton.bottomAnchor, constant: 5),
     optionsStackView.trailingAnchor.constraint(equalTo: dropdownButton.trailingAnchor),
     optionsStackView.widthAnchor.constraint(equalToConstant: 270),
     optionsStackView.heightAnchor.constraint(equalToConstant: 25)
     ])
     }*/
    /*
     func createButtonWithTitle(_ title: String) -> UIButton {
     let button = UIButton(type: .system)
     button.setTitle(title, for: .normal)
     button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
     button.setTitleColor(.white, for: .normal)
     button.backgroundColor = UIColor(red: 131/255.0, green: 10/255.0, blue: 70/255.0, alpha: 1)
     button.layer.cornerRadius = 12.5
     button.layer.borderColor = UIColor.white.cgColor
     button.layer.borderWidth = 1
     button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
     button.isUserInteractionEnabled = true
     
     
     // Set alpha based on currentOption
     if currentOption == title {
     button.alpha = 1
     }
     
     return button
     }
     
     
     @objc func optionSelected(_ sender: UIButton) {
     print("Selected option:")
     
     guard let title = sender.titleLabel?.text else { return }
     print("Selected option: \(title)")
     // Handle the selection
     currentOption = title
     dropdownTapped()
     //RELOAD HERE
     // Update button alphas
     
     }
     
     func setupDropdownButton() {
     view.addSubview(dropdownButton)
     dropdownButton.setTitle(currentOption, for: .normal)
     let originalImage = UIImage(systemName: "chevron.down")! // Replace with your down arrow image
     let resizedImage = resizeImage(image: originalImage, targetSize: CGSize(width: 12, height: 12)) // Adjust target size as needed
     
     dropdownButton.setImage(resizedImage, for: .normal) // Replace with your down arrow image
     dropdownButton.tintColor = .white
     dropdownButton.setTitleColor(.white, for: .normal)
     dropdownButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
     dropdownButton.addTarget(self, action: #selector(dropdownTapped), for: .touchUpInside)
     dropdownButton.layer.cornerRadius = 10
     dropdownButton.layer.borderWidth = 1
     dropdownButton.layer.borderColor = UIColor.white.cgColor
     
     // Layout the button
     dropdownButton.translatesAutoresizingMaskIntoConstraints = false
     NSLayoutConstraint.activate([
     dropdownButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 35),
     dropdownButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),
     dropdownButton.widthAnchor.constraint(equalToConstant: 90),
     dropdownButton.heightAnchor.constraint(equalToConstant: 20)
     ])
     
     // Adjust the position of the image and text
     dropdownButton.semanticContentAttribute = .forceRightToLeft
     dropdownButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0) // Adjust as needed
     dropdownButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: -2) // Adjust as needed
     }
     
     
     @objc func dropdownTapped() {
     
     optionsStackView.isHidden = !optionsStackView.isHidden
     
     }
     */
    
    /*
     func setupSearchBar() {
     searchBar.delegate = self
     searchBar.placeholder = "Search here"
     searchBar.searchBarStyle = .minimal
     searchBar.isTranslucent = true
     searchBar.backgroundColor = UIColor(red: 131/255.0, green: 10/255.0, blue: 70/255.0, alpha: 1)
     
     //searchBar.backgroundColor = UIColor.black.withAlphaComponent(0.37)
     searchBar.layer.borderWidth = 1
     searchBar.layer.borderColor = UIColor.white.cgColor
     
     
     // Set the corner radius for the entire search bar
     searchBar.layer.cornerRadius = 15
     searchBar.layer.masksToBounds = true
     
     if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
     textfield.textColor = .white
     textfield.backgroundColor = UIColor.clear
     textfield.font = UIFont.boldSystemFont(ofSize: 16)
     
     
     // Set placeholder text color
     let placeholderAttrString = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
     textfield.attributedPlaceholder = placeholderAttrString
     if let glassIconView = textfield.leftView as? UIImageView {
     glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
     glassIconView.tintColor = .white
     }
     
     if let clearButton = textfield.value(forKey: "clearButton") as? UIButton {
     clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
     clearButton.tintColor = .clear
     }
     
     // Drop shadow
     searchBar.layer.masksToBounds = false // Important for shadow
     searchBar.layer.shadowColor = UIColor.white.cgColor
     searchBar.layer.shadowOffset = CGSize(width: 0, height: 1)
     searchBar.layer.shadowOpacity = 0.5
     searchBar.layer.shadowRadius = 5
     }
     
     searchBar.translatesAutoresizingMaskIntoConstraints = false
     view.addSubview(searchBar)
     
     NSLayoutConstraint.activate([
     searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
     searchBar.heightAnchor.constraint(equalToConstant: 30),
     searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
     searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
     ])
     }
     */
    
    
    func loadData(queryFrom: String, dateStrings: [String], completion: @escaping ([EventLoad]) -> Void) {
        let ref = Database.database().reference(withPath: queryFrom)
        var events: [EventLoad] = []
        let group = DispatchGroup()
        
        for dateString in dateStrings {
            group.enter()
            ref.child(dateString).observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {
                    print(dateString)
                    print("No data available")
                    group.leave()
                    return
                }
                for (key, data) in value {
                    if let eventData = data as? [String: Any],
                       let creator = eventData["creator"] as? String,
                       let date = dateString as? String,
                       let deals = eventData["deals"] as? String,
                       let description = eventData["description"] as? String,
                       let eventName = eventData["eventName"] as? String,
                       let imageURL = eventData["imageURL"] as? String,
                       let isGoing = eventData["isGoing"] as? [String],
                       let location = eventData["location"] as? String,
                       let time = eventData["time"] as? String,
                       let venueName = eventData["venueName"] as? String,
                       let type = eventData["type"] as? String,
                       let eventKey = key as? String
                    {
                        let event = EventLoad(creator: creator, date: date, deals: deals, description: description, eventName: eventName, imageURL: imageURL, isGoing: isGoing, location: location, time: time, venueName: venueName, type: type, eventKey: eventKey)
                        events.append(event)
                        print("FUCK!!")
                        print(event.creator)
                        
                    }
                }
                print("leaving gropu")
                print(String(events.count))
                group.leave()
            }) { error in
                print(error.localizedDescription)
                group.leave()
            }
        }
        print("time to execute completion")
        group.notify(queue: .main) {
            
            completion(events)
        }
    }
    
    
    private func setupVerticalCollectionView() {
        print("setting up collection view")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        // Adjust the item size as per your requirement
        layout.itemSize = CGSize(width: view.frame.width - 15, height: 200)
        
        verticalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        verticalCollectionView.dataSource = self
        verticalCollectionView.delegate = self
        verticalCollectionView.isScrollEnabled = true
        
        verticalCollectionView.backgroundColor = .clear // Change as needed
        if let flowLayout = verticalCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.minimumInteritemSpacing = 0
            
        }
        verticalCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        // Register your custom cell here
        verticalCollectionView.register(VerticalCollectionViewCell.self, forCellWithReuseIdentifier: "VerticalCell")
        verticalCollectionView.register(TopGalleryCollectionViewCell.self, forCellWithReuseIdentifier: "GalleryCell")
        
        verticalCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verticalCollectionView)
        
        NSLayoutConstraint.activate([
            verticalCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            verticalCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            verticalCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 15),
            verticalCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let pink = UIColor(red: 255/255, green: 22/255, blue: 142/255, alpha: 1).cgColor
        gradientLayer.colors = [pink, UIColor.black.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Return the number of sections you want in the vertical collection view
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items you want in each section
        return filters.count // Example number
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            // This is the gallery section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! TopGalleryCollectionViewCell
            cell.delegate = self
            
            
            let filterTitle = filters[indexPath.item]
            
            cell.configure(title: filterTitle, with: events)
            cell.contentView.backgroundColor = .clear
            return cell
        } else if indexPath.item == 1 {
            // This is the main content section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerticalCell", for: indexPath) as! VerticalCollectionViewCell
            // Configure your cell here
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.delegate = self
            
            let filterTitle = filters[indexPath.item]
            cell.configure(title: filterTitle, with: events)
            return cell
        }
        else if indexPath.item == 2 { //Rush Events
            // This is the main content section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerticalCell", for: indexPath) as! VerticalCollectionViewCell
            // Configure your cell here
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.delegate = self
            //**************
            
            //**************
            
            let filterTitle = filters[indexPath.item]
            cell.configure(title: filterTitle, with: rushList)
            return cell
        }
        else if indexPath.item == 3 { //Bar Club
            // This is the main content section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerticalCell", for: indexPath) as! VerticalCollectionViewCell
            // Configure your cell here
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.delegate = self
            //**************
            
            //**************
            
            let filterTitle = filters[indexPath.item]
            cell.configure(title: filterTitle, with: barList)
            return cell
        }
        else {
            // This is the main content section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerticalCell", for: indexPath) as! VerticalCollectionViewCell
            // Configure your cell here
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.delegate = self
            
            let filterTitle = filters[indexPath.item]
            cell.configure(title: filterTitle, with: events)
            return cell
        }
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Adjust cell size
        if indexPath.item == 0 {
            return CGSize(width: view.frame.width - 15, height: view.frame.width - 45 + 48) // this is size of pic plus spacing plus height of label
        }
        else {
            return CGSize(width: view.frame.width, height: 200) // Example size
        }
    }
    func getDatesBasedOnCurrentOption() -> [String] {
        var dates: [String] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        
        
        if currentOption == "Today" {
            let today = Date()
            print(today)
            dates.append(dateFormatter.string(from: today))
        } else if currentOption == "Tomorrow" {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            dates.append(dateFormatter.string(from: tomorrow))
        } else if currentOption == "This Week" {
            let today = Date()
            let calendar = Calendar.current
            
            // Find the start of the current week
            if let weekStart = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: today)) {
                for i in 0..<7 {
                    if let weekDay = calendar.date(byAdding: .day, value: i, to: weekStart) {
                        dates.append(dateFormatter.string(from: weekDay))
                    }
                }
                print("printing dates")
                print(dates)
            }
        }
        return dates
    }
    func didSelectEventLoad(eventLoad: EventLoad) {
        let detailsVC = EventDetailsViewController(eventLoad: eventLoad)
        present(detailsVC, animated: true, completion: nil)
    }
    func prepareRushData() {
        // Filter and sort events
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        rushList = events.filter { $0.type == "Frat" }.sorted {
            guard let date1 = dateFormatter.date(from: $0.date),
                  let date2 = dateFormatter.date(from: $1.date) else {
                return false
            }
            return date1 < date2
        }
    }
    func prepareBarClubData() {
        // Filter and sort events
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        barList = events.filter { $0.type == "Bar" || $0.type == "Club"}.sorted {
            guard let date1 = dateFormatter.date(from: $0.date),
                  let date2 = dateFormatter.date(from: $1.date) else {
                return false
            }
            return date1 < date2
        }
    }
    func getEventsSortedByFriends() async -> [EventLoad] {
        var friendsDict = [Int: [String]]()
        for (index, item) in events.enumerated() {
            let commonFriends = await self.checkFriendshipStatus(isGoing: item.isGoing)
            friendsDict[index] = commonFriends
        }
        
        let sortedKeys = friendsDict.keys.sorted {
            (friendsDict[$0]?.count ?? 0) > (friendsDict[$1]?.count ?? 0)
        }
        
        var topFriends: [EventLoad] = []
        for item in sortedKeys {
            topFriends.append(events[item])
        }
        
        return topFriends
    }
    private func setupPullToRefresh() {
        // Set the target for the refresh control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        // Set the tint color of the refresh control to hot pink (RGB: 255, 22, 148)
        refreshControl.tintColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0)
        
        // Add the refresh control to the table view
        verticalCollectionView.addSubview(refreshControl)
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Add a delay of 5 milliseconds before refreshing the page
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Replace the below lines with your actual refresh logic
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let AppHomeVC = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            AppHomeVC.overrideUserInterfaceStyle = .dark
            AppHomeVC.modalPresentationStyle = .fullScreen
            self.present(AppHomeVC, animated: false, completion: nil)
            
            // End the refreshing animation
            self.refreshControl.endRefreshing()
        }
    }
    func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Replace the below lines with your actual refresh logic
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let AppHomeVC = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            AppHomeVC.overrideUserInterfaceStyle = .dark
            AppHomeVC.modalPresentationStyle = .fullScreen
            self.present(AppHomeVC, animated: false, completion: nil)
            
            // End the refreshing animation
            self.refreshControl.endRefreshing()
        }
    }
        func checkFriendshipStatus(isGoing: [String]) async -> [String] {
            guard let currentUserUID = Auth.auth().currentUser?.uid else {
                print("Error: No user is currently signed in.")
                return []
            }
            
            let userRef = Firestore.firestore().collection("users").document(currentUserUID)
            
            do {
                let document = try await userRef.getDocument()
                if document.exists {
                    guard let friendList = document.data()?["friends"] as? [String] else {
                        print("Error: No friends list found.")
                        return []
                    }
                    
                    let commonFriends = friendList.filter { isGoing.contains($0) }
                    print(commonFriends)
                    //returns a list of common friends uid
                    return commonFriends
                } else {
                    print("Error: Current user document does not exist.")
                    return []
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                return []
            }
            
            
        }
        
        
        
        
        
    
}

