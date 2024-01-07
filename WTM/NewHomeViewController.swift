import UIKit
import FirebaseDatabase

class NewHomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    var verticalCollectionView: UICollectionView!
    let filters = ["Trending", "Friend's Choice", "Your Favorites", "Best Deals"]
    var events: [EventLoad] = []
    let searchBar = UISearchBar()
    let dropdownButton = UIButton(type: .system)
    let dates = ["This Week", "Tomorrow", "Today"]
    let optionsStackView = UIStackView()
    let titleLabel = UILabel()





 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupSearchBar()
        setupDropdownButton()
        setupOptionsStackView()
        setupTitleLabel()
        let datelist = getDatesBasedOnCurrentOption()
        loadData(queryFrom: currCity + "Events", dateStrings: datelist) { [weak self] loadedEvents in

            self?.events = loadedEvents
            print(self?.events[0].creator)
            self?.setupVerticalCollectionView()


        }

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let path = UIBezierPath(roundedRect: dropdownButton.bounds,
                                byRoundingCorners: [.topRight, .bottomRight],
                                cornerRadii: CGSize(width: 15, height: 15))

        // Create a shape layer and apply it as the mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        dropdownButton.layer.mask = maskLayer

        // Create an additional layer for the border
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskLayer.path // Reuse the same path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth = 1
        borderLayer.frame = dropdownButton.bounds

        // Add the border layer to the button
        dropdownButton.layer.addSublayer(borderLayer)
    }
    func setupTitleLabel() {
        view.addSubview(titleLabel)

        titleLabel.text = "CalEvents"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center


        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: searchBar.topAnchor, constant: -15)
        ])
    }
    
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
    }
    func setupDropdownButton() {
        view.addSubview(dropdownButton)
        dropdownButton.setTitle("This week", for: .normal)
        let originalImage = UIImage(systemName: "chevron.down")! // Replace with your down arrow image
        let resizedImage = resizeImage(image: originalImage, targetSize: CGSize(width: 15, height: 15)) // Adjust target size as needed
        
        dropdownButton.setImage(resizedImage, for: .normal) // Replace with your down arrow image
        dropdownButton.tintColor = .white
        dropdownButton.setTitleColor(.white, for: .normal)
        dropdownButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        dropdownButton.addTarget(self, action: #selector(dropdownTapped), for: .touchUpInside)
        /*
        let path = UIBezierPath(roundedRect: dropdownButton.bounds,
                                byRoundingCorners: [.topRight, .bottomRight],
                                cornerRadii: CGSize(width: 15, height: 15))

        // Create a shape layer and apply it as the mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        dropdownButton.layer.mask = maskLayer

        // Create an additional layer for the border
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskLayer.path // Reuse the same path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth = 1
        borderLayer.frame = dropdownButton.bounds

        // Add the border layer to the button
        dropdownButton.layer.addSublayer(borderLayer)*/
        

        // Layout the button
        dropdownButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dropdownButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            dropdownButton.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            dropdownButton.widthAnchor.constraint(equalToConstant: 110),
            dropdownButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        // Adjust the position of the image and text
        dropdownButton.semanticContentAttribute = .forceRightToLeft
        dropdownButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0) // Adjust as needed
        dropdownButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: -2) // Adjust as needed
    }

    @objc func dropdownTapped() {
        optionsStackView.isHidden = !optionsStackView.isHidden
    }
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
            // Update button alphas

    }

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
                       let venueName = eventData["venueName"] as? String
                        {
                        let event = EventLoad(creator: creator, date: date, deals: deals, description: description, eventName: eventName, imageURL: imageURL, isGoing: isGoing, location: location, time: time, venueName: venueName)
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
            verticalCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
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
            
            let postImage = UIImage(named: "AppIcon") ?? UIImage()
            let otherimage = UIImage(named: "Fiji") ?? UIImage()
            let filterTitle = filters[indexPath.item]

            cell.configure(title: filterTitle, with: events)
            cell.contentView.backgroundColor = .clear
            return cell
        } else {
            // This is the main content section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerticalCell", for: indexPath) as! VerticalCollectionViewCell
            // Configure your cell here
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear

            let filterTitle = filters[indexPath.item]
            cell.configure(title: filterTitle, with: events)
            return cell
        }
    }


    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Adjust cell size
        if indexPath.item == 0 {
            return CGSize(width: view.frame.width, height: 350) // Example size
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
            dates.append(dateFormatter.string(from: today))
        } else if currentOption == "Tomorrow" {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            dates.append(dateFormatter.string(from: tomorrow))
        } else if currentOption == "This Week" {
            let today = Date()
            let calendar = Calendar.current
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!

            for i in 0..<7 {
                if let weekDay = calendar.date(byAdding: .day, value: i, to: weekStart) {
                    dates.append(dateFormatter.string(from: weekDay))
                }
            }
        }

        return dates
    }
}
func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size

    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height

    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }

    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage ?? image
}

