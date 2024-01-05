import UIKit
import FirebaseDatabase

class NewHomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var verticalCollectionView: UICollectionView!
    let filters = ["trending", "friend's choice", "your favorites", "best deals"]
    var events: [EventLoad] = []


 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()

        loadData(queryFrom: "BerkeleyEvents", dateStrings: ["Jan 4, 2023", "Dec 31, 2024"]) { [weak self] loadedEvents in

            self?.events = loadedEvents
            self?.setupVerticalCollectionView()


        }

    }
    func loadData(queryFrom: String, dateStrings: [String], completion: @escaping ([EventLoad]) -> Void) {
        let ref = Database.database().reference(withPath: queryFrom)
        var events: [EventLoad] = []
        let group = DispatchGroup()

        for dateString in dateStrings {
            group.enter()
            ref.child(dateString).observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {
                    print("No data available")
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

                group.leave()
            }) { error in
                print(error.localizedDescription)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(events)
        }
    }


    private func setupVerticalCollectionView() {
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
        gradientLayer.colors = [ UIColor.black.cgColor, pink]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
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
            return CGSize(width: 300, height: 350) // Example size
        }
        else {
            return CGSize(width: view.frame.width, height: 200) // Example size
        }
    }
}
