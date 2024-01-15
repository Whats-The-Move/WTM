import UIKit
import FirebaseAuth
import Firebase

class repliesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mainMessage: chatMessage?
    var replies: [chatMessage] = []
    let tableView = UITableView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura", size: 24)
        label.textColor = .black
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-Dem", size: 18)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura-Dem", size: 14)
        label.textColor = .gray
        return label
    }()

    private let thumbsUpButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        button.tintColor = .black
        return button
    }()

    private let thumbsDownButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        button.tintColor = .black
        return button
    }()

    private let likesCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura", size: 16)
        label.textColor = .black
        return label
    }()

    private let dislikesCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura", size: 16)
        label.textColor = .black
        return label
    }()

    private let horizontalLine: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let replyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Post a reply"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont(name: "Futura", size: 14)
        button.setTitleColor(UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0), for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBottomView()
        setupTableView()
        tableView.register(replyCell.self, forCellReuseIdentifier: "CellIdentifier")
        fetchReplies()
        
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func fetchReplies() {
        guard let mainMessage = mainMessage else { return }

        let chatID = mainMessage.chatID
        let repliesRef = Database.database().reference().child("\(currCity)Chat").child(chatID).child("replies")

        repliesRef.observe(.value) { snapshot  in
            self.replies.removeAll()

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let replyData = childSnapshot.value as? [String: Any] {

                    // Use the chatID as the key for replies
                    if let message = replyData["message"] as? String,
                       let likes = replyData["likes"] as? [String],
                       let dislikes = replyData["dislikes"] as? [String],
                       let time = replyData["time"] as? Int {
                                                                        
                        let picture = ""
                        let tag = ""
                        
                        let reply = chatMessage(chatID: childSnapshot.key, message: message, tag: tag, likes: likes, dislikes: dislikes, time: time, picture: picture)
                        self.replies.append(reply)
                    }
                }
            }
            self.replies.sort { $0.time < $1.time }
            self.tableView.reloadData()
        }
    }

    private func setupUI() {
        view.backgroundColor = .white

        titleLabel.text = mainMessage?.tag
        messageLabel.text = mainMessage?.message
        if let timestamp = mainMessage?.time {
            timeLabel.text = timeAgoString(from: timestamp)
        }

        setupThumbsButtons()

        // Add subviews
        [titleLabel, messageLabel, timeLabel, thumbsUpButton, likesCountLabel, thumbsDownButton, dislikesCountLabel, horizontalLine, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)

        // Set up constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            cancelButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            timeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            thumbsUpButton.topAnchor.constraint(equalTo: timeLabel.topAnchor),
            thumbsUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),

            likesCountLabel.centerYAnchor.constraint(equalTo: thumbsUpButton.centerYAnchor),
            likesCountLabel.leadingAnchor.constraint(equalTo: thumbsUpButton.trailingAnchor, constant: 5),

            thumbsDownButton.topAnchor.constraint(equalTo: thumbsUpButton.topAnchor),
            thumbsDownButton.leadingAnchor.constraint(equalTo: likesCountLabel.trailingAnchor, constant: 10),

            dislikesCountLabel.centerYAnchor.constraint(equalTo: thumbsDownButton.centerYAnchor),
            dislikesCountLabel.leadingAnchor.constraint(equalTo: thumbsDownButton.trailingAnchor, constant: 5),

            horizontalLine.topAnchor.constraint(equalTo: dislikesCountLabel.bottomAnchor, constant: 20),
            horizontalLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            horizontalLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            horizontalLine.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
        ])

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
    }
    
    @objc func cancelButtonTapped(){
        dismiss(animated: true)
    }
    
    private var bottomViewBottomConstraint: NSLayoutConstraint!
    
    private func setupBottomView() {
        view.addSubview(bottomView)
        bottomView.addSubview(replyTextField)
        bottomView.addSubview(sendButton)
        sendButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        bottomViewBottomConstraint = bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomViewBottomConstraint.isActive = true

        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 110),

            replyTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -16),
            replyTextField.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            replyTextField.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),

            sendButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            sendButton.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardHeight = keyboardFrame.cgRectValue.height
        updateBottomViewConstraints(with: keyboardHeight, show: true)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        updateBottomViewConstraints(with: 0, show: false)
    }

    private func updateBottomViewConstraints(with height: CGFloat, show: Bool) {
        // Update the bottom constraint based on keyboard height
        bottomViewBottomConstraint.constant = show ? -height : 0

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    
    @objc func submitButtonTapped() {
        guard let message = replyTextField.text, let mainMessage = mainMessage else {
            return
        }

        let chatID = mainMessage.chatID
        let chatRef = Database.database().reference().child("\(currCity)Chat").child(chatID)

        // Check if "replies" child exists in Firebase Realtime Database
        chatRef.child("replies").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                // "replies" child exists, proceed to add a new reply
                self.addReplyToFirebase(chatRef: chatRef, message: message)
            } else {
                // "replies" child doesn't exist, create it and then add a new reply
                chatRef.child("replies").setValue(true) { (error, _) in
                    if let error = error {
                        print("Error creating 'replies' child: \(error)")
                    } else {
                        // "replies" child created successfully
                        self.addReplyToFirebase(chatRef: chatRef, message: message)
                    }
                }
            }
        }
        
        replyTextField.text = ""
        dismissKeyboard()
    }

    private func addReplyToFirebase(chatRef: DatabaseReference, message: String) {
        let replyID = UUID().uuidString
        let replyRef = chatRef.child("replies").child(replyID)
        let currentTime = getCurrentDateTime()

        // Set up reply message data
        let replyMessageData: [String: Any] = [
            "message": message,
            "likes": ["a"],
            "dislikes": ["a"],
            "time": currentTime
        ]

        // Save the reply message data to the database
        replyRef.setValue(replyMessageData)
    }
    
    private func getCurrentDateTime() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let currentDateTime = Int(dateFormatter.string(from: Date()))
        return currentDateTime ?? 0
    }

    private func setupThumbsButtons() {
        thumbsUpButton.addTarget(self, action: #selector(thumbsUpButtonTapped), for: .touchUpInside)
        thumbsDownButton.addTarget(self, action: #selector(thumbsDownButtonTapped), for: .touchUpInside)
        
        likesCountLabel.text = "\(mainMessage!.likes.count - 1)"
        likesCountLabel.textColor = .gray
        dislikesCountLabel.text = "\(mainMessage!.dislikes.count - 1)"
        dislikesCountLabel.textColor = .gray

        updateLikeDislikeButtons() // Update buttons based on initial state
    }

    @objc private func thumbsUpButtonTapped() {
        guard let mainMessage = mainMessage, let currentUID = Auth.auth().currentUser?.uid else {
            return
        }

        if mainMessage.likes.contains(currentUID) {
            // Remove UID from likes array
            mainMessage.likes.removeAll { $0 == currentUID }
        } else {
            // Remove UID from dislikes array if present
            mainMessage.dislikes.removeAll { $0 == currentUID }
            // Add UID to likes array
            mainMessage.likes.append(currentUID)
        }

        updateLikeDislikeButtons()
        updateLikesDislikesInDatabase(message: mainMessage)
    }

    @objc private func thumbsDownButtonTapped() {
        guard let mainMessage = mainMessage, let currentUID = Auth.auth().currentUser?.uid else {
            return
        }

        if mainMessage.dislikes.contains(currentUID) {
            // Remove UID from dislikes array
            mainMessage.dislikes.removeAll { $0 == currentUID }
        } else {
            // Remove UID from likes array if present
            mainMessage.likes.removeAll { $0 == currentUID }
            // Add UID to dislikes array
            mainMessage.dislikes.append(currentUID)
        }

        updateLikeDislikeButtons()
        updateLikesDislikesInDatabase(message: mainMessage)
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

    private func updateLikeDislikeButtons() {
        guard let mainMessage = mainMessage, let currentUID = Auth.auth().currentUser?.uid else {
            return
        }

        // Update thumbs up button
        if mainMessage.likes.contains(currentUID) {
            thumbsUpButton.tintColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
        } else {
            thumbsUpButton.tintColor = .black
        }

        // Update thumbs down button
        if mainMessage.dislikes.contains(currentUID) {
            thumbsDownButton.tintColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
        } else {
            thumbsDownButton.tintColor = .black
        }

        // Update likes and dislikes count labels
        likesCountLabel.text = "\(mainMessage.likes.count - 1)"
        dislikesCountLabel.text = "\(mainMessage.dislikes.count - 1)"
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as! replyCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        // Configure the cell with your data
        let replyMessage = replies[indexPath.row]
        cell.replyMessage = replyMessage
        cell.parentChatID = mainMessage?.chatID
        cell.configure(with: replyMessage)

        return cell
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
