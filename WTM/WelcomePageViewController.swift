//
//  WelcomePageViewController.swift
//  WTM
//
//  Created by Aman Shah on 1/11/24.
//

import UIKit

class WelcomePageViewController: UIViewController {

    // UI Elements
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome!"
        label.font = UIFont(name: "Futura-Medium", size: 36)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    let signInDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in or create a new account"
        label.font = UIFont(name: "Futura-Medium", size: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center

        return label
    }()

    let welcomePicImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "WelcomePic"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = UIFont(name: "Futura-Medium", size: 18)
        button.backgroundColor = UIColor(red: 255/255, green: 28/255, blue: 142/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let fratBarButton: UIButton = {
        let button = UIButton()
        let attributedString = NSMutableAttributedString(string: "Frat, Bar, or Club? ")
        attributedString.append(NSAttributedString(string: "Click here", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 255/255, green: 28/255, blue: 142/255, alpha: 1)]))
        button.setAttributedTitle(attributedString, for: .normal)
        button.titleLabel?.font = UIFont(name: "Futura-Medium", size: 16)
        button.titleLabel?.textColor = .gray
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(fratBarTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let signUpButton: UIButton = {
        let button = UIButton()
        let attributedString = NSMutableAttributedString(string: "No account yet? ")
        attributedString.append(NSAttributedString(string: "Sign up", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 255/255, green: 28/255, blue: 142/255, alpha: 1)]))
        button.setAttributedTitle(attributedString, for: .normal)
        button.titleLabel?.font = UIFont(name: "Futura-Medium", size: 16)
        button.titleLabel?.textColor = .gray
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1
        return button
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(welcomeLabel)
        view.addSubview(signInDescriptionLabel)
        view.addSubview(welcomePicImageView)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(fratBarButton)

        // Set width and height anchors
        NSLayoutConstraint.activate([
            welcomeLabel.widthAnchor.constraint(equalToConstant: 250),
            welcomeLabel.heightAnchor.constraint(equalToConstant: 50),
            
            signInDescriptionLabel.widthAnchor.constraint(equalToConstant: 250),
            signInDescriptionLabel.heightAnchor.constraint(equalToConstant: 50),
            
            welcomePicImageView.widthAnchor.constraint(equalToConstant: 270),
            welcomePicImageView.heightAnchor.constraint(equalToConstant: 270),
            
            signInButton.widthAnchor.constraint(equalToConstant: 310),
            signInButton.heightAnchor.constraint(equalToConstant: 45),
            
            signUpButton.widthAnchor.constraint(equalToConstant: 310),
            signUpButton.heightAnchor.constraint(equalToConstant: 45),
            fratBarButton.widthAnchor.constraint(equalToConstant: 310),
            fratBarButton.heightAnchor.constraint(equalToConstant: 45)
        ])

        // Center everything on the X-axis
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomePicImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fratBarButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // Add vertical constraints
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            signInDescriptionLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 14),
            welcomePicImageView.topAnchor.constraint(equalTo: signInDescriptionLabel.bottomAnchor, constant: 60),
            signInButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -160),
            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 15),
            fratBarButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 5)
        ])
    }

    // MARK: - Button Actions

    @objc func signInButtonTapped() {
        let vc = storyboard?.instantiateViewController(identifier: "SignUpPage")
        vc?.modalPresentationStyle = .overFullScreen
        self.present(vc!, animated: true)
    }

    @objc func signUpButtonTapped() {
        /*let newAcct1VC = NewAcctLandingViewController()
        newAcct1VC.modalPresentationStyle = .overFullScreen
        present(newAcct1VC, animated: true)
        */
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CreateAccountStart")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    @objc func fratBarTapped() {
        //todo
        /*let newAcct1VC = NewAcctLandingViewController()
        newAcct1VC.modalPresentationStyle = .overFullScreen
        present(newAcct1VC, animated: true)
        */
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CreatePartyAcct")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}

