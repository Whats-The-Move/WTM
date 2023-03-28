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
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var helloWorld: UILabel!
    @IBOutlet weak var Profile: UILabel!
    
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
    public var rankDict = [String : Int]()
    public var countNum = 34

    override func viewDidLoad() {
        super.viewDidLoad()
        let user_address1 = UserDefaults.standard.string(forKey: "user_address") ?? "user"

        helloWorld.text = "Hello " + user_address1
        refreshButton.layer.cornerRadius = 4
        logoutButton.layer.cornerRadius = 4        
        for recognizer in view.gestureRecognizers ?? [] {
            if let swipeRecognizer = recognizer as? UISwipeGestureRecognizer, swipeRecognizer.direction == .down {
                view.removeGestureRecognizer(swipeRecognizer)
            }
        }
        
        gifImage.loadGif(name: "finalillini")
        gifImage.contentMode = .scaleAspectFit
        partyList.overrideUserInterfaceStyle = .dark
        searchBar.overrideUserInterfaceStyle = .dark
        refreshButton.overrideUserInterfaceStyle = .light
        logoutButton.overrideUserInterfaceStyle = .light
        
        partyList.reloadData()
        
        databaseRef = Database.database().reference().child("Parties")
        databaseRef?.queryOrdered(byChild: "Likes").observe(.childAdded) { [weak self] (snapshot) in
            let key = snapshot.key
            guard let value = snapshot.value as? [String : Any] else {return}
            if let likes = value["Likes"] as? Int, let dislikes = value["Dislikes"] as? Int, let allTimeLikes = value["allTimeLikes"] as? Double, let allTimeDislikes = value["allTimeDislikes"] as? Double, let address = value["Address"] as? String {
                let party = Party(name: key, likes: likes, dislikes: dislikes, allTimeLikes: allTimeLikes, allTimeDislikes: allTimeDislikes, address: address)
                self?.parties.insert(party, at: 0)
                self?.likeDict[party.name] = party.likes
                self?.dislikeDict[party.name] = party.dislikes
                self?.overallLikeDict[party.name] = party.allTimeLikes
                self?.overallDislikeDict[party.name] = party.allTimeDislikes
                self?.addressDict[party.name] = party.address
                self?.rankDict[party.name] = self?.countNum
                self?.partyArray.insert(party.name, at: 0)
                if let row = self?.parties.count {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self?.partyList.insertRows(at: [indexPath], with: .automatic)
                    self?.countNum -= 1
                    //if((self?.parties.count)! <= 58){
                      //  self?.partyList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    //} else {
                    /*
                        self?.partyList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            self?.scrollToTop()
                            print("scrolled to top")
                     
                        }
                     */
                    //}
                }
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        /*
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
                    //if((self?.parties.count)! <= 58){
                      //  self?.partyList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    //} else {
                        self?.partyList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            self?.scrollToTop()
                            print("scrolled to top")
                        }
                    //}
                }
            }
        }
        partyList.reloadData()
         */
    }
   
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "AppHome") as! AppHomeViewController
        newViewController.modalPresentationStyle = .fullScreen
        present(newViewController, animated: false, completion: nil)
        */
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let TabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        TabBarController.overrideUserInterfaceStyle = .dark
        TabBarController.modalPresentationStyle = .fullScreen
        present(TabBarController, animated: false, completion: nil)
        
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "SignUpPage") as! ViewController
        newViewController.modalPresentationStyle = .fullScreen
        present(newViewController, animated: false, completion: nil)
        UserDefaults.standard.set(false, forKey: "authenticated")

    }

    
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        partyList.scrollToRow(at: indexPath, at: .top, animated: true)
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
        let party = parties[indexPath.row]
        //let party = parties[indexPath.row]
        let cell = partyList.dequeueReusableCell(withIdentifier: "partyCell", for: indexPath)

        cell.textLabel?.text = party.name
        
        if overallLikeDict[party.name] != nil &&  overallLikeDict[party.name]! + overallDislikeDict[party.name]! != 0{
            let percent = String(((overallLikeDict[party.name]! / (overallLikeDict[party.name]! + overallDislikeDict[party.name]!)) * 100).truncate(places: 2)) + "%"
            cell.detailTextLabel?.text = "#" + String(rankDict[party.name]!) + " Rank   |" + "   " + "Overall Approval Percentage: " +  percent
        } else {
            cell.detailTextLabel?.text = "#" + String(rankDict[party.name]!) + " Rank   |" + "   " + "Not the move tonight!"
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
