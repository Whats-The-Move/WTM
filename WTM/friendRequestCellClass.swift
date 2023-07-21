import UIKit
import Kingfisher

protocol FriendRequestCellDelegate: AnyObject {
    func didTapAcceptButton(at index: Int)
    func didTapDenyButton(at index: Int)
}

class FriendRequestCellClass: UITableViewCell {
    
    weak var delegate: FriendRequestCellDelegate?
    private var cellIndex: Int = 0
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // Set any other properties for your profile image view
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Accept", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor.green
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let denyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Deny", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 8
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(acceptButton)
        contentView.addSubview(denyButton)
        
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        denyButton.addTarget(self, action: #selector(denyButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = contentView.bounds.height - 10
        profileImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize)
        profileImageView.layer.cornerRadius = imageSize / 2
        profileImageView.clipsToBounds = true
        
        let buttonWidth: CGFloat = 60
        let buttonHeight: CGFloat = 30
        let padding: CGFloat = 10
        
        nameLabel.frame = CGRect(x: profileImageView.frame.maxX + padding, y: 5, width: contentView.bounds.width - (3 * padding) - (2 * buttonWidth) - imageSize, height: 20)
        usernameLabel.frame = CGRect(x: profileImageView.frame.maxX + padding, y: 25, width: contentView.bounds.width - (3 * padding) - (2 * buttonWidth) - imageSize, height: 15)
        acceptButton.frame = CGRect(x: contentView.bounds.width - (2 * padding) - (2 * buttonWidth), y: contentView.bounds.height - buttonHeight - 5, width: buttonWidth, height: buttonHeight)
        denyButton.frame = CGRect(x: contentView.bounds.width - padding - buttonWidth, y: contentView.bounds.height - buttonHeight - 5, width: buttonWidth, height: buttonHeight)
    }
    
    @objc private func acceptButtonTapped() {
        delegate?.didTapAcceptButton(at: cellIndex)
    }
    
    @objc private func denyButtonTapped() {
        delegate?.didTapDenyButton(at: cellIndex)
    }
    
    func configure(with name: String, username: String, profileImageURL: URL?, index: Int) {
        nameLabel.text = name
        usernameLabel.text = username
        cellIndex = index
        
        // Load the profile image using Kingfisher
        profileImageView.kf.setImage(with: profileImageURL)
    }
}
