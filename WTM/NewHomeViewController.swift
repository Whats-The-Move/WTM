import UIKit

class NewHomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var verticalCollectionView: UICollectionView!
    let filters = ["trending", "friend's choice", "your favorites", "best deals"]
    var events: [[EventLoad]]

    init(events: [[EventLoad]]) {
        self.events = events
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVerticalCollectionView()
        setupGradientBackground()
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
        gradientLayer.colors = [ UIColor.white.cgColor, pink]
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

            cell.configure(title: filterTitle, with: events[indexPath.item])
            cell.contentView.backgroundColor = .clear
            return cell
        } else {
            // This is the main content section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VerticalCell", for: indexPath) as! VerticalCollectionViewCell
            // Configure your cell here
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear

            let filterTitle = filters[indexPath.item]
            cell.configure(title: filterTitle, with: events[indexPath.item])
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
