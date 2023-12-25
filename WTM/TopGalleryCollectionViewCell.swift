import UIKit

class TopGalleryCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //var galleryImages: [UIImage] = []
    var titleLabel: UILabel!
    var galleryCollectionView: UICollectionView!
    var pageControl: UIPageControl!
    var events: [EventLoad] = []



    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        setupGalleryCollectionView()
        setupPageControl()

    }
    func configure(title: String, with events: [EventLoad]) {
        self.titleLabel.text = title
        self.events = events
        //self.galleryCollectionView.reloadData() // Reload data with new events
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func setupGalleryCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 280, height: 350)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        galleryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //galleryCollectionView.collectionViewLayout = layout

 
        galleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        galleryCollectionView.showsHorizontalScrollIndicator = false
        galleryCollectionView.isPagingEnabled = true
        galleryCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        galleryCollectionView.layer.cornerRadius = 10
        contentView.addSubview(galleryCollectionView)

        NSLayoutConstraint.activate([
            galleryCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            galleryCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            galleryCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            galleryCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = events.count// Replace with your number of pages
        pageControl.currentPage = 0

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pageControl)
        NSLayoutConstraint.activate([

            // PageControl Constraints
            pageControl.topAnchor.constraint(equalTo: galleryCollectionView.bottomAnchor, constant: 5), // Adjust the constant for spacing
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
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
        cell.configure(with: events[indexPath.item])
        //cell.layer.cornerRadius = 10
        return cell
    }
}

class ImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    var pplLabel: UILabel!
    var pplImage: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    func configure(with event: EventLoad) {
        //imageView.image = image
        setupImageView(event: event)
        setupPplLabel(event: event)
        setupPplImage()
        setupCellAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -70),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    private func setupPplLabel(event: EventLoad) {
            pplLabel = UILabel()
            pplLabel.translatesAutoresizingMaskIntoConstraints = false
            pplLabel.text = String(event.isGoing.count) // Set the default text
            pplLabel.font = UIFont.boldSystemFont(ofSize: 18)
            contentView.addSubview(pplLabel)

            NSLayoutConstraint.activate([
                pplLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
                //pplLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                pplLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 10),
                pplLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                pplLabel.heightAnchor.constraint(equalToConstant: 50)
            ])
        }

        private func setupPplImage() {
            pplImage = UIImageView(image: UIImage(systemName: "person.3.fill"))
            pplImage.tintColor = UIColor(red: 255/255, green: 22/255, blue: 142/255, alpha: 1)
            pplImage.translatesAutoresizingMaskIntoConstraints = false
            pplImage.contentMode = .scaleAspectFit
            contentView.addSubview(pplImage)

            NSLayoutConstraint.activate([
                pplImage.centerYAnchor.constraint(equalTo: pplLabel.centerYAnchor),
                pplImage.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -5),
                pplImage.widthAnchor.constraint(equalToConstant: 40),
                pplImage.heightAnchor.constraint(equalToConstant: 32)
            ])
        }


    private func setupCellAppearance() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true


    }
}
