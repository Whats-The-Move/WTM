//
//  PartyAcctViewController.swift
//  WTM
//
//  Created by Aman Shah on 4/5/23.
//
//need to add auth stage here
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class PartyAcctViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    var typeOptions = ["Frat", "Bar", "Nightclub", "School club"]
    var cityOptions = ["Berkeley", "Champaign", "Chicago"]
    var selectedType = "Frat"
    var selectedCity = "Berkeley"
    @IBOutlet weak var barLabel: UILabel!
    
    var partyName: UITextField!
    
    var personName: UITextField!
    
    var contactEmail: UITextField!

    var password: UITextField!

    var venueAddress: UITextField!
    
    var type: UIPickerView!

    var city: UIPickerView!

    var uploadLabel: UILabel!
    
    var certificateUpload: UIButton!
    
    var success: UILabel!
    var fail: UILabel!

    
    var borderView: UIView!
    
    var backButton: UIButton!
    
    let imagePickerController = UIImagePickerController()
    
    var lineView: UIView!
    
    var barLoginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPartyName()

        setupBackButton()
        
        setupVenueAddress()
        setupPersonName()
        setupContactEmail()
        setupPassword()
        setupShowPasswordButton()
        setupTypePickerView()
        setupCityPickerView()
        setupUploadLabel()
        setupCertificateUploadButton()
 
        //setupLineView()
        setupBarLoginButton()
        setupSuccess()
        success.isHidden = true
        setupFail()
        fail.isHidden = true
        imagePickerController.delegate = self
        certificateUpload.addTarget(self, action: #selector(certificateUploadTapped), for: .touchUpInside)

    }
    
    func setupBackButton() {
        backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the button image and tint color to black
        backButton.setImage(UIImage(systemName: "chevron.backward.circle"), for: .normal)
        backButton.tintColor = .black
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Enable user interaction for the button
        backButton.isUserInteractionEnabled = true
        
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func backButtonTapped() {
        // Handle the button tap event here, e.g., dismiss the view controller
        self.dismiss(animated: true, completion: nil)
    }

    func setupPartyName() {
        partyName = UITextField()
        partyName.borderStyle = .roundedRect
        partyName.clipsToBounds = true

        partyName.placeholder = "Name of Frat/Bar/Party"
        partyName.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Set background color to white
        partyName.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size
        partyName.layer.cornerRadius = 10 // Add rounded corners
        partyName.layer.borderWidth = 1.0 // Add border
        partyName.layer.borderColor = UIColor.darkGray.cgColor // Set border color to black
        partyName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(partyName)

        NSLayoutConstraint.activate([
            partyName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            partyName.topAnchor.constraint(equalTo: barLabel.bottomAnchor, constant: 50),
            partyName.widthAnchor.constraint(equalToConstant: 320), // Set width to 300
            partyName.heightAnchor.constraint(equalToConstant: 45) // Set height to 35
        ])
    }
    

    func setupVenueAddress() {
        venueAddress = UITextField()
        venueAddress.borderStyle = .roundedRect
        venueAddress.clipsToBounds = true

        venueAddress.placeholder = "Address of Frat/Bar/Party"
        venueAddress.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)// Set background color to white
        venueAddress.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size
        venueAddress.layer.cornerRadius = 10 // Add rounded corners
        venueAddress.layer.borderWidth = 1.0 // Add border
        venueAddress.layer.borderColor = UIColor.darkGray.cgColor // Set border color to black
        venueAddress.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(venueAddress)

        NSLayoutConstraint.activate([
            venueAddress.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            venueAddress.topAnchor.constraint(equalTo: partyName.bottomAnchor, constant: 10),
            venueAddress.widthAnchor.constraint(equalToConstant: 320), // Set width to 300
            venueAddress.heightAnchor.constraint(equalToConstant: 45) // Set height to 35
        ])
    }

    func setupPersonName() {
        personName = UITextField()
        personName.borderStyle = .roundedRect
        personName.clipsToBounds = true

        personName.placeholder = "Name of Person who is point of contact"
        personName.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Set background color to white
        personName.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size
        personName.layer.cornerRadius = 10 // Add rounded corners
        personName.layer.borderWidth = 1.0 // Add border
        personName.layer.borderColor = UIColor.darkGray.cgColor // Set border color to black
        personName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(personName)

        NSLayoutConstraint.activate([
            personName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            personName.topAnchor.constraint(equalTo: venueAddress.bottomAnchor, constant: 10),
            personName.widthAnchor.constraint(equalToConstant: 320), // Set width to 300
            personName.heightAnchor.constraint(equalToConstant: 45) // Set height to 35
        ])
    }

    func setupContactEmail() {
        contactEmail = UITextField()
        contactEmail.borderStyle = .roundedRect
        contactEmail.clipsToBounds = true
        contactEmail.placeholder = "Email address of primary contact"
        contactEmail.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Set background color to white
        contactEmail.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size

        contactEmail.layer.cornerRadius = 10 // Add rounded corners
        contactEmail.layer.borderWidth = 1.0 // Add border

        contactEmail.layer.borderColor = UIColor.darkGray.cgColor // Set border color to black
        contactEmail.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contactEmail)

        NSLayoutConstraint.activate([
            contactEmail.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contactEmail.topAnchor.constraint(equalTo: personName.bottomAnchor, constant: 10),
            contactEmail.widthAnchor.constraint(equalToConstant: 320), // Set width to 300
            contactEmail.heightAnchor.constraint(equalToConstant: 45) // Set height to 35
        ])
    }
    func setupPassword() {
        password = UITextField()
        password.borderStyle = .roundedRect
        password.clipsToBounds = true
        password.isSecureTextEntry = true
        password.placeholder = "Password"
        password.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Set background color to white
        password.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size

        password.layer.cornerRadius = 10 // Add rounded corners
        password.layer.borderWidth = 1.0 // Add border

        password.layer.borderColor = UIColor.darkGray.cgColor // Set border color to black
        password.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(password)

        NSLayoutConstraint.activate([
            password.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            password.topAnchor.constraint(equalTo: contactEmail.bottomAnchor, constant: 10),
            password.widthAnchor.constraint(equalToConstant: 320), // Set width to 300
            password.heightAnchor.constraint(equalToConstant: 45) // Set height to 35
        ])
    }
    private func setupShowPasswordButton() {
        let showPasswordButton = UIButton(type: .custom)
        showPasswordButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        showPasswordButton.tintColor = .black
        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        showPasswordButton.addTarget(self, action: #selector(showPassword), for: .touchUpInside)
        view.addSubview(showPasswordButton)
        
        NSLayoutConstraint.activate([
            showPasswordButton.widthAnchor.constraint(equalToConstant: 30),
            showPasswordButton.heightAnchor.constraint(equalToConstant: 20),
            showPasswordButton.centerYAnchor.constraint(equalTo: password.centerYAnchor),
            showPasswordButton.trailingAnchor.constraint(equalTo: password.trailingAnchor, constant: -10)
        ])
    }
    @objc private func showPassword() {
        password.isSecureTextEntry = !password.isSecureTextEntry
    }
    
    func setupTypePickerView() {
        type = UIPickerView()
        type.delegate = self
        type.dataSource = self
        type.translatesAutoresizingMaskIntoConstraints = false
        type.frame = CGRect(x: 0, y: 0, width: 320, height: 40)

        view.addSubview(type)
        
        NSLayoutConstraint.activate([
            type.leadingAnchor.constraint(equalTo: password.leadingAnchor),
            type.trailingAnchor.constraint(equalTo: password.trailingAnchor),
            type.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 0),
            type.heightAnchor.constraint(equalToConstant: 60) // Adjust the height as needed
        ])
    }
    
    // MARK: - City Picker View Setup
    
    func setupCityPickerView() {
        city = UIPickerView()
        city.delegate = self
        city.dataSource = self
        city.translatesAutoresizingMaskIntoConstraints = false
        city.frame = CGRect(x: 0, y: 0, width: 320, height: 40)

        view.addSubview(city)
        
        NSLayoutConstraint.activate([
            city.leadingAnchor.constraint(equalTo: type.leadingAnchor),
            city.trailingAnchor.constraint(equalTo: type.trailingAnchor),
            city.topAnchor.constraint(equalTo: type.bottomAnchor, constant: 0),
            city.heightAnchor.constraint(equalToConstant: 60) // Adjust the height as needed
        ])
    }
    func setupUploadLabel() {
        uploadLabel = UILabel()
        uploadLabel.text = "Upon clicking submit below, you'll have to submit proof that you are a registered organization (liquor license, frat registration, etc.)"
        uploadLabel.textColor = .black // Set text color to black
        uploadLabel.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size
        uploadLabel.numberOfLines = 0 // Allow multiple lines for long text
        uploadLabel.textAlignment = .center // Center-align the text
        uploadLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uploadLabel)

        NSLayoutConstraint.activate([
            uploadLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadLabel.topAnchor.constraint(equalTo: city.bottomAnchor, constant: 30), // 20px below contactEmail
            uploadLabel.widthAnchor.constraint(equalToConstant: 320), // 20px below contactEmail

        ])
    }


    func setupCertificateUploadButton() {
        certificateUpload = UIButton()

        certificateUpload.setTitle("Upload and Submit", for: .normal)
        certificateUpload.setTitleColor(.white, for: .normal) // Set text color to white

        certificateUpload.backgroundColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1) // Set background fill color to white
        certificateUpload.layer.cornerRadius = 10 // Add rounded corners
        certificateUpload.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(certificateUpload)

        NSLayoutConstraint.activate([
            certificateUpload.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            certificateUpload.topAnchor.constraint(equalTo: uploadLabel.bottomAnchor, constant: 30),
            certificateUpload.widthAnchor.constraint(equalToConstant: 320), // Set width to 300
            certificateUpload.heightAnchor.constraint(equalToConstant: 45) // Set height to 35
        ])
    }
    
    func setupSuccess() {
        success = UILabel()
        success.text = "Account created successfully!"
        success.textColor = .black // Set text color to black
        success.font = UIFont(name: "Futura-Medium", size: 16) // Set font style and size
        success.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(success)

        NSLayoutConstraint.activate([
            success.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            success.topAnchor.constraint(equalTo: barLoginButton.bottomAnchor, constant: 10), // 20px under certificateUpload button
        ])
    }
    func setupFail() {
        fail = UILabel()
        fail.numberOfLines = 0 // Allow text to wrap to multiple lines

        fail.text = "Error. Try again or email aman04shah@gmail.com"
        fail.textColor = .black // Set text color to black
        fail.font = UIFont(name: "Futura-Medium", size: 14) // Set font style and size
        fail.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fail)

        NSLayoutConstraint.activate([
            fail.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fail.topAnchor.constraint(equalTo: barLoginButton.bottomAnchor, constant: 20), // 20px under certificateUpload button
            fail.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20)
        ])
    }
    func setupLineView() {
        lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .white
        // Set the button image and tint color to black

        
 
        
        // Enable user interaction for the button
        
        view.addSubview(lineView)

        NSLayoutConstraint.activate([
            lineView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lineView.topAnchor.constraint(equalTo: fail.bottomAnchor, constant: 20),
            lineView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    func setupBarLoginButton() {
        barLoginButton = UIButton()
        barLoginButton.translatesAutoresizingMaskIntoConstraints = false
        let attributedString = NSMutableAttributedString(string: "Have a party account? ")
        attributedString.append(NSAttributedString(string: "Sign in", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 255/255, green: 28/255, blue: 142/255, alpha: 1)]))
        barLoginButton.setAttributedTitle(attributedString, for: .normal)
        // Set the button title and styling
        //barLoginButton.setTitle("Already been approved? Sign in instead", for: .normal)
        
        barLoginButton.setTitleColor(.gray, for: .normal)
        barLoginButton.backgroundColor = .white
        //barLoginButton.layer.borderWidth = 2.0
        barLoginButton.layer.borderColor = UIColor.black.cgColor
        barLoginButton.titleLabel?.adjustsFontSizeToFitWidth = true
        barLoginButton.titleLabel?.minimumScaleFactor = 0.5 // You can adjust this value as needed.
        barLoginButton.titleLabel?.font =  UIFont(name: "Futura-Medium", size: 16)
        barLoginButton.layer.cornerRadius = 8
        barLoginButton.clipsToBounds = true
        barLoginButton.addTarget(self, action: #selector(barLoginTapped), for: .touchUpInside)
        
        // Enable user interaction for the button
        barLoginButton.isUserInteractionEnabled = true
        
        view.addSubview(barLoginButton)
        
        NSLayoutConstraint.activate([
            barLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            barLoginButton.topAnchor.constraint(equalTo: certificateUpload.bottomAnchor, constant: 5),
            barLoginButton.widthAnchor.constraint(equalToConstant: 320),
            barLoginButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }


    @objc func barLoginTapped() {
        // Instantiate the view controller with the identifier "BarSignIn" from the storyboard
        let vc = storyboard?.instantiateViewController(identifier: "SignUpPage") as ViewController?
        vc?.modalPresentationStyle = .overFullScreen
        vc?.barAcct = true
        self.present(vc!, animated: true)
        /*
        if let barSignInViewController = storyboard?.instantiateViewController(withIdentifier: "BarSignIn") {
            
            // Wrap the view controller in a navigation controller to ensure it's shown full screen
            let navigationController = UINavigationController(rootViewController: barSignInViewController)
            
            // Present the navigation controller modally
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }*/
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == type {
            return typeOptions.count
        } else if pickerView == city {
            return cityOptions.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == type {
            return typeOptions[row]
        } else if pickerView == city {
            return cityOptions[row]
        }
        return nil
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == type {
            selectedType = typeOptions[row]
            print("Selected Type: \(selectedType)")
            // Do something with the selected type
        } else if pickerView == city {
            selectedCity = cityOptions[row]
            print("Selected City: \(selectedCity)")
            // Do something with the selected city
        }
    }


  @objc func certificateUploadTapped(_ sender: Any) {
        guard let partyName = partyName.text, !partyName.isEmpty,
                let personName = personName.text, !personName.isEmpty,
                let contactEmail = contactEmail.text, !contactEmail.isEmpty,
                let venueAddress = venueAddress.text, !venueAddress.isEmpty
        else{
            let alert = UIAlertController(title: "Alert", message: "Missing field data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
            print("missing field data")
            return
        }
        let imagePickerActionSheet = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let libraryButton = UIAlertAction(title: "Choose from Library", style: .default) { (action) in
                self.imagePickerController.sourceType = .photoLibrary
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            imagePickerActionSheet.addAction(libraryButton)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo", style: .default) { (action) in
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        imagePickerActionSheet.addAction(cancelButton)
        
        present(imagePickerActionSheet, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                // Upload the image to Firebase Storage
            let storageRef = Storage.storage().reference().child("pendingParties/\(String(describing: self.partyName.text)).jpg")
            //"partyImages/\(UUID().uuidString).jpg"
                guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
                    return
                }
                storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        // Handle the error
                        print("Error uploading image: \(error.localizedDescription)")
                        self.fail.isHidden = false
                        

                        return
                    }
                    
                    // Once the image is uploaded, get its download URL and store it in Firestore
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Handle the error
                            print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                            self.fail.isHidden = false

                            return
                        }
                        //add the auth right here, only if successful, put into firestore. also get and put uid in that way as the doc title
                        // Store the download URL in Firestore
                        let email = self.contactEmail.text
                        //setting password to
                        let password = self.partyName.text
                        //do auth
                        Auth.auth().createUser(withEmail: email!, password: password! ) { (authResult, error) in
                            if let error = error {
                                print("Error creating user: \(error.localizedDescription)")
                                let alert = UIAlertController(title: "Alert", message: "Invalid email/password", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion:  {
                                    return
                                })
                                print("missing field data")
                                return
                                // Handle the error here (e.g., show an error message to the user)
                            } else {
                                UserDefaults.standard.set(true, forKey: "partyAcct")

                                let uid = Auth.auth().currentUser?.uid
                                print("created!" + uid!)
                                let userRef = Firestore.firestore().collection("barUsers").document(uid ?? "")
                                let data: [String: Any] = [
                                   
                                    "proofURL": downloadURL.absoluteString,
                                    "venueName": self.partyName.text,
                                    "venueAddress": self.venueAddress.text,
                                    "email": self.contactEmail.text,
                                    "personName" : self.personName.text,
                                    "verified" : "no",
                                    "type" : self.selectedType ,//needs work
                                    "location": self.selectedCity,         
                                    "hours" : "",
                                    "profilePic": ""
                                    
                                    // Add other fields as needed
                                ]
                                userRef.setData(data) { error in
                                    if let error = error {
                                        // Handle the error
                                        print("Error creating Firestore document: \(error.localizedDescription)")
                                        self.fail.isHidden = false

                                        return
                                    }
                                    
                                    // Success!

                                    self.submitSuccess()
                                    currCity = self.selectedCity
                                    print("Image uploaded and download URL stored in Firestore!")
                                }
                                // User creation was successful
                                if let user = authResult?.user {
                                    print("User created successfully with UID: \(user.uid)")
                                    // You can perform additional actions here after user creation
                                }
                            }
                        }
   







                    }
                }
            }
            
            dismiss(animated: true, completion: nil)
       }
    func submitSuccess (){
        UserDefaults.standard.set(true, forKey: "partyAcct")
        UserDefaults.standard.set(true, forKey: "authenticated")
        self.success.isHidden = false
        self.fail.isHidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appHomeVC = storyboard.instantiateViewController(identifier: "TabBarController")
        appHomeVC.modalPresentationStyle = .overFullScreen
        self.present(appHomeVC, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
