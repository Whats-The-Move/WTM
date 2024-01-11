import Foundation
import Kingfisher
import UIKit
import Firebase
import FirebaseDatabase

class InviteCellClass: UITableViewCell {

    var profileImageView: UIImageView!
    var nameLabel: UILabel!
    var checkButton: UIButton!
    var crossButton: UIButton!
    var inviteValue: String?
    var inviteKey: String?
    var undoButton: UIButton!
    var eventsDatabaseRef: DatabaseReference?
    var oldNameLabel: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        oldNameLabel = ""
        setupProfileImageView()
        setupButtons()
        setupNameLabel()
        setupUndoButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupProfileImageView() {
        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileImageView)

        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func setupNameLabel() {
        nameLabel = UILabel()
        nameLabel.font = UIFont(name: "Futura-Medium", size: 16)
        nameLabel.numberOfLines = 0 // Allow multiple lines
        nameLabel.lineBreakMode = .byWordWrapping // Enable word wrapping
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkButton.leadingAnchor, constant: -10)
        ])
    }
    
    func setupButtons() {
        // Check Button
        checkButton = UIButton(type: .system)
        checkButton.setTitle("✅", for: .normal)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        contentView.addSubview(checkButton)

        // Cross Button
        crossButton = UIButton(type: .system)
        crossButton.setTitle("❌", for: .normal)
        crossButton.translatesAutoresizingMaskIntoConstraints = false
        crossButton.addTarget(self, action: #selector(crossButtonTapped), for: .touchUpInside)
        contentView.addSubview(crossButton)

        // Set up constraints for buttons
        NSLayoutConstraint.activate([
            crossButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            crossButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            checkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkButton.trailingAnchor.constraint(equalTo: crossButton.leadingAnchor, constant: -10)
        ])
    }
    
    func setupUndoButton() {
        undoButton = UIButton(type: .system)
        undoButton.setTitle("Undo", for: .normal)
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.addTarget(self, action: #selector(undoButtonTapped), for: .touchUpInside)
        contentView.addSubview(undoButton)

        // Set up constraints for the undo button
        NSLayoutConstraint.activate([
            undoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            undoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])

        // Initially hide the undo button
        undoButton.isHidden = true
    }

    @objc func checkButtonTapped() {
        guard let inviteKey = inviteKey, let eventsDatabaseRef = eventsDatabaseRef else {
            print("Invite key or eventsDatabaseRef is nil")
            return
        }
        
        print("invite Value: " + inviteValue!)
        
        if let currentUserUID = Auth.auth().currentUser?.uid {
            eventsDatabaseRef.observeSingleEvent(of: .value) { (snapshot) in
                for dateSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                    let date = dateSnapshot.key
                    
                    // Iterate through event IDs under each date
                    for eventSnapshot in dateSnapshot.children.allObjects as! [DataSnapshot] {
                        let eventID = eventSnapshot.key

                        // Check if the current eventID matches the inviteKey
                        if eventID == self.inviteValue {
                            let isGoingSnapshot = eventSnapshot.childSnapshot(forPath: "isGoing")

                            // Check if isGoing branch exists
                            if let isGoingDict = isGoingSnapshot.value as? [String: Any] {
                                var isGoing = isGoingDict.compactMap { $0.value as? String }
                                // isGoing branch exists, update it
                                isGoing.append(currentUserUID)
                                isGoingSnapshot.ref.setValue(isGoing)
                            } else {
                                // isGoing branch does not exist, create it
                                let isGoing = [currentUserUID]
                                isGoingSnapshot.ref.setValue(isGoing)
                            }

                            print("User data updated successfully")
                            self.nameLabel.text = "You successfully accepted the invite"
                            self.checkButton.isHidden = true
                            self.crossButton.isHidden = true
                            return
                        }
                    }
                }
                print("Event ID not found in any date")
            }
        } else {
            print("Current user not authenticated")
        }
    }

    @objc func crossButtonTapped() {
        guard let inviteKey = inviteKey, let eventsDatabaseRef = eventsDatabaseRef else {
            print("Invite key or eventsDatabaseRef is nil")
            return
        }

        if let currentUserUID = Auth.auth().currentUser?.uid {
            eventsDatabaseRef.observeSingleEvent(of: .value) { [self] (snapshot) in
                for dateSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                    for eventSnapshot in dateSnapshot.children.allObjects as! [DataSnapshot] {
                        let eventID = eventSnapshot.key

                        if eventID == self.inviteValue {
                            // Update the invites map in Firestore to remove the specific partyID
                            let db = Firestore.firestore()
                            let userDocRef = db.collection("users").document(currentUserUID)

                            userDocRef.updateData([
                                "invites.\(inviteKey)": FieldValue.arrayRemove([inviteValue])
                            ]) { error in
                                if let error = error {
                                    print("Error updating user data: \(error.localizedDescription)")
                                } else {
                                    print("User data updated successfully")
                                }
                            }

                            self.nameLabel.text = "You rejected the invite"
                            self.checkButton.isHidden = true
                            self.crossButton.isHidden = true
                            self.undoButton.isHidden = false
                            return
                        }
                    }
                }
                print("Event ID not found in any date")
            }
        } else {
            print("Current user not authenticated")
        }
    }
    
    @objc func undoButtonTapped() {
        guard let inviteKey = inviteKey, let eventsDatabaseRef = eventsDatabaseRef else {
            print("Invite key or eventsDatabaseRef is nil")
            return
        }

        if let currentUserUID = Auth.auth().currentUser?.uid {
            eventsDatabaseRef.observeSingleEvent(of: .value) { [self] (snapshot) in
                for dateSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                    for eventSnapshot in dateSnapshot.children.allObjects as! [DataSnapshot] {
                        let eventID = eventSnapshot.key

                        if eventID == self.inviteValue {
                            // Revert the action performed by the cross button
                            // Update the invites map in Firestore to add the invite back
                            let db = Firestore.firestore()
                            let userDocRef = db.collection("users").document(currentUserUID)

                            userDocRef.updateData([
                                "invites.\(inviteKey)": FieldValue.arrayUnion([self.inviteValue!])
                            ]) { error in
                                if let error = error {
                                    print("Error updating user data: \(error.localizedDescription)")
                                } else {
                                    print("User data updated successfully")
                                }
                            }

                            self.nameLabel.text = oldNameLabel
                            self.checkButton.isHidden = false
                            self.crossButton.isHidden = false
                            self.undoButton.isHidden = true
                            return
                        }
                    }
                }
                print("Event ID not found in any date")
            }
        } else {
            print("Current user not authenticated")
        }
    }

    func configure(with inviterName: String, profileImageURL: String, eventName: String, venueName: String) {
        nameLabel.text = "\(inviterName) has invited you to \(eventName) @ \(venueName)"
        oldNameLabel = nameLabel.text!

        // Load profile image using Kingfisher
        if let url = URL(string: profileImageURL) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "default_profile_image"))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Adjust the preferredMaxLayoutWidth of nameLabel
        nameLabel.preferredMaxLayoutWidth = nameLabel.bounds.width
    }
}
