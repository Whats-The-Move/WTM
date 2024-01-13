import UIKit
import Firebase

class messagingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let stackView = UIStackView()
    private let newButton = UIButton()
    private let hotButton = UIButton()
    private let topButton = UIButton()
    private var messages: [chatMessage] = []
    private var messagesTwo: [chatMessage] = []
    let addButton = UIButton(type: .system)
    let noMessagesLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleLabel()
        setupTableView()
        setupStackView()
        
        noMessagesLabel.text = "No messages available"
        noMessagesLabel.font = UIFont(name: "Futura", size: 18)
        noMessagesLabel.textColor = UIColor.gray
        noMessagesLabel.textAlignment = .center
        noMessagesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noMessagesLabel)
        
        NSLayoutConstraint.activate([
            noMessagesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noMessagesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        view.backgroundColor = .black
        setupAddButton()

        // Reference to the "currCityChat" branch in the Firebase Realtime Database
        let chatRef = Database.database().reference().child("\(currCity)Chat")

        // Use .childAdded initially
        chatRef.observe(.childAdded) { snapshot, _ in
            let chatID = snapshot.key
            let messageRef = chatRef.child(chatID)

            messageRef.observeSingleEvent(of: .value) { messageSnapshot in
                if
                    let messageData = messageSnapshot.value as? [String: Any],
                    let message = messageData["message"] as? String,
                    let tag = messageData["tag"] as? String,
                    let likes = messageData["likes"] as? [String],
                    let dislikes = messageData["dislikes"] as? [String],
                    let time = messageData["time"] as? Int
                {
                    let newMessage = chatMessage(chatID: chatID, message: message, tag: tag, likes: likes, dislikes: dislikes, time: time)
                    self.messages.append(newMessage)

                    // Sort messages based on time before reloading the table view
                    self.messages.sort { $0.time > $1.time }
                    self.messagesTwo = self.messages
                    self.noMessagesLabel.isHidden = !self.messages.isEmpty
                    self.tableView.reloadData()
                }
            }
        }

        // Switch to .childChanged for subsequent updates
        chatRef.observe(.childChanged) { snapshot, _ in
            let chatID = snapshot.key
            let messageRef = chatRef.child(chatID)

            messageRef.observeSingleEvent(of: .value) { messageSnapshot in
                if
                    let messageData = messageSnapshot.value as? [String: Any],
                    let message = messageData["message"] as? String,
                    let tag = messageData["tag"] as? String,
                    let likes = messageData["likes"] as? [String],
                    let dislikes = messageData["dislikes"] as? [String],
                    let time = messageData["time"] as? Int
                {
                    // Check if the message already exists in the array
                    if let existingMessage = self.messages.first(where: { $0.chatID == chatID }) {
                        // Update the existing message
                        existingMessage.message = message
                        existingMessage.tag = tag
                        existingMessage.likes = likes
                        existingMessage.dislikes = dislikes
                        existingMessage.time = time
                    } else {
                        // Add the new message to the array
                        let newMessage = chatMessage(chatID: chatID, message: message, tag: tag, likes: likes, dislikes: dislikes, time: time)
                        self.messages.append(newMessage)
                    }

                    // Sort messages based on time before reloading the table view
                    self.messages.sort { $0.time > $1.time }
                    self.messagesTwo = self.messages
                    self.tableView.reloadData()
                }
            }
        }
        sortButtonTapped(newButton)
    }
    
    func setupAddButton() {
        // Create and configure the large system image button
        addButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addButton.tintColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        // Add the button to the view
        view.addSubview(addButton)

        // Set up constraints to position the button at the top right
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 44), // Adjust the size as needed
            addButton.heightAnchor.constraint(equalToConstant: 44),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }
    
    @objc func addButtonTapped() {
        // Instantiate and present the addMessageViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addMessageVC = storyboard.instantiateViewController(withIdentifier: "addMessageVC") as? addMessageViewController {
            present(addMessageVC, animated: true, completion: nil)
        }
    }
    
    func setupStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10.0

        newButton.setTitle("New", for: .normal)
        hotButton.setTitle("Hot", for: .normal)
        topButton.setTitle("Top", for: .normal)

        [newButton, hotButton, topButton].forEach {
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = .clear
            $0.titleLabel?.font = UIFont(name: "Futura", size: 16) // Replace with your desired font
            $0.addTarget(self, action: #selector(sortButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview($0)
        }

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        stackView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -5).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        // Set default styles for selected and unselected states
        let selectedAttributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]
        let normalAttributes: [NSAttributedString.Key: Any] = [:]

        newButton.setAttributedTitle(NSAttributedString(string: "New", attributes: selectedAttributes), for: .selected)
        newButton.setAttributedTitle(NSAttributedString(string: "New", attributes: normalAttributes), for: .normal)
        hotButton.setAttributedTitle(NSAttributedString(string: "Hot", attributes: normalAttributes), for: .normal)
        hotButton.setAttributedTitle(NSAttributedString(string: "Hot", attributes: selectedAttributes), for: .selected)
        topButton.setAttributedTitle(NSAttributedString(string: "Top", attributes: normalAttributes), for: .normal)
        topButton.setAttributedTitle(NSAttributedString(string: "Top", attributes: selectedAttributes), for: .selected)
    }
    
    @objc func sortButtonTapped(_ sender: UIButton) {
        // Unselect all buttons before selecting the tapped one
        [newButton, hotButton, topButton].forEach { $0.isSelected = false }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"

        switch sender {
        case newButton:
            // Sort messages based on time (chronological order)
            messages = messagesTwo
            messages.sort { $0.time > $1.time }
        case hotButton:
            messages = messagesTwo
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let currentTimeString = formatter.string(from: Date())
            let twentyFourHoursAgo = Int(currentTimeString)! - 2000000
            print(twentyFourHoursAgo)
            var last24HoursMessages = messages.filter { $0.time > Int(twentyFourHoursAgo) }
            // Sort by the sum of likes and dislikes
            last24HoursMessages.sort {
                ($0.likes.count + $0.dislikes.count) > ($1.likes.count + $1.dislikes.count)
            }

            messages = last24HoursMessages
        case topButton:
            // Sort by the sum of likes and dislikes
            messages = messagesTwo
            messages.sort {
                ($0.likes.count + $0.dislikes.count) > ($1.likes.count + $1.dislikes.count)
            }
        default:
            break
        }

        sender.isSelected = true // Set the selected state for the tapped button
        tableView.reloadData()
        noMessagesLabel.isHidden = !messages.isEmpty
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessageCell
        let message = messages[indexPath.section]
        cell.configure(with: message)

        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0 // Adjust this value for the vertical space between sections
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let spacingView = UIView()
        spacingView.backgroundColor = .clear
        return spacingView
    }

    // Other UITableViewDelegate and UITableViewDataSource methods as needed

    func setupTitleLabel() {
        titleLabel.text = currCity + " Chat"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Futura", size: 24)
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func setupTableView() {
        // Set up the table view
        tableView.backgroundColor = .black
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        //tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: "cell")
    }
}
