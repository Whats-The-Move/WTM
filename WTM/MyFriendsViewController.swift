//
//  MyFriendsViewController.swift
//  WTM
//
//  Created by Aman Shah on 2/27/23.
//

import UIKit

class MyFriendsViewController: UIViewController {

    
    @IBOutlet weak var friendList: UITableView!
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

extension MyFriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let party = parties[indexPath.row]
        let cell = friendList.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        
        
        return cell    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        }
}


