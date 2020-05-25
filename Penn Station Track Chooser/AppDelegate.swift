//
//  AppDelegate.swift
//  Penn Station Track Chooser
//
//  Created by Adam Cmiel on 5/10/20.
//  Copyright © 2020 Adam Cmiel. All rights reserved.
//
import Combine
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var trackUpdatesSubject = PassthroughSubject<[TrackUpdate], API.APIError>()
    private var cancellable = Set<AnyCancellable>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        API.requestFeed()
            .map { FeedParser(message: $0).trackUpdates(at: .PennStation) }
            .sink(receiveCompletion: { error in
                switch error {
                case .failure:
                    print("fetching data failed")
                case .finished:
                    print("fetching data finished")
                }
            }) { [unowned self] trainData in
                self.trackUpdatesSubject.send(trainData)
                return
            }
            .store(in: &self.cancellable)

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

