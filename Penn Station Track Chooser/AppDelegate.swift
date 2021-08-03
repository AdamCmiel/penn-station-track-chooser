//
//  AppDelegate.swift
//  Penn Station Track Chooser
//
//  Created by Adam Cmiel on 5/10/20.
//  Copyright © 2020 Adam Cmiel. All rights reserved.
//
import Combine
import CoreLocation
import UIKit
import UserNotifications

private func sinkError(_ completion: Subscribers.Completion<Error>) {
    switch completion {
    case .failure:
        print("fetching data failed")
    case .finished:
        print("fetching data finished")
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let trackUpdatesSubject = PassthroughSubject<[TrackUpdate], API.APIError>()

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        return manager
    }()

    private lazy var notificationCenter: UNUserNotificationCenter = {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        return center
    }()

    var trackUpdates: AnyPublisher<[TrackUpdate], Never> {
        self.trackUpdatesSubject
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    static var shared: AppDelegate! {
        return UIApplication.shared.delegate as? AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoring(for: Station.PennStation.region)
        notificationCenter.requestAuthorization(options: [.badge, .alert], completionHandler: { _, _ in })

        async {
            do {
                let message = try await API.requestFeed(forThe: .ace)
                let updates = FeedParser(message: message).trackUpdates(at: .PennStation)
                trackUpdatesSubject.send(updates)
            } catch {
                print(error)
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

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("monitoring \(region.identifier)")
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier.contains(Station.PennStation.rawValue) else {
            return
        }
        
        async {
            do {
                let message = try await API.requestFeed(forThe: .ace)
                let updates = FeedParser(message: message).trackUpdates(at: .PennStation)
                notifyUser(of: updates)
            } catch {
                print(error)
            }
        }
    }

    private func notifyUser(of trackUpdates: [TrackUpdate]) {
        // Schedule the request with the system.
        print("adding notification request")
        notificationCenter.add(UNNotificationRequest.from(updates: trackUpdates)) { error in
            if error != nil {
                print(error.debugDescription)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {}

private extension UNNotificationRequest {
    static func from(updates: [TrackUpdate]) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "Penn station track updates"
        content.body = updates.map { $0.asString }.joined(separator: "\r")

        let uuidString = UUID().uuidString
        return UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)
    }
}

private extension TrackUpdate {
    var asString: String { "\(direction): \(trainUpdatesString)" }

    private var trainUpdatesString: String {
        self.trainUpdates
            .prefix(3)
            .map { "\($0.train.rawValue): \($0.minutesToArrive )"}
            .joined(separator: ", ")
    }
}
