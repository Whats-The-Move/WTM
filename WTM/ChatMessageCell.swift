import UIKit

class ChatMessageCell: UITableViewCell {

    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        // Constraints for the bubble view
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 250), // You can adjust the width as needed
        ])
        
        // Constraints for the message label inside the bubble view
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
        ])
        
        // Additional customization for the cell
        selectionStyle = .none
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: Message) {
        messageLabel.text = message.text
        
        // Set bubble color based on the creator
        if message.creatorID == UID {
            bubbleView.backgroundColor = .systemPink
            bubbleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: centerXAnchor).isActive = true
            messageLabel.textAlignment = .right
        } else {
            bubbleView.backgroundColor = .systemGray
            bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: centerXAnchor).isActive = true
            messageLabel.textAlignment = .left
        }
        
        // Additional customization for the cell
        bubbleView.layer.cornerRadius = 10
        bubbleView.layer.masksToBounds = true
    }
}
