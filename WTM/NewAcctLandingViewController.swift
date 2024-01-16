//
//  NewAcctLandingViewController.swift
//  WTM
//
//  Created by Aman Shah on 1/12/24.
//

import UIKit
import FirebaseFirestore

class NewAcctLandingViewController: UIViewController, UITextFieldDelegate {
    var descriptionLabel: UILabel!
    var email: UITextField!
    var password: UITextField!
    var submitButton: UIButton!
    var backButton: UIButton!
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        //button setup
        
        
        
        backButton = createBackButton()
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        
        
        
        
        
        descriptionLabel = createLabel(text: "Enter your school email and password", fontSize: 36)
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16), // Adjust as needed
            descriptionLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10), // Adjust as needed
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 120),
        ])
        
        
        
        email = createTextField(placeholder: "partygoer@college.edu", fontSize: 18)
        view.addSubview(email)
        email.overrideUserInterfaceStyle = .light

        NSLayoutConstraint.activate([
            email.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            email.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -96),
            email.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            email.heightAnchor.constraint(equalToConstant: 60),
        ])
        email.delegate = self
        
        
        
        password = createTextField(placeholder: "Password (6 char minimum)", fontSize: 18, isSecure: true)
        view.addSubview(password)
        password.overrideUserInterfaceStyle = .light

        NSLayoutConstraint.activate([
            password.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            password.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 18),
            password.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            password.heightAnchor.constraint(equalToConstant: 60),
        ])
        password.delegate = self
        setupShowPasswordButton()


        /*
        submitButton = createButton(title: "Continue", bgColor: UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1))
        view.addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            submitButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 18),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            submitButton.heightAnchor.constraint(equalToConstant: 100),
        ])*/
        

    }
    
    func createLabel(text: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "Futura-Medium", size: fontSize)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }
    
    func createTextField(placeholder: String, fontSize: CGFloat, isSecure: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont(name: "Futura-Medium", size: fontSize)
        textField.textColor = .gray
        textField.isSecureTextEntry = isSecure
        textField.backgroundColor = .gray
        textField.layer.cornerRadius = 8.0
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        textField.autocapitalizationType = .none
        textField.clipsToBounds = true
        return textField
    }
    
    func createButton(title: String, bgColor: UIColor) -> UIButton {
        let submitButton = UIButton(type: .system)
        submitButton.setTitle(title, for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = bgColor
        submitButton.layer.cornerRadius = 8.0
        submitButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        submitButton.titleLabel?.font = UIFont(name: "Futura-Medium", size: 18)
        return submitButton
    }


    func createBackButton() -> UIButton {
        let submitButton = UIButton()
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysTemplate)
        submitButton.setImage(backImage, for: .normal)
        submitButton.tintColor = .black
        submitButton.backgroundColor = .clear
        submitButton.layer.cornerRadius = 15
        submitButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        return submitButton
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
    

    
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func nextTapped() {

    }
    @IBAction func continuePressed(_ sender: Any) {
        guard let email = email.text, !email.isEmpty,
              let password = password.text, !password.isEmpty
                
                
        else{
            print("missing field data")
            let alert = UIAlertController(title: "Alert", message: "Fill the blanks", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sorry I won't do it again", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
            return
        }
        
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
                    let alert = UIAlertController(title: "Alert", message: "Account already exists", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion:  {
                        return
                    })
                    //exit everything, wrong password happened
                    
    
                }
                else{
                    //email does not exist
                    if email.contains(".edu") == false {
                        print("it says use SCHOOL email")
                        let alert = UIAlertController(title: "Alert", message: "Please use your school (.edu) email.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Sorry, I won't do it again.", style: .default, handler: nil))
                        self.present(alert, animated: true, completion:  {
                            return
                        })
                        
                    return
                    }
                    if self.isPasswordValid(password) == false {
                        let alert = UIAlertController(title: "Alert", message: "Password invalid. Must contain uppercase, lowercase, and numbers", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Sorry, I won't do it again.", style: .default, handler: nil))
                        self.present(alert, animated: true, completion:  {
                            return
                        })
                    return
                    }
                    
                    
                    createEmail = email
                    createPassword = password
                    if email.hasSuffix("@illinois.edu") {
                        currCity = "Champaign"
                    } else if email.hasSuffix("@berkeley.edu") {
                        currCity = "Berkeley"
                    } else {
                        currCity = ""
                    }
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "CreateAccount1")
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true)

                }
            }
        }
 
    
    
    }
    func isPasswordValid(_ password: String) -> Bool {
        // Check if the password is at least 6 characters long
        guard password.count >= 6 else {
            return false
        }

        // Check if the password contains at least one uppercase letter
        let uppercaseLetterRegex = ".*[A-Z]+.*"
        let uppercaseLetterTest = NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex)
        guard uppercaseLetterTest.evaluate(with: password) else {
            return false
        }

        // Check if the password contains at least one lowercase letter
        let lowercaseLetterRegex = ".*[a-z]+.*"
        let lowercaseLetterTest = NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegex)
        guard lowercaseLetterTest.evaluate(with: password) else {
            return false
        }

        // Check if the password contains at least one numeric digit
        let numericDigitRegex = ".*[0-9]+.*"
        let numericDigitTest = NSPredicate(format: "SELF MATCHES %@", numericDigitRegex)
        guard numericDigitTest.evaluate(with: password) else {
            return false
        }

        // All criteria met
        return true
    }
    

}



//*******

