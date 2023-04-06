//
//  PartyAcctViewController.swift
//  WTM
//
//  Created by Aman Shah on 4/5/23.
//

import UIKit

class PartyAcctViewController: UIViewController {
 
    @IBOutlet weak var partyName: UITextField!
    @IBOutlet weak var personName: UITextField!
    @IBOutlet weak var contactEmail: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLayoutSubviews()
        
        


        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        partyName.placeholder = "Name of Frat/Bar/Party"
        personName.placeholder = "Name of Person who is point of contact"
        contactEmail.placeholder = "Email address of primary contact"
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
