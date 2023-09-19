import UIKit

class DestinationViewController: UIViewController {
    // UI Elements
    private let titleLabel = UILabel()
    private let venueNameLabel = UILabel()
    private let startTimeLabel = UILabel()
    private let eventName = UILabel()
    private let addressLabel = UILabel()
    private let descriptionLabel = UILabel()
    var labels : [UILabel] = []



    // Data Properties
    var selectedItem: Event // Replace YourItemType with your data type

    // Custom initializer to pass data
    init(selectedItem: Event = Event()) {
        self.selectedItem = selectedItem // Initialize with the provided item or a default value
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("printing the event i got")
        print(selectedItem.date ?? "4")
        print(selectedItem.name ?? "4")
        view.backgroundColor = .white
        // Configure UI elements
        configureLabels()
        // Add UI elements to the view
        view.addSubview(titleLabel)
        view.addSubview(venueNameLabel)
        view.addSubview(startTimeLabel)
        view.addSubview(eventName)
        view.addSubview(descriptionLabel)
        view.addSubview(addressLabel)
        labels = [venueNameLabel, eventName, startTimeLabel, addressLabel, descriptionLabel]

        
        addHorizontalLine(belowView: titleLabel, spacing: 10.0)

        // Add constraints
        configureConstraints()
        labels.forEach { label in
            label.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        }
    }

    private func configureLabels() {
        // Configure titleLabel
        titleLabel.font = UIFont(name: "Futura-Medium", size: 40)
        titleLabel.textColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1.0)
        // Assuming selectedItem.date is of type Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy" // Define the desired date format
        titleLabel.text = dateFormatter.string(from: selectedItem.date)


        // Configure venueNameLabel
        venueNameLabel.font = UIFont(name: "Futura-Medium", size: 20)
        venueNameLabel.textColor = UIColor.black
        venueNameLabel.text = "Who?: " + selectedItem.place // Set the text based on selectedItem's properties

        eventName.font = UIFont(name: "Futura-Medium", size: 20)
        eventName.textColor = UIColor.black
        eventName.text = "What?: " + selectedItem.name // Set the text based on selectedItem's properties

        // Configure startTimeLabel
        startTimeLabel.font = UIFont(name: "Futura-Medium", size: 20)
        startTimeLabel.textColor = UIColor.black
        // Assuming selectedItem.time is a Unix timestamp (TimeInterval)
        dateFormatter.dateFormat = "h:mm a" // Define the desired time format

        let selectedTimeDate = Date(timeIntervalSince1970: Double(selectedItem.time))
        let selectedEndTimeDate = Date(timeIntervalSince1970: Double(selectedItem.time))
        startTimeLabel.text = "When?: " + dateFormatter.string(from: selectedTimeDate) + " to " + dateFormatter.string(from: selectedEndTimeDate)
        
        addressLabel.font = UIFont(name: "Futura-Medium", size: 20)
        addressLabel.textColor = UIColor.black
        addressLabel.text = "Where?: " + selectedItem.location // Set the text based on selectedItem's properties
        
        descriptionLabel.font = UIFont(name: "Futura-Medium", size: 20)
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.text = "Description: " + selectedItem.description // Set the text based on selectedItem's properties
        descriptionLabel.numberOfLines = 0
    }
    func addHorizontalLine(belowView viewAbove: UIView, spacing: CGFloat = 10.0) {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.gray // Set the line color as needed
        lineView.translatesAutoresizingMaskIntoConstraints = false
        viewAbove.superview?.addSubview(lineView) // Add lineView to the same superview as viewAbove

        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: viewAbove.bottomAnchor, constant: spacing),
            lineView.leadingAnchor.constraint(equalTo: viewAbove.superview!.leadingAnchor), // Use superview's leading
            lineView.trailingAnchor.constraint(equalTo: viewAbove.superview!.trailingAnchor), // Use superview's trailing
            lineView.heightAnchor.constraint(equalToConstant: 1.0) // 1px height

            // Add this constraint to specify the bottom of lineView
        ])
    }

    private func configureConstraints() {
        // Add constraints for titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true

        // Add constraints for venueNameLabel
        venueNameLabel.translatesAutoresizingMaskIntoConstraints = false
        venueNameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 20).isActive = true
        venueNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40).isActive = true

        // Add constraints for startTimeLabel

        
        eventName.translatesAutoresizingMaskIntoConstraints = false
        eventName.leadingAnchor.constraint(equalTo: venueNameLabel.leadingAnchor).isActive = true
        eventName.topAnchor.constraint(equalTo: venueNameLabel.bottomAnchor, constant: 40).isActive = true
        
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        startTimeLabel.leadingAnchor.constraint(equalTo: eventName.leadingAnchor).isActive = true
        startTimeLabel.topAnchor.constraint(equalTo: eventName.bottomAnchor, constant: 40).isActive = true

        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.leadingAnchor.constraint(equalTo: startTimeLabel.leadingAnchor).isActive = true
        addressLabel.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 40).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 40).isActive = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Animate labels one after another with a 1-second delay
        for (index, label) in labels.enumerated() {
            UIView.animate(withDuration: 0.5, delay: Double(index) * 0.3, options: .curveEaseInOut, animations: {
                label.transform = .identity // Reset the label's position
            }, completion: nil)
        }
    }

}
