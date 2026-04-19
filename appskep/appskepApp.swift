//
//  appskepApp.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import SwiftUI
import UserNotifications

final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

enum NotificationPermissionHelper {
    static func requestIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await withCheckedContinuation { continuation in
            center.getNotificationSettings { currentSettings in
                continuation.resume(returning: currentSettings)
            }
        }

        guard settings.authorizationStatus == .notDetermined else { return }

        _ = await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }
}

@main
struct appskepApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var tryOutCoordinator = TryOutCoordinator()
    @StateObject private var myClassViewModel = MyClassViewModel()
    private let notificationDelegate = AppNotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainTabView()
                } else {
                    NavigationStack {
                        LoginView()
                    }
                }
            }
            .environmentObject(authManager)
            .environmentObject(tryOutCoordinator)
            .environmentObject(myClassViewModel)
            .preferredColorScheme(.light)
            .task {
                await NotificationPermissionHelper.requestIfNeeded()
            }
        }
    }
}

