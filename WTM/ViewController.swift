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
        email.textColor = .black
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
            UserDefaults.standard.set(true, forKey: "authenticated")
            signUP()
        }
    }
    
    func signUP() {
            
            // Create a reference to the Realtime Database
            let databaseRef = Database.database().reference()
            var username = ""
            
        if email.text != nil && email.text!.contains("illinois.edu") == true{
            let i = email.text!.firstIndex(of: "@")
            username = email.text!.substring(to: i!)
            }

            // Listen for new user creation events in Firebase Authentication
        if email.text != nil && email.text!.contains("illinois.edu") == true {
                Auth.auth().addStateDidChangeListener { (auth, user) in
                    if let user = user {
                        // A new user has signed up
                        // Create a new user in the Realtime Database
                        let userRef = databaseRef.child("Users").child(username)
                        let userData = [
                            "name": (self.email.text)!
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

