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
    
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    // Unselected and selected star images
    let unselectedStarImage = UIImage(systemName: "star")
    let selectedStarImage = UIImage(systemName: "star.fill")

   // The selected rating (initially 0, indicating no rating selected yet)
   var rating = 0
    
    @IBOutlet weak var reviewList: UITableView! {
        didSet {
            reviewList.dataSource = self
        }
    }
    
    var databaseRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        star1.setImage(unselectedStarImage, for: .normal)
        star2.setImage(unselectedStarImage, for: .normal)
        star3.setImage(unselectedStarImage, for: .normal)
        star4.setImage(unselectedStarImage, for: .normal)
        star5.setImage(unselectedStarImage, for: .normal)
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
        
        let alert = UIAlertController(title: "Alert", message: "thanks for the input... not a single mf asked", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion:  {
            return
        })
        viewDidLoad()
    }

    @IBAction func star1Tapped(_ sender: Any) {
        star1.setImage(selectedStarImage, for: .normal)
        star2.setImage(unselectedStarImage, for: .normal)
        star3.setImage(unselectedStarImage, for: .normal)
        star4.setImage(unselectedStarImage, for: .normal)
        star5.setImage(unselectedStarImage, for: .normal)
       // Update the rating variable to reflect the user's selection
       rating = 1
        print("star1")
        
    }
    
    @IBAction func star2Tapped(_ sender: Any) {
        star1.setImage(selectedStarImage, for: .normal)
        star2.setImage(selectedStarImage, for: .normal)
        star3.setImage(unselectedStarImage, for: .normal)
        star4.setImage(unselectedStarImage, for: .normal)
        star5.setImage(unselectedStarImage, for: .normal)
       // Update the rating variable to reflect the user's selection
       rating = 2
        print("star2")
    }
    
    @IBAction func star3Tapped(_ sender: Any) {
        star1.setImage(selectedStarImage, for: .normal)
        star2.setImage(selectedStarImage, for: .normal)
        star3.setImage(selectedStarImage, for: .normal)
        star4.setImage(unselectedStarImage, for: .normal)
        star5.setImage(unselectedStarImage, for: .normal)
       // Update the rating variable to reflect the user's selection
       rating = 3
        print("star3")
    }
    
    @IBAction func star4Tapped(_ sender: Any) {
        star1.setImage(selectedStarImage, for: .normal)
        star2.setImage(selectedStarImage, for: .normal)
        star3.setImage(selectedStarImage, for: .normal)
        star4.setImage(selectedStarImage, for: .normal)
        star5.setImage(unselectedStarImage, for: .normal)
       // Update the rating variable to reflect the user's selection
       rating = 4
        print("star4")
    }
    
    
    @IBAction func star5Tapped(_ sender: Any) {
        star1.setImage(selectedStarImage, for: .normal)
        star2.setImage(selectedStarImage, for: .normal)
        star3.setImage(selectedStarImage, for: .normal)
        star4.setImage(selectedStarImage, for: .normal)
        star5.setImage(selectedStarImage, for: .normal)
       // Update the rating variable to reflect the user's selection
       rating = 5
        print("star5")
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
