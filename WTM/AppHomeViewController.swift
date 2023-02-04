//
//  AppHomeViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 1/21/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AppHomeViewController: UIViewController {
    
    var rank = 0
    var timer: Timer?
    
    @IBOutlet weak var partyList: UITableView! {
        didSet {
            partyList.dataSource = self
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gifImage: UIImageView!
    
    var partyArray = [String]()
    var searching = false
    var searchParty = [String]()
    
    var databaseRef: DatabaseReference?
    var userDatabaseRef: DatabaseReference?
    public var parties = [Party]()
    public var likeDict = [String : Int]()
    public var dislikeDict = [String : Int]()
    public var overallLikeDict = [String : Double]()
    public var overallDislikeDict = [String : Double]()
    public var addressDict = [String : String]()
    public var userVotes = [String : Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        gifImage.loadGif(name: "finalillini")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        partyList.reloadData()
        super.viewWillAppear(animated)
        
        databaseRef = Database.database().reference().child("Parties")
        databaseRef?.queryOrdered(byChild: "Likes").observe(.childAdded) { [weak self] (snapshot) in
            let key = snapshot.key
            guard let value = snapshot.value as? [String : Any] else {return}
            if let likes = value["Likes"] as? Int, let dislikes = value["Dislikes"] as? Int, let allTimeLikes = value["allTimeLikes"] as? Double, let allTimeDislikes = value["allTimeDislikes"] as? Double, let address = value["Address"] as? String {
                let party = Party(name: key, likes: likes, dislikes: dislikes, allTimeLikes: allTimeLikes, allTimeDislikes: allTimeDislikes, address: address)
                self?.parties.append(party)
                self?.likeDict[party.name] = party.likes
                self?.dislikeDict[party.name] = party.dislikes
                self?.overallLikeDict[party.name] = party.allTimeLikes
                self?.overallDislikeDict[party.name] = party.allTimeDislikes
                self?.addressDict[party.name] = party.address
                self?.partyArray.append(party.name)
                if let row = self?.parties.count {
                    let indexPath = IndexPath(row: row - 1, section: 0)
                    self?.partyList.insertRows(at: [indexPath], with: .automatic)
                    if((self?.parties.count)! <= 50){
                        self?.partyList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    } else {
                        self?.scrollToTop()
                    }
                }
            }
        }
    }
    

    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        partyList.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    func updateDicts() {
        
        databaseRef = Database.database().reference().child("Parties")
        databaseRef?.observe(.childAdded){ [weak self] (snapshot) in
            let key = snapshot.key
            guard let value = snapshot.value as? [String : Any] else {return}
            if let likes = value["Likes"] as? Int, let dislikes = value["Dislikes"] as? Int, let allTimeLikes = value["allTimeLikes"] as? Double, let allTimeDislikes = value["allTimeDislikes"] as? Double, let address = value["Address"] as? String {
                let party = Party(name: key, likes: likes, dislikes: dislikes, allTimeLikes: allTimeLikes, allTimeDislikes: allTimeDislikes, address: address)
                    self?.likeDict[party.name] = party.likes
                    self?.dislikeDict[party.name] = party.dislikes
                    self?.overallLikeDict[party.name] = party.allTimeLikes
                    self?.overallDislikeDict[party.name] = party.allTimeDislikes
                    self?.addressDict[party.name] = party.address
            }
        }
        
    }
    
}

extension AppHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchParty.count
        }
        return parties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(parties.count)
        let party = parties[parties.count - 1 - indexPath.row]
        //let party = parties[indexPath.row]
        let cell = partyList.dequeueReusableCell(withIdentifier: "partyCell", for: indexPath)
        
        rank = indexPath.row + 1

        cell.textLabel?.text = party.name
        
        if overallLikeDict[party.name] != nil &&  overallLikeDict[party.name]! + overallDislikeDict[party.name]! != 0{
            let percent = String(((overallLikeDict[party.name]! / (overallLikeDict[party.name]! + overallDislikeDict[party.name]!)) * 100).truncate(places: 2)) + "%"
            cell.detailTextLabel?.text = "#" + String(rank) + " Rank   |" + "   " + "Overall Approval Percentage: " +  percent
        } else {
            cell.detailTextLabel?.text = "#" + String(rank) + " Rank   |" + "   " + "Not the move tonight!"
        }
        
        if searching {
            cell.textLabel?.text = searchParty[indexPath.row]
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedParty = parties[indexPath.row]
        performSegue(withIdentifier: "popupSegue", sender: selectedParty)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateDicts()
        let date = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        var newDate : NSDate?
        cal.range(of: .day, start: &newDate, interval: nil, for: date as Date)

        
        if segue.identifier == "popupSegue" {
                let destinationVC = segue.destination as! popUpViewController
                if let cell = sender as? UITableViewCell {
                    destinationVC.titleText = (cell.textLabel?.text)!
                    destinationVC.likesLabel = likeDict[(cell.textLabel?.text)!]!
                    destinationVC.dislikesLabel = dislikeDict[(cell.textLabel?.text)!]!
                    destinationVC.addressLabel = addressDict[(cell.textLabel?.text)!]!
                }
            }
    }
}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

extension AppHomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty ?? true {
            searching = false
            searchBar.resignFirstResponder()
            partyList.reloadData()
            return
        }
        searchParty = partyArray.filter({$0.lowercased().contains(searchText.lowercased())})
        searching = true
        partyList.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        partyList.reloadData()
    }
}
