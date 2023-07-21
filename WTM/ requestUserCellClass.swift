import UIKit
import Kingfisher
import FirebaseAuth
import FirebaseFirestore

class requestUserCellClass: UITableViewCell {
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25  // Adjust the corner radius to your preference
        return imageView
    }()
    
    public let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.darkGray, for: .normal) // Set text color to dark gray
        button.backgroundColor = .clear // Set background color to transparent
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(addButton) // Add the "Add" button as a subview
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    
    @objc private func addButtonTapped() {
        guard let currentUserUID = Auth.auth().currentUser?.uid,
              let personUsername = usernameLabel.text else {
            // If the current user is not logged in or the person's username is missing, handle the error or return
            return
        }
        
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        let query = usersCollection.whereField("username", isEqualTo: personUsername)

        query.getDocuments { (snapshot, error) in
            if let error = error {
                // Handle the error
                print("Error fetching person's UID: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot,
                  let document = snapshot.documents.first else {
                // Handle case when the person is not found
                return
            }

            let personUID = document.documentID
            let personData = document.data()
            
            if var pendingRequests = personData["pendingFriendRequests"] as? [String], pendingRequests.contains(currentUserUID) {
                // If the current user's UID is in pendingFriendRequests, remove it
                pendingRequests.removeAll { $0 == currentUserUID }
                let friendRequestData = ["pendingFriendRequests": pendingRequests]
                usersCollection.document(personUID).updateData(friendRequestData) { [weak self] error in
                    guard let self = self else {
                        return
                    }
                    
                    if let error = error {
                        // Handle the error
                        print("Error removing friend request: \(error.localizedDescription)")
                    } else {
                        // Friend request removed successfully
                        print("Friend request reverted successfully")
                        self.addButton.setTitle("Add", for: .normal)
                        self.addButton.backgroundColor = .clear
                        self.addButton.isEnabled = true
                    }
                }
            } else {
                // If the current user's UID is not in pendingFriendRequests, add it
                let friendRequestData = ["pendingFriendRequests": FieldValue.arrayUnion([currentUserUID])]
                usersCollection.document(personUID).updateData(friendRequestData) { [weak self] error in
                    guard let self = self else {
                        return
                    }
                    
                    if let error = error {
                        // Handle the error
                        print("Error adding friend request: \(error.localizedDescription)")
                    } else {
                        // Friend request sent successfully
                        print("Friend request sent successfully")
                        self.addButton.setTitle("Sent", for: .normal)
                        self.addButton.backgroundColor = .gray
                        self.addButton.isEnabled = true
                    }
                }
            }
        }
    }


    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            usernameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with user: User) {
        nameLabel.text = user.name
        usernameLabel.text = user.username

        // Set the profile image using Kingfisher library
        if let profileImageURL = URL(string: user.profilePic) {
            profileImageView.kf.setImage(with: profileImageURL, placeholder: UIImage(named: "placeholder"))
        } else {
            profileImageView.image = UIImage(named: "placeholder")
        }

        // Fetch the current user's UID
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            // If current user is not logged in, show the addButton
            addButton.isHidden = false
            return
        }

        // Check if the current user's UID is present in the person's pendingFriendRequests
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else {
                // Handle error or nil self
                return
            }
            
            if let data = document.data(),
               let pendingFriendRequests = data["pendingFriendRequests"] as? [String] {
                // Hide the addButton if the current user's UID is found in pendingFriendRequests
                //self.addButton.isHidden = pendingFriendRequests.contains(currentUserUID)
                if pendingFriendRequests.contains(currentUserUID){
                    self.addButton.setTitle("Sent", for: .normal)
                    self.addButton.backgroundColor = .gray
                    self.addButton.isEnabled = true
                } else{
                    self.addButton.setTitle("Add", for: .normal)
                    self.addButton.backgroundColor = .clear
                    self.addButton.isEnabled = true
                }
            } else {
                // Show the addButton if there are no pendingFriendRequests or error in data
                //self.addButton.isHidden = false
                self.addButton.setTitle("Add", for: .normal)
                self.addButton.backgroundColor = .clear
                self.addButton.isEnabled = true
            }
        }
    }
}
