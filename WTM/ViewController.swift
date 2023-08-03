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

    @IBOutlet var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var emailInvalid: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FirebaseAuth.Auth.auth().currentUser != nil {
            //TAKE PAST LOGIN SCREEN TO HOME SCREEN
            print("USER IS IN")
            UserDefaults.standard.set(FirebaseAuth.Auth.auth().currentUser?.email, forKey: "user_address")
            UserDefaults.standard.set(true, forKey: "authenticated")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appHomeVC = storyboard.instantiateViewController(identifier: "AppHome")
            appHomeVC.modalPresentationStyle = .overFullScreen
            self.present(appHomeVC, animated: true)


        }
        let authenticated = UserDefaults.standard.bool(forKey: "authenticated")
        if authenticated {
            print("USER IS IN")

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appHomeVC = storyboard.instantiateViewController(identifier: "AppHome")
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
        if email.text!.contains(".edu") == false {
            print("it says use SCHOOL email")
            let alert = UIAlertController(title: "Alert", message: "It says use SCHOOL email dumbass", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sorry I won't do it again", style: .default, handler: nil))
            present(alert, animated: true, completion:  {
                return
            })
            
        return
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
                UserDefaults.standard.set(true, forKey: "authenticated")

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
                          let alert = UIAlertController(title: "Alert", message: "Wrong password", preferredStyle: .alert)
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
                        strongSelf.showCreateAccount(email: email, password: password)
                        
                    }
                  }
                }
                 return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "TabBarController")
                        vc.modalPresentationStyle = .overFullScreen
            self?.present(vc, animated: true)
        })


    }
    
    func showCreateAccount(email: String, password: String){
        let alert = UIAlertController(title: "Create Account", message: "Would you like to create an account", preferredStyle: .alert)
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
                let usersCollection = db.collection("users")

                // Add a new user to the "users" collection with some data
                usersCollection.document(uid!).setData([
                    "email": email,
                    "uid": uid!,
                    "images": [],
                    "bestFriends": [],
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
                let alert = UIAlertController(title: "Congrats!", message: "You've just sold your soul to a lifetime of degeneracy and alcoholism!", preferredStyle: .alert)
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emailInvalid.isHidden = true
        email.borderStyle = .roundedRect

        // Set the border color and width
        var placeholderText = "Enter School Email"
        var emailAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray,  // Set the desired color here
        ]
        var attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: emailAttributes)
        email.attributedPlaceholder = attributedPlaceholder
        email.layer.borderWidth = 2
        email.layer.borderColor = UIColor.black.cgColor
        email.frame = CGRect(x: 20,
                                  y: label.frame.origin.y + label.frame.size.height + 10,
                                  width: view.frame.size.width - 40,
                                  height: 50)
        
        placeholderText = "Enter Password (6 character min)"
        var passAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray,  // Set the desired color here
        ]
        attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: passAttributes)
        password.attributedPlaceholder = attributedPlaceholder
        password.layer.borderWidth = 2
        password.layer.borderColor = UIColor.black.cgColor
        password.isSecureTextEntry = true
        password.frame = CGRect(x: 20, y: email.frame.origin.y + email.frame.size.height + 10, width: view.frame.size.width - 100, height: 50)
        button.frame = CGRect(x: -70 + view.frame.size.width, y: password.frame.origin.y, width: 50, height: 50)




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

     

