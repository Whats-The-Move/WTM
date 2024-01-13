//
//  NewAcct3ViewController.swift
//  WTM
//
//  Created by Aman Shah on 1/12/24.
//

import UIKit

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
    }
    

    
}
