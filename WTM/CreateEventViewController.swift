//
//  CreateEventViewController.swift
//  WTM
//
//  Created by Aman Shah on 6/13/23.
//

import UIKit

class CreateEventViewController: UIViewController {
    @IBOutlet weak var bkgdView: UIView!
    
    @IBOutlet weak var dateAndTime: UIDatePicker!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    
    @IBOutlet weak var inviteesText: UITextView!
    var selectedUsers: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(inviteesTapped))
             inviteesText.addGestureRecognizer(tapGestureRecognizer)
             inviteesText.isUserInteractionEnabled = true
        let selectedUserNames = selectedUsers.map { $0.name }
           inviteesText.text = selectedUserNames.joined(separator: ", ")
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        descriptionText.isEditable = true
        descriptionText.text = "Description/details"
        descriptionText.textAlignment = .left
        descriptionText.font = UIFont.systemFont(ofSize: 16)
        descriptionText.layer.cornerRadius = 8
        bkgdView.layer.cornerRadius = 8
        dateAndTime.layer.cornerRadius = 8
    }
    @objc func inviteesTapped() {
        let party = Party(name: "Joes", likes: 0, dislikes: 0, allTimeLikes: 0, allTimeDislikes: 0, address: "5", rating: 3, isGoing: [""])
        // Create an instance of friendsGoingViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let InviteListVC = storyboard.instantiateViewController(withIdentifier: "InviteList") as! InviteListViewController
        
        // Pass the selected party object
        InviteListVC.selectedParty = party
        
        InviteListVC.modalPresentationStyle = .overFullScreen
        
        // Present the friendsGoingVC modally
        present(InviteListVC, animated: true, completion: nil)
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
