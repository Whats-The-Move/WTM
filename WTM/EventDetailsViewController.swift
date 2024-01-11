import UIKit

class EventDetailsViewController: UIViewController {
    var eventLoad: EventLoad
    let barImage = UIImageView()
    let nameLabel = UILabel()
    let infoStackView = UIStackView()
    let descriptionLabel = UILabel()



    init(eventLoad: EventLoad) {
        self.eventLoad = eventLoad
        super.init(nibName: nil, bundle: nil)
        // Additional setup if needed
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Call the setupBarImage function
        setupBarImage()
        addBackButton()
        addNameLabel()
        addInfoStackView()
        addDescriptionLabel()
        print(eventLoad.creator)
        // Setup UI and use eventLoad as needed
    }
    override func viewDidLayoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = barImage.bounds // Corrected line
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        gradientLayer.locations = [0.3, 1.0]

        // Add gradient layer as an overlay to barImage
        barImage.layer.addSublayer(gradientLayer)
    }

    func setupBarImage() {
        // Configure barImage
        barImage.translatesAutoresizingMaskIntoConstraints = false
        barImage.contentMode = .scaleAspectFill
        barImage.clipsToBounds = true
        loadImage(from: eventLoad.imageURL, to: barImage)
        // Add barImage to the view
        view.addSubview(barImage)

        // Setup constraints for barImage to span the top half of the screen
        NSLayoutConstraint.activate([
            barImage.topAnchor.constraint(equalTo: view.topAnchor),
            barImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            barImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            barImage.heightAnchor.constraint(equalTo: view.widthAnchor)
        ])

        // Set an example image (replace with your own logic to load an image)

        // Add gradient layer

    }
    func addBackButton() {
            let backButton = UIButton(type: .system)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
            backButton.tintColor = .white
            backButton.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
            backButton.layer.cornerRadius = 15 // Half of the button's height for a circular button
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

            view.addSubview(backButton)

            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                backButton.widthAnchor.constraint(equalToConstant: 30),
                backButton.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
    func addNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.text = eventLoad.eventName
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5 // Adjust as needed
        nameLabel.textAlignment = .center

        view.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: barImage.bottomAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 300),
            nameLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    func addInfoStackView() {
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.axis = .horizontal
        infoStackView.spacing = 0 // No spacing between labels and separators
        infoStackView.alignment = .center

        // Create labels
        let venueName = eventLoad.venueName + "   "
        let venueLabel = createInfoLabel(text: venueName)
        let dateLabel = createInfoLabel(text: String(eventLoad.date.prefix(eventLoad.date.count - 6)))
        let timeLabel = createInfoLabel(text: eventLoad.time)
        let typeLabel = createInfoLabel(text: eventLoad.type)

        // Add labels to stack view
        infoStackView.addArrangedSubview(venueLabel)
        infoStackView.addArrangedSubview(dateLabel)
        infoStackView.addArrangedSubview(timeLabel)
        infoStackView.addArrangedSubview(typeLabel)

        // Add stack view to the view
        view.addSubview(infoStackView)

        // Set up constraints for the infoStackView
        NSLayoutConstraint.activate([
            infoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 25),
            infoStackView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }

    func createInfoLabel(text: String) -> UIStackView {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)

        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5 // Adjust as needed
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        // Add thin line separator to the right
        let separatorView = UIView()
        separatorView.backgroundColor = .gray
        NSLayoutConstraint.activate([
            separatorView.widthAnchor.constraint(equalToConstant: 1),
            separatorView.heightAnchor.constraint(equalToConstant: 30),
            label.widthAnchor.constraint(equalToConstant: 74)
        ])
 


        // Set equal width for label and separator

        // Create a horizontal stack view to combine label and separator
        let labelStackView = UIStackView(arrangedSubviews: [label, separatorView])
        labelStackView.axis = .horizontal
        labelStackView.alignment = .fill
        labelStackView.spacing = 0

        return labelStackView
    }
    func addDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = eventLoad.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)

        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0 // Allow multiple lines for description

        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            descriptionLabel.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 25),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    




        @objc func backButtonTapped() {
            // Dismiss the current view controller
            self.dismiss(animated: true, completion: nil)
        }
    func loadImage(from urlString: String, to imageView: UIImageView) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        imageView.kf.setImage(with: url)
    }
}
