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
        let inviteListVC = storyboard?.instantiateViewController(withIdentifier: "InviteList") as! InviteListViewController
           inviteListVC.didSelectUsers = { [weak self] users in
               // Update inviteesText with the names of the selected users
               let names = users.map { $0.name }
               self?.inviteesText.text = names.joined(separator: ", ")
           }
           present(inviteListVC, animated: true, completion: nil)
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
