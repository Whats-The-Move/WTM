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
class CreateEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    var cancel: UIButton!
    var save: UIButton!
    var eventTitle: UITextField!
    var imageView: UIImageView!
    var deals: UITextField!
    var datePicker: UIDatePicker!
    var time: UITextField!
    var repeatLabel: UILabel!
    var descriptionText: UITextView!
    var repeatTableView: UITableView!
    
    var typeOptions = ["Drink Discount", "Free Drink", "Event Alert", "Other"]
    var typeChoice = "drink discount"
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var imageUploadURL = ""
    var selectedUsers: [User] = []
    var selectedDays: [String] = []
    
    var eventToEdit: EventLoad?

    //var scrollView = UIScrollView()
    //var contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        //setupScrollView()
        setupCancel()
        setupSave()
        setupEventTitle()
        setupImageView()
        setupDescriptionText()
        setupDatePicker()
        setupDeals()

        setupTime()
        setupRepeatLabel()
        setupTableView()
        //addSubviews()
        setFonts()
        setupGestureRecognizers()
        
        if let event = eventToEdit {
            setupToEdit()
        }

    }
    func setupToEdit (){
        eventTitle.text =  eventToEdit?.eventName ?? ""
        
        loadImage(from: eventToEdit?.imageURL ?? "", to: imageView)
        self.imageUploadURL = eventToEdit?.imageURL ?? ""
        
        descriptionText.text = eventToEdit?.description ?? "" // Temporary text for debugging

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        if let date = dateFormatter.date(from: eventToEdit?.date ?? "") {
            datePicker.date = date
            datePicker.isUserInteractionEnabled = false // Disables interaction
        }
        
        deals.text =  eventToEdit?.deals ?? ""

        time.text =  eventToEdit?.time ?? ""


        
    }
    private func setFonts() {
        let futuraMedium20 = UIFont(name: "Futura-Medium", size: 20)
        let futuraMedium40 = UIFont(name: "Futura-Medium", size: 40)

        // Set font for each UI component
        cancel.titleLabel?.font = futuraMedium20
        save.titleLabel?.font = futuraMedium20
        eventTitle.font = futuraMedium40
        deals.font = futuraMedium20
        time.font = futuraMedium20
        repeatLabel.font = futuraMedium20
        descriptionText.font = futuraMedium20
        
        imageView.image = UIImage(named: "EventPhoto")
        
        eventTitle.delegate = self
        descriptionText.delegate = self
        //inviteesText.delegate = self
        

        
        
        // Do any additional setup after loading the view.
        
    }

