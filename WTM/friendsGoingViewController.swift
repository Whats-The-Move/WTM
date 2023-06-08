//
//  friendsGoingViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 6/8/23.
//

import UIKit

class friendsGoingViewController: UIViewController {

    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var friendsGoingTableView: UITableView!
    
    var friends: [User] = []
    var searching = false
    var searchFriend: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
