//
//  CustomCellClass.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 5/25/23.
//

import Foundation
import UIKit

class CustomCellClass: UITableViewCell {
    func configure(with party: Party, rankDict: [String: Int]) {
        if let partyLabel = viewWithTag(1) as? UILabel {
            partyLabel.text = party.name
        }
        if let subtitleLabel = viewWithTag(2) as? UILabel {
            subtitleLabel.text = "#" + String(rankDict[party.name] ?? 0)
        }
        if let ratingLabel = viewWithTag(3) as? UILabel {
            ratingLabel.text = String(party.rating)
        }
    }
}
