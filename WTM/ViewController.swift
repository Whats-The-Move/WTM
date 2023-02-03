//
//  ViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 1/21/23.
//

import UIKit
import FirebaseAuth
import Firebase

class ViewController: UIViewController {

    @IBOutlet var email: UITextField!
    
    override func viewDidLoad() {
            super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signInTapped(_ sender: Any) {
        if email.text?.isEmpty == true {
            print ("No text in email field")
            return
        } else if email.text!.contains("illinois.edu") == false {
            print("This app currently only accepts UIUC students")
            let alert = UIAlertController(title: "Alert", message: "This app currently only accepts UIUC students", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
        }
        else {
            signUP()
        }
    }
    
    func signUP() {
        Auth.auth().createUser(withEmail: email.text!, password: "12345678") { (authResult, error) in

            guard let user = authResult?.user, error == nil else {
                print("Error \(error?.localizedDescription)")
                return
            }
            
            // Create a reference to the Realtime Database
            let databaseRef = Database.database().reference()
            var username = ""
            
            if user.email != nil && user.email!.contains("illinois.edu") == true{
                let i = user.email!.firstIndex(of: "@")
                username = user.email!.substring(to: i!)
            }

            // Listen for new user creation events in Firebase Authentication
            if user.email != nil && user.email!.contains("illinois.edu") == true {
                Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        // A new user has signed up
                        // Create a new user in the Realtime Database
                        let userRef = databaseRef.child("Users").child(username)
                        let userData = [
                            "name": (user.email)!,
                            "votes": 5
                        ] as [String : Any]
                        userRef.setValue(userData)
                    }
                }
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "AppHome")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }

}

