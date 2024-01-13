//
//  NewAcctLandingViewController.swift
//  WTM
//
//  Created by Aman Shah on 1/12/24.
//

import UIKit

class NewAcctLandingViewController: UIViewController {
    
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
        
        
        
        
        
        
        descriptionLabel = createLabel(text: "Enter your school email and password.", fontSize: 36)
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16), // Adjust as needed
            descriptionLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10), // Adjust as needed
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 120),
        ])
        
        
        
        email = createTextField(placeholder: "partygoer@college.edu", fontSize: 18)
        view.addSubview(email)

        NSLayoutConstraint.activate([
            email.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            email.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -96),
            email.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            email.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        
        
        password = createTextField(placeholder: "Password (6 char minimum)", fontSize: 18, isSecure: true)
        view.addSubview(password)

        NSLayoutConstraint.activate([
            password.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            password.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 18),
            password.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            password.heightAnchor.constraint(equalToConstant: 60),
        ])

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
    

    
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func nextTapped() {
        let newAcct1VC = NewAcct1ViewController()
        newAcct1VC.modalPresentationStyle = .overFullScreen
        present(newAcct1VC, animated: true)
    }
    @IBAction func continuePressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CreateAccount1")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}



//*******

