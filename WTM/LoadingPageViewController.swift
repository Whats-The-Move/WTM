import UIKit
import FirebaseAuth

class LoadingPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if the user is authenticated in Firebase
        if let currentUser = Auth.auth().currentUser {
            // User is authenticated in Firebase, check "authenticated" flag
            if authenticated && launchedBefore {
                let isPartyAccount = UserDefaults.standard.bool(forKey: "partyAccount")
                if isPartyAccount {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let appHomeVC = storyboard.instantiateViewController(identifier: "TabBarController") as! UITabBarController
                    appHomeVC.selectedIndex = 2
                    appHomeVC.modalPresentationStyle = .overFullScreen
                    self.present(appHomeVC, animated: true)
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let appHomeVC = storyboard.instantiateViewController(identifier: "TabBarController")
                    appHomeVC.modalPresentationStyle = .overFullScreen
                    self.present(appHomeVC, animated: true)
                }
            } else {
                UserDefaults.standard.set(true, forKey: "launchedBefore")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "WelcomePage")
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
        } else {
            // User is not authenticated in Firebase, proceed based on "authenticated" flag
            if authenticated {
                UserDefaults.standard.set(false, forKey: "authenticated")
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "WelcomePage")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }

}
