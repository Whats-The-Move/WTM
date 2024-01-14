import UIKit
import Firebase
import FirebaseAuth
import Kingfisher

protocol MessageCellDelegate: AnyObject {
    func repliesButtonTapped(inCell cell: MessageCell, withMessage message: chatMessage)
}

class MessageCell: UITableViewCell {

    // MARK: - Properties
    private var minHeightConstraint: NSLayoutConstraint!
    private var message: chatMessage?
    weak var delegate: MessageCellDelegate?
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-Medium", size: 18)
        label.textColor = .black
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-Dem", size: 14)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-Dem", size: 10)
        label.textColor = .gray
        return label
    }()

    private let likeButton: UIButton = {
        let button = UIButton()
        //button.setTitle("👍", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        return button
    }()

    private let dislikeButton: UIButton = {
        let button = UIButton()
        //button.setTitle("👎", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
    
    private let repliesButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
    
    private let pictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupButtons()
        setupImageView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with message: chatMessage) {
        tagLabel.text = message.tag
        messageLabel.text = message.message
        timeLabel.text = timeAgoString(from: message.time)
        likeButton.setTitle("👍\(message.likes.count - 1)", for: .normal)
        dislikeButton.setTitle("👎\(message.dislikes.count - 1)", for: .normal)
        likeButton.backgroundColor = .clear
        dislikeButton.backgroundColor = .clear
        likeButton.setTitleColor(.gray, for: .normal)
        dislikeButton.setTitleColor(.gray, for: .normal)
        self.message = message
        
        if message.likes.contains(Auth.auth().currentUser!.uid) {
            likeButton.layer.cornerRadius = 4
            likeButton.backgroundColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
            likeButton.setTitleColor(.white, for: .normal)
        } else if message.dislikes.contains(Auth.auth().currentUser!.uid) {
            dislikeButton.layer.cornerRadius = 4
            dislikeButton.backgroundColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
            dislikeButton.setTitleColor(.white, for: .normal)
        }

        // Reference to the "replies" branch under the message.chatID in the Firebase Realtime Database
        let repliesRef = Database.database().reference().child("\(currCity)Chat").child(message.chatID).child("replies")

        // Observe for changes in the replies branch
        repliesRef.observeSingleEvent(of: .value) { snapshot in
            if let repliesCount = snapshot.children.allObjects as? [DataSnapshot] {
                // Update the repliesButton title with the number of replies
                self.repliesButton.setTitle("💬\(repliesCount.count)", for: .normal)
            }
        }
        
        if message.picture != "" {
            self.pictureImageView.isHidden = false
            let url = URL(string: message.picture)
            self.pictureImageView.kf.setImage(with: url)
        } else {
            self.pictureImageView.isHidden = true
        }

        backgroundColor = .black
    }
    // MARK: - Private Methods
    
    @objc private func likeButtonTapped() {
        guard let message = self.message, let currentUID = Auth.auth().currentUser?.uid else {
            return
        }

        // If the dislike button was already tapped, reset it
        if message.dislikes.contains(currentUID) {
            message.dislikes.removeAll { $0 == currentUID }
            dislikeButton.backgroundColor = .clear
            //dislikeButton.layer.cornerRadius = 0
            dislikeButton.setTitle("👎\(message.dislikes.count - 1)", for: .normal)
            dislikeButton.setTitleColor(.gray, for: .normal)
        }

        if message.likes.contains(currentUID) {
            // Remove UID from likes array
            message.likes.removeAll { $0 == currentUID }
            likeButton.backgroundColor = .clear
            //likeButton.layer.cornerRadius = 0
            likeButton.setTitle("👍\(message.likes.count - 1)", for: .normal)
            likeButton.setTitleColor(.gray, for: .normal)
        } else {
            // Add UID to likes array
            message.likes.append(currentUID)
            likeButton.backgroundColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
            likeButton.layer.cornerRadius = 4
            likeButton.setTitle("👍\(message.likes.count + 1)", for: .normal)
            likeButton.setTitleColor(.white, for: .normal)
        }

        // Update likes array in the database
        DispatchQueue.main.async {
            self.updateLikesDislikesInDatabase(message: message)
        }

    }

    @objc private func dislikeButtonTapped() {
        guard let message = self.message, let currentUID = Auth.auth().currentUser?.uid else {
            return
        }

        // If the like button was already tapped, reset it
        if message.likes.contains(currentUID) {
            message.likes.removeAll { $0 == currentUID }
            likeButton.backgroundColor = .clear
            //likeButton.layer.cornerRadius = 0
            likeButton.setTitle("👍\(message.likes.count - 1)", for: .normal)
            likeButton.setTitleColor(.gray, for: .normal)
         }

        if message.dislikes.contains(currentUID) {
            // Remove UID from dislikes array
            message.dislikes.removeAll { $0 == currentUID }
            dislikeButton.backgroundColor = .clear
            //dislikeButton.layer.cornerRadius = 0
            dislikeButton.setTitle("👎\(message.dislikes.count - 1)", for: .normal)
            dislikeButton.setTitleColor(.gray, for: .normal)
        } else {
            // Add UID to dislikes array
            message.dislikes.append(currentUID)
            dislikeButton.backgroundColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
            dislikeButton.layer.cornerRadius = 4
            dislikeButton.setTitle("👎\(message.dislikes.count + 1)", for: .normal)
            dislikeButton.setTitleColor(.white, for: .normal)
        }

        // Update dislikes array in the database
        DispatchQueue.main.async {
            self.updateLikesDislikesInDatabase(message: message)
        }
    }
    
    @objc private func repliesButtonTapped() {
        print("replies tapped")
        if let message = message {
            delegate?.repliesButtonTapped(inCell: self, withMessage: message)
        }
    }

    private func updateLikesDislikesInDatabase(message: chatMessage) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }

        let chatID = message.chatID
        let chatRef = Database.database().reference().child("\(currCity)Chat").child(chatID)

        // Update the likes and dislikes arrays in the database
        chatRef.updateChildValues(["likes": message.likes, "dislikes": message.dislikes])
    }

    private func updateLikeDislikeCounts() {
        guard let message = self.message else { return }

        likeButton.setTitle("👍\(message.likes.count - 1)", for: .normal)
        dislikeButton.setTitle("👎\(message.dislikes.count - 1)", for: .normal)
    }


    private func setupUI() {
        contentView.addSubview(tagLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(dislikeButton)
        contentView.addSubview(repliesButton)
        contentView.backgroundColor = .white

        // Additional constraints for spacing and rounded corners
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        tagLabel.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: 4).isActive = true

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        messageLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 4).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        //timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
                
        minHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 125)
        minHeightConstraint.priority = .required
        minHeightConstraint.isActive = true
        messageLabel.addObserver(self, forKeyPath: "contentSize", options: [.new], context: nil)
    }
    
    private func setupImageView() {
        contentView.addSubview(pictureImageView)

        pictureImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        pictureImageView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8).isActive = true
        pictureImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        pictureImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        //pictureImageView.bottomAnchor.constraint(equalTo: repliesButton.topAnchor, constant: 8).isActive = true
        
        // Constrain picture height to 200 if there is an image
        let pictureHeightConstraint = pictureImageView.heightAnchor.constraint(equalToConstant: 200)
        pictureHeightConstraint.priority = .required
        pictureHeightConstraint.isActive = true

        let aspectRatioConstraint = NSLayoutConstraint(item: pictureImageView,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: pictureImageView,
                                                       attribute: .width,
                                                       multiplier: 9.0/16.0,
                                                       constant: 0)
        aspectRatioConstraint.priority = .required
        aspectRatioConstraint.isActive = true

        pictureImageView.contentMode = .scaleAspectFit
        pictureImageView.layer.cornerRadius = 8
        pictureImageView.clipsToBounds = true
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize", let newSize = change?[.newKey] as? CGSize {
            var heightIncrease = newSize.height - messageLabel.bounds.height + 25

            if !message!.picture.isEmpty {
                heightIncrease += 200.0 + 10.0
            }

            // Update the cell height
            self.minHeightConstraint.constant = max(125.0, self.minHeightConstraint.constant + heightIncrease)
        }
    }

    // Remove observer when the cell is deallocated
    deinit {
        messageLabel.removeObserver(self, forKeyPath: "contentSize")
    }

    private func setupButtons() {
        contentView.addSubview(likeButton)
        contentView.addSubview(dislikeButton)
        contentView.addSubview(repliesButton)
        
        dislikeButton.translatesAutoresizingMaskIntoConstraints = false
        dislikeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32).isActive = true
        dislikeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        dislikeButton.addTarget(self, action: #selector(dislikeButtonTapped), for: .touchUpInside)
        dislikeButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5).isActive = true

        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.trailingAnchor.constraint(equalTo: dislikeButton.leadingAnchor, constant: -16).isActive = true
        likeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        likeButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5).isActive = true
        
        repliesButton.translatesAutoresizingMaskIntoConstraints = false
        repliesButton.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -32).isActive = true
        repliesButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        repliesButton.addTarget(self, action: #selector(repliesButtonTapped), for: .touchUpInside)
        repliesButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5).isActive = true
    }

    private func timeAgoString(from timestamp: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        
        if let date = dateFormatter.date(from: String(timestamp)) {
            let components = Calendar.current.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: date, to: Date())

            if let year = components.year, year > 0 {
                return "\(year) " + (year > 1 ? "yrs ago" : "yr ago")
            } else if let month = components.month, month > 0 {
                return "\(month) " + (month > 1 ? "months ago" : "month ago")
            } else if let week = components.weekOfYear, week > 0 {
                return "\(week) " + (week > 1 ? "wks ago" : "wk ago")
            } else if let day = components.day, day > 0 {
                return "\(day) " + (day > 1 ? "days ago" : "day ago")
            } else if let hour = components.hour, hour > 0 {
                return "\(hour) " + (hour > 1 ? "hrs ago" : "hr ago")
            } else if let minute = components.minute, minute >= 0 {
                return "\(minute) " + (minute > 1 ? "mins ago" : "min ago")
            } else {
                return "Just now"
            }
        } else {
            return "Invalid Timestamp"
        }
    }
}
