//
//  PicturesViewController.swift
//  WTM
//
//  Created by Aman Shah on 4/30/23.
//

import UIKit
import Firebase
import Kingfisher
struct PictureModel {
    let caption: String
    let username: String
    let audioTrackName: String
    let fileName: String
    let fileFormat: String
}
class PicturesViewController: UIViewController {
    private var collectionView: UICollectionView?
    private var data = [PictureModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<10{
            let model = PictureModel(
                caption: "caption",
                username: "uid to come later",
                audioTrackName: "audio track",
                fileName: "video",
                fileFormat: "mov"
            )
            data.append(model)
        }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(PicturesCollectionViewCell.self, forCellWithReuseIdentifier: PicturesCollectionViewCell.identifier)
        collectionView?.isPagingEnabled = true
        collectionView?.dataSource = self
        view.addSubview(collectionView!)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
}
extension PicturesViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        return data.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = data[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PicturesCollectionViewCell.identifier, for: indexPath) as! PicturesCollectionViewCell
        cell.configure(with: model)
        return cell
    }
    
}
extension PicturesViewController: PicturesCollectionViewCellDelegate {
    func didTapLikeButton(with model: PictureModel) {
        print("like button tapped")
    }

    func didTapProfileButton(with model: PictureModel) {
        print("profile button tapped")
    }

    func didTapShareButton(with model: PictureModel) {
        print("share button tapped")
    }

    func didTapCommentButton(with model: PictureModel) {
        print("comment button tapped")
    }
}
