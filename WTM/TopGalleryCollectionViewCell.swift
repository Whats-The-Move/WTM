import UIKit

class TopGalleryCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var galleryImages: [UIImage] = []
    private var titleLabel: UILabel!
    private let galleryCollectionView: UICollectionView
    var pageControl: UIPageControl!

    let picWidth = 250

    override init(frame: CGRect) {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 290, height: 290)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = -10
        galleryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        galleryCollectionView.collectionViewLayout = layout


        super.init(frame: frame)

        setupTitleLabel()
        setupGalleryCollectionView()
        setupPageControl()
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
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func setupGalleryCollectionView() {
        
        
        galleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        galleryCollectionView.showsHorizontalScrollIndicator = false
        galleryCollectionView.isPagingEnabled = true
        galleryCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self

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
        pageControl.numberOfPages = 2 // Replace with your number of pages
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

    func configure(with images: [UIImage], title: String) {
        self.galleryImages = images
        self.titleLabel.text = title
        self.galleryCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            fatalError("Could not dequeue ImageCell")
        }
        cell.configure(with: galleryImages[indexPath.row])
        //cell.layer.cornerRadius = 10
        return cell
    }
}

class ImageCell: UICollectionViewCell {
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func configure(with image: UIImage) {
        imageView.image = image
    }
}
