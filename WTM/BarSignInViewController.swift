//
//  BarSignInViewController.swift
//  WTM
//
//  Created by Aman Shah on 8/31/23.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseFirestore

class BarSignInViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var emailInvalid: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        KeyboardManager.shared.enableTapToDismiss()
        setupShowPasswordButton()
        setupConstraints()
        email.layer.cornerRadius = 8
        password.layer.cornerRadius = 8
        email.clipsToBounds = true
        password.clipsToBounds = true
        label.adjustsFontSizeToFitWidth = true
        
        if FirebaseAuth.Auth.auth().currentUser != nil {
            //TAKE PAST LOGIN SCREEN TO HOME SCREEN
            print("USER IS IN")
            UserDefaults.standard.set(FirebaseAuth.Auth.auth().currentUser?.email, forKey: "user_address")
            UserDefaults.standard.set(true, forKey: "authenticated")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appHomeVC = storyboard.instantiateViewController(identifier: "TabBarController")
            appHomeVC.modalPresentationStyle = .overFullScreen
            self.present(appHomeVC, animated: true)
            
            
        }
        let authenticated = UserDefaults.standard.bool(forKey: "authenticated")
        if authenticated {
            print("USER IS IN")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appHomeVC = storyboard.instantiateViewController(identifier: "TabBarController")
            appHomeVC.modalPresentationStyle = .overFullScreen
            self.present(appHomeVC, animated: true)
            
        }
        email.textColor = .black
        password.textColor = .black
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        //need to add wrong password button
        print("poo")

        guard let email = email.text, !email.isEmpty,
              let password = password.text, !password.isEmpty
        else{
            print("missing field data")
            return
        }
        
        FirebaseAuth.Auth.auth().signIn( withEmail: email, password: password, completion: {[weak self] result, error in
            guard let strongSelf = self else {return}
            guard error == nil else{
                //say if pass wrong error here. look through user database, if this is already a user then say wrong password and return out of function here
                //look through what we have in firestore, is the email entered already there? if so give alert which says wrong password

                let db = Firestore.firestore()
                let barUsersCollection = db.collection("barUsers")

                barUsersCollection.whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        if let document = querySnapshot?.documents.first {
                            // Document with the specified email exists
                            print("Email found")

                            // Create the Firebase user
                            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                                if let error = error {
                                    print("Error creating user: \(error)")
                                } else {
                                    print("User created successfully")
                                    // You can perform additional actions here after user creation
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let appHomeVC = storyboard.instantiateViewController(identifier: "TabBarController")
                                    appHomeVC.modalPresentationStyle = .overFullScreen
                                    self?.present(appHomeVC, animated: true)
                                }
                            }
                        } else {
                            // No document with the specified email found
                            print("Not approved yet")
                            let alertController = UIAlertController(title: "Not Approved Yet", message: "If you've applied, you'll receive an email when you have been approved.", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                // Dismiss the alert and exit functions
                            }))

                            // Present the alert
                            self?.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
                

                return
                
            }
            //this is for normal login- they alr are signed in just set fcm token and take them to app home
            if let currentUser = Auth.auth().currentUser {
                print(currentUser.uid)
                let uid = currentUser.uid
                let userRef = Firestore.firestore().collection("users").document(uid)
                let data: [String: Any] = [
                    "fcmToken": userFcmToken
                ]
                
                userRef.updateData(data) { error in
                    if let error = error {
                        print("Error removing FCM token from Firestore: \(error.localizedDescription)")
                    } else {
                        print("FCM token removed from Firestore.")
                    }
                }
            }
            
            UserDefaults.standard.set(true, forKey: "authenticated")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appHomeVC = storyboard.instantiateViewController(identifier: "TabBarController")
            appHomeVC.modalPresentationStyle = .overFullScreen
            self?.present(appHomeVC, animated: true)
        })
        
        
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Reset Password", message: "Enter your email to receive a password reset link.", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Email"
        }
        
        let resetAction = UIAlertAction(title: "Reset", style: .default) { _ in
            guard let email = alertController.textFields?.first?.text, !email.isEmpty else {
                return
            }
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    print("Error sending password reset email: \(error)")
                    let failureAlert = UIAlertController(title: "Error", message: "This email may not be a user or invalid", preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    failureAlert.addAction(okayAction)
                    self.present(failureAlert, animated: true, completion: nil)
                    // Handle error and show appropriate message to the user
                } else {
                    print("Password reset email sent successfully")
                    let successAlert = UIAlertController(title: "Success", message: "Check your email for reset instructions.", preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    successAlert.addAction(okayAction)
                    self.present(successAlert, animated: true, completion: nil)
                    // Show a success message to the user
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    private func setupShowPasswordButton() {
        let showPasswordButton = UIButton(type: .custom)
        showPasswordButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        showPasswordButton.tintColor = .black
        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        showPasswordButton.addTarget(self, action: #selector(showPassword), for: .touchUpInside)
        view.addSubview(showPasswordButton)
        
        NSLayoutConstraint.activate([
            showPasswordButton.widthAnchor.constraint(equalToConstant: 20),
            showPasswordButton.heightAnchor.constraint(equalToConstant: 20),
            showPasswordButton.centerYAnchor.constraint(equalTo: password.centerYAnchor),
            showPasswordButton.trailingAnchor.constraint(equalTo: password.trailingAnchor, constant: -10)
        ])
    }
    
    // Function to toggle the visibility of the password text field
    @objc private func showPassword() {
        password.isSecureTextEntry = !password.isSecureTextEntry
    }
    
    // Your other methods and code
    
    
    
    func showCreateAccount(email: String, password: String){
        let alert = UIAlertController(title: "Create Account", message: "Would you like to create an account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "continue", style: .default, handler: {_ in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self] result, error in
                
                guard let strongSelf = self else {return}
                guard error == nil else{
                    print("failed")
                    self?.emailInvalid.isHidden = false
                    return
                }
                print("signed in")
                // Get a reference to the "users" collection
                //print(Auth.auth().currentUser!)
                let uid = Auth.auth().currentUser?.uid
                
                
                let i = email.firstIndex(of: "@")
                let username = email.substring(to: i!)
                UserDefaults.standard.set(username, forKey: "user_address")
                print(username)
                
                print(uid ?? String())
                let db = Firestore.firestore()
                
                // Get a reference to the "users" collection
                let usersCollection = db.collection("barUsers")
                
                // Add a new user to the "users" collection with some data
                usersCollection.document(uid!).setData([
                    "email": email,
                    "uid": uid!,
                    "images": [],
                    "bestFriends": [],
                    "friends": [],
                    "fcmToken": userFcmToken,
                    "pendingFriendRequests": [],
                    "spots": []
                    //"username": username
                ]) { (error) in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added successfully")
                    }
                }
                
                UserDefaults.standard.set(true, forKey: "authenticated")
                let alert = UIAlertController(title: "Congrats!", message: "Welcome to WTM!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                    alert.dismiss(animated: true) {
                        // Present the new view controller
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "CreateAccount")
                        vc.modalPresentationStyle = .overFullScreen
                        self?.present(vc, animated: true)
                    }
                }))
                self?.present(alert, animated: true, completion:  {
                    return
                })
                
                
                
                //switch view controller?
                /*
                 strongSelf.label.isHidden = true
                 strongSelf.emailField.isHidden = true
                 strongSelf.passwordField.isHidden = true
                 strongSelf.button.isHidden = true
                 */
            })
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: {_ in
        }))
        present(alert, animated: true)
    }
    private func setupConstraints() {
        // Logo at the top
        logo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logo.widthAnchor.constraint(equalToConstant: 240),
            logo.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Label below the logo
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 100)
        ])
        
        // Email text field
        email.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            email.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            email.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            email.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -70),
            email.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Password text field
        password.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            password.leadingAnchor.constraint(equalTo: email.leadingAnchor),
            password.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 20),
            password.widthAnchor.constraint(equalTo: email.widthAnchor, constant: -60),
            password.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Show password button
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: email.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: password.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Forgot password button
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotPasswordButton.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 20),
            forgotPasswordButton.leadingAnchor.constraint(equalTo: email.leadingAnchor),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: email.trailingAnchor)
        ])
        
        
        // Email invalid label
        emailInvalid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailInvalid.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailInvalid.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 20)
        ])
        
        // Motto at the bottom
    }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            emailInvalid.isHidden = true
            email.borderStyle = .roundedRect
            password.borderStyle = .roundedRect  // Add this line
            
            // Set the border color and width
            var placeholderText = "Enter School Email"
            var emailAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.lightGray,  // Set the desired color here
            ]
            var attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: emailAttributes)
            email.attributedPlaceholder = attributedPlaceholder
            email.layer.borderWidth = 2
            email.layer.borderColor = UIColor.black.cgColor
            // email.frame = CGRect(x: 20,y: label.frame.origin.y + label.frame.size.height + 10, width: view.frame.size.width - 40, height: 50)
            
            placeholderText = "Enter Password (6 character min)"
            var passAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.lightGray,  // Set the desired color here
            ]
            attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: passAttributes)
            password.attributedPlaceholder = attributedPlaceholder
            password.layer.borderWidth = 2
            password.layer.borderColor = UIColor.black.cgColor
            password.isSecureTextEntry = true
            //password.frame = CGRect(x: 20, y: email.frame.origin.y + email.frame.size.height + 10, width: view.frame.size.width - 100, height: 50)
            //button.frame = CGRect(x: -70 + view.frame.size.width, y: password.frame.origin.y, width: 50, height: 50)
            
        }
        
        /*
         
         if email.text?.isEmpty == true {
         print ("No text in email field")
         return
         } else if email.text!.contains(".edu") == false {
         print("This app currently only accepts UIUC students")
         let alert = UIAlertController(title: "Alert", message: "This app currently only accepts college students", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         present(alert, animated: true, completion:  {
         return
         })
         }
         else {
         UserDefaults.standard.set(true, forKey: "authenticated")
         signUP()
         }
         }*/
        /*
         func signUP() {
         
         // Create a reference to the Realtime Database
         let databaseRef = Database.database().reference()
         var username = ""
         
         if email.text != nil && email.text!.contains(".edu") == true{
         
         let i = email.text!.firstIndex(of: "@")
         username = email.text!.substring(to: i!)
         UserDefaults.standard.set(username, forKey: "user_address")
         
         }
         
         let newUserId = databaseRef.child("Users").childByAutoId().key ?? ""
         let newUserRef = databaseRef.child("Users").child(username)
         let newUser = [
         "email": (self.email.text)!
         ]
         newUserRef.setValue(newUser)
         
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let vc = storyboard.instantiateViewController(identifier: "TabBarController")
         vc.modalPresentationStyle = .overFullScreen
         self.present(vc, animated: true)
         
         }*/
        
        
        
}

    
    

