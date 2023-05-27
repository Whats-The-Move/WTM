//
//  HeaderCollectionReusableView.swift
//  WTM
//
//  Created by Aman Shah on 5/1/23.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    let titleLabel = UILabel()

       override init(frame: CGRect) {
           super.init(frame: frame)

           // Configure the label
           titleLabel.textColor = .black
           titleLabel.font = UIFont.systemFont(ofSize: 20)
           titleLabel.translatesAutoresizingMaskIntoConstraints = false
           addSubview(titleLabel)

           // Add constraints to center the label horizontally and vertically
           NSLayoutConstraint.activate([
               titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
               titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
           ])
       }

       required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
   }
