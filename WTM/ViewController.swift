//
//  ViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 1/21/23.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseFirestore



class ViewController: UIViewController {

    var barAcct = false
    var email: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "Enter school email"

        textField.font = UIFont(name: "Futura-Medium", size: 18)
        textField.textColor = .gray
        textField.backgroundColor = .gray
        textField.layer.cornerRadius = 8.0
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Light gray
        textField.autocapitalizationType = .none

        // Add any additional constraints as needed
        return textField
    }()

    var password: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password (6 char minimum)"
        textField.font = UIFont(name: "Futura-Medium", size: 18)
        textField.textColor = .gray
        textField.isSecureTextEntry = true
        textField.backgroundColor = .gray
        textField.layer.cornerRadius = 8.0
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Light gray
        textField.autocapitalizationType = .none

        // Add any additional constraints as needed
        return textField
    }()

    var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont(name: "Futura-Medium", size: 14)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        // Add any additional constraints as needed
        return button
    }()

    var logo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "WTM_")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Add any additional constraints as needed
        return imageView
    }()

    var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0)
        button.layer.cornerRadius = 8.0
        button.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "Futura-Medium", size: 18)


        return button
    }()

    var backButton: UIButton = {
        let button = UIButton()
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysTemplate)
        button.setImage(backImage, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15 // half of the desired height
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Button Actions



    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Add the backButton to your view hierarchy, then apply these constraints
        view.addSubview(backButton)
        view.addSubview(email)
        view.addSubview(password)

        view.addSubview(button)
        view.addSubview(forgotPasswordButton)
        view.addSubview(logo)
        if barAcct{
            email.placeholder = "Enter email"

        }

        // Constraints
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        
        
        KeyboardManager.shared.enableTapToDismiss()
        setupShowPasswordButton()
        setupConstraints()
        
        email.layer.cornerRadius = 8
        password.layer.cornerRadius = 8
        email.clipsToBounds = true
        password.clipsToBounds = true


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
        if !barAcct{
            if email.text!.contains(".edu") == false {
                print("it says use SCHOOL email")
                let alert = UIAlertController(title: "Alert", message: "Please use your school (.edu) email.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Sorry, I won't do it again.", style: .default, handler: nil))
                present(alert, animated: true, completion:  {
                    return
                })
                
                return
            }
        }
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
                let usersCollection = db.collection("users")
                usersCollection.whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        // Handle the error
                        print("Error getting documents: \(error)")
                    } else {
                        // Check if the query returned any documents
                        if let document = querySnapshot?.documents.first {
                            // Document exists with the given email
                            print("email already exists, wrong password")
                            UserDefaults.standard.set(false, forKey: "authenticated")
                            let alert = UIAlertController(title: "Alert", message: "Wrong password.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Sorry, I'll get it right this time", style: .default, handler: nil))
                            self?.present(alert, animated: true, completion:  {
                                return
                            })
                            //exit everything, wrong password happened
                            return
                            
                            
                            print("Document data: \(document.data())")
                        } else {
                            // No document exists with the given email, make new account
                            print("Document does not exist")
                            UserDefaults.standard.set(false, forKey: "partyAccount")
                            
                            UserDefaults.standard.set(true, forKey: "authenticated")
                            //strongSelf.showCreateAccount(email: email, password: password)
                            
                        }
                    }
                }
                return
            }
            
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
            UserDefaults.standard.set(false, forKey: "partyAccount")

            UserDefaults.standard.set(true, forKey: "authenticated")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appHomeVC = storyboard.instantiateViewController(identifier: "TabBarController")
            appHomeVC.modalPresentationStyle = .overFullScreen
            self?.present(appHomeVC, animated: true)
        })


    }
    
    @objc func forgotPasswordTapped() {
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


    /*
    func showCreateAccount(email: String, password: String){
        let alert = UIAlertController(title: "Create Account", message: "Would you like to create an account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "continue", style: .default, handler: {_ in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self] result, error in
                
                    guard let strongSelf = self else {return}
                    guard error == nil else{
                        print("failed")
                        //self?.emailInvalid.isHidden = false
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
                let usersCollection = db.collection("users")

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
    }*/
    
    private func setupConstraints() {
        // Logo at the top
        logo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            logo.widthAnchor.constraint(equalToConstant: 150),
            logo.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Label below the logo

        
        // Email text field
        email.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            email.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            email.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 20),
            email.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -70),
            email.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        // Password text field
        password.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            password.leadingAnchor.constraint(equalTo: email.leadingAnchor),
            password.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 15),
            password.widthAnchor.constraint(equalTo: email.widthAnchor),
            password.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        // Show password button

        
        // Forgot password button
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            forgotPasswordButton.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            forgotPasswordButton.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 15),
            forgotPasswordButton.widthAnchor.constraint(equalToConstant: 120),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 15),
            button.widthAnchor.constraint(equalTo: email.widthAnchor),
            button.heightAnchor.constraint(equalToConstant: 45)
        ])


        
        // Email invalid label

        
        // Motto at the bottom

    }

    @objc func backButtonTapped() {
        // Handle back button tap
        dismiss(animated: true, completion: nil)
    }

   
  
    
}

class KeyboardManager {
    static let shared = KeyboardManager()

    private var tapGesture: UITapGestureRecognizer!
    
    private init() {
        // Initialize tap gesture recognizer to dismiss keyboard when tapping outside of text fields
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        tapGesture.isEnabled = false
        UIApplication.shared.keyWindow?.addGestureRecognizer(tapGesture)
        
        // Observe keyboard show/hide notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Call this method to enable keyboard dismissal on tap outside of text fields
    func enableTapToDismiss() {
        tapGesture.isEnabled = true
    }
    
    @objc private func handleTap() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        tapGesture.isEnabled = true
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        tapGesture.isEnabled = false
    }
}

     

