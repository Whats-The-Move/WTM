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
    var rating: Int
    var date: Double
}

class reviewViewController: UIViewController {
    var titleText: String = ""
    
    var reviews: [Reviews] = []

    @IBOutlet weak var backgroundTableView: UIView!
    @IBOutlet weak var submitReview: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var avgStars: UILabel!
    
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
    var avg = 0.0
    
    @IBOutlet weak var reviewList: UITableView! {
        didSet {
            reviewList.dataSource = self
        }
    }
    
    var databaseRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

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
            var totalRating = 0
            var reviewCount = 0
            for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let reviewDict = childSnapshot.value as? [String:Any]{
                        print(reviewDict)
                        let comment = reviewDict["comment"] as? String
                       let date = reviewDict["date"] as? Double
                       let rating = reviewDict["rating"] as? Int
                        let review = Reviews(reviewText: comment, rating: rating ?? 5, date: date ?? 1682310604178)
                        if let rating = reviewDict["rating"] as? Int {
                            totalRating += rating
                            reviewCount += 1
                        }
                        self.reviews.insert(review, at: 0)
                    }
            }
            
            if reviewCount != 0 {
                self.avg = Double(totalRating) / Double(reviewCount)
                
            }

            
                self.avg = round(self.avg * 10) / 10.0
                self.databaseRef = Database.database().reference().child("Parties").child(self.titleText)
                self.databaseRef?.child("avgStars").setValue(self.avg)
            print("self.avg is " + String(self.avg))
           self.avgStars.text = String(self.avg)
            
            

            
            self.reviewList.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        // Calculate the height of the keyboard
        let keyboardHeight = keyboardFrame.size.height
        
        // Adjust the view's frame to move the text field above the keyboard
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -keyboardHeight
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        // Restore the original position of the view
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func submitReviewTapped(_ sender: Any) {
        let uuid = UUID().uuidString
        let randomString = String(uuid.prefix(8))
        var databaseRef = Database.database().reference()
        let review = textField.text
        let Dateobj = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        //let currentDate = formatter.string(from: Dateobj)
        let currentDate = ServerValue.timestamp()
        let reviewDict = [
            "comment": review,
            "rating": rating,
            "date": currentDate
        ] as [String : Any]

        //let newUserId = databaseRef.child("Parties").child(titleText).child("Reviews").childByAutoId().key ?? ""
        let newUserRef = databaseRef.child("Parties").child(titleText).child("Reviews")
        let newReviewRef = newUserRef.childByAutoId()
        newReviewRef.setValue(reviewDict) { (error, ref) in
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
    func timeAgoString(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: (timestamp - 1000)/1000 )
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .numeric
        return formatter.localizedString(for: date, relativeTo: Date())
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let review = reviews[indexPath.row]
       

        let reviewDate = review.date
        let timeString = timeAgoString(from: reviewDate )
        
        
        cell.textLabel?.text = timeString + ": " + (review.reviewText ??  "")
        return cell
    }
}
