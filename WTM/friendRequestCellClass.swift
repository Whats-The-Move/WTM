import UIKit

protocol FriendRequestCellDelegate: AnyObject {
    func didTapAcceptButton(at index: Int)
    func didTapDenyButton(at index: Int)
}

class FriendRequestCellClass: UITableViewCell {
    
    weak var delegate: FriendRequestCellDelegate?
    private var cellIndex: Int = 0
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textColor = .black
        return label
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Accept", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let denyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Deny", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 5
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameLabel)
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
        
        let buttonWidth: CGFloat = 80
        let buttonHeight: CGFloat = 30
        let padding: CGFloat = 16
        
        nameLabel.frame = CGRect(x: padding, y: contentView.bounds.midY - 10, width: contentView.bounds.width - (3 * padding) - (2 * buttonWidth), height: 20)
        acceptButton.frame = CGRect(x: contentView.bounds.width - (2 * padding) - (2 * buttonWidth), y: contentView.bounds.midY - (buttonHeight / 2), width: buttonWidth, height: buttonHeight)
        denyButton.frame = CGRect(x: contentView.bounds.width - padding - buttonWidth, y: contentView.bounds.midY - (buttonHeight / 2), width: buttonWidth, height: buttonHeight)
    }
    
    @objc private func acceptButtonTapped() {
        delegate?.didTapAcceptButton(at: cellIndex)
    }
    
    @objc private func denyButtonTapped() {
        delegate?.didTapDenyButton(at: cellIndex)
    }
    
    func configure(with name: String, index: Int) {
        nameLabel.text = name
        cellIndex = index
    }
}
