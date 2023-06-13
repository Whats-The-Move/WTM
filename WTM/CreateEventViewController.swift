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
    override func viewDidLoad() {
        super.viewDidLoad()

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
