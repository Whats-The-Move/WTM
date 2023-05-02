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
class PicturesViewController: UIViewController, UICollectionViewDelegate {
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
        var tabBarHeight = CGFloat(83.0)
        if let tabBarController = self.tabBarController {
            tabBarHeight = tabBarController.tabBar.frame.size.height
            print("Tab bar height: \(tabBarHeight)")
        }
        let headerHeight = 20.0
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.height - tabBarHeight - headerHeight)
        layout.sectionInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
 

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.headerReferenceSize = CGSize(width: collectionView?.frame.width ?? 400, height: headerHeight)
            flowLayout.sectionHeadersPinToVisibleBounds = true

        }
        collectionView?.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView")

        collectionView?.register(PicturesCollectionViewCell.self, forCellWithReuseIdentifier: PicturesCollectionViewCell.identifier)
        collectionView?.isPagingEnabled = true
        collectionView?.dataSource = self
        collectionView?.delegate = self
        //self.tabBarController?.overrideUserInterfaceStyle = .dark
        let customColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.6)

        self.tabBarController?.tabBar.tintColor = customColor // set to the desired color

        view.addSubview(collectionView!)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
 
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath) as! HeaderCollectionReusableView
            headerView.titleLabel.text = "Your Header Title"
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
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
