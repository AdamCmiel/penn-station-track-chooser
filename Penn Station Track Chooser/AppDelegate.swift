//
//  AppDelegate.swift
//  Penn Station Track Chooser
//
//  Created by Adam Cmiel on 5/10/20.
//  Copyright © 2020 Adam Cmiel. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        API.requestFeed { result in
            switch result {
            case .failure:
                return
            case .success(let message):
                let parser = FeedParser(message: message)
                let pennUpdates = parser.trackUpdates(at: .PennStation)
//                let tripIDs = ATrainUpdates.map { $0.tripUpdate.trip.tripID }

                print(pennUpdates.count)
            }
        }


        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

