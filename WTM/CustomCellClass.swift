import Foundation
import UIKit
import FirebaseAuth
import Firebase
protocol CustomCellDelegate: AnyObject {
    func buttonClicked(for party: Party)
}

class CustomCellClass: UITableViewCell {
    weak var delegate: CustomCellDelegate?
    private var party: Party?

    @IBAction func buttonClicked(_ sender: UIButton) {
        guard let party = party else {
            return
        }
        delegate?.buttonClicked(for: party)
    }

    func configure(with party: Party, rankDict: [String: Int]) {
        self.party = party
        if let partyLabel = viewWithTag(1) as? UILabel {
            partyLabel.text = party.name
        }
        if let subtitleLabel = viewWithTag(2) as? UILabel {
            subtitleLabel.text = "#" + String(rankDict[party.name] ?? 0)
        }
        if let ratingLabel = viewWithTag(3) as? UILabel {
            ratingLabel.text = String(party.rating)
        }


        if let goingButton = viewWithTag(4) as? UIButton {
            var isGoing = false
            checkIfUserIsGoing(party: party) { isUserGoing in
                //print("isUserGoing: \(isUserGoing)")
                // Use the value of isUserGoing to update the button's appearance or perform any other action
                isGoing = isUserGoing
                if let titleLabel = goingButton.titleLabel {
                    let label = isGoing ? "See you there" : "Yeah I'll Be There"
                    titleLabel.text = label
                    titleLabel.textColor = UIColor.white
                    titleLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
                }
                let backgroundColor = isGoing ? UIColor.green : UIColor.systemPink
                print(backgroundColor)
                goingButton.backgroundColor = backgroundColor
                //let backgroundImage = isGoing ? UIImage(named: "video.png") : UIImage(named: "video.png")
                            //goingButton.setBackgroundImage(backgroundImage, for: .normal)
                
               
            }
            goingButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            
            


            // let backgroundColor = isGoing ? UIColor.green : UIColor.systemPink
            // goingButton.backgroundColor = backgroundColor
        }
    }
    private func checkIfUserIsGoing(party: Party, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let partyRef = Database.database().reference().child("Parties").child(party.name)
        
        partyRef.child("isGoing").observeSingleEvent(of: .value) { snapshot in
            var isUserGoing = false
            
            if snapshot.exists() {
                if let attendees = snapshot.value as? [String] {
                    isUserGoing = attendees.contains(uid)
                }
            }
            
            completion(isUserGoing)
        }
    }









}
