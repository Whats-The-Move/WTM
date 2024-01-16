import UIKit
import Kingfisher

class VerticalCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var titleLabel: UILabel!
    var horizontalCollectionView: UICollectionView!
    var events: [EventLoad] = []
    var nothingLabel: UILabel!
    weak var delegate: TopGalleryCollectionViewCellDelegate?


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        setupHorizontalCollectionView()
    }
    func configure(title: String, with events: [EventLoad]) {
        titleLabel.text = title
        self.events = events
        setupNothingLabel()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTitleLabel() {
        titleLabel = UILabel()
        //titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.font = UIFont(name: "Futura-Medium", size: 20)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    private func setupNothingLabel() {
        nothingLabel = UILabel()
        //titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nothingLabel.font = UIFont(name: "Futura-Medium", size: 20)

        nothingLabel.translatesAutoresizingMaskIntoConstraints = false
        nothingLabel.textColor = .lightGray
        nothingLabel.text = "Nothing right now"
        nothingLabel.textAlignment = .center
        contentView.bringSubviewToFront(nothingLabel)
        

        if events.count == 0 {
            nothingLabel.isHidden = false
        }
        else{
            nothingLabel.isHidden = true

        }
        contentView.addSubview(nothingLabel)

        NSLayoutConstraint.activate([
            nothingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 20),
            nothingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -15),
            nothingLabel.widthAnchor.constraint(equalToConstant: 300),
            nothingLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    private func setupHorizontalCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 150) // Adjust as needed

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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("event clicked")
        let selectedEventLoad = events[indexPath.item]
        delegate?.didSelectEventLoad(eventLoad: selectedEventLoad)
    }

    // Add more delegate methods as needed...
}
class HorizontalCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var pplLabel: UILabel!
    var pplImage: UIImageView!
    weak var delegate: TopGalleryCollectionViewCellDelegate?
    private var gradientLayer: CAGradientLayer?
    var cellDetailsLabel: UILabel! // Declare the new label





    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

    }

    func configure(with eventLoad: EventLoad) {
        // Load the image into imageView. Example:
        //imageView.image = UIImage(named: imageName)
        
        //change above to immageview.image = loadImage(event.imageURL)
        let event = eventLoad
        setupCellAppearance()

        setupImageView(event: event)
        setupGradientBackground() // Set up the gradient here

        setupPplLabel(event: event)
        setupPplImage(event: event)
        setupCellDetailsLabel(event: event)
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
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor) // Height of the image
        ])
    }
    private func setupGradientBackground() {
        gradientLayer?.removeFromSuperlayer() // Remove the old gradient layer if it exists

        let gradient = CAGradientLayer()
        gradient.frame = contentView.bounds
        let transparent = UIColor.black.withAlphaComponent(0.0).cgColor
        let black = UIColor.black.withAlphaComponent(1.0).cgColor

        gradient.colors = [transparent, black]
        gradient.locations = [0.8, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)

        imageView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient // Store the gradient layer
    }
    
    private func setupPplLabel(event: EventLoad) {
        pplLabel = UILabel()
        //imageView.layer.cornerRadius = 10
        pplLabel.translatesAutoresizingMaskIntoConstraints = false
        pplLabel.text = String(event.isGoing.count)
        pplLabel.font = UIFont(name: "Futura-Medium", size: 13)
        pplLabel.textColor = .white
        contentView.addSubview(pplLabel)

        NSLayoutConstraint.activate([
            pplLabel.heightAnchor.constraint(equalToConstant: 20),
            pplLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -4),
            pplLabel.widthAnchor.constraint(equalToConstant: 20),
            pplLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    private func setupPplImage(event: EventLoad) {
        pplImage = UIImageView(image: UIImage(systemName: "person.3.fill"))
        pplImage.tintColor = UIColor.white
        pplImage.translatesAutoresizingMaskIntoConstraints = false
        pplImage.contentMode = .scaleAspectFit // Set contentMode to scaleAspectFit

        contentView.addSubview(pplImage)

        NSLayoutConstraint.activate([
            pplImage.centerYAnchor.constraint(equalTo: pplLabel.centerYAnchor),
            pplImage.trailingAnchor.constraint(equalTo: pplLabel.leadingAnchor), // 5 points space between label and image
            pplImage.widthAnchor.constraint(equalToConstant: 22), // Adjust size as needed
            pplImage.heightAnchor.constraint(equalToConstant: 18)  // Adjust size as needed
        ])
    }
    private func setupCellDetailsLabel(event: EventLoad) {
        cellDetailsLabel = UILabel()
        cellDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        cellDetailsLabel.font = UIFont(name: "Futura-Medium", size: 14)
        cellDetailsLabel.adjustsFontSizeToFitWidth = true
        cellDetailsLabel.textColor = .white
        cellDetailsLabel.text = event.eventName // MADE JUST evnet NAME CUZ TOO SMALL OTHERWISE
        contentView.addSubview(cellDetailsLabel)

        NSLayoutConstraint.activate([
            cellDetailsLabel.centerYAnchor.constraint(equalTo: pplLabel.centerYAnchor), // Adjust constant for padding
            cellDetailsLabel.heightAnchor.constraint(equalTo: pplLabel.heightAnchor), // Adjust constant for padding
            cellDetailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5), // Set the height of the label
            cellDetailsLabel.trailingAnchor.constraint(equalTo: pplImage.leadingAnchor, constant: -5)
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
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        

        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: 150),
            contentView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
}
