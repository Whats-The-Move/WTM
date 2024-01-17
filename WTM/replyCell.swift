import UIKit
import FirebaseAuth
import Firebase

class replyCell: UITableViewCell {
    
    private var minHeightConstraint: NSLayoutConstraint!
    var replyMessage: chatMessage?
    var parentChatID: String?

    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-Dem", size: 16)
        label.numberOfLines = 0
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura", size: 12)
        label.textColor = .gray
        return label
    }()

    let thumbsUpButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        button.tintColor = .white
        return button
    }()

    let thumbsDownButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    func configure(with message: chatMessage) {
        replyMessage = message
        messageLabel.text = message.message
        timeLabel.text = timeAgoString(from: message.time)
    
        thumbsUpButton.setTitle(" \(replyMessage!.likes.count - 1)", for: .normal)
        thumbsDownButton.setTitle(" \(replyMessage!.dislikes.count - 1)", for: .normal)
        thumbsUpButton.setTitleColor(.white, for: .normal)
        thumbsDownButton.setTitleColor(.white, for: .normal)
        
        setupThumbsButtons()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupThumbsButtons() {
        guard let replyMessage = replyMessage else {
            print("didnt work")
            return
        }
        
        thumbsUpButton.addTarget(self, action: #selector(thumbsUpButtonTapped), for: .touchUpInside)
        thumbsDownButton.addTarget(self, action: #selector(thumbsDownButtonTapped), for: .touchUpInside)

        updateLikeDislikeButtons() // Update buttons based on initial state
    }
    
    private func updateLikeDislikeButtons() {
        guard let replyMessage = replyMessage, let currentUID = Auth.auth().currentUser?.uid else {
            return
        }

        // Update thumbs up button
        if replyMessage.likes.contains(currentUID) {
            thumbsUpButton.tintColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
        } else {
            thumbsUpButton.tintColor = .gray
        }

        // Update thumbs down button
        if replyMessage.dislikes.contains(currentUID) {
            thumbsDownButton.tintColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
        } else {
            thumbsDownButton.tintColor = .gray
        }

        // Update likes and dislikes count labels
        thumbsUpButton.setTitle(" \(replyMessage.likes.count - 1)", for: .normal)
        thumbsDownButton.setTitle(" \(replyMessage.dislikes.count - 1)", for: .normal)
    }
    
    @objc private func thumbsUpButtonTapped() {
        guard let replyMessage = replyMessage, let currentUID = Auth.auth().currentUser?.uid else {
            return
        }

        if replyMessage.likes.contains(currentUID) {
            // Remove UID from likes array
            replyMessage.likes.removeAll { $0 == currentUID }
        } else {
            // Remove UID from dislikes array if present
            replyMessage.dislikes.removeAll { $0 == currentUID }
            // Add UID to likes array
            replyMessage.likes.append(currentUID)
        }

        updateLikeDislikeButtons()
        updateLikesDislikesInDatabase(message: replyMessage)
    }

    @objc private func thumbsDownButtonTapped() {
        guard let replyMessage = replyMessage, let currentUID = Auth.auth().currentUser?.uid else {
            return
        }

        if replyMessage.dislikes.contains(currentUID) {
            // Remove UID from dislikes array
            replyMessage.dislikes.removeAll { $0 == currentUID }
        } else {
            // Remove UID from likes array if present
            replyMessage.likes.removeAll { $0 == currentUID }
            // Add UID to dislikes array
            replyMessage.dislikes.append(currentUID)
        }

        updateLikeDislikeButtons()
        updateLikesDislikesInDatabase(message: replyMessage)
    }
    
    private func updateLikesDislikesInDatabase(message: chatMessage) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }

        let chatID = message.chatID
        let chatRef = Database.database().reference().child("\(currCity)Chat").child(parentChatID!).child("replies").child(message.chatID)

        // Update the likes and dislikes arrays in the database
        chatRef.updateChildValues(["likes": message.likes, "dislikes": message.dislikes])
    }

    private func setupUI() {
        // Add subviews
        [messageLabel, timeLabel, thumbsUpButton, thumbsDownButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        minHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        minHeightConstraint.priority = .required
        minHeightConstraint.isActive = true
        messageLabel.addObserver(self, forKeyPath: "contentSize", options: [.new], context: nil)

        // Set up constraints
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            thumbsUpButton.topAnchor.constraint(equalTo: timeLabel.topAnchor),
            thumbsUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -80),

            thumbsDownButton.topAnchor.constraint(equalTo: thumbsUpButton.topAnchor),
            thumbsDownButton.leadingAnchor.constraint(equalTo: thumbsUpButton.trailingAnchor, constant: 10)
        ])
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize", let newSize = change?[.newKey] as? CGSize {
            let heightIncrease = newSize.height - messageLabel.bounds.height + 25

            // Update the cell height
            self.minHeightConstraint.constant = max(60, self.minHeightConstraint.constant + heightIncrease)
        }
    }
    
    deinit {
        messageLabel.removeObserver(self, forKeyPath: "contentSize")
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
