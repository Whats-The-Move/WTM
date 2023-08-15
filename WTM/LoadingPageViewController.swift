//
//  LoadingPageViewController.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 1/21/23.
//

import UIKit

class LoadingPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if launchedBefore && authenticated {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appHomeVC = storyboard.instantiateViewController(identifier: "TabBarController")
            appHomeVC.modalPresentationStyle = .overFullScreen
            self.present(appHomeVC, animated: true)
        } else {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "SignUpPage")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }

}
