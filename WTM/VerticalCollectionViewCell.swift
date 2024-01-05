import UIKit
import Kingfisher

class VerticalCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var titleLabel: UILabel!
    var horizontalCollectionView: UICollectionView!
    var events: [EventLoad] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        setupHorizontalCollectionView()
    }
    func configure(title: String, with events: [EventLoad]) {
        titleLabel.text = title
        self.events = events
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    private func setupHorizontalCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 150) // Adjust as needed

        horizontalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        horizontalCollectionView.backgroundColor = .clear
        horizontalCollectionView.dataSource = self
        horizontalCollectionView.delegate = self
        horizontalCollectionView.register(HorizontalCollectionViewCell.self, forCellWithReuseIdentifier: "HorizontalCell")

        horizontalCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(horizontalCollectionView)

        NSLayoutConstraint.activate([
            horizontalCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            horizontalCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            horizontalCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            horizontalCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // Implement UICollectionViewDataSource and UICollectionViewDelegateFlowLayout methods...
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items in each horizontal collection view
        return events.count // Example number
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalCell", for: indexPath) as! HorizontalCollectionViewCell
        // Configure your cell here
        //cell.backgroundColor = .lightGray // Example styling

        cell.configure(with: events[indexPath.item])
        return cell
    }

    // Add more delegate methods as needed...
}
class HorizontalCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var pplLabel: UILabel!
    var pplImage: UIImageView!



    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

    }
    func configure(with eventLoad: EventLoad) {
        // Load the image into imageView. Example:
        //imageView.image = UIImage(named: imageName)
        
        //change above to immageview.image = loadImage(event.imageURL)
        let event = eventLoad
        setupImageView(event: event)
        setupPplLabel(event: event)
        setupPplImage(event: event)
        setupCellAppearance()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView(event: EventLoad) {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        //imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        loadImage(from: event.imageURL, to: self.imageView)

        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 120) // Height of the image
        ])
    }
    private func setupPplLabel(event: EventLoad) {
        pplLabel = UILabel()
        //imageView.layer.cornerRadius = 10
        pplLabel.translatesAutoresizingMaskIntoConstraints = false
        pplLabel.text = String(event.isGoing.count)
        pplLabel.font = UIFont.boldSystemFont(ofSize: 16)
        pplLabel.textColor = .black
        contentView.addSubview(pplLabel)

        NSLayoutConstraint.activate([
            pplLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            pplLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            pplLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 10),
            pplLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    private func setupPplImage(event: EventLoad) {
        pplImage = UIImageView(image: UIImage(systemName: "person.3.fill"))
        pplImage.tintColor = UIColor(red: 255/255, green: 22/255, blue: 142/255, alpha: 1)
        pplImage.translatesAutoresizingMaskIntoConstraints = false
        pplImage.contentMode = .scaleAspectFit // Set contentMode to scaleAspectFit

        contentView.addSubview(pplImage)

        NSLayoutConstraint.activate([
            pplImage.centerYAnchor.constraint(equalTo: pplLabel.centerYAnchor),
            pplImage.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -5), // 5 points space between label and image
            pplImage.widthAnchor.constraint(equalToConstant: 30), // Adjust size as needed
            pplImage.heightAnchor.constraint(equalToConstant: 24)  // Adjust size as needed
        ])
    }

    func loadImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        imageView.kf.setImage(with: url)
    }

    private func setupCellAppearance() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: 150),
            contentView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
}
