//
//  AppDelegate.swift
//  WTM
//
//  Created by Nikunj  Tyagi on 1/21/23.
//
//AMAN'S FIRST TEST COMMIT
import UIKit
import Firebase

import FirebaseAuth
import GoogleSignIn
import FirebaseCore

public var partyAccount = false
public var launchedBefore = false
public var authenticated = false
public var user_address = ""
public var currentDate = ""
public var votesLabel = 0

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        partyAccount = UserDefaults.standard.bool(forKey: "partyAccount")
        launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        authenticated = UserDefaults.standard.bool(forKey: "authenticated")
        user_address = UserDefaults.standard.string(forKey: "user_address") ?? "user"
        votesLabel = UserDefaults.standard.integer(forKey: "votesLabel")
        currentDate = UserDefaults.standard.string(forKey: "currentDate") ?? ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let newDate = dateFormatter.string(from: Date())
        
        if newDate != currentDate {
            UserDefaults.standard.setValue(5, forKey: "votesLabel")
            UserDefaults.standard.setValue(newDate, forKey: "currentDate")
        } else {
            UserDefaults.standard.setValue(newDate, forKey: "currentDate")
        }
        
                
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        let launchCount = UserDefaults.standard.integer(forKey: "launchCount")
        UserDefaults.standard.set(launchCount + 1, forKey: "launchCount")
        UserDefaults.standard.synchronize()
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }

}