/*
    private func setupScrollView() {
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            // Important: contentView's bottom should be equal or greater than scrollView's bottom
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Add a height constraint if needed
            // contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: minimumHeight)
        ])
    }
*/


    private func setupCancel() {
        cancel = UIButton(type: .system)
        cancel.setTitle("Cancel", for: .normal)
        let pinkColor = UIColor(red: 255/255.0, green: 28/255.0, blue: 142/255.0, alpha: 1.0)
        cancel.setTitleColor(pinkColor, for: .normal)
        let futuraBig = UIFont(name: "Futura-Medium", size: 20)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        
        cancel.backgroundColor = .white
        cancel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancel)

        NSLayoutConstraint.activate([
            cancel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            cancel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancel.widthAnchor.constraint(equalToConstant: 100),
            cancel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupSave() {
        save = UIButton(type: .system)
        save.setTitle("Save", for: .normal)
        let pinkColor = UIColor(red: 255/255.0, green: 28/255.0, blue: 142/255.0, alpha: 1.0)
        save.setTitleColor(pinkColor, for: .normal)
        save.backgroundColor = .white
        save.translatesAutoresizingMaskIntoConstraints = false
        save.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        view.addSubview(save)

        NSLayoutConstraint.activate([
            save.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            save.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            save.widthAnchor.constraint(equalToConstant: 100),
            save.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    private func setupEventTitle() {
        eventTitle = UITextField()
        eventTitle.attributedPlaceholder = NSAttributedString(string: "Event Title", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        eventTitle.textColor = .black
        eventTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(eventTitle)
        eventTitle.textAlignment = .center

        NSLayoutConstraint.activate([
            eventTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventTitle.topAnchor.constraint(equalTo: save.bottomAnchor, constant: 15),
            eventTitle.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            eventTitle.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupImageView() {
        imageView = UIImageView()
        imageView.image = UIImage(named: "profile.icon") // Ensure this image is in your assets
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: eventTitle.bottomAnchor, constant: 15),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupDescriptionText() {
        descriptionText = UITextView()
        descriptionText.overrideUserInterfaceStyle = .light
        descriptionText.textColor = .black
        //descriptionText.backgroundColor = .lightGray // Temporary background color for visibility
        descriptionText.text = "Description" // Temporary text for debugging

        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionText)
       

        NSLayoutConstraint.activate([
            descriptionText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionText.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            descriptionText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionText.heightAnchor.constraint(equalToConstant: 170)
        ])
    }

    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 200),
            datePicker.topAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 10),
            datePicker.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: 70),
            datePicker.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupDeals() {
        deals = UITextField()
        deals.attributedPlaceholder = NSAttributedString(string: "Deals (optional)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        deals.textColor = .black
        deals.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deals)

        NSLayoutConstraint.activate([
            deals.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deals.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 15),
            deals.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deals.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupTime() {
        time = UITextField()
        time.attributedPlaceholder = NSAttributedString(string: "Time", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        time.textColor = .black
        time.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(time)

        NSLayoutConstraint.activate([
            time.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            time.topAnchor.constraint(equalTo: deals.bottomAnchor, constant: 13),
            time.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            time.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupRepeatLabel() {
        repeatLabel = UILabel()
        repeatLabel.isUserInteractionEnabled = true
        repeatLabel.text = "Does not repeat"
        repeatLabel.textColor = .black
        repeatLabel.translatesAutoresizingMaskIntoConstraints = false
        //hiding for now
        repeatLabel.isHidden =  true
        view.addSubview(repeatLabel)

        NSLayoutConstraint.activate([
            repeatLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            repeatLabel.topAnchor.constraint(equalTo: time.bottomAnchor, constant: 15),
            repeatLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    

    
    

    /*
    private func addSubviews() {
        contentView.addSubview(cancel)
        contentView.addSubview(save)
        contentView.addSubview(eventTitle)
        contentView.addSubview(imageView)
        contentView.addSubview(deals)
        contentView.addSubview(datePicker)
        contentView.addSubview(time)
        contentView.addSubview(repeatLabel)
        contentView.addSubview(descriptionText)
    }*/
    
    
    
    private func setupTableView() {
        repeatTableView = UITableView()
        repeatTableView.delegate = self
        repeatTableView.dataSource = self
        repeatTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        repeatTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(repeatTableView)
        NSLayoutConstraint.activate([
            repeatTableView.centerXAnchor.constraint(equalTo: repeatLabel.centerXAnchor),
            repeatTableView.heightAnchor.constraint(equalToConstant: 200),
            repeatTableView.widthAnchor.constraint(equalToConstant: 160),
            repeatTableView.bottomAnchor.constraint(equalTo: repeatLabel.topAnchor)
        ])
        repeatTableView.isHidden = true
    }
    


    
    private func setupGestureRecognizers() {
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        repeatLabel.isUserInteractionEnabled = true
        repeatLabel.addGestureRecognizer(tapGestureRecognizer)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }
    @objc func imageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
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
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        if eventTitle.isFirstResponder ||  descriptionText.isFirstResponder  {
            let maxY = max(eventTitle.frame.maxY, descriptionText.frame.maxY)
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
    @objc func dismissKeyboard() {
        descriptionText.resignFirstResponder()
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
                
                self.imageUploadURL = downloadURL.absoluteString
                // Do something with imageUploadURL
                print("Download URL: \(self.imageUploadURL)")
            }
        }
    }
    // ... Rest of your methods ...
    
    // Don't forget to update any method that refers to UI elements, replacing IBOutlet references with the newly created UI elements.
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
    
    @objc func cancelTapped() {
        self.dismiss(animated: true)
    }
 

    @objc func saveTapped() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy" // "Jan 3, 2023" format
        
        guard let eventTitle = eventTitle.text,
              let deals = deals.text,
              let time = time.text,
              let eventDescription = descriptionText.text
        else {
            print("didn't fill it")
            return
            
        }
        if  eventTitle == "" ||  eventDescription == "Description" || imageUploadURL == "" || time == "" {
            let alertController = UIAlertController(title: "Missing Information", message: "One or more fields are empty. Please fill out all required fields.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
            return
        }

        let currentUserUID = Auth.auth().currentUser?.uid ?? ""

        let db = Firestore.firestore()
        let userRef = db.collection("barUsers").document(currentUserUID)
        

        let imageURL = self.imageUploadURL
        let date = datePicker.date

        let dateString = dateFormatter.string(from: date)

        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let venueName = document["venueName"] as? String, let creatorLocation = document["location"] as? String, let type = document["type"] as? String {
                    // Successfully fetched the venueName
                    print("Venue Name: \(venueName)")
                    let privatesRef = Database.database().reference().child("\(creatorLocation)Events").child(dateString)
                    
                    var newEventRef = privatesRef.childByAutoId()
                    if self.eventToEdit != nil {
                        newEventRef = privatesRef.child(self.eventToEdit?.eventKey ?? "")
                    }
                     let eventInfo: [String: Any] = [
                        "creator": currentUserUID,
                     "deals" : deals,
                     "description": eventDescription,
                     "eventName": eventTitle,
                    "imageURL": imageURL,
                        "isGoing" : ["placeholder"],
                     "location": "N/A",
                     "time" : time,
                     "venueName": venueName,
                    "repitition": self.selectedDays,
                        "type" : type
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
        descriptionText.text = ""
        
        
        // Display a message
        let alertController = UIAlertController(title: "Congratulations", message: "You have created an event! You can find it in My Events", preferredStyle: .alert)
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
    func loadImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        imageView.kf.setImage(with: url)
    }
}
