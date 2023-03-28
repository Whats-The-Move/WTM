//
//  MyFriendsViewController.swift
//  WTM
//
//  Created by Aman Shah on 2/27/23.
//

import UIKit
import FirebaseDatabase

class MyFriendsViewController: UIViewController {
    
    var users: [String] = []

    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var friendList: UITableView!{
        didSet {
            friendList.dataSource = self
        }
    }
    
    var databaseRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference().child("Users")
        databaseRef?.observe(.childAdded) { (snapshot) in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let userText = childSnapshot.value as? String {
                    let friend = userText
                    self.users.append(friend)
                }
            }
            self.friendList.reloadData()
        }
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

extension MyFriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let review = users[indexPath.row]
        cell.textLabel?.text = review
        return cell
    }
}

extension MyFriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty ?? true {
            searchBar.resignFirstResponder()
            friendList.reloadData()
            return
        }
        let searchParty = users.filter({$0.lowercased().contains(searchText.lowercased())})
        friendList.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        friendList.reloadData()
    }
}

