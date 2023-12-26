import UIKit
import Firebase
import FirebaseAuth

class anonymousChatViewController: UIViewController {

    @IBOutlet weak var textTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var backButtton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = currCity + " Chat"
        configureTableView()
        observeMessages()
        addKeyboardObservers()
        addSwipeGesture()
    }
    
    deinit {
        removeKeyboardObservers()
    }

    func configureTableView() {
        textTableView.delegate = self
        textTableView.dataSource = self
        textTableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        
        // Set the automatic dimension for row height
        textTableView.rowHeight = UITableView.automaticDimension
        textTableView.estimatedRowHeight = 44  // You can adjust this value based on your content
    }

    func observeMessages() {
        let databaseRef = Database.database().reference().child("\(currCity)Chat")
        
        databaseRef.observe(.childAdded) { snapshot in
            guard let messageData = snapshot.childSnapshot(forPath: "message").value as? String,
                  let creatorID = snapshot.childSnapshot(forPath: "creator").value as? String else {
                return
            }
            
            let message = Message(creatorID: creatorID, text: messageData)
            self.messages.append(message)
            
            DispatchQueue.main.async {
                self.textTableView.reloadData()
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.textTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    @IBAction func sendMessage(_ sender: UIButton) {
        guard let text = messageTextField.text, !text.isEmpty else {
            return
        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = dateFormatter.string(from: currentDate)

        let databaseRef = Database.database().reference().child("\(currCity)Chat").child(dateString)
        let message = ["message": text, "creator": Auth.auth().currentUser?.uid]

        databaseRef.setValue(message)
        messageTextField.text = ""
    }

    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -keyboardFrame.height
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }

    func addSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension anonymousChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]

        cell.configure(with: message)
        
        return cell
    }

}

struct Message {
    let creatorID: String
    let text: String
}
