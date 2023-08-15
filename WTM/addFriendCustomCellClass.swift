import UIKit
import Kingfisher
import FirebaseAuth
import FirebaseFirestore
protocol AddFriendCellDelegate: AnyObject {
    func showAlertForDeletion(from cell: UITableViewCell)
}

class addFriendCustomCellClass: UITableViewCell {
    weak var delegate: AddFriendCellDelegate?

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
    public let deleteButton: UIButton = {
        let button = UIButton()
        //label.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("delete", for: .normal)
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
        contentView.addSubview(deleteButton)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    
    @objc private func deleteButtonTapped() {
        deleteUsername = usernameLabel.text ?? ""

        delegate?.showAlertForDeletion(from: self)

        
        
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
            
             deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
             deleteButton.widthAnchor.constraint(equalToConstant: 60),
             deleteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with user: User, hasDeleteButton: Bool) {
        if hasDeleteButton {
            deleteButton.isHidden = false
        }
        else{
            deleteButton.isHidden = true
        }
        nameLabel.text = user.name
        usernameLabel.text = user.username
        
        // Set the profile image using SDWebImage library
        if let profileImageURL = URL(string: user.profilePic) {
            profileImageView.kf.setImage(with: profileImageURL, placeholder: UIImage(named: "placeholder"))
        } else {
            profileImageView.image = UIImage(named: "placeholder")
        }
    }
}
