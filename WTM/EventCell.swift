import UIKit

class EventCell: UITableViewCell {
    let placeLabel = UILabel()
    let nameLabel = UILabel()
    let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // Override the default setSelected method to prevent highlighting
        // This will disable the default highlighting behavior
    }

    private func setupSubviews() {
        placeLabel.textColor = .white
        nameLabel.textColor = .white
        timeLabel.textColor = .white
        
        contentView.addSubview(placeLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1).cgColor
        contentView.clipsToBounds = true
        
        // Place Label
        placeLabel.font = UIFont(name: "Futura", size: 16)
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            placeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            placeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // Name Label
        nameLabel.font = UIFont(name: "Futura", size: 14)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: placeLabel.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // Time Label
        timeLabel.font = UIFont(name: "Futura", size: 14)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50) // Ensure minimum width for time label
        ])
        
        // Set content compression resistance priorities
        placeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
