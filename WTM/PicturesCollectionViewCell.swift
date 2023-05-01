//
//  PicturesCollectionViewCell.swift
//  WTM
//
//  Created by Aman Shah on 4/30/23.
//

import UIKit
import AVFoundation

protocol PicturesCollectionViewCellDelegate: AnyObject {
    func didTapLikeButton(with model: PictureModel)

    func didTapProfileButton(with model: PictureModel)

    func didTapShareButton(with model: PictureModel)

    func didTapCommentButton(with model: PictureModel)
}
class PicturesCollectionViewCell: UICollectionViewCell {
   //subviews
    static let identifier = "PicturesCollectionViewCell"
    private let usernameLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .left
            label.textColor = .white
            return label
        }()

    private let captionLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .left
            label.textColor = .white
            return label
        }()

    private let audioLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .left
            label.textColor = .white
            return label
        }()

        // Buttons
    private let profileButton: UIButton = {
            let button = UIButton()
            button.setBackgroundImage(UIImage(systemName: "person.circle"), for: .normal)
            return button
        }()

    private let likeButton: UIButton = {
            let button = UIButton()
            button.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
            return button
        }()

    private let commentButton: UIButton = {
            let button = UIButton()
            button.setBackgroundImage(UIImage(systemName: "text.bubble.fill"), for: .normal)
            return button
        }()

    private let shareButton: UIButton = {
            let button = UIButton()
            button.setBackgroundImage(UIImage(systemName: "arrowshape.turn.up.right.fill"), for: .normal)
            return button
        }()

    private let pictureContainer = UIView()

        // Delegate
    weak var delegate: PicturesCollectionViewCellDelegate?

    var player: AVPlayer?
    
    private var model: PictureModel?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        contentView.backgroundColor = .red
        contentView.clipsToBounds = true
        addSubviews()
    }
    private func addSubviews(){
        contentView.addSubview(pictureContainer)

        contentView.addSubview(usernameLabel)
        contentView.addSubview(captionLabel)
        contentView.addSubview(audioLabel)

        contentView.addSubview(profileButton)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(shareButton)

        // Add actions
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchDown)
        profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchDown)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchDown)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchDown)

        pictureContainer.clipsToBounds = true

        contentView.sendSubviewToBack(pictureContainer)
    }
    @objc private func didTapLikeButton() {
            guard let model = model else { return }
            delegate?.didTapLikeButton(with: model)
    }

    @objc private func didTapCommentButton() {
        guard let model = model else { return }
        delegate?.didTapCommentButton(with: model)
    }

    @objc private func didTapShareButton() {
        guard let model = model else { return }
        delegate?.didTapShareButton(with: model)
    }

    @objc private func didTapProfileButton() {
        guard let model = model else { return }
        delegate?.didTapProfileButton(with: model)
    }
    override func layoutSubviews() {
            super.layoutSubviews()

            pictureContainer.frame = contentView.bounds

            let size = contentView.frame.size.width/7
            let width = contentView.frame.size.width
            let height = contentView.frame.size.height - 100

            // Buttons
            shareButton.frame = CGRect(x: width-size, y: height-size, width: size, height: size)
            commentButton.frame = CGRect(x: width-size, y: height-(size*2)-10, width: size, height: size)
            likeButton.frame = CGRect(x: width-size, y: height-(size*3)-10, width: size, height: size)
            profileButton.frame = CGRect(x: width-size, y: height-(size*4)-10, width: size, height: size)

            // Labels
            // username. caption, audio
            audioLabel.frame = CGRect(x: 5, y: height-30, width: width-size-10, height: 50)
            captionLabel.frame = CGRect(x: 5, y: height-80, width: width-size-10, height: 50)
            usernameLabel.frame = CGRect(x: 5, y: height-120, width: width-size-10, height: 50)
        }
    override func prepareForReuse() {
            super.prepareForReuse()
            captionLabel.text = nil
            audioLabel.text = nil
            usernameLabel.text = nil
    }

   
    public func configure(with model: PictureModel){
        self.model = model
        configurePicture()
    }
    private func configurePicture() {
            guard let model = model else {
                return
            }
            guard let path = Bundle.main.path(forResource: model.fileName,
                                              ofType: model.fileFormat) else {
                                                print("Failed to find video")
                                                return
            }
            player = AVPlayer(url: URL(fileURLWithPath: path))

            let playerView = AVPlayerLayer()
            playerView.player = player
            playerView.frame = contentView.bounds
            playerView.videoGravity = .resizeAspectFill
            pictureContainer.layer.addSublayer(playerView)
            player?.volume = 0
            player?.play()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
