//
//  ProfileViewController.swift
//  WTM
//
//  Created by Aman Shah on 2/26/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ProfileViewController: UIViewController {
//    @IBOutlet weak var userbox: UILabel!
    @IBOutlet weak var userbox: UILabel!
    @IBOutlet weak var emailbox: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user_address1 = UserDefaults.standard.string(forKey: "user_address") ?? "none"
        userbox.text =  "username: " + user_address1
        var email_address1 = user_address1 + "@illinois.edu"
        emailbox.text =  "email: " + email_address1

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
