import UIKit
import Firebase
import FirebaseStorage

class addMessageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create a Post"
        label.font = UIFont(name: "Futura", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont(name: "Futura", size: 15)
        button.tintColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    let tagTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add a tag"
        textField.borderStyle = .roundedRect
        textField.inputView = UIPickerView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let messageTextField: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = UIColor.black
        return textView
    }()

    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.tintColor = UIColor(red: 1.0, green: 0.086, blue: 0.58, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    var selectedImage: UIImage?
    var eventList: [String] = ["Other"]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupPickerView()
        fetchDataFromFirebase()
    }

    func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(cancelButton)
        view.addSubview(tagTextField)
        view.addSubview(messageTextField)
        view.addSubview(submitButton)
        view.addSubview(photoButton)
        view.addSubview(selectedImageView)

        // Set up constraints
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),

            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),

            tagTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tagTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tagTextField.widthAnchor.constraint(equalToConstant: 350),

            messageTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageTextField.topAnchor.constraint(equalTo: tagTextField.bottomAnchor, constant: 16),
            messageTextField.leadingAnchor.constraint(equalTo: tagTextField.leadingAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: tagTextField.trailingAnchor),
            messageTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            submitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            submitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            submitButton.widthAnchor.constraint(equalToConstant: 44),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            
            photoButton.leadingAnchor.constraint(equalTo: tagTextField.leadingAnchor),
            photoButton.topAnchor.constraint(equalTo: messageTextField.bottomAnchor, constant: 10),
            photoButton.widthAnchor.constraint(equalToConstant: 44),
            photoButton.heightAnchor.constraint(equalToConstant: 44),
            
            selectedImageView.trailingAnchor.constraint(equalTo: tagTextField.trailingAnchor),
            selectedImageView.leadingAnchor.constraint(equalTo: tagTextField.leadingAnchor),
            selectedImageView.topAnchor.constraint(equalTo: messageTextField.bottomAnchor, constant: 10),
            selectedImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 350), // Maximum width constraint
            selectedImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 350), // Maximum height constraint
        ])

        // Set delegate for messageTextField to handle dynamic resizing
        messageTextField.delegate = self
    }
    
    @objc func photoButtonTapped() {
        showImagePicker()
    }

    func setupPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        tagTextField.inputView = pickerView
    }
    
    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = pickedImage
            selectedImageView.image = pickedImage
            // Display the selected image as needed
            // For now, you can print the image size
            print("Selected Image Size: \(pickedImage.size)")
        }

        dismiss(animated: true, completion: nil)
    }

    func fetchDataFromFirebase() {
        let eventsRef = Database.database().reference().child(currCity + "Events")

        eventsRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }

            if let datesData = snapshot.value as? [String: Any] {
                for (_, dateValue) in datesData {
                    if let dateData = dateValue as? [String: Any] {
                        for (_, eventData) in dateData {
                            if let eventIdData = eventData as? [String: Any],
                                let eventName = eventIdData["eventName"] as? String,
                                let venueName = eventIdData["venueName"] as? String {
                                let eventString = "\(eventName) @ \(venueName)"
                                self.eventList.append(eventString)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
    }

    func adjustTextViewHeight() {
        let fixedWidth = messageTextField.frame.size.width
        let newSize = messageTextField.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

        let minHeight: CGFloat = 100
        let height = max(minHeight, newSize.height)

        messageTextField.constraints.filter { $0.firstAttribute == .height }.forEach {
            $0.constant = height
        }
    }
    
    @objc func submitButtonTapped() {
        guard let tag = tagTextField.text, !tag.isEmpty,
              let message = messageTextField.text, !message.isEmpty else {
            // Display alert if tagTextField or messageTextField is empty
            showAlert(message: "Please fill in all text fields to post.")
            return
        }

        let chatRef = Database.database().reference().child("\(currCity)Chat")
        let chatID = UUID().uuidString // Generate a unique 32-digit ID

        let messageRef = chatRef.child(chatID)
        let currentTime = getCurrentDateTime()

        // Set up chat message data
        var chatMessageData: [String: Any] = [
            "message": message,
            "tag": tag,
            "likes": ["a"],
            "dislikes": ["a"],
            "time": currentTime
        ]

        if let image = selectedImage {
            uploadImageToFirebase(image: image) { downloadURL in
                chatMessageData["picture"] = downloadURL

                // Add the rest of the message data and dismiss the view controller
                messageRef.setValue(chatMessageData)
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            // No image selected, proceed without "picture" field
            messageRef.setValue(chatMessageData)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func uploadImageToFirebase(image: UIImage, completion: @escaping (String?) -> Void) {
        print("hello i am in uploadimagetofirebase")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("compression didnt work")
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child("images").child(UUID().uuidString)
        print(storageRef)
        
        // Upload the image data to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Get the download URL
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "")")
                    completion(nil)
                    return
                }
                print(downloadURL.absoluteString)
                // Return the download URL
                completion(downloadURL.absoluteString)
            }
        }
    }

    // Helper function to get current date and time as an Int
    private func getCurrentDateTime() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        let currentDateTime = Int(dateFormatter.string(from: Date()))
        return currentDateTime ?? 0
    }

    // Helper function to show alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventList.count
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tagTextField.text = eventList[row]
    }

    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
