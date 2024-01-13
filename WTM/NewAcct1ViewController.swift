//
//  NewAcct1ViewController.swift
//  WTM
//
//  Created by Aman Shah on 1/12/24.
//

import UIKit


class NewAcct1ViewController: UIViewController {
    var descriptionLabel: UILabel!
    var phone: UITextField!
    var backButton: UIButton!
    //var submitButton: UIButton!
    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let vc = NewAcctLandingViewController()
        
        backButton = vc.createBackButton()
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        
        descriptionLabel = vc.createLabel(text: "Enter your phone number", fontSize: 36)
        view.addSubview(descriptionLabel)
        
        phone = vc.createTextField(placeholder: "Phone", fontSize: 18, isSecure: false)
        view.addSubview(phone)



        
        setupConstraints()
        
        
        // Do any additional setup after loading the view.
    }
    
    func setupConstraints(){
        // Assuming you already have a descriptionLabel, email, password, and submitButton
        
        // Add the descriptionLabel, email, password, and submitButton to your view hierarchy
        
        // Set up constraints for the descriptionLabel
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
        
        // Set up constraints for the email text field

        NSLayoutConstraint.activate([
            phone.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            phone.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -96),
            phone.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            phone.heightAnchor.constraint(equalToConstant: 60),
        ])
        


        
    }
    @objc func nextTapped (){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CreateAccountStart")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CreateAccount2")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}
