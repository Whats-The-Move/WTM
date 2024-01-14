import UIKit

class TopGalleryCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TopGalleryCollectionViewCellDelegate {

    
    //var galleryImages: [UIImage] = []
    var titleLabel: UILabel!
    var galleryCollectionView: UICollectionView!
    var pageControl: UIPageControl!
    var events: [EventLoad] = []
    weak var delegate: TopGalleryCollectionViewCellDelegate?
    
    let dropdownButton = UIButton(type: .system)
    let dates = ["This Week", "Tomorrow", "Today"]
    let optionsStackView = UIStackView()




    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        setupGalleryCollectionView()

    }
    func configure(title: String, with events: [EventLoad]) {
        self.titleLabel.text = title
        self.events = events
        setupPageControl()
        
        setupDropdownButton()
        setupOptionsStackView()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.font = UIFont(name: "Futura-Medium", size: 24)

        //titleLabel.textAlignment = .center
        titleLabel.textColor = .white

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    func setupOptionsStackView() {
        contentView.addSubview(optionsStackView)
        optionsStackView.axis = .horizontal
        optionsStackView.distribution = .fillEqually
        optionsStackView.alignment = .fill
        optionsStackView.spacing = 5
        optionsStackView.isHidden = true  // Initially hidden
        optionsStackView.isUserInteractionEnabled = true


        // Create and add buttons
        let todayButton = createButtonWithTitle("Today")
        let tomorrowButton = createButtonWithTitle("Tomorrow")
        let thisWeekButton = createButtonWithTitle("This Week")
        
        for view in optionsStackView.arrangedSubviews {
            optionsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        optionsStackView.addArrangedSubview(todayButton)
        optionsStackView.addArrangedSubview(tomorrowButton)
        optionsStackView.addArrangedSubview(thisWeekButton)

        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: dropdownButton.bottomAnchor, constant: 15),
            optionsStackView.trailingAnchor.constraint(equalTo: dropdownButton.trailingAnchor),
            optionsStackView.widthAnchor.constraint(equalToConstant: 270),
            optionsStackView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    func createButtonWithTitle(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Futura-Medium", size: 12)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true


        // Set alpha based on currentOption
        if currentOption == title {
            button.backgroundColor = UIColor(_colorLiteralRed: 255/500, green: 28/500, blue: 142/500, alpha: 1.0)
        }

        return button
    }


    @objc func optionSelected(_ sender: UIButton) {
        print("Selected option:")

        guard let title = sender.titleLabel?.text else { return }
        print("Selected option: \(title)")
        // Handle the selection
        currentOption = title
        dropdownTapped()
        delegate?.refreshData()
            //RELOAD HERE
            // Update button alphas

    }
   
    func setupDropdownButton() {
        contentView.addSubview(dropdownButton)
        dropdownButton.setTitle(currentOption, for: .normal)
        let originalImage = UIImage(systemName: "chevron.down")! // Replace with your down arrow image
        let resizedImage = resizeImage(image: originalImage, targetSize: CGSize(width: 12, height: 12)) // Adjust target size as needed
        
        dropdownButton.setImage(resizedImage, for: .normal) // Replace with your down arrow image
        dropdownButton.tintColor = .white
        dropdownButton.setTitleColor(.white, for: .normal)
        dropdownButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        dropdownButton.addTarget(self, action: #selector(dropdownTapped), for: .touchUpInside)
        dropdownButton.layer.cornerRadius = 10
        dropdownButton.layer.borderWidth = 1
        dropdownButton.layer.borderColor = UIColor.white.cgColor
        
        // Layout the button
        dropdownButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dropdownButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dropdownButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            dropdownButton.widthAnchor.constraint(equalToConstant: 90),
            dropdownButton.heightAnchor.constraint(equalToConstant: 20)
        ])

        // Adjust the position of the image and text
        dropdownButton.semanticContentAttribute = .forceRightToLeft
        dropdownButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0) // Adjust as needed
        dropdownButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: -2) // Adjust as needed
    }
     

    @objc func dropdownTapped() {

        optionsStackView.isHidden = !optionsStackView.isHidden

    }
    
    private func setupGalleryCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: contentView.frame.width - 30, height: contentView.frame.width)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        galleryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //galleryCollectionView.collectionViewLayout = layout

        galleryCollectionView.backgroundColor = .clear
        galleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        galleryCollectionView.showsHorizontalScrollIndicator = false
        galleryCollectionView.isPagingEnabled = true
        galleryCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        galleryCollectionView.layer.cornerRadius = 3
        contentView.addSubview(galleryCollectionView)

        NSLayoutConstraint.activate([
            galleryCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            galleryCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            galleryCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            galleryCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30)
        ])
    }
    func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = events.count// Replace with your number of pages
        pageControl.currentPage = 0
        // Assuming you have a UIPageControl object named pageControl
        pageControl.currentPageIndicatorTintColor = UIColor(red: 255/255, green: 22/255, blue: 148/255, alpha: 1)


        pageControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pageControl)
        NSLayoutConstraint.activate([

            // PageControl Constraints
            pageControl.topAnchor.constraint(equalTo: galleryCollectionView.bottomAnchor, constant: 5), // Adjust the constant for spacing
            pageControl.centerXAnchor.constraint(equalTo: galleryCollectionView.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = currentPage
    }




    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            fatalError("Could not dequeue ImageCell")
        }
        //cell.backgroundColor = .black
        cell.delegate = self

        cell.configure(with: events[indexPath.item])
        //cell.layer.cornerRadius = 10

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("event clicked")
        let selectedEventLoad = events[indexPath.item]
        delegate?.didSelectEventLoad(eventLoad: selectedEventLoad)
    }
    func didSelectEventLoad(eventLoad: EventLoad) {
        print("delegate called")
        delegate?.didSelectEventLoad(eventLoad: eventLoad)
    }
    func refreshData() {
        delegate?.refreshData()
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }






}
protocol TopGalleryCollectionViewCellDelegate: AnyObject {
    func didSelectEventLoad(eventLoad: EventLoad)
    func refreshData()
}

class ImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    var pplLabel: UILabel!
    var pplImage: UIImageView!
    var cellDetailsLabel: UILabel! // Declare the new label
    private var gradientLayer: CAGradientLayer?
    

    

    weak var delegate: TopGalleryCollectionViewCellDelegate?


    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    func configure(with event: EventLoad) {
        //imageView.image = image
        setupImageView(event: event)
        setupGradientBackground()
        setupCellDetailsLabel(event: event) // Setup the new label

        setupPplLabel(event: event)
        setupPplImage()

        setupCellAppearance()
        contentView.bringSubviewToFront(cellDetailsLabel)
        contentView.bringSubviewToFront(pplLabel)
        contentView.bringSubviewToFront(pplImage)



    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupCellDetailsLabel(event: EventLoad) {
        cellDetailsLabel = UILabel()
        cellDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        cellDetailsLabel.font = UIFont(name: "Futura-Medium", size: 14)
        cellDetailsLabel.textColor = .white
        cellDetailsLabel.text = event.eventName // Set your text
        contentView.addSubview(cellDetailsLabel)

        NSLayoutConstraint.activate([
            cellDetailsLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10), // Adjust constant for padding
            cellDetailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10), // Adjust constant for padding
            cellDetailsLabel.heightAnchor.constraint(equalToConstant: 20) // Set the height of the label
        ])
    }

    private func setupImageView(event: EventLoad) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        HorizontalCollectionViewCell().loadImage(from: event.imageURL, to: self.imageView)

        //imageView.layer.cornerRadius = 10
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    private func setupPplLabel(event: EventLoad) {
        pplLabel = UILabel()
        pplLabel.translatesAutoresizingMaskIntoConstraints = false
        pplLabel.text = String(event.isGoing.count) // Set the default text
        pplLabel.font = UIFont(name: "Futura-Medium", size: 14)
        pplLabel.textColor = .white
        contentView.addSubview(pplLabel)

        NSLayoutConstraint.activate([
            pplLabel.bottomAnchor.constraint(equalTo: cellDetailsLabel.bottomAnchor),
            //pplLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            pplLabel.widthAnchor.constraint(equalToConstant: 30),
            pplLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            pplLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func setupPplImage() {
        pplImage = UIImageView(image: UIImage(systemName: "person.3.fill"))
        pplImage.tintColor = .white
        //UIColor(red: 255/255, green: 22/255, blue: 142/255, alpha: 1)
        pplImage.translatesAutoresizingMaskIntoConstraints = false
        pplImage.contentMode = .scaleAspectFit
        contentView.addSubview(pplImage)

        NSLayoutConstraint.activate([
            pplImage.bottomAnchor.constraint(equalTo: pplLabel.bottomAnchor),
            pplImage.trailingAnchor.constraint(equalTo: pplLabel.leadingAnchor),
            pplImage.widthAnchor.constraint(equalToConstant: 24),
            pplImage.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    

    private func setupGradientBackground() {
        gradientLayer?.removeFromSuperlayer() // Remove the old gradient layer if it exists

        let gradient = CAGradientLayer()
        gradient.frame = contentView.bounds
        let transparent = UIColor.black.withAlphaComponent(0.0).cgColor
        let black = UIColor.black.withAlphaComponent(1.0).cgColor

        gradient.colors = [transparent, black]
        gradient.locations = [0.80, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)

        imageView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient // Store the gradient layer
    }




    private func setupCellAppearance() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true


    }
}
