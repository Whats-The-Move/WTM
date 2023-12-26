//
//  CreateEventViewController.swift
//  WTM
//
//  Created by Aman Shah on 6/13/23.
//

import UIKit
import Firebase
import FirebaseAuth
import StoreKit

class CreateEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        typeOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typeOptions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.typeChoice = typeOptions[row]
        //here's where you do the code for firebase
        // Update your UI or perform actions based on the selected option
    }

    
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description" {
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
        }
    }


    var typeOptions = ["Drink Discount", "Free Drink", "Event Alert", "Other"]
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var save: UIButton!
    
    @IBOutlet weak var eventTitle: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var deals: UITextField!
    @IBOutlet weak var typePicker: UIPickerView!

    
    @IBOutlet weak var time: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var descriptionText: UITextView!
    var typeChoice = "drink discount"
    var repeatTableView: UITableView!
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var imageUploadURL = ""
    var selectedUsers: [User] = []
    var selectedDays: [String] = []
    var userEditing = false
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    //MAKE IT SO IF EDITING SHOW BUTTON
    override func viewDidLoad() {
        super.viewDidLoad()

        setupScrollView()
        //setupConstraints()
        setupTableView()
        setupTypePicker()
        if let image = UIImage(named: "profileIcon") {
                imageView.image = image
            } else {
                print("Image not found")
            }

        //addHorizontalLine(belowView: eventTitle, spacing: 10.0)

        //addHorizontalLine(belowView: repeatLabel, spacing: 14.0)
        
        //addHorizontalLine(belowView: location, spacing: 10.0)
        //addHorizontalLine(belowView: typePicker, spacing: 10.0)

       // addHorizontalLine(belowView: descriptionText, spacing: 13.0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        
        if let futuraBig = UIFont(name: "Futura-Medium", size: 40) {
            eventTitle.font = futuraBig
        }
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

    func setupScrollView() {
        scrollView = UIScrollView()
        contentView = UIView()
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Transfer all subviews from self.view to contentView
        transferSubviewsToContentView()
    }
    func transferSubviewsToContentView() {
        let subviews = view.subviews.filter { $0 != scrollView }
        for subview in subviews {
            subview.removeFromSuperview()
            contentView.addSubview(subview)
        }
        setupConstraints()
        // Since we are moving subviews, we need to re-apply the constraints to contentView
        // Ideally, this would be done in Interface Builder or by re-activating each view's constraints relative to contentView.
        // For now, this function will be a placeholder for you to manually update the constraints as needed.
    }
    @objc func imageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
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
    func setupTypePicker(){
        //add the options for the type picker here
        typePicker.dataSource = self
        typePicker.delegate = self

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
        lineView.backgroundColor = UIColor.gray // Set the line color as needed
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
        let view = contentView
        cancel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            cancel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancel.widthAnchor.constraint(equalToConstant: 100),
            cancel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Save button constraints
        save.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            save.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            save.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            save.widthAnchor.constraint(equalToConstant: 100),
            save.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Event title constraints
        eventTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            eventTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100),
            eventTitle.widthAnchor.constraint(equalToConstant: 200),
            eventTitle.heightAnchor.constraint(equalToConstant: 50)
        ])
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: eventTitle.bottomAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionText.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            descriptionText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            descriptionText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            descriptionText.heightAnchor.constraint(equalToConstant: 120)
        ])
        typePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            typePicker.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 30),
            typePicker.topAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 20),
            typePicker.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            typePicker.heightAnchor.constraint(equalToConstant: 80)
        ])
        deals.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deals.leadingAnchor.constraint(equalTo: descriptionText.leadingAnchor),
            deals.topAnchor.constraint(equalTo: typePicker.bottomAnchor, constant: 15),
            deals.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            deals.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Location constraints
        location.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            location.leadingAnchor.constraint(equalTo: descriptionText.leadingAnchor),
            location.topAnchor.constraint(equalTo: deals.bottomAnchor, constant: 15),
            location.widthAnchor.constraint(equalToConstant: 300),
            location.heightAnchor.constraint(equalToConstant: 50)
        ])
        date.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            date.leadingAnchor.constraint(equalTo: descriptionText.leadingAnchor),
            date.topAnchor.constraint(equalTo: location.bottomAnchor, constant: 15),
            date.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            date.heightAnchor.constraint(equalToConstant: 50)
        ])
        time.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            time.leadingAnchor.constraint(equalTo: descriptionText.leadingAnchor),
            time.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 15),
            time.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            time.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        
        // Repeat Label constraints
        repeatLabel.translatesAutoresizingMaskIntoConstraints = false
        repeatLabel.text = "Does not repeat"
        NSLayoutConstraint.activate([
            repeatLabel.leadingAnchor.constraint(equalTo: time.leadingAnchor),
            repeatLabel.topAnchor.constraint(equalTo: time.bottomAnchor, constant:  15),
            repeatLabel.widthAnchor.constraint(equalToConstant: 300),
            repeatLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Repeat Button constraints


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
        // Create a bold font

        if let futuraBold = UIFont(name: "Futura-Bold", size: 18) {
            save.titleLabel?.font = futuraBold

        }
        if let futuraRegular = UIFont(name: "Futura-Medium", size: 18) {
            cancel.titleLabel?.font = futuraRegular
            location.font = futuraRegular
            repeatLabel.font = futuraRegular
            descriptionText.font = futuraRegular
            deals.font = futuraRegular
            time.font = futuraRegular
            date.font = futuraRegular
        }


        descriptionText.layer.cornerRadius = 8
        
        var pinkColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0)
        pinkColor = UIColor.black
        // Create a UITextField


        // Create an NSAttributedString with the custom pink color for the placeholder text
        let pinkPlaceholderText = NSAttributedString(string: "Event Title", attributes: [NSAttributedString.Key.foregroundColor: pinkColor])
        eventTitle.attributedPlaceholder = pinkPlaceholderText
        var pinkPlaceholderTextLocation = NSAttributedString(string: "Address", attributes: [NSAttributedString.Key.foregroundColor: pinkColor])
        location.attributedPlaceholder = pinkPlaceholderTextLocation
        var placeholderText = NSAttributedString(string: "Date", attributes: [NSAttributedString.Key.foregroundColor: pinkColor])
        date.attributedPlaceholder = placeholderText
        placeholderText = NSAttributedString(string: "Time", attributes: [NSAttributedString.Key.foregroundColor: pinkColor])
        time.attributedPlaceholder = placeholderText
        placeholderText = NSAttributedString(string: "Deals", attributes: [NSAttributedString.Key.foregroundColor: pinkColor])
        deals.attributedPlaceholder = placeholderText


        //dateAndTime.setValue(UIColor.white, forKeyPath: "textColor")

        // Set the background color to gray
        //dateAndTime.backgroundColor = pinkColor
        //endTime.backgroundColor = pinkColor
        
        eventTitle.backgroundColor = .clear
        location.backgroundColor = .clear

    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
 

    @IBAction func saveTapped(_ sender: Any) {
        guard let eventTitle = eventTitle.text,
              let date = date.text,
              let deals = deals.text,
              let location = location.text,
              let time = time.text,
              let eventDescription = descriptionText.text
        else {
            print("didn't fill it")
            return
            
        }
        if  eventTitle == "" || location == "" || eventDescription == "Description" {
            let alertController = UIAlertController(title: "Missing Information", message: "One or more fields are empty. Please fill out all required fields.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
            return
        }
        let unixStart = 4
        let unixEnd = 4
        let currentUserUID = Auth.auth().currentUser?.uid ?? ""
        let imageURL = self.imageUploadURL
        
        // Get the invitee UIDs as an array
        /*var inviteeUIDs = selectedUsers.map { $0.uid }
        inviteeUIDs.append(currentUserUID)*/

        // Assuming you have authenticated the user and have access to their UID
        let db = Firestore.firestore()
        let userRef = db.collection("barUsers").document(currentUserUID)
        var placeName = "testParty"
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let venueName = document["venueName"] as? String, let creatorLocation = document["location"] as? String {
                    // Successfully fetched the venueName
                    print("Venue Name: \(venueName)")
                    placeName = venueName
                    let privatesRef = Database.database().reference().child("\(creatorLocation)Events")
                    let newEventRef = privatesRef.childByAutoId()
                    
                    // Create a dictionary with the event information
                    let eventInfo: [String: Any] = [
                        "title": eventTitle,
                        "start": unixStart,
                        "end": unixEnd,
                        "location": location,
                        "description": eventDescription,
                        "creator": currentUserUID,
                        "eventType": self.typeChoice,
                        "repitition": self.selectedDays 
                    ]
                    /*
                     let eventInfo: [String: Any] = [
                        "creator": currentUserUID,
                        "date": date,
                     "deals" : deals,
                     "description": eventDescription,
                     "eventName": eventTitle,
                        "imageURL": imageURL, //not good
                     "location": location,
                     "time" : time,
                     "venueName": placeName
                         "eventType": self.typeChoice,
                         "repitition": self.selectedDays ?? "none"
                     ]
                     */
                    
                    // Set the event information under the new child node
                    newEventRef.setValue(eventInfo) { error, _ in
                        if let error = error {
                            print("Error creating event: \(error.localizedDescription)")
                        } else {
                            print("Event created successfully!")
                            // TODO: Perform any additional actions after event creation
                        }
                    }
                } else {
                    // The "venueName" field does not exist or is not a String
                    print("Venue Name not found or is not a String")
                }
            } else {
                // Document does not exist or there was an error
                print("Document does not exist or an error occurred")
            }
        }
        // Create a new child node under "Privates" and generate a unique key

        
        self.eventTitle.text = ""
        self.location.text = ""
        descriptionText.text = ""
        
        
        // Display a message
        let alertController = UIAlertController(title: "Congratulations", message: "You have created an event!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            print("ok")
            self.dismiss(animated: true)

        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        if #available(iOS 10.3, *) {
            if !UserDefaults.standard.bool(forKey: "reviewRequested") {
                UserDefaults.standard.set(true, forKey: "reviewRequested")
                print("Changing value")
                SKStoreReviewController.requestReview()

            }
        } else {
            // Fallback code for iOS versions earlier than 10.3
            // You can implement your custom review prompt or use third-party libraries.
        }

    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        imageView.image = selectedImage

        // Call the function to upload the image
        uploadImageToFirebase(image: selectedImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func uploadImageToFirebase(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print(error?.localizedDescription ?? "Unknown error occurred")
                return
            }
            
            // Retrieve the download URL
            imageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print(error?.localizedDescription ?? "Unknown error occurred")
                    return
                }
                
                let imageUploadURL = downloadURL.absoluteString
                // Do something with imageUploadURL
                print("Download URL: \(imageUploadURL)")
            }
        }
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
