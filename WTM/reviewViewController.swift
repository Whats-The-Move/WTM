//
//  reviewViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 3/15/23.
//

import UIKit
import FirebaseDatabase
import Foundation

struct Reviews {
    var reviewText: String?
}

class reviewViewController: UIViewController {
    var titleText: String = ""
    
    var reviews: [Reviews] = []

    @IBOutlet weak var backgroundTableView: UIView!
    @IBOutlet weak var submitReview: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var reviewList: UITableView! {
        didSet {
            reviewList.dataSource = self
        }
    }
    
    var databaseRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleText + " Reviews"
        
        popUpView.layer.cornerRadius = 8
        backgroundTableView.layer.cornerRadius = 8
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        print(titleText)
        
        reviews.removeAll()
        reviewList.reloadData()
        
        databaseRef = Database.database().reference().child("Parties").child(titleText).child("Reviews")
        databaseRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let reviewText = childSnapshot.value as? String {
                    let review = Reviews(reviewText: reviewText)
                    self.reviews.insert(review, at: 0)
                }
            }
            self.reviewList.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitReviewTapped(_ sender: Any) {
        let uuid = UUID().uuidString
        let randomString = String(uuid.prefix(8))
        let databaseRef = Database.database().reference()
        let review = textField.text
        //let newUserId = databaseRef.child("Parties").child(titleText).child("Reviews").childByAutoId().key ?? ""
        let newUserRef = databaseRef.child("Parties").child(titleText).child("Reviews")
        let newReviewRef = newUserRef.childByAutoId()
        newReviewRef.setValue(review) { (error, ref) in
                if let error = error {
                    print("Error adding review: \(error.localizedDescription)")
                } else {
                    print("Review added successfully.")
                    self.textField.text = ""
                }
            }
        
        viewDidLoad()
    }
}

extension reviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let review = reviews[indexPath.row]
        cell.textLabel?.text = review.reviewText
        return cell
    }
}
