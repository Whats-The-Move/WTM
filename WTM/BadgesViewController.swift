//
//  BadgesViewController.swift
//  WTM
//
//  Created by Aman Shah on 6/17/23.
//

import UIKit

class BadgesViewController: UIViewController {

    @IBOutlet weak var bkgdView: UIView!
    @IBOutlet weak var bestFriendsView: UIView!
    @IBOutlet weak var favSpotView: UIView!
    @IBOutlet weak var fratView: UIView!
    @IBOutlet weak var bestFriendsPic: UIImageView!
    
    @IBOutlet weak var favSpotPic: UIImageView!
    
    @IBOutlet weak var fratPic: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        bestFriendsView.layer.cornerRadius = 10
        favSpotView.layer.cornerRadius = 10
        fratView.layer.cornerRadius = 10
        bestFriendsPic.layer.cornerRadius = bestFriendsPic.frame.width / 2
        favSpotPic.layer.cornerRadius = bestFriendsPic.frame.width / 2
        fratPic.layer.cornerRadius = bestFriendsPic.frame.width / 2
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let frameWidth = 299.0
        let frameHeight = screenHeight * (2/3) - 100
        
        let frameX = (screenWidth - frameWidth) / 2
        let frameY = screenHeight / 4
        
        bkgdView.frame = CGRect(x: frameX, y: frameY, width: frameWidth, height: frameHeight)
        let headerHeight: CGFloat = 60.0
        let spacing: CGFloat = 15.0
        let horizontalPadding: CGFloat = 15.0

        
        let stackView = UIStackView(arrangedSubviews: [bestFriendsView, favSpotView, fratView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        
        // Calculate the frame for the stack view
        let stackViewWidth = bkgdView.bounds.width - (horizontalPadding * 2)
        let stackViewHeight = bkgdView.bounds.height - headerHeight - (spacing * 2)
        let stackViewX = bkgdView.bounds.origin.x + horizontalPadding
        let stackViewY = headerHeight + spacing
        
        stackView.frame = CGRect(x: stackViewX, y: stackViewY, width: stackViewWidth, height: stackViewHeight)
        
        bkgdView.addSubview(stackView)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
