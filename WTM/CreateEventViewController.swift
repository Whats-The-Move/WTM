//
//  CreateEventViewController.swift
//  WTM
//
//  Created by Aman Shah on 6/13/23.
//

import UIKit
import Firebase
import FirebaseAuth

class CreateEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let day = daysOfWeek[indexPath.row]
        cell.textLabel?.text = day
        cell.accessoryType = selectedDays.contains(day) ? .checkmark : .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let day = daysOfWeek[indexPath.row]
        if selectedDays.contains(day) {
            // Deselect the day
            selectedDays.removeAll { $0 == day }
        } else {
            // Select the day
            selectedDays.append(day)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var save: UIButton!
    
    @IBOutlet weak var eventTitle: UITextField!
    
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var dateAndTime: UIDatePicker!
    @IBOutlet weak var endTime: UIDatePicker!
    
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    
    var repeatTableView: UITableView!
        
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @IBOutlet weak var createButton: UIButton!
    var selectedUsers: [User] = []
    var selectedDays: [String] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupTableView()
        addHorizontalLine(belowView: eventTitle, spacing: 10.0)

        addHorizontalLine(belowView: repeatLabel, spacing: 10.0)
        
        addHorizontalLine(belowView: location, spacing: 10.0)
        addHorizontalLine(belowView: typePicker, spacing: 10.0)

        addHorizontalLine(belowView: endTime, spacing: 10.0)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        repeatLabel.isUserInteractionEnabled = true
        repeatLabel.addGestureRecognizer(tapGestureRecognizer)
        
        eventTitle.delegate = self
        location.delegate = self
        descriptionText.delegate = self
        //inviteesText.delegate = self
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeGesture.direction = .down
        swipeGesture.delegate = self
        descriptionText.addGestureRecognizer(swipeGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        descriptionText.resignFirstResponder()
    }
    @objc func labelTapped(){
        repeatTableView.isHidden = !repeatTableView.isHidden
        print(selectedDays.count)
        if selectedDays.count != 0 {
            let joinedDays = selectedDays.joined(separator: ", ")
            repeatLabel.text = "Every " + joinedDays
            if selectedDays.count == 7 {
                repeatLabel.text = "Every Day"
            }
        }

        else {
            repeatLabel.text = "Does not repeat"
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func setupTableView() {
        // Create and configure the tableView
        repeatTableView = UITableView()
        repeatTableView.delegate = self
        repeatTableView.dataSource = self
        repeatTableView.translatesAutoresizingMaskIntoConstraints = false

        // Register the default UITableViewCell class with the table view
        repeatTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        // Add the tableView to the view hierarchy
        view.addSubview(repeatTableView)

        // Set up constraints to center it in the view
        NSLayoutConstraint.activate([
            repeatTableView.centerXAnchor.constraint(equalTo: repeatLabel.centerXAnchor),
            repeatTableView.topAnchor.constraint(equalTo: repeatLabel.bottomAnchor),
            repeatTableView.widthAnchor.constraint(equalToConstant: 160),
            repeatTableView.heightAnchor.constraint(equalToConstant: 200)
        ])
        repeatTableView.isHidden = true
    }

    func addHorizontalLine(belowView viewAbove: UIView, spacing: CGFloat = 10.0) {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.white // Set the line color as needed
        lineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineView)

        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: viewAbove.bottomAnchor, constant: spacing),
            lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1.0) // 1px height
        ])
    }

    func setupConstraints() {
        // Cancel button constraints
        cancel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            cancel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancel.widthAnchor.constraint(equalToConstant: 100),
            cancel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Save button constraints
        save.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            save.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            save.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            save.widthAnchor.constraint(equalToConstant: 100),
            save.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Event title constraints
        eventTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            eventTitle.widthAnchor.constraint(equalToConstant: 200),
            eventTitle.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Location constraints
        location.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            location.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            location.topAnchor.constraint(equalTo: eventTitle.bottomAnchor, constant: 20),
            location.widthAnchor.constraint(equalToConstant: 300),
            location.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        typePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            typePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            typePicker.topAnchor.constraint(equalTo: location.bottomAnchor, constant: 20),
            typePicker.widthAnchor.constraint(equalToConstant: 300),
            typePicker.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Date and Time constraints
        dateAndTime.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateAndTime.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //dateAndTime.widthAnchor.constraint(equalToConstant: 229),
            dateAndTime.topAnchor.constraint(equalTo: typePicker.bottomAnchor, constant: 30),
            dateAndTime.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // End Time constraints
        endTime.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            endTime.leadingAnchor.constraint(equalTo: dateAndTime.leadingAnchor),
            endTime.trailingAnchor.constraint(equalTo: dateAndTime.trailingAnchor),
            endTime.topAnchor.constraint(equalTo: dateAndTime.bottomAnchor, constant: 20),
            endTime.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Repeat Label constraints
        repeatLabel.translatesAutoresizingMaskIntoConstraints = false
        repeatLabel.text = "Does not repeat"
        NSLayoutConstraint.activate([
            repeatLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            repeatLabel.topAnchor.constraint(equalTo: endTime.bottomAnchor, constant: 30),
            repeatLabel.widthAnchor.constraint(equalToConstant: 300),
            repeatLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Repeat Button constraints

        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionText.topAnchor.constraint(equalTo: repeatLabel.bottomAnchor, constant: 50),
            descriptionText.leadingAnchor.constraint(equalTo: repeatLabel.leadingAnchor),
            descriptionText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
            descriptionText.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // Restore the original position of the view
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        // Calculate the height of the keyboard
        let keyboardHeight = keyboardFrame.size.height

        // Check if the text field is hidden by the keyboard
        if eventTitle.isFirstResponder || location.isFirstResponder || descriptionText.isFirstResponder  {
            let maxY = max(eventTitle.frame.maxY, location.frame.maxY, descriptionText.frame.maxY)
            let visibleHeight = view.frame.height - keyboardHeight
            if maxY > visibleHeight {
                // Adjust the view's frame to move the text field above the keyboard
                let offsetY = maxY - visibleHeight + 10 // Add 10 for padding
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -offsetY)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        descriptionText.isEditable = true
        //descriptionText.text = "Description/details"
        descriptionText.textAlignment = .left
        descriptionText.font = UIFont.systemFont(ofSize: 16)
        descriptionText.layer.cornerRadius = 8
        dateAndTime.layer.cornerRadius = 8
        
        let pinkColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0)

        // Create a UITextField


        // Create an NSAttributedString with the custom pink color for the placeholder text
        let pinkPlaceholderText = NSAttributedString(string: "Event Title", attributes: [NSAttributedString.Key.foregroundColor: pinkColor])
        eventTitle.attributedPlaceholder = pinkPlaceholderText
        let pinkPlaceholderTextLocation = NSAttributedString(string: "address", attributes: [NSAttributedString.Key.foregroundColor: pinkColor])
        location.attributedPlaceholder = pinkPlaceholderTextLocation
        dateAndTime.setValue(UIColor.white, forKeyPath: "textColor")

        // Set the background color to gray
        dateAndTime.backgroundColor = pinkColor
        endTime.backgroundColor = pinkColor
        
        eventTitle.backgroundColor = .clear
        location.backgroundColor = .clear

    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
 

    @IBAction func createTapped(_ sender: Any) {
    guard let eventTitle = eventTitle.text,
              let location = location.text,
              let eventDescription = descriptionText.text
            else {
            return
            print("didn't fill it")
        }
        let dateTime = dateAndTime.date

        let currentUserUID = Auth.auth().currentUser?.uid ?? ""
        
        // Get the invitee UIDs as an array
        var inviteeUIDs = selectedUsers.map { $0.uid }
        inviteeUIDs.append(currentUserUID)
        
        // Create a reference to the "Privates" node in Firebase Realtime Database
        let privatesRef = Database.database().reference().child("Events1")
        
        // Create a new child node under "Privates" and generate a unique key
        let newEventRef = privatesRef.childByAutoId()
        
        // Create a dictionary with the event information
        let eventInfo: [String: Any] = [
            "event": eventTitle,
            "dateTime": dateTime.timeIntervalSince1970,
            "location": location,
            "description": eventDescription,
            "invitees": inviteeUIDs,
            "isGoing": [currentUserUID],
            "creator": currentUserUID
        ]
        
        // Set the event information under the new child node
        newEventRef.setValue(eventInfo) { error, _ in
            if let error = error {
                print("Error creating event: \(error.localizedDescription)")
            } else {
                print("Event created successfully!")
                // TODO: Perform any additional actions after event creation
            }
        }
        
        self.eventTitle.text = ""
        self.location.text = ""
        descriptionText.text = ""
        
        
        // Display a message
        let alertController = UIAlertController(title: "Congratulations", message: "You have created an event!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
    /*
    @objc func inviteesTapped() {
        let inviteListVC = storyboard?.instantiateViewController(withIdentifier: "InviteList") as! InviteListViewController
            inviteListVC.selectedUsers = selectedUsers  // Pass the selectedUsers array to InviteListViewController
            inviteListVC.didSelectUsers = { [weak self] users in
                // Update inviteesText with the names of the selected users
                let names = users.map { $0.name }
                self?.inviteesText.text = names.joined(separator: ", ")
                self?.selectedUsers = users  // Update the selectedUsers array with the newly selected users
            }
            present(inviteListVC, animated: true, completion: nil)
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
