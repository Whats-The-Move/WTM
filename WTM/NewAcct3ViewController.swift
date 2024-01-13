//
//  NewAcct3ViewController.swift
//  WTM
//
//  Created by Aman Shah on 1/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewAcct3ViewController: UIViewController {

    var backButton: UIButton!
    var descriptionLabel: UILabel!
    var username: UITextField!
    var displayName: UITextField!
    var interests: UITextField!

    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = NewAcctLandingViewController()
        backButton = vc.createBackButton()
        view.addSubview(backButton)
        descriptionLabel = vc.createLabel(text: "Last Step!", fontSize: 36)
        view.addSubview(descriptionLabel)
        username = vc.createTextField(placeholder: "Username", fontSize: 18)
        view.addSubview(username)


        
        displayName = vc.createTextField(placeholder: "Display Name", fontSize: 18)
        view.addSubview(displayName)
        interests = vc.createTextField(placeholder: "List 3 interests", fontSize: 18)
        view.addSubview(interests)


        
        setupConstraints()
        // Do any additional setup after loading the view.
    }
    func setupConstraints(){
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16), // Adjust as needed
            descriptionLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10), // Adjust as needed
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 120),
        ])
        NSLayoutConstraint.activate([
            username.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            username.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -96 - 78),
            username.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            username.heightAnchor.constraint(equalToConstant: 60),
        ])
        NSLayoutConstraint.activate([
            displayName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            displayName.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 18),
            displayName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            displayName.heightAnchor.constraint(equalToConstant: 60),
        ])
        NSLayoutConstraint.activate([
            interests.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            interests.topAnchor.constraint(equalTo: displayName.bottomAnchor, constant: 18),
            interests.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            interests.heightAnchor.constraint(equalToConstant: 60),
        ])
        
    }

    
    @IBAction func partyPressed(_ sender: Any) {
        guard let username = username.text, !username.isEmpty,
              let displayName = displayName.text, !displayName.isEmpty,
              let interests = interests.text, !interests.isEmpty
            

        else{
            print("missing field data")
            let alert = UIAlertController(title: "Alert", message: "Fill the blanks", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sorry I won't do it again", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
            return
        }
        createUsername = username
        createDisplayName = displayName
        createInterests = interests
        
        if username.contains(" ") {
            print("Username contains spaces")
            let alert = UIAlertController(title: "Alert", message: "Username should not contain spaces", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        checkUsernameAvailability(username: username) { isAvailable, error in
            if let error = error {
                // Handle the error
                print("Error checking username availability: \(error.localizedDescription)")
                return
            }
          
            if isAvailable {
                // Create a new user with email and password
                Auth.auth().createUser(withEmail: createEmail, password: createPassword) { (authResult, error) in
                    if let error = error {
                        // Handle the error
                        print("Error creating user: \(error.localizedDescription)")
                        let alert = UIAlertController(title: "Alert", message: "Error creating user", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    // User successfully created, proceed with adding data to Firestore
                    if let authResult = authResult {
                        let uid = authResult.user.uid
                        let userRef = Firestore.firestore().collection("users").document(uid)
                        
                        let data: [String: Any] = [
                            "email": createEmail,
                            "username": createUsername,
                            "name": createDisplayName,
                            "phone": createPhone,
                            "interests": createInterests,
                            "profilePic": createImageURL,
                            "uid": uid,
                            "images": [],
                            "bestFriends": [],
                            "friends": [],
                            "fcmToken": userFcmToken,
                            "pendingFriendRequests": [],
                            "spots": []
                        ]
                        
                        userRef.setData(data, merge: true) { error in
                            if let error = error {
                                // Handle the error
                                print("Error creating Firestore document: \(error.localizedDescription)")
                                let alert = UIAlertController(title: "Alert", message: "Error creating Firestore document", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                            
                            // Success!
                            UserDefaults.standard.set(true, forKey: "authenticated")

                            print("Added username, name, phone, and interests")
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let appHomeVC = storyboard.instantiateViewController(identifier: "createAddFriend")
                            appHomeVC.modalPresentationStyle = .overFullScreen
                            self.present(appHomeVC, animated: true)
                        }
                    }
                }
          
            }
            else{
                // Username is already taken
                print("Username is already taken")
                let alert = UIAlertController(title: "Alert", message: "Username taken", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return // Exit the entire function
            }
        }
        // Check if the username is valid (add your validation logic here)

        
     
        /*
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CreateAccount1")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)*/
    }
    func checkUsernameAvailability(username: String, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        
        let query = usersCollection.whereField("username", isEqualTo: username)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle the error
                completion(false, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                // No documents found, username is available
                completion(true, nil)
                return
            }
            
            // If any documents are found, the username is already taken
            let isTaken = !documents.isEmpty
            completion(!isTaken, nil)
        }
    }
    

    
}
