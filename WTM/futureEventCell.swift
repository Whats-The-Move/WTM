import UIKit
import Kingfisher
import FirebaseFirestore

class futureEventCell: UITableViewCell {
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16) // Bold font for event name
        return label
    }()
    
    let creatorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura", size: 14) // Futura font for creator
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura", size: 14) // Futura font for time
        return label
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func fetchUserData(for uid: String, completion: @escaping (String?, String?) -> Void) {
        let usersRef = Firestore.firestore().collection("barUsers").document(uid)

        usersRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let venueName = data?["venueName"] as? String
                let profilePic = data?["profilePic"] as? String

                completion(venueName, profilePic)
            } else {
                completion(nil, nil)
            }
        }
    }

    private func setupViews() {
        // Add image view to the cell's content view
        contentView.addSubview(profileImageView)

        // Add labels to the cell's content view
        contentView.addSubview(nameLabel)
        contentView.addSubview(creatorLabel)
        contentView.addSubview(timeLabel)

        // Layout constraints for the image view
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 76), // Adjust the width as needed
            profileImageView.heightAnchor.constraint(equalToConstant: 76), // Adjust the height as needed
        ])
        
        // Apply corner radius to image view
        profileImageView.layer.cornerRadius = 8
        profileImageView.layer.masksToBounds = true

        // Layout constraints for the labels
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        creatorLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            creatorLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            creatorLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            creatorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            timeLabel.topAnchor.constraint(equalTo: creatorLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with event: EventNew) {
        if event.isDateCell {
            nameLabel.text = ""
            creatorLabel.text = ""
            timeLabel.text = ""
            profileImageView.image = nil
            backgroundColor = UIColor(red: 1, green: 0.0862745098, blue: 0.5803921569, alpha: 1)
            nameLabel.textColor = .white
            creatorLabel.textColor = .white
            timeLabel.textColor = .white
            contentView.layer.cornerRadius = 8
            contentView.layer.masksToBounds = true
            textLabel?.text = DateFormatter.localizedString(from: event.date, dateStyle: .medium, timeStyle: .none)
        } else {
            fetchUserData(for: event.creator) { venueName, profilePic in
                DispatchQueue.main.async {
                    self.nameLabel.text = event.name
                    self.creatorLabel.text = venueName ?? ""
                    self.timeLabel.text = event.time
                    self.backgroundColor = .white
                    self.nameLabel.textColor = .black
                    self.creatorLabel.textColor = .black
                    self.timeLabel.textColor = .black
                    self.textLabel?.text = ""

                    // Load image using Kingfisher
                    if let profilePicURL = profilePic,
                       let url = URL(string: profilePicURL) {
                        self.loadImage(with: url)
                    }
                }
            }
        }
    }


    func loadImage(with url: URL) {
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"), // You can use a placeholder image
            options: [
                .processor(DownsamplingImageProcessor(size: profileImageView.bounds.size)),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
    }
}
