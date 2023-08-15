import UIKit
import Kingfisher
import FirebaseAuth
import FirebaseFirestore

class removeFriendCustomCellClass: UITableViewCell {
    
    var friendRemoved: (() -> Void)?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
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
    
    private let removeButton: UIButton = {
        let button = UIButton()
        let trashIcon = UIImage(systemName: "trash.circle")
        button.setImage(trashIcon?.withTintColor(.red, renderingMode: .alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(removeButton)
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            usernameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            removeButton.widthAnchor.constraint(equalToConstant: 30),
            removeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Ensure proper spacing between nameLabel and usernameLabel
        NSLayoutConstraint.activate([
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: removeButton.leadingAnchor, constant: -16),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: removeButton.leadingAnchor, constant: -16)
        ])
    }
    
    func configure(with user: User) {
        nameLabel.text = user.name
        usernameLabel.text = user.username
        
        if let profileImageURL = URL(string: user.profilePic) {
            profileImageView.kf.setImage(with: profileImageURL, placeholder: UIImage(named: "placeholder"))
        } else {
            profileImageView.image = UIImage(named: "placeholder")
        }
    }
    
    @objc private func removeButtonTapped() {
        // Get the friend's username from the usernameLabel
        guard let friendUsername = usernameLabel.text else {
            return
        }

        // Create an alert to confirm friend removal
        let alert = UIAlertController(
            title: "Remove Friend",
            message: "Are you sure you want to remove this friend? Both you and them will not be able to see each other going to parties anymore.",
            preferredStyle: .alert
        )

        // Add action to confirm removal
        alert.addAction(UIAlertAction(title: "Okay, remove this friend", style: .destructive, handler: { [weak self] _ in
            // Fetch the current user's UID
            guard let currentUserUID = Auth.auth().currentUser?.uid else {
                return
            }

            // Fetch the friend's UID using the friendUsername
            let db = Firestore.firestore()
            let userRef = db.collection("users").whereField("username", isEqualTo: friendUsername)

            userRef.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching friend's UID: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot,
                      let friendDocument = snapshot.documents.first else {
                    print("Friend not found")
                    return
                }

                let friendUID = friendDocument.documentID

                // Get references to the current user's and friend's documents
                let currentUserRef = db.collection("users").document(currentUserUID)
                let friendUserRef = db.collection("users").document(friendUID)

                // Update the current user's document to remove the friend's UID from the friends array
                currentUserRef.updateData(["friends": FieldValue.arrayRemove([friendUID])]) { error in
                    if let error = error {
                        print("Error removing friend from current user's friends list: \(error.localizedDescription)")
                        return
                    }
                    print("Removed friend from current user's friends list")

                    // Update the friend's document to remove the current user's UID from the friends array
                    friendUserRef.updateData(["friends": FieldValue.arrayRemove([currentUserUID])]) { error in
                        if let error = error {
                            print("Error removing current user from friend's friends list: \(error.localizedDescription)")
                        } else {
                            print("Removed current user from friend's friends list")

                            // Call friendRemoved() here after successfully removing the friend from both friends lists
                            self?.friendRemoved?()
                        }
                    }
                }
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Present the alert using the correct view controller
        if let viewController = findViewController() {
            viewController.present(alert, animated: true, completion: nil)
        } else {
            print("Unable to find a view controller to present the alert.")
        }
    }

        
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let currentResponder = responder {
            if let viewController = currentResponder as? UIViewController {
                return viewController
            }
            responder = currentResponder.next
        }
        return nil
    }
}
