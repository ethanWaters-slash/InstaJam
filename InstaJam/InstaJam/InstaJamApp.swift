//
//  InstaJamApp.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 🔧 Configure Firebase
        FirebaseApp.configure()
        
        // 💬 Firebase Messaging setup
        Messaging.messaging().delegate = self

        // 🔔 Request Notification Permissions
        configureUserNotifications(application)

        return true
    }

    // MARK: - 🔔 Notification Configuration

    private func configureUserNotifications(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification authorization error: \(error)")
            } else {
                print("🔔 Notification permission granted: \(granted)")
            }
        }

        application.registerForRemoteNotifications()
    }

    // MARK: - 📡 APNs Token Registration

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        print("📲 APNs device token set for Firebase")
    }

    // MARK: - 🔁 FCM Token Handling

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("📬 Received FCM Token: \(fcmToken)")
        
        // 👉 Optionally upload token to Firestore or your backend
        // FirebaseService.shared.saveFCMToken(fcmToken)
    }

    // MARK: - 👀 Foreground Notification Handling

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 📢 Display banner even if app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}

@main
struct InstaJamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isLoggedIn = false
    @State private var path = NavigationPath()

    var body: some Scene {
        WindowGroup {
            RootView(isLoggedIn: $isLoggedIn, path: $path)
                .onAppear {
                    if AuthService.shared.getCurrentUser() != nil {
                        isLoggedIn = true
                    }
                }
        }
    }
}

