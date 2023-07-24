import UIKit

class ReviewTableViewCell: UITableViewCell {
    let dateLabel = UILabel()
    let bodyLabel = UILabel()
    let starRatingLabel = UILabel()
    struct Reviews {
        var reviewText: String?
        var rating: Int
        var date: Double
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCellLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        positionLabels()
    }

    private func setupCellLayout() {
        // Add the labels to the cell's content view
        contentView.addSubview(dateLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(starRatingLabel)

        // Customize the labels as needed
        dateLabel.font = UIFont(name: "Futura-Medium", size: 15)
        bodyLabel.font = UIFont(name: "Futura-Medium", size: 18)
        starRatingLabel.font = UIFont(name: "Futura-Medium", size: 15)
    }

    private func positionLabels() {
        // Set up constraints to position the labels
        // (Same constraints as before)
        // ...
    }

    func configure(comment: String, date: Double, rating: Int) {
        // Configure the cell with review data
        dateLabel.text = "review.date"
        bodyLabel.text = comment
        starRatingLabel.text = "review.rating"
    }
}
